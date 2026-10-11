import Foundation
import Observation
import UserNotifications
import MnemonicsCore
#if canImport(FirebaseMessaging)
import FirebaseMessaging
import FirebaseCore
#endif
#if canImport(UIKit)
import UIKit
#endif

/// In-app inbox + admin-notification poller + FCM registration
/// (ports NotificationManager, NotificationPoller, NotificationService, LocalNotifications).
@Observable @MainActor
final class NotificationHub: NSObject {
    static let shared = NotificationHub()
    private(set) var inbox = NotificationInbox()
    private var seen = Set<String>()
    private var timer: Task<Void, Never>?
    private var userId: String?

    private let seenURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("seen_admin_notifications.json")
    }()

    // MARK: Inbox

    func show(title: String, message: String, sourceKey: String? = nil, toast: Bool = true) {
        guard let id = inbox.add(title: title, message: message, sourceKey: sourceKey, showToast: toast) else { return }
        if toast { Task { try? await Task.sleep(nanoseconds: 5_000_000_000); inbox.expireToast(id) } }
    }
    func dismiss(_ id: Int) { inbox.dismiss(id) }
    func markAllRead() { inbox.markAllRead() }
    func clearAll() { inbox.clearAll() }

    // MARK: Lifecycle

    func start(userId: String?) async {
        self.userId = userId
        UNUserNotificationCenter.current().delegate = self
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        #if canImport(UIKit)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
        #if canImport(FirebaseMessaging)
        if FirebaseApp.app() != nil {
            Messaging.messaging().delegate = self
            try? await Messaging.messaging().subscribe(toTopic: "all_users")
        }
        #endif
        loadSeen()
        await poll()
        timer?.cancel()
        timer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await self?.poll()
            }
        }
    }
    func stop() { timer?.cancel(); timer = nil }

    func markSeen(_ id: String) { if seen.insert(id).inserted { saveSeen() } }

    func poll() async {
        guard let items = try? await AdminNotificationFeed.fetch() else { return }
        let r = AdminNotificationFeed.select(items: items, seen: seen, userId: userId)
        seen = r.seen
        for n in r.fresh {
            show(title: n.title, message: n.body, sourceKey: n.id, toast: false)
            await postLocal(title: n.title, body: n.body, id: n.id)
        }
        saveSeen()
    }

    func postLocal(title: String, body: String, id: String? = nil) async {
        let c = UNMutableNotificationContent(); c.title = title; c.body = body; c.sound = .default
        let req = UNNotificationRequest(identifier: id ?? UUID().uuidString, content: c, trigger: nil)
        try? await UNUserNotificationCenter.current().add(req)
    }

    func registerToken(_ token: String) async { await AdminNotificationFeed.registerDevice(token: token, userId: userId) }

    func fcmToken() async -> String? {
        #if canImport(FirebaseMessaging)
        return try? await Messaging.messaging().token()
        #else
        return nil
        #endif
    }

    // MARK: seen persistence (capped at 200, as Flutter)

    private func loadSeen() {
        guard seen.isEmpty, let d = try? Data(contentsOf: seenURL), let ids = try? JSONDecoder().decode([String].self, from: d) else { return }
        seen = Set(ids)
    }
    private func saveSeen() {
        var ids = Array(seen); if ids.count > 200 { ids = Array(ids.suffix(200)); seen = Set(ids) }
        if let d = try? JSONEncoder().encode(ids) { try? d.write(to: seenURL, options: .atomic) }
    }
}

extension NotificationHub: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let c = notification.request.content
        let id = c.userInfo["notification_id"] as? String
        await MainActor.run {
            if let id { self.markSeen(id) }
            if !c.title.isEmpty || !c.body.isEmpty { self.show(title: c.title, message: c.body, sourceKey: id, toast: false) }
        }
        return [.banner, .sound, .badge, .list]
    }
}

#if canImport(FirebaseMessaging)
extension NotificationHub: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task { @MainActor in await self.registerToken(fcmToken) }
    }
}
#endif

#if canImport(UIKit)
/// Hands the APNs token to Firebase Messaging (the Flutter plugin does this automatically).
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        if FirebaseApp.app() != nil { Messaging.messaging().apnsToken = deviceToken }
        #endif
    }
}
#endif
