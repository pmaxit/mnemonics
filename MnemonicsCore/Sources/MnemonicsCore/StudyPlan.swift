import Foundation

typealias JSONObject = [String: Any]
private extension Dictionary where Key == String, Value == Any {
    func str(_ k: String, _ d: String = "") -> String { self[k] as? String ?? d }
    func int(_ k: String, _ d: Int = 0) -> Int { (self[k] as? NSNumber)?.intValue ?? d }
    func dbl(_ k: String, _ d: Double = 0) -> Double { (self[k] as? NSNumber)?.doubleValue ?? d }
    func bool(_ k: String, _ d: Bool = false) -> Bool { self[k] as? Bool ?? d }
    func list(_ k: String) -> [JSONObject] { (self[k] as? [Any] ?? []).compactMap { $0 as? JSONObject } }
    func strings(_ k: String) -> [String] { (self[k] as? [Any] ?? []).map { "\($0)" } }
    func obj(_ k: String) -> JSONObject { self[k] as? JSONObject ?? [:] }
}

// MARK: - Multi-day study plan (/study-plan/create, /study-plan/<uid>)

public enum DayStatus: String, Sendable { case notAttempted = "not_attempted", inProgress = "in_progress", done }

public struct StudyPlanDay: Identifiable, Hashable, Sendable {
    public var id: Int { dayNumber }
    public let dayNumber: Int
    public let words: [String]
    public var status: DayStatus
    public let startedAt: Date?, doneAt: Date?
    public let xpValue: Int
    public var isReviewDay: Bool { dayNumber % 4 == 0 }
    public var dayLabel: String { isReviewDay ? "Review Day \(dayNumber)" : "Day \(dayNumber)" }

    init(json j: JSONObject) {
        dayNumber = j.int("day_number"); words = j.strings("words")
        status = DayStatus(rawValue: j.str("status", "not_attempted")) ?? .notAttempted
        startedAt = (j["started_at"] as? String).flatMap(DateCoding.date)
        doneAt = (j["done_at"] as? String).flatMap(DateCoding.date)
        xpValue = j.int("xp_value", 10)
    }
}

public enum PlanBadge: CaseIterable, Sendable {
    case firstSteps, onFire, weekWarrior, halfway, champion, xpHunter, xpMaster
    public var emoji: String { ["🎯", "🔥", "⚔️", "🏔️", "👑", "⭐", "🏆"][PlanBadge.allCases.firstIndex(of: self)!] }
    public var title: String { ["First Steps", "On Fire", "Week Warrior", "Halfway There", "Champion", "XP Hunter", "XP Master"][PlanBadge.allCases.firstIndex(of: self)!] }
    public var detail: String { ["Complete your first day", "3-day streak", "7-day streak", "50% complete", "Complete the entire plan", "Earn 100 XP", "Earn 500 XP"][PlanBadge.allCases.firstIndex(of: self)!] }
}

public struct StudyPlan: Identifiable, Hashable, Sendable {
    public let id: String, userId: String, title: String
    public let totalWords: Int, numDays: Int, wordsPerDay: Int
    public let startDate: String, status: String
    public var days: [StudyPlanDay]
    public let totalXp: Int
    public let difficultyPref: String, dailyCommitment: String

    init(json j: JSONObject) {
        id = j.str("id"); userId = j.str("user_id"); title = j.str("title")
        totalWords = j.int("total_words"); numDays = j.int("num_days"); wordsPerDay = j.int("words_per_day")
        startDate = j.str("start_date"); status = j.str("status", "active")
        days = j.list("days").map(StudyPlanDay.init(json:))
        totalXp = j.int("total_xp"); difficultyPref = j.str("difficulty_pref", "balanced")
        dailyCommitment = j.str("daily_commitment", "standard")
    }

