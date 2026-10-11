import Foundation

public enum ReviewDifficultyRating: String, Codable, CaseIterable, Sendable { case easy, medium, hard }

/// Port of `ReviewActivity` (one row per flashcard rating).
public struct ReviewActivity: Codable, Hashable, Sendable {
    public var word: String
    public var reviewedAt: Date
    public var rating: ReviewDifficultyRating
    public init(word: String, reviewedAt: Date, rating: ReviewDifficultyRating) {
        self.word = word; self.reviewedAt = reviewedAt; self.rating = rating
    }
}

public extension WordDifficulty {
    var displayName: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
    var emoji: String { String(repeating: "⭐", count: rank) }
}
public extension LearningStage {
    var displayName: String { switch self { case .newWord: "New"; case .learning: "Learning"; case .mastered: "Mastered" } }
    var emoji: String { switch self { case .newWord: "🆕"; case .learning: "📚"; case .mastered: "🏆" } }
}

public enum MilestoneType: String, Codable, Sendable { case vocabulary, consistency, dedication, accuracy, category }

public struct Milestone: Identifiable, Hashable, Sendable {
    public let id: String, title: String, description: String
    public let type: MilestoneType
    public let targetValue: Int, currentValue: Int
    public let isUnlocked: Bool
    public var progress: Double { targetValue == 0 ? 0 : min(1, Double(currentValue) / Double(targetValue)) }
}

public struct DailyProgress: Hashable, Sendable, Identifiable {
    public var id: Date { date }
    public let date: Date
    public let wordsLearned: Int
    public let reviewsCompleted: Int
}

public struct CategoryStats: Hashable, Sendable, Identifiable {
    public var id: String { name }
    public let name: String
    public var wordsLearned: Int
    public var totalWords: Int
    public var averageAccuracy: Double
}

public struct DifficultyStats: Hashable, Sendable, Identifiable {
    public var id: WordDifficulty { difficulty }
    public let difficulty: WordDifficulty
    public let wordsLearned: Int
    public let totalWords: Int
    public let averageAccuracy: Double
}

/// Union of `StatisticsData` (practice tab) and `ProfileStatistics` (profile tab).
public struct LearningStatistics: Sendable {
    public var totalLearned = 0                 // practice: tested || learned
    public var totalWordsLearned = 0            // profile: tested || learned || reviewCount>0
    public var learnedToday = 0
    public var wordsLearnedThisWeek = 0
    public var newCount = 0, inProgressCount = 0, masteredCount = 0
    public var categoryBreakdown: [String: Int] = [:]
    public var difficultyBreakdown: [WordDifficulty: Int] = [:]
    public var weeklyProgress: [DailyProgress] = []
    public var averageAccuracy = 0.0
    public var totalReviews = 0
    public var streak = 0
    public var longestStreak = 0
    public var totalStudyTimeMinutes = 0        // 1 minute per review activity (as Flutter)
    public var studySessionsThisWeek = 0
    public var learningVelocity = 0.0           // words / week over last 4 weeks
    public var categoryStats: [CategoryStats] = []
    public var difficultyStats: [DifficultyStats] = []
    public var milestones: [Milestone] = []
    public var joinDate: Date?
    public var lastStudyDate: Date?
    public var masteredCategories = 0
    public init() {}
}

public enum StatisticsCalculator {
    static func isStudied(_ d: UserWordData) -> Bool { d.hasBeenTested || d.isLearned }
    static func inProgress(_ d: UserWordData) -> Bool { d.learningStage == .learning || (d.reviewCount > 0 && !d.isLearned) }

