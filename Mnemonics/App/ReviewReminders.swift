import Foundation
import UserNotifications
import MnemonicsCore

/// Local notifications so words come back "after a certain time".
/// One notification per day that has words due, at 9:00 (or at the due time if later today).
struct ReviewReminders {
    private let center = UNUserNotificationCenter.current()
    private static let prefix = "review-due-"

    func requestAuthorizationIfNeeded() async {
        let s = await center.notificationSettings()
        if s.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    func reschedule(for items: [UserWordData], now: Date = Date()) async {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(Self.prefix) })

        let cal = Calendar.current
        // Bucket by day; anything already overdue is bucketed into "tomorrow 9:00" unless due later today.
        var buckets: [Date: [String]] = [:]
        for item in items {
            guard let due = item.nextReview else { continue }
            let day = cal.startOfDay(for: max(due, now))
            buckets[day, default: []].append(item.word)
        }
        for (day, words) in buckets.sorted(by: { $0.key < $1.key }).prefix(30) {
            var fire = cal.date(bySettingHour: 9, minute: 0, second: 0, of: day) ?? day
            if fire <= now { fire = now.addingTimeInterval(60 * 60) }
            let content = UNMutableNotificationContent()
            content.title = "Time to review"
            content.body = words.count == 1
                ? "“\(words[0])” is ready for review."
                : "\(words.count) words are ready for review, including “\(words[0])”."
            content.sound = .default
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let id = Self.prefix + String(Int(day.timeIntervalSince1970))
            try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }
}
