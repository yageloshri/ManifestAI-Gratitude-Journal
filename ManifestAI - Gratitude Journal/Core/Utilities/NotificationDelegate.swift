/// NotificationDelegate.swift
/// UNUserNotificationCenterDelegate — handles the 369 notification's
/// actionable buttons (retention-plan.md §3.2) and lets banners show while
/// the app is foregrounded. Also centralizes the `Notification.Name`
/// constants the retention mechanics post across the app.

import Foundation
import UserNotifications

extension Notification.Name {
    /// Posted when the user taps "Write Now" on a 369 notification, or taps
    /// the notification banner itself. The tab host isn't owned by this pass
    /// (another engineer is mid-edit on MainTabView) — wire it up with:
    ///
    ///   .onReceive(NotificationCenter.default.publisher(for: .openRitualRequested)) { _ in
    ///       switchTab(.method369)
    ///   }
    static let openRitualRequested = Notification.Name("com.manifestai.openRitualRequested")

    /// Posted exactly once, the first time the user completes *any* 369
    /// phase OR saves their first journal entry. Primes the contextual full
    /// notification-permission pre-prompt (§3.4, handled in ManifestAIApp).
    static let firstMeaningfulActionCompleted = Notification.Name("com.manifestai.firstMeaningfulActionCompleted")
}

/// Fires `.firstMeaningfulActionCompleted` exactly once across the app's
/// lifetime — the 369 ritual path already calls this from
/// `Ritual369Manager.record(_:)`. The journal path needs one line wired in
/// wherever a `JournalEntry` is first saved (see MainTabView's journal save
/// flow — not edited here, another engineer owns that file):
///
///   FirstMeaningfulAction.markCompletedIfNeeded()
enum FirstMeaningfulAction {
    private static let key = "has_completed_first_meaningful_action"

    static func markCompletedIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        dlog("🎉 FirstMeaningfulAction: first ritual phase / journal entry completed")
        NotificationCenter.default.post(name: .firstMeaningfulActionCompleted, object: nil)
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    /// Let banners/sound/badge show even while the app is in the foreground
    /// — otherwise a delivered notification would be silently swallowed.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    /// Handles the WRITE_NOW / SNOOZE_1H actions (§3.2) and the default tap.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier

        switch response.actionIdentifier {
        case "WRITE_NOW", UNNotificationDefaultActionIdentifier:
            dlog("🔔 NotificationDelegate: opening ritual from \(identifier)")
            NotificationCenter.default.post(name: .openRitualRequested, object: nil)

        case "SNOOZE_1H":
            dlog("🔔 NotificationDelegate: snoozing \(identifier) by 1 hour")
            NotificationManager369.shared.snoozeNotification(identifier: identifier)

        default:
            break
        }

        completionHandler()
    }
}
