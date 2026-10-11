import Foundation

/// An example sentence paired with its use-case / collocation header.
public struct PhraseUsage: Hashable, Sendable {
    public let useCase: String
    public let sentence: String
}

/// Port of `VocabularyWordContextX` (vocabulary_word.dart).
public extension VocabularyWord {
    /// Real usage sentences, excluding phrase fragments and filler.
    var contextSentences: [String] {
        var seen = Set<String>(), results: [String] = []
        func add(_ raw: String?) {
            guard let raw else { return }
            let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if s.isEmpty || s == "No example available" { return }
            if !Self.looksLikeUsageSentence(s, word) { return }
            if seen.insert(s.lowercased()).inserted { results.append(s) }
        }
        for group in exampleSentences { for s in group { add(s) } }
        add(example)
        for s in Self.aiInsightsList(aiInsights, ["example_sentences", "exampleSentences"]) { add(s) }
        return results
    }

    var phraseUsages: [PhraseUsage] {
        let sentences = contextSentences, phrasesList = effectivePhrases
        var out: [PhraseUsage] = [], used = Set<String>()
        for (i, sentence) in sentences.enumerated() {
            var matched: String?
            for p in phrasesList {
                let t = p.trimmingCharacters(in: .whitespaces)
                if !t.isEmpty && Self.phraseMatches(t, sentence) { matched = Self.capitalize(t); break }
            }
            matched = matched ?? Self.extractUseCase(sentence, word)
            let base = matched ?? "Use Case \(i + 1)"
            var unique = base, counter = 2
            while used.contains(unique.lowercased()) { unique = "\(base) (\(counter))"; counter += 1 }
            used.insert(unique.lowercased())
            out.append(PhraseUsage(useCase: unique, sentence: sentence))
        }
        return out
    }

    var effectivePhrases: [String] {
        phrases.isEmpty ? Self.aiInsightsList(aiInsights, ["common_phrases", "commonPhrases"]) : phrases
    }
    var effectiveSynonyms: [String] {
        synonyms.isEmpty ? Self.aiInsightsList(aiInsights, ["synonyms"]) : synonyms
    }

    // MARK: helpers

    private static let ignored: Set<String> = ["the", "a", "an", "their", "his", "her", "its", "our", "my", "your",
                                               "this", "that", "these", "those", "to", "of", "for", "in", "on", "with"]

    private static func regex(_ pattern: String) -> NSRegularExpression? {
        try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }
    private static func firstMatch(_ pattern: String, in s: String) -> String? {
        guard let re = regex(pattern), let m = re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)),
              let r = Range(m.range, in: s) else { return nil }
        return String(s[r])
    }

    static func phraseMatches(_ phrase: String, _ sentence: String) -> Bool {
        let s = sentence.lowercased(), p = phrase.lowercased().trimmingCharacters(in: .whitespaces)
        if s.contains(p) { return true }
        let tokens = p.split(whereSeparator: \.isWhitespace).map(String.init).filter { !$0.isEmpty && !ignored.contains($0) }
        if tokens.count < 2 { return false }
        let pattern = "\\b" + tokens.map(NSRegularExpression.escapedPattern(for:)).joined(separator: "(?:\\s+\\w+){0,3}\\s+") + "\\b"
        return firstMatch(pattern, in: s) != nil
    }

    private static func trimNonWord(_ s: String) -> String {
        var t = Substring(s)
        while let f = t.first, !(f.isLetter || f.isNumber || f == "_") { t = t.dropFirst() }
        while let l = t.last, !(l.isLetter || l.isNumber || l == "_") { t = t.dropLast() }
        return String(t)
    }

    static func extractUseCase(_ sentence: String, _ word: String) -> String? {
        let w = NSRegularExpression.escapedPattern(for: word)
        for pattern in ["\\b\(w)\\w*(?:\\s+[A-Za-z]+){1,3}", "(?:\\b[A-Za-z]+\\s+)?\\b\(w)\\w*(?:\\s+[A-Za-z]+){1,2}"] {
            if let raw = firstMatch(pattern, in: sentence) {
                let cleaned = trimNonWord(raw.trimmingCharacters(in: .whitespaces))
                if cleaned.split(whereSeparator: \.isWhitespace).count >= 2 { return capitalize(cleaned) }
            }
        }
        return nil
    }

    static func capitalize(_ t: String) -> String { t.isEmpty ? t : t.prefix(1).uppercased() + t.dropFirst() }

    static func looksLikeUsageSentence(_ sentence: String, _ word: String) -> Bool {
        if sentence.count < 20 { return false }
        if !containsWordForm(sentence, word) { return false }
        if sentence.split(whereSeparator: \.isWhitespace).count < 5 { return false }
        let lower = sentence.lowercased()
        let blocked = ["comes up often", "make your own sentence", "explain the meaning", "used correctly in",
                       "practising", "first saw", "will make it stick"]
        return !blocked.contains { lower.contains($0) }
    }

    static func containsWordForm(_ sentence: String, _ word: String) -> Bool {
        let l = sentence.lowercased(), w = word.lowercased()
        if l.contains(w) { return true }
        if w.count > 4 { let stem = String(w.dropLast()); if stem.count >= 4 && l.contains(stem) { return true } }
        return false
    }

    static func aiInsightsList(_ ai: String?, _ keys: [String]) -> [String] {
        guard var cleaned = ai?.trimmingCharacters(in: .whitespacesAndNewlines), !cleaned.isEmpty else { return [] }
        if cleaned.hasPrefix("```") {
            if let r = cleaned.range(of: "^```json?\\s*", options: .regularExpression) { cleaned.removeSubrange(r) }
            if let r = cleaned.range(of: "\\s*```$", options: .regularExpression) { cleaned.removeSubrange(r) }
        }
        guard let data = cleaned.data(using: .utf8), let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
        for k in keys { if let arr = obj[k] as? [Any] { return arr.map { "\($0)" } } }
        return []
    }
}

/// Port of `WordInsights` (AI insights JSON blob).
public struct WordInsights: Sendable {
    public var definition = "No definition available."
    public var commonPhrases: [String] = [], exampleSentences: [String] = [], synonyms: [String] = []
    public var memoryTip = "No memory tip available."
    public init?(jsonString source: String) {
        var s = source.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("```json") { s.removeFirst(7) } else if s.hasPrefix("```") { s.removeFirst(3) }
        if s.hasSuffix("```") { s.removeLast(3) }
        guard let d = s.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8),
              let o = try? JSONSerialization.jsonObject(with: d) as? [String: Any] else { return nil }
        definition = o["definition"] as? String ?? definition
        commonPhrases = (o["common_phrases"] as? [Any] ?? []).map { "\($0)" }
        exampleSentences = (o["example_sentences"] as? [Any] ?? []).map { "\($0)" }
        synonyms = (o["synonyms"] as? [Any] ?? []).map { "\($0)" }
        memoryTip = o["memory_tip"] as? String ?? memoryTip
    }
}
