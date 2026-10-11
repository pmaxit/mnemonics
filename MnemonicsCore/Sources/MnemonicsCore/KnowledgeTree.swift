import Foundation

public struct TreeBranchSpec: Hashable, Sendable, Identifiable {
    public var id: String { category }
    public let category: String
    public let wordCount: Int
    public let colorHex: UInt32
}

/// Port of `buildTreeBranches` / `colorForCategory` (knowledge_tree_widget.dart).
public enum KnowledgeTree {
    static let categoryColors: [String: UInt32] = [
        "character": 0x26A69A, "speech": 0x5C6BC0, "intellect": 0x7E57C2, "conflict": 0xEF5350,
        "morality": 0x66BB6A, "change": 0x26C6DA, "academic": 0x4CAF50, "common": 0xFFA726,
    ]
    static let fallback: [UInt32] = [0x4CAF50, 0xE91E63, 0xFF7043, 0x42A5F5, 0xAB47BC, 0x26C6DA]

    public static func color(for category: String) -> UInt32 {
        if let c = categoryColors[category.lowercased()] { return c }
        let hash = category.utf16.reduce(0) { $0 + Int($1) }
        return fallback[hash % fallback.count]
    }

    public static func branches(learnedWords: [String], wordToCategory: [String: String]) -> [TreeBranchSpec] {
        var counts: [String: Int] = [:]
        for w in learnedWords { counts[wordToCategory[w] ?? "General", default: 0] += 1 }
        return counts.map { TreeBranchSpec(category: $0.key, wordCount: $0.value, colorHex: color(for: $0.key)) }
            .sorted { $0.wordCount != $1.wordCount ? $0.wordCount > $1.wordCount : $0.category < $1.category }
    }

    public static func depth(totalLearned n: Int) -> Int {
        n == 0 ? 1 : n < 5 ? 2 : n < 15 ? 3 : n < 30 ? 4 : n < 60 ? 5 : n < 100 ? 6 : 7
    }
    public static func healthFactor(daysSincePractice d: Int) -> Double {
        d <= 1 ? 1.0 : d >= 7 ? 0.2 : 1.0 - Double(d - 1) * 0.13
    }
    public static func levelName(totalLearned n: Int) -> String {
        n >= 100 ? "Oak" : n >= 60 ? "Dense Tree" : n >= 30 ? "Mature Tree" : n >= 15 ? "Young Tree" : n >= 5 ? "Sapling" : n >= 1 ? "Sprout" : "Seed"
    }
    public static func statusMessage(totalLearned: Int, daysSincePractice d: Int, branches: [TreeBranchSpec]) -> String {
        if totalLearned == 0 { return "Plant a seed by learning words!" }
        if let b = branches.first { return "Growing strong on \"\(b.category.prefix(1).uppercased() + b.category.dropFirst().lowercased())\" words." }
        if d == 0 { return "Thriving beautifully!" }
        if d == 1 { return "Looking healthy." }
        if d < 4 { return "Leaves are looking a bit dry..." }
        return "Drooping! Needs practice watering!"
    }

    /// Smart pathfinding: next category to focus on (home_screen.dart).
    public static func suggestedCategory(_ stats: [CategoryStats]) -> CategoryStats? {
        guard var s = stats.first else { return nil }
        for c in stats where c.wordsLearned < c.totalWords && (c.averageAccuracy < s.averageAccuracy || s.wordsLearned >= s.totalWords) { s = c }
        return s.wordsLearned >= s.totalWords ? nil : s
    }
}
