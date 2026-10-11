import Foundation

/// Local, offline-first record of every word the user is learning and when it is next due.
/// Replaces the Hive `user_word_data` box. Persists as JSON in Application Support.
public actor ProgressStore {
    private var items: [String: UserWordData] = [:]
    private var activities: [ReviewActivity] = []
    private let fileURL: URL?
    private var activitiesURL: URL? { fileURL?.deletingLastPathComponent().appendingPathComponent("review_activity.json") }

    public init(fileURL: URL? = ProgressStore.defaultURL()) {
        self.fileURL = fileURL
        if let fileURL, let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([String: UserWordData].self, from: data) {
            items = decoded
        }
        if let aURL = fileURL?.deletingLastPathComponent().appendingPathComponent("review_activity.json"),
           let data = try? Data(contentsOf: aURL),
           let decoded = try? Self.decoder.decode([ReviewActivity].self, from: data) {
            activities = decoded
        }
    }

    private static let decoder: JSONDecoder = { let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d }()
    private static let encoder: JSONEncoder = { let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e }()

    public func allActivities() -> [ReviewActivity] { activities }
    public func recordActivity(_ a: ReviewActivity) {
        activities.append(a)
        if let url = activitiesURL, let data = try? Self.encoder.encode(activities) { try? data.write(to: url, options: .atomic) }
    }
    /// Wipe everything (profile → reset progress).
    public func resetAll() {
        items = [:]; activities = []; persist()
        if let url = activitiesURL { try? FileManager.default.removeItem(at: url) }
    }

    public static func defaultURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("user_word_data.json")
    }

    public func all() -> [UserWordData] { Array(items.values) }
    public func get(_ word: String) -> UserWordData? { items[word] }

    public func save(_ data: UserWordData) { items[data.word] = data; persist() }

    /// Replace everything with remote state (used by sync).
    public func replaceAll(_ newItems: [UserWordData]) {
        items = Dictionary(uniqueKeysWithValues: newItems.map { ($0.word, $0) }); persist()
    }

    /// Record a review result and schedule the next one (SM-2).
    @discardableResult
    public func review(word: String, rating: ReviewRating, now: Date = Date()) -> UserWordData {
        let updated = SpacedRepetition.apply(rating: rating, to: items[word], word: word, now: now)
        save(updated)
        recordActivity(ReviewActivity(word: word, reviewedAt: now,
                                      rating: ReviewDifficultyRating(rawValue: rating.rawValue) ?? .medium))
        return updated
    }

    /// "I'm learning this" — records the word and schedules its first review for tomorrow.
    @discardableResult
    public func startLearning(word: String, now: Date = Date()) -> UserWordData {
        if let existing = items[word], existing.firstLearnedAt != nil { return existing }
        var d = items[word] ?? UserWordData(word: word)
        d.firstLearnedAt = now
        d.learningStage = .learning
        d.interval = 1
        d.nextReview = Calendar.current.date(byAdding: .day, value: 1, to: now)
        save(d)
        return d
    }

    public func markLearned(word: String, _ learned: Bool, now: Date = Date()) {
        if learned { markAsLearned(word: word, now: now) }
        else { var d = items[word] ?? UserWordData(word: word); d.isLearned = false; save(d) }
    }

    public func setNotes(word: String, _ notes: String) {
        var d = items[word] ?? UserWordData(word: word); d.notes = notes; save(d)
    }

    /// Words whose review time has arrived, most overdue first.
    public func dueWords(now: Date = Date()) -> [UserWordData] {
        items.values.filter { $0.isDue(at: now) }
            .sorted { ($0.nextReview ?? .distantFuture) < ($1.nextReview ?? .distantFuture) }
    }

    public func upcoming(now: Date = Date()) -> [UserWordData] {
        items.values.filter { ($0.nextReview ?? .distantPast) > now }
            .sorted { ($0.nextReview ?? .distantFuture) < ($1.nextReview ?? .distantFuture) }
    }

    private func persist() {
        guard let fileURL, let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

public extension ProgressStore {
    /// Port of `UserProgressService.markWordAsLearned`.
    func markAsLearned(word: String, now: Date = Date()) {
        var d = get(word) ?? UserWordData(word: word)
        d.isLearned = true; d.hasBeenTested = true; d.learningStage = .mastered
        if d.firstLearnedAt == nil { d.firstLearnedAt = now }
        if d.totalAnswers == 0 { d.totalAnswers = 1; d.correctAnswers = 1; d.reviewCount = max(d.reviewCount, 1); d.lastReviewedAt = d.lastReviewedAt ?? now }
        save(d)
    }
    /// Port of `UserProgressService.resetWordProgress`.
    func resetWord(_ word: String) {
        guard var d = get(word) else { return }
        d.isLearned = false; d.learningStage = .newWord; d.reviewCount = 0; d.correctAnswers = 0; d.totalAnswers = 0
        d.firstLearnedAt = nil; d.lastReviewedAt = nil; d.nextReview = nil
        save(d)
    }
}
