import Foundation

public struct InboxItem: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String, message: String
    public let timestamp: Date
    public let sourceKey: String?
    public var read = false
    public var isToast = false
}

/// Port of `NotificationManager` (in-app inbox, max 50, de-duped by sourceKey).
public struct NotificationInbox: Sendable {
    public private(set) var items: [InboxItem] = []
    public static let maxSize = 50
    public init() {}

    public var unreadCount: Int { items.filter { !$0.read }.count }
    public var toasts: [InboxItem] { items.filter(\.isToast) }

    /// Returns the new item's id, or nil if a notification with the same sourceKey already exists.
    @discardableResult
    public mutating func add(title: String, message: String, sourceKey: String? = nil, showToast: Bool = true, now: Date = Date(), id: Int? = nil) -> Int? {
        if let k = sourceKey, items.contains(where: { $0.sourceKey == k }) { return nil }
        let newID = id ?? Int(now.timeIntervalSince1970 * 1000) + items.count
        items.insert(InboxItem(id: newID, title: title, message: message, timestamp: now, sourceKey: sourceKey, isToast: showToast), at: 0)
        if items.count > Self.maxSize { items.removeLast() }
        return newID
    }
    public mutating func dismiss(_ id: Int) { items.removeAll { $0.id == id } }
    public mutating func expireToast(_ id: Int) { if let i = items.firstIndex(where: { $0.id == id }) { items[i].isToast = false } }
    public mutating func markAllRead() { for i in items.indices { items[i].read = true } }
    public mutating func clearAll() { items.removeAll() }

    public static func timeLabel(_ date: Date, now: Date = Date()) -> String {
        let d = now.timeIntervalSince(date)
        if d < 60 { return "Just now" }
        if d < 3600 { return "\(Int(d / 60))m ago" }
        if d < 86_400 { return "\(Int(d / 3600))h ago" }
        return "\(Int(d / 86_400))d ago"
    }
}

public struct AdminNotification: Hashable, Sendable {
    public let id: String, title: String, body: String
    public let targetUserId: String?
    public let sentAt: Date?
}

/// Port of `NotificationPoller` selection rules (https://mnemonics-notifications-production.up.railway.app).
public enum AdminNotificationFeed {
    public static let baseURL = URL(string: "https://mnemonics-notifications-production.up.railway.app")!
    public static let firstLaunchGrace: TimeInterval = 45

    public static func fetch(session: URLSession = .shared) async throws -> [AdminNotification] {
        var c = URLComponents(url: baseURL.appendingPathComponent("api/notifications"), resolvingAgainstBaseURL: false)!
        c.queryItems = [.init(name: "status", value: "sent"), .init(name: "limit", value: "30")]
        var req = URLRequest(url: c.url!); req.timeoutInterval = 8
        let (data, resp) = try await session.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200,
              let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let raw = obj["notifications"] as? [[String: Any]] else { return [] }
        return raw.compactMap { r in
            guard let id = r["id"] as? String else { return nil }
            let date = ((r["sentAt"] as? String) ?? (r["createdAt"] as? String)).flatMap(DateCoding.date)
            return AdminNotification(id: id, title: r["title"] as? String ?? "Notification", body: r["body"] as? String ?? "",
                                     targetUserId: r["targetUserId"] as? String, sentAt: date)
        }
    }

    /// Returns (fresh items to show, updated seen set). On a first launch, anything older than the grace window is pre-marked seen.
    public static func select(items: [AdminNotification], seen: Set<String>, userId: String?, now: Date = Date()) -> (fresh: [AdminNotification], seen: Set<String>) {
        var seen = seen
        if seen.isEmpty {
            let cutoff = now.addingTimeInterval(-firstLaunchGrace)
            for i in items { if let s = i.sentAt, s < cutoff { seen.insert(i.id) } }
        }
        var fresh: [AdminNotification] = []
        for i in items.reversed() {
            if seen.contains(i.id) { continue }
            if let t = i.targetUserId, !t.isEmpty, let u = userId, t != u { seen.insert(i.id); continue }
            fresh.append(i)
        }
        for i in fresh { seen.insert(i.id) }
        return (fresh, seen)
    }

    public static func registerDevice(token: String, userId: String?, session: URLSession = .shared) async {
        var req = URLRequest(url: baseURL.appendingPathComponent("api/devices/register"))
        req.httpMethod = "POST"; req.timeoutInterval = 8
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = ["token": token, "platform": "ios"]
        if let userId { body["userId"] = userId }
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await session.data(for: req)
    }
}
