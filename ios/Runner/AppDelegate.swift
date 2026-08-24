import Flutter
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var pendingApnsToken: Data?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    requestNotificationPermissionAndRegister(application)
    return launched
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    UNUserNotificationCenter.current().delegate = self
    UIApplication.shared.registerForRemoteNotifications()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      UIApplication.shared.registerForRemoteNotifications()
      self.applyPendingApnsToken()
    }

    let channel = FlutterMethodChannel(
      name: "mnemonics/local_notifications",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "show":
        self?.showLocalNotification(call.arguments, result: result)
      case "requestPermission":
        self?.requestNotificationPermissionAndRegister(UIApplication.shared) { granted in
          result(granted)
        }
      case "prime":
        self?.applyPendingApnsToken()
        UIApplication.shared.registerForRemoteNotifications()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    pendingApnsToken = deviceToken
    applyPendingApnsToken()
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    let hex = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    NSLog("APNs token registered (%d bytes): %@", deviceToken.count, hex)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("APNs registration failed: %@", error.localizedDescription)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .list, .sound, .badge])
  }

  private func applyPendingApnsToken() {
    guard let token = pendingApnsToken, FirebaseApp.app() != nil else { return }
    Messaging.messaging().apnsToken = token
  }

  private func requestNotificationPermissionAndRegister(
    _ application: UIApplication,
    completion: ((Bool) -> Void)? = nil
  ) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      granted,
      error in
      if let error {
        NSLog("Notification permission error: %@", error.localizedDescription)
      }
      NSLog("Notification permission granted: %@", granted ? "yes" : "no")
      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
        completion?(granted)
      }
    }
  }

  private func showLocalNotification(_ arguments: Any?, result: @escaping FlutterResult) {
    let args = arguments as? [String: Any]
    let content = UNMutableNotificationContent()
    content.title = args?["title"] as? String ?? ""
    content.body = args?["body"] as? String ?? ""
    content.sound = .default
    let identifier = (args?["id"] as? String) ?? UUID().uuidString
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    )

    let deliver = {
      UNUserNotificationCenter.current().add(request) { error in
        if let error {
          result(
            FlutterError(
              code: "show_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        } else {
          result(nil)
        }
      }
    }

    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        deliver()
      default:
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
          granted,
          _ in
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            if granted {
              deliver()
            } else {
              result(
                FlutterError(
                  code: "denied",
                  message: "Notification permission was not granted",
                  details: nil
                )
              )
            }
          }
        }
      }
    }
  }
}