    public var completedDays: Int { days.filter { $0.status == .done }.count }
    public var inProgressDays: Int { days.filter { $0.status == .inProgress }.count }
    public var progress: Double { numDays > 0 ? Double(completedDays) / Double(numDays) : 0 }
    public var uniqueWords: Set<String> { Set(days.flatMap(\.words)) }
    public func learnedWordCount(_ learned: Set<String>) -> Int {
        let done = Set(days.filter { $0.status == .done }.flatMap(\.words))
        return uniqueWords.filter { learned.contains($0) || done.contains($0) }.count
    }
    public func wordProgress(_ learned: Set<String>) -> Double {
        let w = uniqueWords
        return w.isEmpty ? progress : min(1, max(0, Double(learnedWordCount(learned)) / Double(w.count)))
    }
    public var earnedXp: Int { days.filter { $0.status == .done }.reduce(0) { $0 + $1.xpValue } }
    public var streak: Int { var s = 0; for d in days { if d.status == .done { s += 1 } else { break } }; return s }
    public var unlockedBadges: [PlanBadge] {
        var b: [PlanBadge] = []
        if completedDays >= 1 { b.append(.firstSteps) }
        if streak >= 3 { b.append(.onFire) }
        if streak >= 7 { b.append(.weekWarrior) }
        if progress >= 0.5 { b.append(.halfway) }
        if completedDays == numDays && numDays > 0 { b.append(.champion) }
        if earnedXp >= 100 { b.append(.xpHunter) }
        if earnedXp >= 500 { b.append(.xpMaster) }
        return b
    }
}

// MARK: - Today's adaptive plan (/study-plan/<uid>/today)

public struct StudyPlanItem: Hashable, Sendable, Identifiable {
    public var id: String { word + reason }
    public let wordId: Int?, word: String, reason: String, category: String, difficulty: String, stage: String
    public let accuracy: Double, mnemonicHint: Bool
    init(json j: JSONObject) {
        wordId = (j["word_id"] as? NSNumber)?.intValue; word = j.str("word"); reason = j.str("reason")
        category = j.str("category"); difficulty = j.str("difficulty"); stage = j.str("stage")
        accuracy = j.dbl("accuracy"); mnemonicHint = j.bool("mnemonic_hint")
    }
    public var reasonLabel: String {
        switch reason { case "due": "Due"; case "weak": "Weak"; case "new": "New"; case "exam": "Pace"; case "bonus": "Bonus"; default: reason }
    }
}
public struct StudyPlanTrack: Hashable, Sendable, Identifiable {
    public let id: String, title: String, why: String, priority: Int, items: [StudyPlanItem]
    init(json j: JSONObject) { id = j.str("id"); title = j.str("title"); why = j.str("why"); priority = j.int("priority"); items = j.list("items").map(StudyPlanItem.init(json:)) }
}
public struct DailyPlanSplit: Hashable, Sendable {
    public let review: Int, weak: Int, newWords: Int, bonus: Int
    init(json j: JSONObject) { review = j.int("review"); weak = j.int("weak"); newWords = j.int("new"); bonus = j.int("bonus") }
}
public struct StudyStrategy: Hashable, Sendable {
    public let headline: String, howToStudy: String, nextAction: String, tips: [String]
    init(json j: JSONObject) { headline = j.str("headline"); howToStudy = j.str("how_to_study"); nextAction = j.str("next_action"); tips = j.strings("tips") }
}
public struct StudyMilestone: Hashable, Sendable {
    public let id: String, label: String, remaining: Int, kind: String
    init(json j: JSONObject) { id = j.str("id"); label = j.str("label"); remaining = j.int("remaining"); kind = j.str("kind") }
}
public struct StudyIncentive: Hashable, Sendable {
    public let streakDays: Int, dailyGoalWords: Int, dailyGoalMinutes: Int, pointsIfCompleted: Int
    public let pointsNote: String, copy: String, completedToday: Bool
    public let nextMilestone: StudyMilestone?
    init(json j: JSONObject) {
        streakDays = j.int("streak_days"); dailyGoalWords = j.int("daily_goal_words"); dailyGoalMinutes = j.int("daily_goal_minutes")
        pointsIfCompleted = j.int("points_if_completed"); pointsNote = j.str("points_note"); copy = j.str("copy")
        completedToday = j.bool("completed_today")
        nextMilestone = (j["next_milestone"] as? JSONObject).map(StudyMilestone.init(json:))
    }
}
public struct ProfileSnapshot: Hashable, Sendable {
    public let newCount: Int, learningCount: Int, masteredCount: Int, dueCount: Int, remainingNew: Int
    public let accuracy: Double, weakCategories: [String], examKind: String?
    init(json j: JSONObject) {
        newCount = j.int("new"); learningCount = j.int("learning"); masteredCount = j.int("mastered"); dueCount = j.int("due")
        accuracy = j.dbl("accuracy"); weakCategories = j.strings("weak_categories"); examKind = j["exam_kind"] as? String
        remainingNew = j.int("remaining_new")
    }
}
public struct DailyStudyPlan: Sendable {
    public let date: String, userId: String
    public let estimatedMinutes: Int, availableMinutes: Int
    public let split: DailyPlanSplit
    public let tracks: [StudyPlanTrack], items: [StudyPlanItem]
    public let strategy: StudyStrategy, incentive: StudyIncentive, profileSnapshot: ProfileSnapshot
    public let completed: Bool
    public var requiredWords: [String] { items.filter { $0.reason != "bonus" }.map(\.word) }
    init(json j: JSONObject) {
        date = j.str("date"); userId = j.str("user_id"); estimatedMinutes = j.int("estimated_minutes")
        availableMinutes = j.int("available_minutes", 20); split = DailyPlanSplit(json: j.obj("split"))
        tracks = j.list("tracks").map(StudyPlanTrack.init(json:)); items = j.list("items").map(StudyPlanItem.init(json:))
        strategy = StudyStrategy(json: j.obj("strategy")); incentive = StudyIncentive(json: j.obj("incentive"))
        profileSnapshot = ProfileSnapshot(json: j.obj("profile_snapshot")); completed = j.bool("completed")
    }
}

