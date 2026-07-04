/// NotificationManager369.swift
/// Manages local notifications for the 369 Manifestation Method.
/// Schedules morning/afternoon/evening writing-session reminders and the
/// "streak at risk" nudge — see docs/retention-plan.md §3.1–3.3, §3.7.
///
/// 3.5: each of the 3 windows can be independently enabled — there is no
/// more single all-or-nothing switch. `setNotificationsEnabled(_:)` remains
/// as a master convenience (used by the existing Profile toggle + logout)
/// that flips all three at once and keeps "daily_reminders_on" in sync as a
/// derived flag for backward compatibility.

import Foundation
import UserNotifications

class NotificationManager369 {
    static let shared = NotificationManager369()

    /// One of the 3 daily writing windows. Kept private — callers use the
    /// named wrapper methods below (`isMorningEnabled()`, `setMorningTime`, …)
    /// so this internal modeling can change without touching call sites.
    private enum Window: CaseIterable {
        case morning, afternoon, evening

        var identifier: String {
            switch self {
            case .morning: return "com.manifestai.369.morning"
            case .afternoon: return "com.manifestai.369.afternoon"
            case .evening: return "com.manifestai.369.evening"
            }
        }

        var enabledKey: String {
            switch self {
            case .morning: return "manifestation369_morning_enabled"
            case .afternoon: return "manifestation369_afternoon_enabled"
            case .evening: return "manifestation369_evening_enabled"
            }
        }

        var timeKey: String {
            switch self {
            case .morning: return "manifestation369_morning_time"
            case .afternoon: return "manifestation369_afternoon_time"
            case .evening: return "manifestation369_evening_time"
            }
        }

        var defaultTime: DateComponents {
            switch self {
            case .morning: return DateComponents(hour: 8, minute: 0)
            case .afternoon: return DateComponents(hour: 14, minute: 0)
            case .evening: return DateComponents(hour: 20, minute: 0)
            }
        }

        var title: String {
            switch self {
            case .morning: return "Morning Ritual"
            case .afternoon: return "Afternoon Ritual"
            case .evening: return "Evening Ritual"
            }
        }

        /// 3.1 copy bank — mystical-warm voice, {name}/{day_number}
        /// interpolated at schedule time. Rotated by day-of-year so
        /// consecutive days never repeat the same line.
        var copyBank: [String] {
            switch self {
            case .morning:
                return [
                    "☀️ Good morning, {name}. Day {day_number} is calling — write your 3 lines and set the tone.",
                    "🌅 {name}, the universe is listening at sunrise. Your 3 morning lines are waiting.",
                    "✨ Rise and manifest, {name}. Three lines, one intention — Day {day_number} begins now."
                ]
            case .afternoon:
                return [
                    "🌤 {name}, your 6 lines are calling. Keep Day {day_number}'s momentum alive.",
                    "🔆 Midday check-in, {name} — 6 affirmations stand between you and today's manifestation.",
                    "💫 Don't let the day drift, {name}. Your 6 lines are ready when you are."
                ]
            case .evening:
                return [
                    "🌙 {name}, close Day {day_number} with your 9 lines. You're almost home.",
                    "✨ The stars are out, {name} — finish strong with tonight's 9 affirmations.",
                    "🌌 One ritual left today, {name}. Write your 9 lines and let Day {day_number} rest easy.",
                    "🕯 {name}, your evening ritual is waiting. Nine lines, then peace."
                ]
            }
        }
    }

    // Legacy master keys, kept for backward compatibility with existing
    // callers (Profile toggle, logout, dead ProfileView/Manifest369ViewModel).
    private let notificationsEnabledKey = "manifestation369_notifications_enabled"
    private let masterDerivedKey = "daily_reminders_on"
    private let streakRiskIdentifier = "com.manifestai.369.streakRisk"
    static let categoryIdentifier = "MANIFESTATION_369"

    private init() {}

    // MARK: - Permission