    public static func calculate(vocab: [VocabularyWord], userData: [UserWordData],
                                 activities: [ReviewActivity], now: Date = Date(),
                                 calendar cal: Calendar = .current) -> LearningStatistics {
        var s = LearningStatistics()
        let today = cal.startOfDay(for: now)
        let byWord = Dictionary(vocab.map { ($0.word, $0) }, uniquingKeysWith: { a, _ in a })
        let studied = userData.filter(isStudied)
        let touched = userData.filter { isStudied($0) || $0.reviewCount > 0 }

        s.totalLearned = studied.count
        s.totalWordsLearned = touched.count
        s.learnedToday = studied.filter { $0.lastReviewedAt.map { cal.isDate($0, inSameDayAs: today) } ?? false }.count
        s.newCount = userData.filter { !$0.hasBeenTested && !$0.isLearned }.count
        s.inProgressCount = studied.filter(inProgress).count
        s.masteredCount = studied.filter(\.isMastered).count

        for u in studied {
            let v = byWord[u.word]
            s.categoryBreakdown[v?.category ?? "Unknown", default: 0] += 1
            s.difficultyBreakdown[v?.difficulty ?? .intermediate, default: 0] += 1
        }

        let totalAnswers = studied.reduce(0) { $0 + $1.totalAnswers }
        let correct = studied.reduce(0) { $0 + $1.correctAnswers }
        s.averageAccuracy = totalAnswers > 0 ? Double(correct) / Double(totalAnswers) : 0
        s.totalReviews = activities.count
        s.totalStudyTimeMinutes = activities.count

        s.weeklyProgress = (0..<7).reversed().map { i in
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            return DailyProgress(
                date: day,
                wordsLearned: studied.filter { $0.lastReviewedAt.map { cal.isDate($0, inSameDayAs: day) } ?? false }.count,
                reviewsCompleted: activities.filter { cal.isDate($0.reviewedAt, inSameDayAs: day) }.count)
        }

        let days = activeDays(studied, activities, cal)
        s.streak = currentStreak(days, today: today, cal: cal)
        s.longestStreak = longestStreak(days, cal: cal)

        // Week = Monday…Sunday containing today (Dart weekday: Mon=1)
        let weekday = (cal.component(.weekday, from: today) + 5) % 7 // Mon=0
        let weekStart = cal.date(byAdding: .day, value: -weekday, to: today)!
        let weekEndExclusive = cal.date(byAdding: .day, value: 7, to: weekStart)!
        s.wordsLearnedThisWeek = userData.filter {
            guard $0.isLearned, let f = $0.firstLearnedAt else { return false }
            return f > weekStart && f < weekEndExclusive
        }.count
        s.studySessionsThisWeek = activities.filter { $0.reviewedAt > weekStart && $0.reviewedAt < weekEndExclusive }.count
        let fourWeeksAgo = cal.date(byAdding: .day, value: -28, to: today)!
        s.learningVelocity = Double(studied.filter { ($0.lastReviewedAt ?? .distantPast) > fourWeeksAgo }.count) / 4.0

        // Category stats
        var cats: [String: CategoryStats] = [:]
        for u in touched {
            let cat = byWord[u.word]?.category ?? "general"
            var c = cats[cat] ?? CategoryStats(name: cat, wordsLearned: 0, totalWords: vocab.filter { $0.category == cat }.count, averageAccuracy: 0)
            c.wordsLearned += 1
            cats[cat] = c
        }
        for key in cats.keys {
            let group = touched.filter { (byWord[$0.word]?.category ?? "general") == key }
            let t = group.reduce(0) { $0 + $1.totalAnswers }, c = group.reduce(0) { $0 + $1.correctAnswers }
            cats[key]?.averageAccuracy = t > 0 ? Double(c) / Double(t) : 0
        }
        s.categoryStats = cats.values.sorted { $0.name < $1.name }
        s.masteredCategories = s.categoryStats.filter { $0.totalWords > 0 && $0.wordsLearned >= $0.totalWords }.count

        s.difficultyStats = WordDifficulty.allCases.map { d in
            let group = touched.filter { (byWord[$0.word]?.difficulty ?? .intermediate) == d }
            let t = group.reduce(0) { $0 + $1.totalAnswers }, c = group.reduce(0) { $0 + $1.correctAnswers }
            return DifficultyStats(difficulty: d, wordsLearned: group.count,
                                   totalWords: vocab.filter { $0.difficulty == d }.count,
                                   averageAccuracy: t > 0 ? Double(c) / Double(t) : 0)
        }

        s.milestones = milestones(totalWords: s.totalWordsLearned, streak: s.streak, studyMinutes: s.totalStudyTimeMinutes)
        s.lastStudyDate = (studied.compactMap(\.lastReviewedAt) + activities.map(\.reviewedAt)).max()
        s.joinDate = userData.filter { $0.isLearned }.compactMap(\.firstLearnedAt).min()
        return s
    }

    static func activeDays(_ studied: [UserWordData], _ acts: [ReviewActivity], _ cal: Calendar) -> Set<Date> {
        var days = Set<Date>()
        for d in studied { if let r = d.lastReviewedAt { days.insert(cal.startOfDay(for: r)) } }
        for a in acts { days.insert(cal.startOfDay(for: a.reviewedAt)) }
        return days
    }

