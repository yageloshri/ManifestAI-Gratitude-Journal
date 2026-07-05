import SwiftUI

// MARK: - RTL text alignment helper
//
// The app root intentionally pins `.environment(\.layoutDirection, .leftToRight)`
// (see ManifestAIApp.swift) because every screen is positioned at fixed Figma
// coordinates that must not mirror. That means SwiftUI's automatic RTL layout
// mirroring (leading/trailing flipping sides) never kicks in, even for RTL
// languages like Hebrew and Arabic.
//
// What SHOULD still adapt per-language is TEXT alignment: a Hebrew or Arabic
// sentence reads right-to-left, so left-aligned Latin-style titles look
// broken. `appIsRTL` reports whether the active app language is an RTL
// script; call sites use it to flip `.multilineTextAlignment` / `.frame`
// alignment between `.leading` and `.trailing` while leaving the overall
// screen layout (and any centered text) untouched.
var appIsRTL: Bool {
    Locale.Language(identifier: Locale.preferredLanguages.first ?? "en").characterDirection == .rightToLeft
}
