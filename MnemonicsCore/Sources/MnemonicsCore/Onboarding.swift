import Foundation

/// Port of the onboarding wizard's level assessment + starter plan sizing.
public enum Onboarding {
    public struct Question: Sendable { public let level: Int; public let word: String; public let options: [String]; public let answer: String }
    public static let questions: [Question] = [
        .init(level: 1, word: "Benevolent", options: ["Kind", "Angry", "Fast", "Broken"], answer: "Kind"),
        .init(level: 2, word: "Diligent", options: ["Lazy", "Hardworking", "Smart", "Quiet"], answer: "Hardworking"),
        .init(level: 3, word: "Ephemeral", options: ["Eternal", "Short-lived", "Beautiful", "Heavy"], answer: "Short-lived"),
        .init(level: 4, word: "Sagacious", options: ["Angry", "Wise", "Fragile", "Talkative"], answer: "Wise"),
        .init(level: 5, word: "Loquacious", options: ["Silent", "Greedy", "Talkative", "Brave"], answer: "Talkative"),
    ]
    public static let goals: [(id: String, title: String, desc: String)] = [
        ("character", "Character", "Words about personality & traits."), ("speech", "Speech", "Words about communication & language."),
        ("intellect", "Intellect", "Words about thinking & knowledge."), ("morality", "Morality", "Words about ethics & right vs wrong."),
        ("conflict", "Conflict", "Words about opposition & struggle."), ("change", "Change", "Words about transformation & transition."),
    ]

    public static func assessedLevel(correct: Int) -> Int { correct >= 4 ? 3 : correct >= 2 ? 2 : 1 }
    public static func levelName(_ level: Int) -> String { level == 1 ? "Beginner" : level == 2 ? "Intermediate" : "Advanced" }

    public struct PlanSize: Equatable, Sendable { public let totalWords, numDays, wordsPerDay: Int; public let difficultyPref: String }
    public static func plan(forLevel level: Int) -> PlanSize {
        switch level {
        case 1: PlanSize(totalWords: 50, numDays: 15, wordsPerDay: 4, difficultyPref: "easy_start")
        case 2: PlanSize(totalWords: 75, numDays: 15, wordsPerDay: 5, difficultyPref: "balanced")
        default: PlanSize(totalWords: 100, numDays: 20, wordsPerDay: 5, difficultyPref: "challenging")
        }
    }
}
