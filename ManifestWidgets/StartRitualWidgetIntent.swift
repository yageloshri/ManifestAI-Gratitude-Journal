//
//  StartRitualWidgetIntent.swift
//  ManifestWidgets
//
//  Retention plan 3.8 — the home-screen widget's one interactive element.
//  This intent runs entirely inside the widget extension (openAppWhenRun is
//  left at its default `false`), so tapping the button does NOT itself
//  launch the app — it only flips the shared flag that the app picks up on
//  its next foreground (see SharedDataManager.setPendingDeepLink /
//  consumePendingDeepLink). Opening the app happens separately: tapping
//  anywhere else on the widget uses `widgetURL("manifestai://ritual")`,
//  handled by the app's `onOpenURL` (see report for the exact one-liner).
//

import AppIntents
import WidgetKit

struct StartRitualWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Ritual"
    static var description = IntentDescription("Marks today's 369 ritual as started from the widget.")

    @MainActor
    func perform() async throws -> some IntentResult {
        SharedDataManager.shared.setPendingDeepLink("ritual")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
