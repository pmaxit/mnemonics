import Foundation

public enum SessionDuration: Int, CaseIterable, Identifiable, Sendable {
    case five = 5, ten = 10, fifteen = 15, thirty = 30
    public var id: Int { rawValue }
    public var minutes: Int { rawValue }
    public var displayText: String { "\(rawValue) min" }
    public var detail: String {
        switch self { case .five: "Quick review"; case .ten: "Short session"; case .fifteen: "Standard session"; case .thirty: "Extended session" }
    }
}

public enum SessionMode: String, CaseIterable, Identifiable, Sendable {
    case allWords, dueForReview, strugglingWords, newWords
    public var id: String { rawValue }
    public var title: String {
        switch self { case .allWords: "All Words"; case .dueForReview: "Due for Review"; case .strugglingWords: "Struggling Words"; case .newWords: "New Words" }
    }
    public var detail: String {
        switch self {
        case .allWords: "Review all available words"; case .dueForReview: "Words ready for spaced repetition"
        case .strugglingWords: "Words with low accuracy"; case .newWords: "Words not yet learned"
        }
    }
    public var symbol: String {
        switch self { case .allWords: "books.vertical"; case .dueForReview: "clock"; case .strugglingWords: "chart.line.downtrend.xyaxis"; case .newWords: "sparkles" }
    }

    /// Port of `_loadWordsForSession`. Unreviewed words count as due (as in Flutter).
    /// "New words" uses the intended stage check (Flutter compares an enum to the string 'new', which never matches).
    public func select(from all: [VocabularyWord], progress: [String: UserWordData], now: Date = Date()) -> [VocabularyWord] {
        switch self {
        case .allWords: return all
        case .dueForReview:
            return all.filter { w in
                guard let d = progress[w.word] else { return true }
                return d.nextReview.map { $0 < now } ?? true
            }
        case .strugglingWords:
            return all.filter { w in progress[w.word].map { $0.accuracyRate < 0.6 } ?? false }
        case .newWords:
            return all.filter { w in progress[w.word].map { $0.learningStage == .newWord } ?? true }
        }
    }
}

public struct SessionWordReview: Hashable, Sendable {
    public let word: String
    public let rating: ReviewDifficultyRating
    public let reviewedAt: Date
    public let timeSpent: TimeInterval
    public var wasSkipped = false
    public init(word: String, rating: ReviewDifficultyRating, reviewedAt: Date, timeSpent: TimeInterval, wasSkipped: Bool = false) {
        self.word = word; self.rating = rating; self.reviewedAt = reviewedAt; self.timeSpent = timeSpent; self.wasSkipped = wasSkipped
    }
}

public struct LearningSessionSummary: Sendable {
    public let sessionDuration: TimeInterval
    public let wordsReviewed: Int, uniqueWordsReviewed: Int
    public let difficultyBreakdown: [String: Int]
    public let averageTimePerWord: Double
    public let skippedWords: Int
    public let strugglingWords: [String], masteredWords: [String]

    public var wordsPerMinute: Double {
        let m = Int(sessionDuration / 60)
        return m > 0 ? Double(wordsReviewed) / Double(m) : 0
    }
    public var accuracyRate: Double {
        let total = difficultyBreakdown.values.reduce(0, +)
        guard total > 0 else { return 0 }
        return (Double(difficultyBreakdown["easy"] ?? 0) + Double(difficultyBreakdown["medium"] ?? 0) * 0.5) / Double(total)
    }

    /// Port of `getSessionSummary`.
    public static func make(reviews: [SessionWordReview], start: Date?, end: Date?) -> LearningSessionSummary {
        var breakdown = ["easy": 0, "medium": 0, "hard": 0]
        for r in reviews { breakdown[r.rating.rawValue, default: 0] += 1 }
        var struggling: [String] = [], mastered: [String] = []
        for r in reviews {
            if r.rating == .hard || r.wasSkipped { if !struggling.contains(r.word) { struggling.append(r.word) } }
            else if r.rating == .easy { if !mastered.contains(r.word) { mastered.append(r.word) } }
        }
        let total = reviews.reduce(0) { $0 + $1.timeSpent }
        return LearningSessionSummary(
            sessionDuration: (start != nil && end != nil) ? end!.timeIntervalSince(start!) : 0,
            wordsReviewed: reviews.count, uniqueWordsReviewed: Set(reviews.map(\.word)).count,
            difficultyBreakdown: breakdown, averageTimePerWord: reviews.isEmpty ? 0 : total.rounded(.towardZero) / Double(reviews.count),
            skippedWords: reviews.filter(\.wasSkipped).count, strugglingWords: struggling, masteredWords: mastered)
    }
}
