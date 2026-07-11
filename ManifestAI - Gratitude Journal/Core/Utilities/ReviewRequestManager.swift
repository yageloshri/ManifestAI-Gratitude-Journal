import StoreKit
import UIKit

/// Asks for the native App Store rating prompt (`SKStoreReviewController` /
/// `AppStore.requestReview`) at genuine positive "wow" moments — a finished
/// Elevate, a completed 369 ritual, a saved vision board, a streak milestone.
///
/// The system prompt is the only App Store-compliant way to ask (no custom
/// "rate us" alert that deep-links to the store before a positive signal).
/// Apple already throttles it to ~3 times per 365 days and may silently show
/// nothing; we gate more conservatively on top so it only ever fires when the
/// user is most likely delighted.
///
/// Not actor-isolated so any completion handler can record a moment; the
/// actual prompt is always dispatched onto the main queue before touching
/// UIKit / StoreKit.
enum ReviewRequestManager {
    private static let defaults = UserDefaults.standard

    private enum Key {
        static let installDate = "review_installDate"
        static let lastPromptDate = "review_lastPromptDate"
        static let lastPromptVersion = "review_lastPromptVersion"
        static let promptCount = "review_promptCount"
        static let wowCount = "review_wowCount"
    }

    // Gating knobs.
    private static let minWowMomentsBeforeFirstPrompt = 2
    private static let minDaysSinceInstall: Double = 2
    private static let minDaysBetweenPrompts: Double = 120

    /// Call once early in app launch so "days since install" is anchored.
    static func recordLaunch() {
        if defaults.object(forKey: Key.installDate) == nil {
            defaults.set(Date(), forKey: Key.installDate)
        }
    }

    /// Register a genuine positive completion moment. Records it and, when the
    /// gates allow, asks for the rating a beat later so the prompt lands after
    /// the celebratory UI has settled rather than on top of it.
    static func registerWowMoment(_ moment: String) {
        let wowCount = defaults.integer(forKey: Key.wowCount) + 1
        defaults.set(wowCount, forKey: Key.wowCount)
        dlog("Review: wow moment '\(moment)' (#\(wowCount))")

        guard shouldRequest(wowCount: wowCount) else { return }

        // Let the celebratory UI settle, then ask on the main actor.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            request()
        }
    }

    private static func shouldRequest(wowCount: Int) -> Bool {
        guard wowCount >= minWowMomentsBeforeFirstPrompt else { return false }

        let install = defaults.object(forKey: Key.installDate) as? Date ?? Date()
        guard Date().timeIntervalSince(install) >= minDaysSinceInstall * 86_400 else { return false }

        // Never twice on the same build (Apple ties its cap to the version).
        if defaults.string(forKey: Key.lastPromptVersion) == appVersion { return false }

        if let last = defaults.object(forKey: Key.lastPromptDate) as? Date,
           Date().timeIntervalSince(last) < minDaysBetweenPrompts * 86_400 { return false }

        return true
    }

    @MainActor
    private static func request() {
        guard let scene = activeScene else { return }
        if #available(iOS 16.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
        defaults.set(Date(), forKey: Key.lastPromptDate)
        defaults.set(appVersion, forKey: Key.lastPromptVersion)
        defaults.set(defaults.integer(forKey: Key.promptCount) + 1, forKey: Key.promptCount)
        dlog("Review: presented native rating prompt")
    }

    @MainActor
    private static var activeScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
