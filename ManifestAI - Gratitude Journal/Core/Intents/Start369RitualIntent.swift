// Start369RitualIntent.swift
// Retention plan 3.9 — Siri/Spotlight/Shortcuts/Action Button entry point
// for "Start my ritual in ManifestAI".
//
// Always opens the app (writing a 369 line needs the full ritual screen),
// landing directly on the 369 tab's active writing phase. Communicates with
// MainTabView purely through the shared flag in SharedDataManager — see
// this file's report entry for the exact one-liner MainTabView needs to
// consume it on `scenePhase == .active`.

import AppIntents
import Foundation

struct Start369RitualIntent: AppIntent {
    static var title: LocalizedStringResource = "Start 369 Ritual"
    static var description = IntentDescription("Opens ManifestAI on today's 369 manifestation ritual so you can start writing.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        SharedDataManager.shared.setPendingDeepLink("ritual")
        return .result(dialog: "Opening today's 369 ritual.")
    }
}
