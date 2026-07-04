// RitualActivityAttributes.swift
// Retention plan 3.11 — shape of the 369 ritual Live Activity.
//
// ⚠️ TARGET MEMBERSHIP: this project uses Xcode 16 file-system-synchronized
// groups, so a new file under "ManifestAI - Gratitude Journal/" defaults to
// ONLY the app target. ActivityAttributes types must be compiled into BOTH
// the app (which starts/updates/ends the Activity via RitualLiveActivityController)
// AND the ManifestWidgetsExtension target (which renders it in
// ManifestWidgetsLiveActivity.swift) — otherwise the widget extension won't
// build. After adding this file, open it in Xcode's File Inspector and check
// the "ManifestWidgetsExtension" target membership box in addition to the
// app target (already checked by default).

import ActivityKit
import Foundation

struct RitualActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Lines written so far in the active phase (0...target). The only
        /// thing that changes over the life of the activity.
        var linesWritten: Int
    }

    /// "Morning" / "Afternoon" / "Evening" — fixed for the life of the activity.
    var phaseName: String
    /// 3 / 6 / 9 — fixed for the life of the activity.
    var target: Int
}
