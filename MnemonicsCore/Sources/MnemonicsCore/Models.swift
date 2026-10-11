import Foundation

public enum WordDifficulty: String, Codable, CaseIterable, Sendable {
    case basic, intermediate, advanced

    public var rank: Int {
        switch self {
        case .basic: 1
        case .intermediate: 2
        case .advanced: 3
        }
    }
}

public enum LearningStage: String, Codable, CaseIterable, Sendable {
    case newWord, learning, mastered
}

/// Port of `VocabularyWord` (lib/features/home/domain/vocabulary_word.dart).
public struct VocabularyWord: Codable, Identifiable, Hashable, Sendable {
    public var id: String { word }
    public let word: String
    public let meaning: String
    public let mnemonic: String
    public var aiMnemonic: String?
    public var aiInsights: String?
    public var imageURL: String?
    public var videoURL: String?
    public let example: String
    public var synonyms: [String]
    public var antonyms: [String]
    public var difficulty: WordDifficulty
    public var category: String
    public var setIds: [String]
    public var definition: String?
    public var phrases: [String]
    public var exampleSentences: [[String]]

    public init(word: String, meaning: String, mnemonic: String = "", aiMnemonic: String? = nil,
                aiInsights: String? = nil, imageURL: String? = nil, videoURL: String? = nil,
                example: String = "", synonyms: [String] = [], antonyms: [String] = [],
                difficulty: WordDifficulty = .intermediate, category: String = "",
                setIds: [String] = [], definition: String? = nil, phrases: [String] = [],
                exampleSentences: [[String]] = []) {
        self.word = word; self.meaning = meaning; self.mnemonic = mnemonic
        self.aiMnemonic = aiMnemonic; self.aiInsights = aiInsights
        self.imageURL = imageURL; self.videoURL = videoURL; self.example = example
        self.synonyms = synonyms; self.antonyms = antonyms; self.difficulty = difficulty
        self.category = category; self.setIds = setIds; self.definition = definition
        self.phrases = phrases; self.exampleSentences = exampleSentences
    }

    private enum CodingKeys: String, CodingKey {
        case word, meaning, mnemonic, aiMnemonic, aiInsights, example, synonyms, antonyms
        case difficulty, category, setIds, definition, phrases, exampleSentences
        case imageUrl, videoUrl, image, video
    }

