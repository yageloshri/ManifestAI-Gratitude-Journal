// PushNotificationManager.swift
// Remote push (retention-plan.md §3.10): Firebase Cloud Messaging → APNs.
//
// What this enables once the APNs auth key is uploaded to the Firebase
// console (Project Settings → Cloud Messaging → Apple app configuration):
//   • lapsed-user win-back sends (Day 3/7/14) from Firebase console/Functions
//   • server-triggered "streak freeze about to expire" / "new insight" pushes
//   • time-of-day-optimal sends per user
//
// Topic strategy (no backend required to start): every device subscribes to
// "all_users"; win-back segmentation can start with console campaigns and
// move to Cloud Functions keyed on the last-open time we log to Analytics.

import Foundation
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

final class PushNotificationManager: NSObject, MessagingDelegate {
    static let shared = PushNotificationManager()

    private override init() { super.init() }

    /// Call once at launch, before anything else touches Firebase.
    func configure() {
        // Missing GoogleService-Info.plist (e.g. stripped build) — skip
        // gracefully rather than crash in FirebaseApp.configure().
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            dlog("⚠️ PushNotificationManager: GoogleService-Info.plist missing — remote push disabled")
            return
        }
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        dlog("🔥 PushNotificationManager: Firebase configured")
    }

    /// Registers this launch with APNs. Safe to call on every foreground —
    /// iOS coalesces repeat registrations.
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// Wire-through from the AppDelegate once APNs hands us a device token.
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        dlog("📮 PushNotificationManager: APNs token set")
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        dlog("⚠️ PushNotificationManager: APNs registration failed — \(error.localizedDescription)")
    }

    // MARK: - MessagingDelegate

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        #if DEBUG
        // Full token in DEBUG so it can be pasted into Firebase console's
        // "Send test message" during development.
        dlog("🔥 PushNotificationManager: FCM token \(fcmToken)")
        #else
        dlog("🔥 PushNotificationManager: FCM token \(fcmToken.prefix(12))…")
        #endif
        UserDefaults.standard.set(fcmToken, forKey: "fcm_token")
        // Baseline audience segment for console campaigns / win-back sends.
        // Subscribing requires the APNs token to already be linked — retry
        // until APNs registration (which completes asynchronously after
        // launch) has landed, instead of failing once with FCM error 505.
        subscribeToBaseTopicWhenReady()
    }

    /// Subscribes to "all_users" once Messaging has an APNs token; retries a
    /// few times because APNs registration finishes shortly after launch.
    private func subscribeToBaseTopicWhenReady(attempt: Int = 0) {
        guard attempt < 12 else {
            dlog("⚠️ PushNotificationManager: gave up subscribing to all_users (no APNs token)")
            return
        }
        if Messaging.messaging().apnsToken != nil {
            Messaging.messaging().subscribe(toTopic: "all_users") { error in
                if let error {
                    dlog("⚠️ PushNotificationManager: topic subscribe failed — \(error.localizedDescription)")
                } else {
                    dlog("✅ PushNotificationManager: subscribed to all_users")
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.subscribeToBaseTopicWhenReady(attempt: attempt + 1)
            }
        }
    }
}

/// Minimal UIKit app delegate — SwiftUI needs one only for the APNs
/// registration callbacks, which have no SwiftUI-native equivalent.
final class PushAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        PushNotificationManager.shared.configure()
        // Register with APNs immediately — FCM needs the APNs token linked
        // before any token fetch/topic subscribe, and waiting for the first
        // scenePhase change was too late (FCM error 505 at launch).
        PushNotificationManager.shared.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.shared.didFailToRegisterForRemoteNotifications(error: error)
    }
}
