// TodaysNumberIntent.swift
// Retention plan 3.9 — Siri/Spotlight entry point for "What's my number in
// ManifestAI". Answers directly via dialog without opening the app.
//
// `UserManager` and `NumerologyService` are both safe to call from here even
// though no view/scene is guaranteed to be alive: `UserManager` only proxies
// `@AppStorage` (i.e. plain `UserDefaults.standard` reads) and
// `NumerologyService.calculatePersonalDayNumber(birthDate:)` is a pure
// function of that birth date plus today's date. If either ever stops being
// safely accessible from an intent context, reimplement the formula locally
// here: personalDay = birthDay + birthMonth + today's day + month + year,
// reduced to a single digit.

import AppIntents
import Foundation

struct TodaysNumberIntent: AppIntent {
    static var title: LocalizedStringResource = "Today's Number"
    static var description = IntentDescription("Tells you today's personal numerology day number without opening ManifestAI.")

    // No `openAppWhenRun` — this only needs to compute a number and speak it
    // back via Siri.
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let birthDate = UserManager.shared.birthDate
        let number = NumerologyService.shared.calculatePersonalDayNumber(birthDate: birthDate)
        let title = NumerologyService.shared.getDailyMessageDeterministic(for: number).title
        return .result(dialog: "Today is a Day \(number) — \(title).")
    }
}
