import Foundation

/// Mirrors `ApiConfig` + repositories. Same Railway backend as the Flutter app.
public struct APIClient: Sendable {
    public var baseURL: URL
    public var session: URLSession

    public init(baseURL: URL = URL(string: "https://mnemonics-api-production.up.railway.app")!,
                session: URLSession = .shared) {
        self.baseURL = baseURL; self.session = session
    }

    public enum APIError: Error { case badStatus(Int) }

    private func get(_ path: String, query: [URLQueryItem] = []) async throws -> Data {
        var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { comps.queryItems = query }
        let (data, resp) = try await session.data(from: comps.url!)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) { throw APIError.badStatus(http.statusCode) }
        return data
    }

    public func vocabulary(userID: String? = nil) async throws -> [VocabularyWord] {
        let q = userID.map { [URLQueryItem(name: "user_id", value: $0)] } ?? []
        return try JSONDecoder().decode([VocabularyWord].self, from: try await get("vocabulary", query: q))
    }

    public func wordSets() async throws -> [WordSet] {
        struct Wrapper: Decodable { let sets: [WordSet] }
        let data = try await get("word_sets")
        if let w = try? JSONDecoder().decode(Wrapper.self, from: data) { return w.sets }
        return try JSONDecoder().decode([WordSet].self, from: data)
    }

    /// GET /user_progress/<id> → `{progress: {word: <json object or json string>}}`
    public func userProgress(userID: String) async throws -> [UserWordData] {
        let data = try await get("user_progress/\(userID)")
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let progress = root["progress"] as? [String: Any] else { return [] }
        let decoder = JSONDecoder()
        return progress.values.compactMap { value in
            if let s = value as? String, let d = s.data(using: .utf8) { return try? decoder.decode(UserWordData.self, from: d) }
            if let o = value as? [String: Any], let d = try? JSONSerialization.data(withJSONObject: o) {
                return try? decoder.decode(UserWordData.self, from: d)
            }
            return nil
        }
    }

    public func saveProgress(userID: String, _ item: UserWordData) async throws {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        let w = item.word.addingPercentEncoding(withAllowedCharacters: allowed) ?? item.word
        var req = URLRequest(url: baseURL.appendingPathComponent("user_progress/\(userID)/\(w)"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(item)
        let (_, resp) = try await session.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) { throw APIError.badStatus(http.statusCode) }
    }
}