    static func currentStreak(_ days: Set<Date>, today: Date, cal: Calendar) -> Int {
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        guard days.contains(today) || days.contains(yesterday) else { return 0 }
        var cur = days.contains(today) ? today : yesterday, n = 0
        while days.contains(cur) { n += 1; cur = cal.date(byAdding: .day, value: -1, to: cur)! }
        return n
    }

    static func longestStreak(_ days: Set<Date>, cal: Calendar) -> Int {
        let sorted = days.sorted()
        guard !sorted.isEmpty else { return 0 }
        var longest = 1, cur = 1
        for i in 1..<max(sorted.count, 1) where i < sorted.count {
            let diff = cal.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
            if diff == 1 { cur += 1; longest = max(longest, cur) } else if diff > 1 { cur = 1 }
        }
        return longest
    }

    public static func milestones(totalWords: Int, streak: Int, studyMinutes: Int) -> [Milestone] {
        var out: [Milestone] = []
        for m in [10, 25, 50, 100, 250, 500, 1000] {
            out.append(Milestone(id: "words_\(m)", title: "\(m) Words Learned", description: "Learn \(m) vocabulary words",
                                 type: .vocabulary, targetValue: m, currentValue: totalWords, isUnlocked: totalWords >= m))
        }
        for m in [3, 7, 14, 30, 60, 100, 365] {
            out.append(Milestone(id: "streak_\(m)", title: "\(m) Day Streak", description: "Study for \(m) consecutive days",
                                 type: .consistency, targetValue: m, currentValue: streak, isUnlocked: streak >= m))
        }
        let hours = studyMinutes / 60
        for m in [1, 5, 10, 25, 50, 100] {
            out.append(Milestone(id: "time_\(m)", title: "\(m) Hours Studied", description: "Spend \(m) hours learning vocabulary",
                                 type: .dedication, targetValue: m, currentValue: hours, isUnlocked: hours >= m))
        }
        return out
    }
}

// MARK: - Detail-screen analytics (practice/presentation/screens/details/*)

public struct WordProgressItem: Identifiable, Hashable, Sendable {
    public var id: String { word.word }
    public let word: VocabularyWord
    public let data: UserWordData
}

public struct AccuracyAnalysis: Sendable {
    public let difficultyAccuracy: [String: Double]
    public let categoryAccuracy: [String: Double]
    public let challengingWords: [WordProgressItem]
    public let bestWords: [WordProgressItem]
}

public struct BreakdownCategory: Identifiable, Sendable {
    public var id: String { name }
    public let name: String
    public var words: [WordProgressItem] = []
    public var masteredCount = 0, learningCount = 0, newCount = 0
    public var totalCount: Int { words.count }
    public var averageAccuracy: Double { words.isEmpty ? 0 : words.map(\.data.accuracyRate).reduce(0, +) / Double(words.count) }
}

public extension StatisticsCalculator {
    /// Joins progress with vocabulary, dropping words no longer in the vocabulary ("Unknown" in Flutter).
    static func join(vocab: [VocabularyWord], userData: [UserWordData]) -> [WordProgressItem] {
        let by = Dictionary(vocab.map { ($0.word, $0) }, uniquingKeysWith: { a, _ in a })
        return userData.compactMap { d in by[d.word].map { WordProgressItem(word: $0, data: d) } }
    }

    /// `_getLearnedWords`: learned, or past the "new" stage.
    static func learnedItems(_ items: [WordProgressItem]) -> [WordProgressItem] {
        items.filter { $0.data.isLearned || $0.data.learningStage != .newWord }
    }

    /// `_getTodaysLearnedWords`: first learned today, newest first.
    static func todaysItems(_ items: [WordProgressItem], now: Date = Date(), calendar cal: Calendar = .current) -> [WordProgressItem] {
        let start = cal.startOfDay(for: now), end = cal.date(byAdding: .day, value: 1, to: start)!
        return items.filter { guard let f = $0.data.firstLearnedAt else { return false }; return f > start && f < end }
            .sorted { $0.data.firstLearnedAt! > $1.data.firstLearnedAt! }
    }

