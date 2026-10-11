import Foundation

/// Port of `MysqlDatabaseService.fetchVocabulary` row parsing + `DataMigrationService`.
public enum DataMigration {
    public static func difficulty(from s: String) -> WordDifficulty {
        switch s.lowercased() {
        case "easy", "basic": .basic
        case "hard", "advanced": .advanced
        default: .intermediate
        }
    }
}

public extension VocabularyWord {
    /// Parses an API row. Returns nil for rows missing `word` or `meaning` (skipped, as in Flutter).
    init?(apiRow row: [String: Any]) {
        func s(_ keys: String...) -> String {
            for k in keys { if let v = row[k], !(v is NSNull) { return "\(v)".trimmingCharacters(in: .whitespacesAndNewlines) } }
            return ""
        }
        func list(_ keys: String...) -> [String] {
            for k in keys {
                guard let v = row[k], !(v is NSNull) else { continue }
                if let a = v as? [Any] { return a.map { "\($0)" } }
                if let str = v as? String { return VocabularyWord.parseStringList(str) }
            }
            return []
        }
        let word = s("word"), meaning = s("meaning")
        if word.isEmpty || meaning.isEmpty { return nil }
        let mnemonic = s("mnemonic"), example = s("example"), category = s("category")
        let diff = s("difficulty"), image = s("imageUrl", "image_url"), video = s("videoUrl", "video_url")
        let aiM = s("aiMnemonic", "ai_mnemonic"), aiI = s("aiInsights", "ai_insights"), def = s("definition")
        var nested: [[String]] = []
        if let raw = row["exampleSentences"] ?? row["example_sentences"], !(raw is NSNull) {
            if let a = raw as? [[Any]] { nested = a.map { $0.map { "\($0)" } } }
            else if let a = raw as? [Any] { nested = a.map { ($0 as? [Any])?.map { "\($0)" } ?? ["\($0)"] } }
            else if let str = raw as? String, let d = str.data(using: .utf8),
                    let a = try? JSONSerialization.jsonObject(with: d) as? [Any] {
                nested = a.map { ($0 as? [Any])?.map { "\($0)" } ?? ["\($0)"] }
            }
        }
        self.init(word: word, meaning: meaning,
                  mnemonic: mnemonic.isEmpty ? "No mnemonic available" : mnemonic,
                  aiMnemonic: aiM.isEmpty ? nil : aiM, aiInsights: aiI.isEmpty ? nil : aiI,
                  imageURL: image.isEmpty ? nil : image, videoURL: video.isEmpty ? nil : video,
                  example: example.isEmpty ? "No example available" : example,
                  synonyms: list("synonyms"), antonyms: list("antonyms"),
                  difficulty: DataMigration.difficulty(from: diff.isEmpty ? "medium" : diff),
                  category: category.isEmpty ? "General" : category,
                  setIds: list("setIds", "set_ids"), definition: def.isEmpty ? nil : def,
                  phrases: list("phrases"), exampleSentences: nested)
    }
}

/// Port of `UserProfile` (/user_profile/<id>).
public struct UserProfile: Codable, Hashable, Sendable {
    public var userId: String
    public var vocabularyLevel: String = "1"       // comma separated: "1,2,3"
    public var learningGoal: String = ""
    public var hasCompletedOnboarding = false
    public var enabledWordSets: String = ""        // comma separated category ids

    public init(userId: String) { self.userId = userId }
    public var levels: [Int] { WordRecommendation.parseLevels(vocabularyLevel) }
    public var enabledSetIDs: Set<String> { Set(enabledWordSets.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }) }

    init(json j: [String: Any]) {
        userId = j["user_id"] as? String ?? ""
        if let i = j["vocabulary_level"] as? Int { vocabularyLevel = String(i) } else if let s = j["vocabulary_level"] as? String { vocabularyLevel = s }
        learningGoal = j["learning_goal"] as? String ?? ""
        hasCompletedOnboarding = j["has_completed_onboarding"] as? Bool ?? false
        enabledWordSets = j["enabled_word_sets"] as? String ?? ""
    }
    var json: [String: Any] {
        ["user_id": userId, "vocabulary_level": vocabularyLevel, "learning_goal": learningGoal,
         "has_completed_onboarding": hasCompletedOnboarding, "enabled_word_sets": enabledWordSets]
    }
}

