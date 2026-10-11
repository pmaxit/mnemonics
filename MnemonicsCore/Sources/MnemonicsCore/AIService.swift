import Foundation

/// Port of `AIService` (OpenRouter chat completions). The key is supplied by the app (Info.plist `OPENROUTER_API_KEY`).
public struct AIService: Sendable {
    public var apiKey: String
    public var session: URLSession
    static let base = "https://openrouter.ai/api/v1"
    static let model = "google/gemma-4-12b-instruct"

    public init(apiKey: String, session: URLSession = .shared) { self.apiKey = apiKey; self.session = session }
    public var isConfigured: Bool { !apiKey.isEmpty }

    public enum AIError: LocalizedError {
        case missingKey, api(String)
        public var errorDescription: String? {
            switch self { case .missingKey: "OPENROUTER_API_KEY is not set"; case .api(let m): m }
        }
    }

    func call(_ prompt: String, jsonMode: Bool = false) async throws -> String {
        guard !apiKey.isEmpty else { throw AIError.missingKey }
        var req = URLRequest(url: URL(string: "\(Self.base)/chat/completions")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("https://mnemonics-app.com", forHTTPHeaderField: "HTTP-Referer")
        req.setValue("Mnemonics App", forHTTPHeaderField: "X-Title")
        var body: [String: Any] = ["model": Self.model, "messages": [["role": "user", "content": prompt]], "temperature": 0.7]
        if jsonMode { body["response_format"] = ["type": "json_object"] }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, resp) = try await session.data(for: req)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            let msg = ((obj?["error"] as? [String: Any])?["message"] as? String) ?? "HTTP \((resp as? HTTPURLResponse)?.statusCode ?? 0)"
            throw AIError.api("Failed to generate response: \(msg)")
        }
        let content = ((obj?["choices"] as? [[String: Any]])?.first?["message"] as? [String: Any])?["content"] as? String
        return content ?? ""
    }

    public func generateMnemonic(word: String, meaning: String, nativeLanguage: String? = nil) async throws -> String {
        let instruction = nativeLanguage.map {
            "The user speaks \($0). You can bridge the English word with a similar sounding word in \($0)."
        } ?? "Create a vivid visual association to help remember it."
        let prompt = """
        You are an expert at creating highly memorable, slightly bizarre, and effective mnemonics for learning English vocabulary.
        Create a short, engaging mnemonic to help remember the following word:

        Word: "\(word)"
        Meaning: "\(meaning)"

        Instructions:
        1. \(instruction)
        2. Make it visual and funny or bizarre, as these stick best in memory.
        3. Keep it to 1-2 short sentences.
        4. Don't explain what a mnemonic is, just provide the mnemonic story/association directly.
        5. Emphasize the connection between the *sound* of the word and its *meaning*.
        """
        do { let r = try await call(prompt); return r.isEmpty ? "Hmm, my brain fizzled out. Try generating again!" : r }
        catch { throw AIError.api("Failed to generate magic mnemonic. Please try again.") }
    }

    public func generateWordInsights(word: String) async throws -> String {
        let prompt = """
        For the word detail screen can you add more information about the word.

        Act as a GRE vocabulary tutor.

        For the given word, help me learn it through association and context.

        For the word: "\(word)"

        1. Give a short, simple definition suitable for GRE preparation.
        2. Generate 12-15 short phrases where the word is naturally used.
           Do NOT write full sentences here — only short phrases (2-4 words).
           The phrases should cover different contexts such as behavior, science, society, emotions, academic writing, etc.
        3. Write 5 concise example sentences that use the word naturally in different real-world contexts (e.g. health, politics, daily life). Each sentence must show the word in action — never mention the word itself as a vocabulary item.
        4. Give 3 synonyms commonly tested on GRE.
        5. Give 1 quick memory tip or association to remember the word.

        Return EXACTLY a valid JSON object with NO OTHER markdown or formatting (DO NOT wrap it in triple backticks) using the following structure:
        {
          "definition": "definition here",
          "common_phrases": ["phrase 1", "phrase 2", "phrase 3"],
          "example_sentences": ["sentence 1", "sentence 2", "sentence 3", "sentence 4", "sentence 5"],
          "synonyms": ["synonym 1", "synonym 2", "synonym 3"],
          "memory_tip": "memory tip here"
        }
        """
        do { return try await call(prompt, jsonMode: true).trimmingCharacters(in: .whitespacesAndNewlines) }
        catch { throw AIError.api("Failed to generate word insights. Please try again.") }
    }

    public func generateTreeWisdom(totalLearned: Int, accuracy: Double, streak: Int) async -> String {
        let prompt = """
        You are the ancient, wise "Tree Spirit of Knowledge". A student is growing a virtual Knowledge Tree by learning vocabulary words.

        Their current stats:
        - Words Learned: \(totalLearned)
        - Accuracy: \(String(format: "%.1f", accuracy * 100))%
        - Current Streak: \(streak) days

        Write a SINGLE, mystical, encouraging sentence (max 20 words) as if the Tree itself is speaking to them.
        Acknowledge their effort or their stats, but keep it poetic and magical.
        Return ONLY the sentence, nothing else.
        """
        if let r = try? await call(prompt) { return r.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines) }
        return "The wind rustles the leaves, whispering of untold words yet to be learned."
    }
}
