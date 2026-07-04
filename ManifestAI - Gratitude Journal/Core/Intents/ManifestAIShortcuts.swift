// ManifestAIShortcuts.swift
// Retention plan 3.9 — registers the natural-language Siri phrases for the
// three App Intents above so they're discoverable via Siri, Spotlight, the
// Shortcuts app, and (on supported devices) the Action Button — a
// zero-notification-permission-required re-entry channel.
//
// No app-side wiring needed beyond what Start369RitualIntent.swift and
// LogGratitudeIntent.swift already document (the pending-deep-link
// consumption in MainTabView). This type just needs to exist somewhere in
// the app target; the system discovers it automatically at launch.

import AppIntents

struct ManifestAIShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: Start369RitualIntent(),
            phrases: [
                "Start my ritual in \(.applicationName)",
                "Start my 369 ritual in \(.applicationName)"
            ],
            shortTitle: "Start Ritual",
            systemImageName: "flame.fill"
        )
        AppShortcut(
            intent: LogGratitudeIntent(),
            phrases: [
                "Log gratitude in \(.applicationName)",
                "Write in my gratitude journal with \(.applicationName)"
            ],
            shortTitle: "Log Gratitude",
            systemImageName: "heart.text.square.fill"
        )
        AppShortcut(
            intent: TodaysNumberIntent(),
            phrases: [
                "What's my number in \(.applicationName)",
                "What's today's number in \(.applicationName)"
            ],
            shortTitle: "Today's Number",
            systemImageName: "number.circle.fill"
        )
    }
}
