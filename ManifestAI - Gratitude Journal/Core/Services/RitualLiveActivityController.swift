// RitualLiveActivityController.swift
// Retention plan 3.11 — Lock Screen + Dynamic Island Live Activity for an
// in-progress 369 ritual phase. This is a plain API surface; nothing in the
// app calls it yet. Wire it into Ritual369Manager.record(_:now:) — see the
// exact one-liners documented at the bottom of this file's report entry (and
// duplicated as comments below the call sites that need them).
//
// Requires the app target's Info.plist to set NSSupportsLiveActivities = YES
// (see report for the exact build-setting keys/line numbers — could not be
// added directly without touching a build config another engineer owns).

import ActivityKit
import Foundation

final class RitualLiveActivityController {
    static let shared = RitualLiveActivityController()
    private init() {}

    private var currentActivity: Activity<RitualActivityAttributes>?

    /// Begins a new Live Activity for `phase` ("Morning" / "Afternoon" /
    /// "Evening"), ending any stale one from an earlier phase first. No-ops
    /// (and logs) if the user has disabled Live Activities.
    func start(phase: String, target: Int, written: Int = 0) {
        guard #available(iOS 16.1, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            dlog("⚠️ RitualLiveActivityController: Live Activities disabled by user")
            return
        }

        // Only one ritual phase is ever in progress at a time — replace,
        // don't stack.
        end()

        let attributes = RitualActivityAttributes(phaseName: phase, target: target)
        let state = RitualActivityAttributes.ContentState(linesWritten: written)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            dlog("✨ RitualLiveActivityController: started \(phase) (target \(target))")
        } catch {
            dlog("❌ RitualLiveActivityController: start failed — \(error)")
        }
    }

    /// Updates the running line count for the phase currently in progress.
    /// No-ops if nothing is running (e.g. Live Activities are disabled, or
    /// `start(phase:target:)` was never called for today's phase).
    func update(written: Int) {
        guard #available(iOS 16.1, *), let activity = currentActivity else { return }
        Task {
            await activity.update(.init(
                state: .init(linesWritten: written),
                staleDate: nil
            ))
        }
    }

    /// Ends the current activity, if any — call when the phase completes,
    /// the ritual day rolls over, or the user backs out of the ritual
    /// screen. Leaves the final state visible briefly rather than vanishing
    /// instantly.
    func end() {
        guard #available(iOS 16.1, *), let activity = currentActivity else { return }
        let finalContent = activity.content
        Task {
            await activity.end(finalContent, dismissalPolicy: .after(.now.addingTimeInterval(5 * 60)))
        }
        currentActivity = nil
    }
}
