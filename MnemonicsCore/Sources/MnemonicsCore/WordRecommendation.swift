import Foundation

public enum WordRecommendation {
    public static let defaultLimit = 20

    public static func difficulty(forLevel level: Int) -> WordDifficulty {
        level <= 1 ? .basic : (level == 2 ? .intermediate : .advanced)
    }

    /// Unlearned words matching the user's levels, filled from nearest difficulties if short.
    public static func recommend(available: [VocabularyWord], learned: Set<String>, levels: [Int],
                                 enabledCategories: Set<String> = [], limit: Int = defaultLimit) -> [VocabularyWord] {
        guard !available.isEmpty, !levels.isEmpty, limit > 0 else { return [] }
        let targets = Set(levels.map(difficulty(forLevel:)))
        let targetRanks = Set(targets.map(\.rank))
        let pool = available.filter {
            !learned.contains($0.word) && (enabledCategories.isEmpty || enabledCategories.contains($0.category))
        }
        func sorted(_ w: [VocabularyWord]) -> [VocabularyWord] {
            w.sorted { ($0.difficulty.rank, $0.word) < ($1.difficulty.rank, $1.word) }
        }
        var result = sorted(pool.filter { targets.contains($0.difficulty) })
        if result.count >= limit { return Array(result.prefix(limit)) }
        var used = Set(result.map(\.word))
        for distance in 1...2 where result.count < limit {
            let ring = sorted(pool.filter { w in
                !used.contains(w.word) && targetRanks.contains { abs(w.difficulty.rank - $0) == distance }
            })
            for w in ring where result.count < limit { result.append(w); used.insert(w.word) }
        }
        // Last resort: any remaining word (alphabetical) — keeps My Words alive on sparse datasets.
        if result.count < limit {
            for w in pool.filter({ !used.contains($0.word) }).sorted(by: { $0.word < $1.word }) where result.count < limit {
                result.append(w)
            }
        }
        return result
    }

    /// Parses a comma-separated level string ("1,2") into sorted levels; falls back to [1].
    public static func parseLevels(_ raw: String?) -> [Int] {
        let levels = Set((raw ?? "").split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }.filter { $0 > 0 }).sorted()
        return levels.isEmpty ? [1] : levels
    }
}
