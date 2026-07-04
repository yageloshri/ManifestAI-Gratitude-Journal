// StreakFreezeManager.swift
// Streak-protection ("streak freeze") mechanics — retention-plan.md §3.6.
//
// Grants 1 free grace day per rolling 30 days (2 for Pro subscribers,
// mirroring the Duolingo finding that doubling available freezes measurably
// lifts DAU). A missed day consumes an available freeze instead of hard-
// resetting progress to zero.
//
// Two independent freeze economies live behind this one type:
//   - The 369 ritual cycle (`Ritual369Manager`) *persists* freeze-consumption
//     dates here via `consumeFreezeIfAvailable` — a missed day is a
//     discrete, one-time event that needs to be recorded permanently so the
//     rolling 30-day budget is enforced across app launches.
//   - The journal streak has no equivalent persisted "miss" event — it's
//     computed live from `JournalEntry` dates every render (in MainTabView,
//     which this pass doesn't own). `effectiveJournalStreak` is a *pure*
//     function that re-derives which gap days would be freeze-eligible
//     directly from the entry dates, with its own independent rolling
//     30-day budget — nothing is persisted for it.

import Foundation

final class StreakFreezeManager {
    static let shared = StreakFreezeManager()

    private static let usedDatesKey = "streakFreeze369_usedDates"

    private init() {}

    /// 1 free grace day per rolling 30 days; Pro doubles it.
    var maxFreezes: Int {
        SubscriptionManager.shared.isPro ? 2 : 1
    }

    // MARK: - 369 ritual cycle (persisted consumption)

    private func loadUsedDates() -> [Date] {
        (UserDefaults.standard.array(forKey: Self.usedDatesKey) as? [TimeInterval] ?? [])
            .map { Date(timeIntervalSince1970: $0) }
    }

    private func saveUsedDates(_ dates: [Date]) {
        UserDefaults.standard.set(dates.map { $0.timeIntervalSince1970 }, forKey: Self.usedDatesKey)
    }

    /// Grace days left in the current rolling 30-day window. Safe to surface
    /// next to the existing streak display in Settings/Profile.
    func availableFreezes(now: Date = Date()) -> Int {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: now) else {
            return maxFreezes
        }
        let usedInWindow = loadUsedDates().filter { $0 > cutoff }.count
        return max(0, maxFreezes - usedInWindow)
    }

    /// Consumes one grace day if the rolling budget allows it. Returns
    /// whether a freeze was actually applied — callers (Ritual369Manager)
    /// fall back to their normal reset behavior when this returns false.
    @discardableResult
    func consumeFreezeIfAvailable(now: Date = Date()) -> Bool {
        guard availableFreezes(now: now) > 0 else { return false }
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        var dates = loadUsedDates().filter { $0 > cutoff }
        dates.append(now)
        saveUsedDates(dates)
        dlog("🧊 StreakFreezeManager: grace day consumed (\(availableFreezes(now: now)) left this 30-day window)")
        return true
    }

    // MARK: - Journal streak (pure, derived — see file header)

    /// Same consecutive-day walk as the plain `streak` computed property in
    /// MainTabView, but a single missed day is bridged — the chain doesn't
    /// break, though the frozen day itself doesn't add to the count — as
    /// long as the rolling 30-day grace budget isn't exhausted. Two missed
    /// days in a row are never protected (mirrors the 369 cycle's "1 day"
    /// grace granularity).
    ///
    /// One-line swap for MainTabView's `streak` computed property:
    ///   StreakFreezeManager.shared.effectiveJournalStreak(entryDays: Set(entries.map { $0.date }))
    func effectiveJournalStreak(entryDays: Set<Date>, now: Date = Date()) -> Int {
        let cal = Calendar.current
        let days = Set(entryDays.map { cal.startOfDay(for: $0) })
        var day = cal.startOfDay(for: now)

        // Today not written yet isn't a "miss" — its window hasn't closed.
        // Judge the streak starting from yesterday, exactly like the
        // unprotected walk.
        if !days.contains(day) {
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = prev
        }

        var count = 0
        var freezesUsed: [Date] = []
        var justFroze = false

        while true {
            if days.contains(day) {
                count += 1
                justFroze = false
            } else if !justFroze, canUseJournalFreeze(on: day, alreadyUsed: freezesUsed) {
                freezesUsed.append(day)
                justFroze = true
            } else {
                break
            }
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return count
    }

    private func canUseJournalFreeze(on date: Date, alreadyUsed: [Date]) -> Bool {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: date) else { return false }
        let usedInWindow = alreadyUsed.filter { $0 > cutoff }.count
        return usedInWindow < maxFreezes
    }

    #if DEBUG
    func debugReset() {
        UserDefaults.standard.removeObject(forKey: Self.usedDatesKey)
    }
    #endif
}