    static func accuracyAnalysis(_ items: [WordProgressItem]) -> AccuracyAnalysis {
        var diff: [String: [Double]] = [:], cat: [String: [Double]] = [:]
        var challenging: [WordProgressItem] = [], best: [WordProgressItem] = []
        for i in items where i.data.totalAnswers > 0 {
            let a = i.data.accuracyRate
            diff[i.word.difficulty.rawValue, default: []].append(a)
            cat[i.word.category, default: []].append(a)
            if a < 0.6 && i.data.totalAnswers >= 3 { challenging.append(i) }
            if a >= 0.9 && i.data.totalAnswers >= 3 { best.append(i) }
        }
        func avg(_ d: [String: [Double]]) -> [String: Double] { d.mapValues { $0.reduce(0, +) / Double($0.count) } }
        return AccuracyAnalysis(
            difficultyAccuracy: avg(diff), categoryAccuracy: avg(cat),
            challengingWords: Array(challenging.sorted { $0.data.accuracyRate < $1.data.accuracyRate }.prefix(10)),
            bestWords: Array(best.sorted { $0.data.accuracyRate > $1.data.accuracyRate }.prefix(10)))
    }

    static func breakdown(_ items: [WordProgressItem], byCategory: Bool) -> [BreakdownCategory] {
        var out: [String: BreakdownCategory] = [:]
        for i in learnedItems(items) {
            let key = byCategory ? i.word.category : i.word.difficulty.rawValue
            var c = out[key] ?? BreakdownCategory(name: key)
            c.words.append(i)
            switch i.data.learningStage { case .mastered: c.masteredCount += 1; case .learning: c.learningCount += 1; case .newWord: c.newCount += 1 }
            out[key] = c
        }
        return Array(out.values)
    }

    /// Sort used by the list detail screens: Recent / Alphabetical / Difficulty / Accuracy.
    static func sorted(_ items: [WordProgressItem], by sort: String, recentUsesLastReview: Bool) -> [WordProgressItem] {
        switch sort {
        case "Alphabetical": return items.sorted { $0.word.word < $1.word.word }
        case "Difficulty": return items.sorted { $0.word.difficulty.rank < $1.word.difficulty.rank }
        case "Accuracy": return items.sorted { $0.data.accuracyRate > $1.data.accuracyRate }
        default:
            func t(_ i: WordProgressItem) -> Date {
                (recentUsesLastReview ? (i.data.lastReviewedAt ?? i.data.firstLearnedAt) : i.data.firstLearnedAt) ?? Date(timeIntervalSince1970: 0)
            }
            return items.sorted { t($0) > t($1) }
        }
    }
}

// MARK: - Profile tab numbers (`unifiedStatisticsProvider`)

/// The Profile tab uses a different calculation from the Progress tab: learned = `isLearned`,
/// streaks from review activities only, accuracy over all word data.
public struct ProfileSummary: Sendable {
    public var totalWordsLearned = 0, wordsLearnedToday = 0, wordsLearnedThisWeek = 0
    public var currentStreak = 0, longestStreak = 0
    public var averageAccuracy = 0.0
    public var totalStudyTimeMinutes = 0
    public var learningVelocity = 0.0
    public var difficultyStats: [DifficultyStats] = []
    public init() {}
    public var studySessions: Int { Int((Double(totalStudyTimeMinutes) / 30).rounded()) }
}

public extension StatisticsCalculator {
    static func profileSummary(vocab: [VocabularyWord], userData: [UserWordData], activities: [ReviewActivity],
                               now: Date = Date(), calendar cal: Calendar = .current) -> ProfileSummary {
        var s = ProfileSummary()
        let today = cal.startOfDay(for: now)
        let learned = userData.filter(\.isLearned)
        s.totalWordsLearned = learned.count
        s.wordsLearnedToday = learned.filter { $0.firstLearnedAt.map { cal.isDate($0, inSameDayAs: today) } ?? false }.count
        let weekday = (cal.component(.weekday, from: today) + 5) % 7
        let weekStart = cal.date(byAdding: .day, value: -weekday, to: today)!
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)!
        s.wordsLearnedThisWeek = learned.filter { guard let f = $0.firstLearnedAt else { return false }; return f > weekStart && f < weekEnd }.count

        let days = Set(activities.map { cal.startOfDay(for: $0.reviewedAt) })
        s.currentStreak = currentStreak(days, today: today, cal: cal)
        s.longestStreak = days.isEmpty ? 0 : longestStreak(days, cal: cal)

        let total = userData.reduce(0) { $0 + $1.totalAnswers }, correct = userData.reduce(0) { $0 + $1.correctAnswers }
        s.averageAccuracy = total > 0 ? Double(correct) / Double(total) : 0
        s.totalStudyTimeMinutes = activities.count
        let cutoff = cal.date(byAdding: .day, value: -28, to: today)!
        s.learningVelocity = Double(userData.filter { ($0.firstLearnedAt ?? .distantPast) > cutoff }.count) / 4.0