    /// Full, user-visible authorization request. Used both by the legacy
    /// per-toggle call sites and the 3.4 contextual pre-prompt flow.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error { dlog("⚠️ NotificationManager369: full authorization error: \(error)") }
                if granted {
                    self.setNotificationsEnabled(true)
                }
                completion(granted)
            }
        }
    }

    /// Quiet, no-dialog authorization (3.4) — requested once at launch while
    /// status is still `.notDetermined`. Provisional notifications deliver
    /// straight to Notification Center with no banner/sound until the user
    /// upgrades via the contextual full prompt.
    func requestProvisionalPermissionIfNeeded(completion: @escaping (Bool) -> Void = { _ in }) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else {
                let alreadyOn = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                DispatchQueue.main.async { completion(alreadyOn) }
                return
            }
            center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
                DispatchQueue.main.async {
                    if let error = error { dlog("⚠️ NotificationManager369: provisional authorization error: \(error)") }
                    if granted {
                        dlog("✅ NotificationManager369: provisional authorization granted (quiet delivery)")
                        self.setNotificationsEnabled(true)
                    }
                    completion(granted)
                }
            }
        }
    }

    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }

    // MARK: - Categories & actions (3.2)

    /// Registers the "Write Now" / "Snooze 1h" actions. Call once, at app
    /// launch (`ManifestAIApp.init`) — safe to call more than once.
    func registerNotificationCategories() {
        let writeNow = UNNotificationAction(identifier: "WRITE_NOW", title: "Write Now",
                                            options: [.foreground])
        let snooze = UNNotificationAction(identifier: "SNOOZE_1H", title: "Remind Me in 1 Hour",
                                           options: [])
        let category = UNNotificationCategory(identifier: Self.categoryIdentifier,
                                               actions: [writeNow, snooze],
                                               intentIdentifiers: [],
                                               options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    /// SNOOZE_1H handler: re-delivers the same window's copy ~1 hour from
    /// now, one-shot (does not touch the recurring daily schedule).
    func snoozeNotification(identifier: String) {
        guard let window = Window.allCases.first(where: { $0.identifier == identifier }) else {
            dlog("⚠️ NotificationManager369: snooze requested for unknown identifier \(identifier)")
            return
        }
        let request = UNNotificationRequest(
            identifier: identifier + ".snoozed",
            content: content(for: window),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { dlog("⚠️ NotificationManager369: error snoozing \(identifier): \(error)") }
        }
    }

    // MARK: - Enable/Disable (master — all 3 windows at once)

    func setNotificationsEnabled(_ enabled: Bool) {
        Window.allCases.forEach { UserDefaults.standard.set(enabled, forKey: $0.enabledKey) }
        syncMasterFlags()
        if enabled {
            scheduleAllNotifications()
        } else {
            cancelAllNotifications()
            cancelStreakAtRiskNotification()
        }
    }

    func areNotificationsEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }

    // MARK: - Enable/Disable (3.5 — per-window)

    func isMorningEnabled() -> Bool { isEnabled(.morning) }
    func isAfternoonEnabled() -> Bool { isEnabled(.afternoon) }
    func isEveningEnabled() -> Bool { isEnabled(.evening) }

    func setMorningEnabled(_ enabled: Bool) { setEnabled(enabled, for: .morning) }
    func setAfternoonEnabled(_ enabled: Bool) { setEnabled(enabled, for: .afternoon) }
    func setEveningEnabled(_ enabled: Bool) { setEnabled(enabled, for: .evening) }

    private func isEnabled(_ window: Window) -> Bool {
        UserDefaults.standard.bool(forKey: window.enabledKey)
    }

    private func setEnabled(_ enabled: Bool, for window: Window) {
        UserDefaults.standard.set(enabled, forKey: window.enabledKey)
        if enabled {
            schedule(window)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [window.identifier])
        }
        syncMasterFlags()
    }

    /// Keeps the legacy master flags truthful: "on" if *any* window is on,
    /// so old readers (Profile's single switch, if ever re-shown) still see
    /// a sane value instead of going stale.
    private func syncMasterFlags() {
        let anyEnabled = Window.allCases.contains { isEnabled($0) }
        UserDefaults.standard.set(anyEnabled, forKey: notificationsEnabledKey)
        UserDefaults.standard.set(anyEnabled, forKey: masterDerivedKey)
    }

    private func anyWindowEnabled() -> Bool {
        Window.allCases.contains { isEnabled($0) }
    }

    // MARK: - Time Management

    func setMorningTime(hour: Int, minute: Int) { setTime(hour: hour, minute: minute, for: .morning) }
    func setAfternoonTime(hour: Int, minute: Int) { setTime(hour: hour, minute: minute, for: .afternoon) }
    func setEveningTime(hour: Int, minute: Int) { setTime(hour: hour, minute: minute, for: .evening) }

    func getMorningTime() -> DateComponents { getTime(for: .morning) }
    func getAfternoonTime() -> DateComponents { getTime(for: .afternoon) }
    func getEveningTime() -> DateComponents { getTime(for: .evening) }

    private func setTime(hour: Int, minute: Int, for window: Window) {
        UserDefaults.standard.set(["hour": hour, "minute": minute], forKey: window.timeKey)
        if isEnabled(window) { schedule(window) }
    }

    private func getTime(for window: Window) -> DateComponents {
        if let dict = UserDefaults.standard.dictionary(forKey: window.timeKey),
           let hour = dict["hour"] as? Int,
           let minute = dict["minute"] as? Int {
            return DateComponents(hour: hour, minute: minute)
        }
        return window.defaultTime
    }

    // MARK: - Scheduling

    func scheduleAllNotifications() {
        Window.allCases.forEach { window in
            if isEnabled(window) {
                schedule(window)
            } else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [window.identifier])
            }
        }
    }

    /// Called whenever the app becomes active (`ManifestAIApp` scenePhase
    /// hook) — re-schedules today's windows with fresh, rotated, personalized
    /// copy (3.1), refreshes the badge (3.3), and re-evaluates the
    /// streak-at-risk push (3.7).
    func rescheduleForToday() {
        scheduleAllNotifications()
        refreshBadge()
        evaluateStreakAtRiskNotification()
    }

    private func schedule(_ window: Window) {
        let request = UNNotificationRequest(
            identifier: window.identifier,
            content: content(for: window),
            trigger: UNCalendarNotificationTrigger(dateMatching: getTime(for: window), repeats: true)
        )
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [window.identifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                dlog("⚠️ NotificationManager369: error scheduling \(window.title): \(error)")
            }
        }
    }

    /// Builds personalized content for `window`: rotates through its copy
    /// bank by day-of-year, interpolates {name}/{day_number}, and stamps the
    /// real unwritten-window badge count (3.1, 3.3).
    private func content(for window: Window) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let bank = window.copyBank
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let template = bank[dayOfYear % bank.count]

        content.title = window.title
        content.body = interpolate(template)
        content.sound = .default
        content.badge = NSNumber(value: unwrittenWindowCount())
        content.categoryIdentifier = Self.categoryIdentifier
        return content
    }

    private func interpolate(_ template: String) -> String {
        let name = UserManager.shared.userName
        let dayNumber = NumerologyService.shared.calculatePersonalDayNumber(birthDate: UserManager.shared.birthDate)
        return template
            .replacingOccurrences(of: "{name}", with: name)
            .replacingOccurrences(of: "{day_number}", with: String(dayNumber))
    }

    // MARK: - Cancel Specific Phase

    func cancelMorningNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Window.morning.identifier])
    }

    func cancelAfternoonNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Window.afternoon.identifier])
    }

    func cancelEveningNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Window.evening.identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: Window.allCases.map { $0.identifier }
        )
    }

    // MARK: - Badge Management (3.3)

    /// Real, actionable badge: how many of today's 3 windows are still
    /// unwritten (0–3) — evaluated from `Ritual369Manager`'s live state.
    private func unwrittenWindowCount() -> Int {
        Ritual369Manager.Phase.allCases.filter { !Ritual369Manager.shared.isComplete($0) }.count
    }

    /// Sets the app icon badge to the real unwritten-window count. Called on
    /// app foreground and whenever a ritual phase completes.
    func refreshBadge() {
        UNUserNotificationCenter.current().setBadgeCount(unwrittenWindowCount())
    }

    /// Hard-clears the badge to 0 (day fully complete / notifications off).
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Streak-at-risk push (3.7)

    /// Copy bank for the ~21:30 "streak at risk" nudge — only ever sent if
    /// there's a real streak to protect and today isn't done yet.
    private var streakRiskCopyBank: [String] {
        [
            "🔥 {name}, your {streak_count}-day streak is still alive — one ritual left tonight to keep it.",
            "⏳ Don't let Day {streak_count} slip away, {name}. A few lines now and your streak holds."
        ]
    }

    /// Evaluates and (re)schedules or cancels the streak-at-risk push based
    /// on `Ritual369Manager`'s current state. Only fires if the user has kept
    /// at least one reminder window on — respects the "everything
    /// user-toggleable, no spam" App Store compliance note.
    private func evaluateStreakAtRiskNotification() {
        guard anyWindowEnabled() else {
            cancelStreakAtRiskNotification()
            return
        }
        let ritual = Ritual369Manager.shared
        guard ritual.activeStreakCount >= 2, !ritual.isTodayComplete else {
            cancelStreakAtRiskNotification()
            return
        }
        scheduleStreakAtRiskNotification(streakCount: ritual.activeStreakCount)
    }

    private func scheduleStreakAtRiskNotification(streakCount: Int) {
        let content = UNMutableNotificationContent()
        let name = UserManager.shared.userName
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let bank = streakRiskCopyBank
        let template = bank[dayOfYear % bank.count]

        content.title = "🔥 Streak at risk"
        content.body = template
            .replacingOccurrences(of: "{name}", with: name)
            .replacingOccurrences(of: "{streak_count}", with: String(streakCount))
        content.sound = .default
        content.badge = NSNumber(value: unwrittenWindowCount())
        content.categoryIdentifier = Self.categoryIdentifier

        var comps = DateComponents()
        comps.hour = 21
        comps.minute = 30
        let request = UNNotificationRequest(
            identifier: streakRiskIdentifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        )
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [streakRiskIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                dlog("⚠️ NotificationManager369: error scheduling streak-at-risk push: \(error)")
            }
        }
    }

    /// Cancelled the moment today's ritual completes (called from
    /// `Ritual369Manager.record(_:)`) or when reminders are turned off.
    func cancelStreakAtRiskNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [streakRiskIdentifier])
    }
}
