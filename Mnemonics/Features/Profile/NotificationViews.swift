import SwiftUI
import MnemonicsCore

/// Port of NotificationBellButton: badge + inbox sheet.
struct NotificationBellButton: View {
    private var hub: NotificationHub { .shared }
    @State private var open = false

    var body: some View {
        Button { hub.markAllRead(); open = true } label: {
            Image(systemName: hub.inbox.unreadCount > 0 ? "bell.fill" : "bell")
                .overlay(alignment: .topTrailing) {
                    if hub.inbox.unreadCount > 0 {
                        Text(hub.inbox.unreadCount > 99 ? "99+" : "\(hub.inbox.unreadCount)").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 4).background(Color.red, in: Capsule()).offset(x: 8, y: -6)
                    }
                }
        }
        .accessibilityLabel("Notifications")
        .sheet(isPresented: $open) { InboxSheet() }
    }
}

struct InboxSheet: View {
    @Environment(\.dismiss) private var dismiss
    private var hub: NotificationHub { .shared }
    var body: some View {
        NavigationStack {
            Group {
                if hub.inbox.items.isEmpty {
                    VStack(spacing: MSpace.s) { Image(systemName: "bell").font(.system(size: 44)).foregroundStyle(MColor.textSecondary); Text("No notifications yet") }
                        .foregroundStyle(MColor.textSecondary).frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(hub.inbox.items) { item in
                            HStack(alignment: .top, spacing: MSpace.m) {
                                Image(systemName: "bell.fill").foregroundStyle(MColor.primaryGreen)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title).font(MFont.bodyLarge.weight(.semibold))
                                    Text("\(item.message)\n\(NotificationInbox.timeLabel(item.timestamp))").font(MFont.small).foregroundStyle(MColor.textSecondary)
                                }
                                Spacer()
                                Button { hub.dismiss(item.id) } label: { Image(systemName: "xmark") }.buttonStyle(.plain).accessibilityLabel("Dismiss")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications").navigationBarTitleDisplayModeIfAvailable()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Clear all") { hub.clearAll() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }.presentationDetents([.medium, .large])
    }
}

/// Port of NotificationDisplay: toast banners over the app.
struct NotificationToastOverlay: View {
    private var hub: NotificationHub { .shared }
    var body: some View {
        VStack(spacing: 0) {
            ForEach(hub.inbox.toasts) { t in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(t.title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        Text(t.message).font(.system(size: 14)).foregroundStyle(.white)
                    }
                    Spacer()
                    Button { hub.dismiss(t.id) } label: { Image(systemName: "xmark").foregroundStyle(.white) }
                }
                .padding(12).background(Color.blue, in: RoundedRectangle(cornerRadius: 8)).shadow(color: .black.opacity(0.1), radius: 4, y: 2).padding(8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }.animation(.easeInOut, value: hub.inbox.toasts.count).allowsHitTesting(!hub.inbox.toasts.isEmpty)
    }
}

/// Port of test_notification_screen.dart.
struct TestNotificationView: View {
    @Environment(AppModel.self) private var model
    @State private var token: String?
    var body: some View {
        VStack(spacing: MSpace.l) {
            Button("Send Test Notification") {
                NotificationHub.shared.show(title: "Test Notification", message: "This is a test notification message")
                model.showToast("Test notification sent")
            }.buttonStyle(PrimaryButtonStyle())
            Button("Get FCM Token") { Task {
                token = await NotificationHub.shared.fcmToken()
                model.showToast(token.map { "FCM Token: \($0)" } ?? "Unable to get FCM token", isError: token == nil)
            } }.buttonStyle(PrimaryButtonStyle(color: MColor.secondaryOrange))
            if let token { Text(token).font(.system(size: 11, design: .monospaced)).textSelection(.enabled).padding() }
            Spacer()
        }.padding(MSpace.l).mScreenBackground()
        .navigationTitle("Test Notifications").navigationBarTitleDisplayModeIfAvailable()
    }
}