        let byWord = Dictionary(vocab.map { ($0.word, $0.difficulty) }, uniquingKeysWith: { a, _ in a })
        s.difficultyStats = WordDifficulty.allCases.map { d in
            let words = userData.filter { byWord[$0.word] == d }
            let t = words.reduce(0) { $0 + $1.totalAnswers }, c = words.reduce(0) { $0 + $1.correctAnswers }
            return DifficultyStats(difficulty: d, wordsLearned: words.filter(\.isLearned).count,
                                   totalWords: vocab.filter { $0.difficulty == d }.count, averageAccuracy: t > 0 ? Double(c) / Double(t) : 0)
        }
        return s
    }
}

// MARK: - DetailedWordStatisticsScreen (`filteredWords` provider)

public enum WordStatType: String, Hashable, Sendable, CaseIterable {
    case learned, struggling, newWords, basic, intermediate, advanced, category, allWords
    public var title: String {
        switch self {
        case .learned: "Learned Words"; case .struggling: "Struggling Words"; case .newWords: "New Words"; case .basic: "Basic Words"
        case .intermediate: "Intermediate Words"; case .advanced: "Advanced Words"; case .category: "Category Words"; case .allWords: "All Words"
        }
    }
    public var detail: String {
        switch self {
        case .learned: "Words you have mastered"; case .struggling: "Words that need more practice"; case .newWords: "Words not yet started"
        case .basic: "Words with basic complexity"; case .intermediate: "Words with intermediate complexity"
        case .advanced: "Words with advanced complexity"; case .category: "Words from specific category"; case .allWords: "Complete vocabulary list"
        }
    }
}

public struct WordWithData: Identifiable, Hashable, Sendable {
    public var id: String { word.word }
    public let word: VocabularyWord
    public let data: UserWordData?
    /// Reviewed = has any review or answer (the screen's "Reviewed Words" section).
    public var isReviewed: Bool { data.map { $0.reviewCount > 0 || $0.totalAnswers > 0 } ?? false }
}

public enum DetailedWords {
    public static func filter(vocab: [VocabularyWord], progress: [String: UserWordData], type: WordStatType,
                              category: String? = nil, search: String = "", sortBy: String = "word", ascending: Bool = true) -> [WordWithData] {
        var items = vocab.map { WordWithData(word: $0, data: progress[$0.word]) }
        switch type {
        case .learned: items = items.filter { $0.data?.learningStage == .mastered || $0.data?.isLearned == true }
        case .struggling: items = items.filter { guard let d = $0.data, d.totalAnswers > 0 else { return false }; return d.accuracyRate < 0.6 }
        case .newWords: items = items.filter { $0.data == nil || $0.data!.learningStage == .newWord || $0.data!.reviewCount == 0 }
        case .basic: items = items.filter { $0.word.difficulty == .basic }
        case .intermediate: items = items.filter { $0.word.difficulty == .intermediate }
        case .advanced: items = items.filter { $0.word.difficulty == .advanced }
        case .category, .allWords: break
        }
        if let c = category, !c.isEmpty { items = items.filter { $0.word.category.lowercased() == c.lowercased() } }
        let q = search.lowercased()
        if !q.isEmpty { items = items.filter { $0.word.word.lowercased().contains(q) || $0.word.meaning.lowercased().contains(q) || $0.word.mnemonic.lowercased().contains(q) } }
        func cmp(_ a: WordWithData, _ b: WordWithData) -> Int {
            switch sortBy {
            case "accuracy": let x = a.data?.accuracyRate ?? 0, y = b.data?.accuracyRate ?? 0; return x < y ? -1 : x > y ? 1 : 0
            case "difficulty": return a.word.difficulty.rank - b.word.difficulty.rank
            case "lastReviewed":
                let x = a.data?.lastReviewedAt ?? Date(timeIntervalSince1970: 0), y = b.data?.lastReviewedAt ?? Date(timeIntervalSince1970: 0)
                return x < y ? -1 : x > y ? 1 : 0
            default: return a.word.word < b.word.word ? -1 : a.word.word > b.word.word ? 1 : 0
            }
        }
        return items.sorted { ascending ? cmp($0, $1) < 0 : cmp($0, $1) > 0 }
    }
}