public extension APIClient {
    private func raw(_ method: String, _ path: String, body: [String: Any]? = nil) async throws -> (Data, Int) {
        var req = URLRequest(url: URL(string: baseURL.absoluteString + "/" + path)!)
        req.httpMethod = method
        if let body { req.setValue("application/json", forHTTPHeaderField: "Content-Type"); req.httpBody = try JSONSerialization.data(withJSONObject: body) }
        let (d, r) = try await session.data(for: req)
        return (d, (r as? HTTPURLResponse)?.statusCode ?? 0)
    }
    private func enc(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))) ?? s
    }

    /// Vocabulary via the same parser as Flutter (skips malformed rows).
    func vocabularyRows(userID: String?) async throws -> [VocabularyWord] {
        let path = userID.map { "vocabulary?user_id=\(enc($0))" } ?? "vocabulary"
        let (d, code) = try await raw("GET", path)
        guard code == 200 else { throw APIError.badStatus(code) }
        let rows = (try JSONSerialization.jsonObject(with: d) as? [Any] ?? []).compactMap { $0 as? [String: Any] }
        return rows.compactMap(VocabularyWord.init(apiRow:))
    }

    /// GET /learned_status/<uid> → all learned words (used to sort word lists).
    func learnedWords(userID: String) async throws -> Set<String> {
        let (d, code) = try await raw("GET", "learned_status/\(enc(userID))")
        guard code == 200 else { throw APIError.badStatus(code) }
        return Set(((try? JSONSerialization.jsonObject(with: d)) as? [String: Any])?["learned_words"] as? [String] ?? [])
    }

    func notes(userID: String, word: String) async throws -> String {
        let (d, code) = try await raw("GET", "notes/\(enc(userID))/\(enc(word))")
        guard code == 200 else { throw APIError.badStatus(code) }
        return ((try? JSONSerialization.jsonObject(with: d)) as? [String: Any])?["notes"] as? String ?? ""
    }
    func saveNotes(userID: String, word: String, notes: String) async throws {
        let (_, code) = try await raw("POST", "notes/\(enc(userID))/\(enc(word))", body: ["notes": notes])
        guard code == 200 else { throw APIError.badStatus(code) }
    }
    func learnedStatus(userID: String, word: String) async throws -> Bool {
        let (d, code) = try await raw("GET", "learned_status/\(enc(userID))/\(enc(word))")
        guard code == 200 else { throw APIError.badStatus(code) }
        return ((try? JSONSerialization.jsonObject(with: d)) as? [String: Any])?["is_learned"] as? Bool ?? false
    }
    func saveLearnedStatus(userID: String, word: String, learned: Bool) async throws {
        let (_, code) = try await raw("POST", "learned_status/\(enc(userID))/\(enc(word))", body: ["is_learned": learned])
        guard code == 200 else { throw APIError.badStatus(code) }
    }
    func resetUser(userID: String) async throws {
        let (_, code) = try await raw("DELETE", "reset/\(enc(userID))")
        guard code == 200 else { throw APIError.badStatus(code) }
    }

    func userProfile(userID: String) async throws -> UserProfile? {
        let (d, code) = try await raw("GET", "user_profile/\(enc(userID))")
        if code == 404 { return nil }
        guard code == 200, let o = try JSONSerialization.jsonObject(with: d) as? [String: Any] else { throw APIError.badStatus(code) }
        return UserProfile(json: o)
    }
    func saveUserProfile(_ p: UserProfile) async throws {
        let (_, code) = try await raw("POST", "user_profile/\(enc(p.userId))", body: p.json)
        guard code == 200 else { throw APIError.badStatus(code) }
    }
    func curateOnboarding(userID: String, goal: String, score: Int) async throws {
        let (_, code) = try await raw("POST", "onboarding/curate", body: ["user_id": userID, "goal": goal, "score": score])
        guard code == 200 else { throw APIError.badStatus(code) }
    }
    func settingsSummary(level: String, enabledSets: String) async -> String {
        if let (d, code) = try? await raw("POST", "settings/summary", body: ["level": level, "enabled_sets": enabledSets]), code == 200,
           let o = try? JSONSerialization.jsonObject(with: d) as? [String: Any], let s = o["summary"] as? String { return s }
        return "Your journey continues at Level \(level) with \(enabledSets)."
    }
}
