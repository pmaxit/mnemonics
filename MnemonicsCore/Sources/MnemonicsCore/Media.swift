import Foundation

/// Port of `resolveVocabularyImageUrl` (core/utils/vocabulary_image_url.dart).
public enum VocabularyMedia {
    static let api = "https://mnemonics-api-production.up.railway.app"

    public static func imageURL(image: String?, word: String?) -> URL? {
        guard let raw = image?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        guard let comps = URLComponents(string: raw), comps.scheme != nil else {
            return raw.hasPrefix("/word_images/") ? URL(string: api + raw) : URL(string: raw)
        }
        let host = (comps.host ?? "").lowercased()
        if host == "media.pollinations.ai" || host == "gen.pollinations.ai" {
            let w = (word ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let slug = w.replacingOccurrences(of: "[^a-z0-9]+", with: "_", options: .regularExpression)
                .replacingOccurrences(of: "^_+|_+$", with: "", options: .regularExpression)
            return slug.isEmpty ? nil : URL(string: "\(api)/word_images/\(slug).jpg")
        }
        return URL(string: raw)
    }

    public static func imageURL(for w: VocabularyWord) -> URL? { imageURL(image: w.imageURL, word: w.word) }

    /// Video URLs may be API-relative (`/videos/<slug>.mp4`).
    public static func videoURL(for w: VocabularyWord) -> URL? {
        guard let raw = w.videoURL?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        if raw.hasPrefix("/") { return URL(string: api + raw) }
        return URL(string: raw)
    }
}

/// The unofficial Google Translate endpoint used by the Flutter `translator` package.
public enum Translator {
    public static func translate(_ text: String, to lang: String = "hi", session: URLSession = .shared) async throws -> String {
        var c = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
        c.queryItems = [.init(name: "client", value: "gtx"), .init(name: "sl", value: "auto"), .init(name: "tl", value: lang),
                        .init(name: "dt", value: "t"), .init(name: "q", value: text)]
        let (data, _) = try await session.data(from: c.url!)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [Any], let parts = root.first as? [Any] else { return "" }
        return parts.compactMap { ($0 as? [Any])?.first as? String }.joined()
    }
}
