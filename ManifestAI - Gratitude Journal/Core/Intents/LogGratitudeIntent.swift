// LogGratitudeIntent.swift
// Retention plan 3.9 — Siri/Spotlight/Shortcuts entry point for
// "Log gratitude in ManifestAI".
//
// Journal entries need the full text editor (and, optionally, the Gemini
// "elevate" pipeline), so this always opens the app rather than accepting
// dictated text directly. Communicates with MainTabView purely through the
// shared flag in SharedDataManager — see this file's report entry for the
// exact one-liner MainTabView needs to consume it on `scenePhase == .active`.

import AppIntents
import Foundation

struct LogGratitudeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Gratitude"
    static var description = IntentDescription("Opens ManifestAI to write a new gratitude journal entry.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        SharedDataManager.shared.setPendingDeepLink("journal_write")
        return .result(dialog: "Opening your gratitude journal.")
    }
}