// MARK: - API

public extension APIClient {
    private func send(_ method: String, _ path: String, body: JSONObject? = nil, expect: Set<Int> = [200]) async throws -> Data {
        var req = URLRequest(url: URL(string: baseURL.absoluteString + "/" + path)!)
        req.httpMethod = method
        if let body { req.setValue("application/json", forHTTPHeaderField: "Content-Type"); req.httpBody = try JSONSerialization.data(withJSONObject: body) }
        let (data, resp) = try await session.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard expect.contains(code) else { throw StudyPlanError.http(code, String(data: data, encoding: .utf8) ?? "") }
        return data
    }
    private func object(_ d: Data) throws -> JSONObject { (try JSONSerialization.jsonObject(with: d) as? JSONObject) ?? [:] }

    func createStudyPlan(userID: String, totalWords: Int, numDays: Int, wordsPerDay: Int, title: String? = nil,
                         difficultyPref: String = "balanced", dailyCommitment: String = "standard") async throws -> StudyPlan {
        var body: JSONObject = ["user_id": userID, "total_words": totalWords, "num_days": numDays, "words_per_day": wordsPerDay,
                                "difficulty_pref": difficultyPref, "daily_commitment": dailyCommitment]
        if let title { body["title"] = title }
        return StudyPlan(json: try object(try await send("POST", "study-plan/create", body: body, expect: [201])))
    }
    func todaysPlan(userID: String, minutes: Int = 20) async throws -> DailyStudyPlan {
        DailyStudyPlan(json: try object(try await send("GET", "study-plan/\(userID)/today?minutes=\(minutes)")))
    }
    func completeTodaysPlan(userID: String, wordsCompleted: Int, points: Int) async throws {
        _ = try await send("POST", "study-plan/\(userID)/today/complete", body: ["words_completed": wordsCompleted, "points": points])
    }
    func activePlans(userID: String) async throws -> [StudyPlan] {
        do {
            let d = try await send("GET", "study-plan/\(userID)")
            return ((try JSONSerialization.jsonObject(with: d)) as? [Any] ?? []).compactMap { ($0 as? JSONObject).map(StudyPlan.init(json:)) }
        } catch StudyPlanError.http(404, _) { return [] }
    }
    func studyDay(userID: String, day: Int) async throws -> StudyPlanDay {
        StudyPlanDay(json: try object(try await send("GET", "study-plan/\(userID)/day/\(day)")))
    }
    func updateDayStatus(userID: String, day: Int, status: DayStatus) async throws {
        _ = try await send("POST", "study-plan/\(userID)/day/\(day)/status", body: ["status": status == .done ? "done" : "in_progress"])
    }
    func deletePlan(id: String) async throws { _ = try await send("DELETE", "study-plan/\(id)") }
}

public enum StudyPlanError: Error, LocalizedError {
    case http(Int, String)
    public var errorDescription: String? {
        if case let .http(code, body) = self {
            let b = body.trimmingCharacters(in: .whitespacesAndNewlines)
            if b.isEmpty || b.hasPrefix("<") { return "Request failed (HTTP \(code))" }
            return b.count > 160 ? String(b.prefix(160)) + "…" : b
        }
        return nil
    }
}
