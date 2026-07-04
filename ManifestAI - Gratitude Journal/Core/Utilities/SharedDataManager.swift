import Foundation
import SwiftUI

class SharedDataManager {
    static let shared = SharedDataManager()
    
    // MARK: - CONFIGURATION
    // ⚠️ CRITICAL: Must match the App Group ID created in Xcode -> Signing & Capabilities
    let appGroupId = "group.com.manifestai.journal"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    // MARK: - KEYS
    private let keyAffirmation = "dailyAffirmation"
    private let keyNumerologyNumber = "dailyNumerologyNumber"
    private let keyNumerologyTitle = "dailyNumerologyTitle"

    // Added for retention plan 3.8/3.9/3.11 (Lock Screen widget, App Intents,
    // Live Activity) — see docs/retention-plan.md.
    private let keyStreakCount = "sharedStreakCount"
    private let keyRitualPhaseName = "sharedRitualPhaseName"
    private let keyRitualWritten = "sharedRitualLinesWritten"
    private let keyRitualTarget = "sharedRitualLinesTarget"
    /// Consumed once by MainTabView on `scenePhase == .active`. Written by:
    /// widget's "Start Ritual" button (StartRitualWidgetIntent), the
    /// `manifestai://` widgetURL open handler, and the Siri/Shortcuts App
    /// Intents (Start369RitualIntent, LogGratitudeIntent). Values in use:
    /// "ritual" (open 369 tab, jump into the active writing phase) and
    /// "journal_write" (open Journal tab, straight to the write screen).
    private let keyPendingDeepLink = "pending_deep_link"

    // MARK: - WRITERS (Called by Main App)
    func saveDailyData(affirmation: String, numerologyNumber: Int, numerologyTitle: String) {
        userDefaults?.set(affirmation, forKey: keyAffirmation)
        userDefaults?.set(numerologyNumber, forKey: keyNumerologyNumber)
        userDefaults?.set(numerologyTitle, forKey: keyNumerologyTitle)

        // Debug
        dlog("💾 SharedDataManager: Saved data to \(appGroupId)")
    }

    /// Current streak (consecutive days), for the Lock Screen/StandBy widget.
    /// Call site: MainTabView, alongside its existing `streak` computed
    /// property (see report for the exact one-liner).
    func saveStreak(_ streak: Int) {
        userDefaults?.set(streak, forKey: keyStreakCount)
    }

    /// Today's 369 ritual progress, for the widget and as a fallback source
    /// of truth if a Live Activity isn't running. Call site:
    /// `Ritual369Manager.record(_:now:)`.
    func saveRitualProgress(phaseName: String, written: Int, target: Int) {
        userDefaults?.set(phaseName, forKey: keyRitualPhaseName)
        userDefaults?.set(written, forKey: keyRitualWritten)
        userDefaults?.set(target, forKey: keyRitualTarget)
    }

    /// Sets the flag the app reads on next foreground to route the user
    /// somewhere specific (widget tap, widget button, or a Siri/Shortcuts
    /// App Intent). See `keyPendingDeepLink` above for accepted values.
    func setPendingDeepLink(_ destination: String) {
        userDefaults?.set(destination, forKey: keyPendingDeepLink)
    }

    // MARK: - READERS (Called by Widget)
    func getDailyAffirmation() -> String {
        return userDefaults?.string(forKey: keyAffirmation) ?? "I am aligned with my highest self."
    }

    func getDailyNumerology() -> (number: Int, title: String) {
        let number = userDefaults?.integer(forKey: keyNumerologyNumber) ?? 0
        let title = userDefaults?.string(forKey: keyNumerologyTitle) ?? "Manifestation"

        // If 0 (not set), return defaults
        if number == 0 {
            return (1, "New Beginnings")
        }

        return (number, title)
    }

    func getStreak() -> Int {
        return userDefaults?.integer(forKey: keyStreakCount) ?? 0
    }

    func getRitualProgress() -> (phaseName: String, written: Int, target: Int) {
        let phaseName = userDefaults?.string(forKey: keyRitualPhaseName) ?? "Morning"
        let written = userDefaults?.integer(forKey: keyRitualWritten) ?? 0
        let target = userDefaults?.integer(forKey: keyRitualTarget) ?? 3
        return (phaseName, written, target)
    }

    // MARK: - READERS (Called by Main App)

    /// Reads and clears the pending deep link in one step — call exactly
    /// once per foreground so a stale value can't re-trigger navigation.
    func consumePendingDeepLink() -> String? {
        guard let value = userDefaults?.string(forKey: keyPendingDeepLink) else { return nil }
        userDefaults?.removeObject(forKey: keyPendingDeepLink)
        return value
    }
}