    // Tolerant decoding: the API returns lists as arrays or as delimited strings, and
    // the bundled JSON uses `image`/`video` while the API uses `imageUrl`/`videoUrl`.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        word = try c.decode(String.self, forKey: .word)
        meaning = (try? c.decode(String.self, forKey: .meaning)) ?? ""
        mnemonic = (try? c.decode(String.self, forKey: .mnemonic)) ?? ""
        aiMnemonic = try? c.decodeIfPresent(String.self, forKey: .aiMnemonic)
        aiInsights = try? c.decodeIfPresent(String.self, forKey: .aiInsights)
        imageURL = (try? c.decodeIfPresent(String.self, forKey: .imageUrl))
            ?? (try? c.decodeIfPresent(String.self, forKey: .image))
        videoURL = (try? c.decodeIfPresent(String.self, forKey: .videoUrl))
            ?? (try? c.decodeIfPresent(String.self, forKey: .video))
        example = (try? c.decode(String.self, forKey: .example)) ?? ""
        synonyms = Self.stringList(c, .synonyms)
        antonyms = Self.stringList(c, .antonyms)
        phrases = Self.stringList(c, .phrases)
        let diff = (try? c.decode(String.self, forKey: .difficulty))?.lowercased() ?? ""
        difficulty = WordDifficulty(rawValue: diff) ?? .intermediate
        category = (try? c.decode(String.self, forKey: .category)) ?? ""
        setIds = Self.stringList(c, .setIds)
        definition = try? c.decodeIfPresent(String.self, forKey: .definition)
        exampleSentences = Self.nestedList(c, .exampleSentences)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(word, forKey: .word); try c.encode(meaning, forKey: .meaning)
        try c.encode(mnemonic, forKey: .mnemonic)
        try c.encodeIfPresent(aiMnemonic, forKey: .aiMnemonic)
        try c.encodeIfPresent(aiInsights, forKey: .aiInsights)
        try c.encodeIfPresent(imageURL, forKey: .imageUrl)
        try c.encodeIfPresent(videoURL, forKey: .videoUrl)
        try c.encode(example, forKey: .example); try c.encode(synonyms, forKey: .synonyms)
        try c.encode(antonyms, forKey: .antonyms); try c.encode(difficulty, forKey: .difficulty)
        try c.encode(category, forKey: .category); try c.encode(setIds, forKey: .setIds)
        try c.encodeIfPresent(definition, forKey: .definition)
        try c.encode(phrases, forKey: .phrases)
        try c.encode(exampleSentences, forKey: .exampleSentences)
    }

    /// Port of `parseStringList`: array, JSON string, or comma separated string.
    static func parseStringList(_ raw: String) -> [String] {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return [] }
        if t.hasPrefix("["), t.hasSuffix("]"),
           let data = t.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [Any] {
            return arr.map { "\($0)" }
        }
        let body = (t.hasPrefix("[") && t.hasSuffix("]")) ? String(t.dropFirst().dropLast()) : t
        return body.split(separator: ",").map {
            var s = $0.trimmingCharacters(in: .whitespaces)
            if s.count >= 2, (s.hasPrefix("\"") && s.hasSuffix("\"")) || (s.hasPrefix("'") && s.hasSuffix("'")) {
                s = String(s.dropFirst().dropLast())
            }
            return s
        }.filter { !$0.isEmpty }
    }

    private static func stringList(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> [String] {
        if let a = try? c.decode([String].self, forKey: k) { return a }
        if let s = try? c.decode(String.self, forKey: k) { return parseStringList(s) }
        return []
    }

    private static func nestedList(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> [[String]] {
        if let a = try? c.decode([[String]].self, forKey: k) { return a }
        if let a = try? c.decode([String].self, forKey: k) { return a.map { [$0] } }
        if let s = try? c.decode(String.self, forKey: k),
           let data = s.data(using: .utf8),
           let a = try? JSONDecoder().decode([[String]].self, from: data) { return a }
        return []
    }
}

/// Port of `UserWordData`. JSON is wire-compatible with the Flutter app / `/user_progress` API.
public struct UserWordData: Codable, Hashable, Sendable {
    public var word: String
    public var notes: String = ""
    public var isLearned: Bool = false
    public var nextReview: Date?
    public var reviewCount: Int = 0
    public var lastReviewedAt: Date?
    public var firstLearnedAt: Date?
    public var correctAnswers: Int = 0
    public var totalAnswers: Int = 0
    public var learningStage: LearningStage = .newWord
    public var easeFactor: Double = 2.5
    public var interval: Int = 0
    public var repetitions: Int = 0
    public var hasBeenTested: Bool = false
    public var aiMnemonic: String?
    public var aiInsights: String?

    public init(word: String) { self.word = word }

    public var accuracyRate: Double {
        hasBeenTested && totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) : 0
    }
    public var isMastered: Bool {
        learningStage == .mastered || (isLearned && accuracyRate >= 0.8)
    }
    public func isDue(at now: Date = Date()) -> Bool {
        guard let nextReview else { return false }
        return nextReview <= now
    }

    private enum CodingKeys: String, CodingKey {
        case word, notes, isLearned, nextReview, reviewCount, lastReviewedAt, firstLearnedAt
        case correctAnswers, totalAnswers, learningStage, easeFactor, interval, repetitions
        case hasBeenTested, aiMnemonic, aiInsights
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        word = try c.decode(String.self, forKey: .word)
        notes = (try? c.decode(String.self, forKey: .notes)) ?? ""
        isLearned = (try? c.decode(Bool.self, forKey: .isLearned)) ?? false
        nextReview = Self.date(c, .nextReview)
        reviewCount = (try? c.decode(Int.self, forKey: .reviewCount)) ?? 0
        lastReviewedAt = Self.date(c, .lastReviewedAt)
        firstLearnedAt = Self.date(c, .firstLearnedAt)
        correctAnswers = (try? c.decode(Int.self, forKey: .correctAnswers)) ?? 0
        totalAnswers = (try? c.decode(Int.self, forKey: .totalAnswers)) ?? 0
        learningStage = LearningStage(rawValue: (try? c.decode(String.self, forKey: .learningStage)) ?? "") ?? .newWord
        easeFactor = (try? c.decode(Double.self, forKey: .easeFactor)) ?? 2.5
        interval = (try? c.decode(Int.self, forKey: .interval)) ?? 0
        repetitions = (try? c.decode(Int.self, forKey: .repetitions)) ?? 0
        hasBeenTested = (try? c.decode(Bool.self, forKey: .hasBeenTested)) ?? false
        aiMnemonic = try? c.decodeIfPresent(String.self, forKey: .aiMnemonic)
        aiInsights = try? c.decodeIfPresent(String.self, forKey: .aiInsights)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(word, forKey: .word); try c.encode(notes, forKey: .notes)
        try c.encode(isLearned, forKey: .isLearned)
        try c.encode(nextReview.map(DateCoding.string), forKey: .nextReview)
        try c.encode(reviewCount, forKey: .reviewCount)
        try c.encode(lastReviewedAt.map(DateCoding.string), forKey: .lastReviewedAt)
        try c.encode(firstLearnedAt.map(DateCoding.string), forKey: .firstLearnedAt)
        try c.encode(correctAnswers, forKey: .correctAnswers)
        try c.encode(totalAnswers, forKey: .totalAnswers)
        try c.encode(learningStage.rawValue, forKey: .learningStage)
        try c.encode(easeFactor, forKey: .easeFactor); try c.encode(interval, forKey: .interval)
        try c.encode(repetitions, forKey: .repetitions)
        try c.encode(hasBeenTested, forKey: .hasBeenTested)
        try c.encode(aiMnemonic, forKey: .aiMnemonic); try c.encode(aiInsights, forKey: .aiInsights)
    }

    private static func date(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Date? {
        guard let s = try? c.decodeIfPresent(String.self, forKey: k) else { return nil }
        return DateCoding.date(s)
    }
}

/// Dart's `toIso8601String()` omits the zone for local times ("2025-01-01T12:00:00.000").
/// Accept both zoned and zone-less strings; write UTC ISO-8601 with `Z`.
enum DateCoding {
    static func string(_ d: Date) -> String {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: d)
    }
    static func date(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        for opts: ISO8601DateFormatter.Options in [[.withInternetDateTime, .withFractionalSeconds], [.withInternetDateTime]] {
            f.formatOptions = opts
            if let d = f.date(from: s) { return d }
        }
        let local = DateFormatter()
        local.locale = Locale(identifier: "en_US_POSIX"); local.timeZone = .current
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss"] {
            local.dateFormat = fmt
            if let d = local.date(from: s) { return d }
        }
        return nil
    }
}

public struct UserSettings: Codable, Hashable, Sendable {
    public var dailyGoal: Int = 60
    public var languageCodes: [String] = ["en"]
    public var reviewFrequency: Int = 30
    public var showMyWords: Bool = true
    public init() {}
}

public struct WordSet: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public var description: String?
}
