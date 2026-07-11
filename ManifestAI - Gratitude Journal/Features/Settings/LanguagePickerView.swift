// LanguagePickerView.swift
// In-app language picker (Profile → Language). Writes the per-app
// "AppleLanguages" override; the new language applies on the next launch
// (bundle language is fixed at process start), so picking offers a restart.

import SwiftUI

struct AppLanguage: Identifiable {
    let code: String        // catalog locale code ("de", "pt-BR", "zh-Hans"…)
    let nativeName: String  // shown in its own language, never localized
    var id: String { code }

    static let all: [AppLanguage] = [
        .init(code: "en", nativeName: "English"),
        .init(code: "he", nativeName: "עברית"),
        .init(code: "de", nativeName: "Deutsch"),
        .init(code: "fr", nativeName: "Français"),
        .init(code: "it", nativeName: "Italiano"),
        .init(code: "es", nativeName: "Español"),
        .init(code: "pt-BR", nativeName: "Português (Brasil)"),
        .init(code: "nl", nativeName: "Nederlands"),
        .init(code: "pl", nativeName: "Polski"),
        .init(code: "tr", nativeName: "Türkçe"),
        .init(code: "ru", nativeName: "Русский"),
        .init(code: "sv", nativeName: "Svenska"),
        .init(code: "nb", nativeName: "Norsk"),
        .init(code: "da", nativeName: "Dansk"),
        .init(code: "fi", nativeName: "Suomi"),
        .init(code: "ja", nativeName: "日本語"),
        .init(code: "ko", nativeName: "한국어"),
        .init(code: "zh-Hans", nativeName: "简体中文"),
        .init(code: "ar", nativeName: "العربية"),
        .init(code: "id", nativeName: "Bahasa Indonesia"),
        .init(code: "vi", nativeName: "Tiếng Việt")
    ]

    /// The active app language code (override if set, else system-resolved).
    static var activeCode: String {
        if let override = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first {
            return normalized(override)
        }
        return normalized(Bundle.main.preferredLocalizations.first ?? "en")
    }

    /// Native display name of the active language (Profile row subtitle).
    static var activeNativeName: String {
        let code = activeCode
        return all.first { $0.code == code }?.nativeName
            ?? all.first { code.hasPrefix($0.code) }?.nativeName
            ?? "English"
    }

    private static func normalized(_ raw: String) -> String {
        // "he-IL" → "he", "pt-BR" stays, "zh-Hans-US" → "zh-Hans"
        if raw.hasPrefix("zh-Hans") { return "zh-Hans" }
        if raw.hasPrefix("pt-BR") || raw.hasPrefix("pt") { return raw.hasPrefix("pt") ? "pt-BR" : raw }
        return raw.split(separator: "-").first.map(String.init) ?? raw
    }
}

struct LanguagePickerView: View {
    var onClose: () -> Void

    @State private var selectedCode = AppLanguage.activeCode
    @State private var showRestartPrompt = false

    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()
            Color.clear
                .overlay(alignment: .top) { EllipseGlowBackground(figmaOpacity: 0.35) }
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // header
                ZStack {
                    Text("Choose Language")
                        .font(DesignTokens.Typography.h4)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(DesignTokens.Colors.textSecondary)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.06)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Close"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(AppLanguage.all) { language in
                            languageRow(language)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("The new language will apply the next time you open the app.",
               isPresented: $showRestartPrompt) {
            Button("Restart Now", role: .destructive) {
                // Standard "apply language" pattern: exit so the next launch
                // loads the newly selected bundle language.
                exit(0)
            }
            Button("Later", role: .cancel) { onClose() }
        }
        .accessibilityIdentifier("languagePicker.root")
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        let selected = language.code == selectedCode
        return Button {
            guard !selected else { return }
            selectedCode = language.code
            UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
            AnalyticsManager.log("language_changed", ["language": language.code])
            showRestartPrompt = true
        } label: {
            HStack {
                Text(language.nativeName)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(DesignTokens.Colors.secondary)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .fill(Color.white.opacity(selected ? 0.06 : 0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .strokeBorder(selected
                                  ? DesignTokens.Colors.secondary.opacity(0.7)
                                  : DesignTokens.Colors.glassBorder.opacity(0.4),
                                  lineWidth: selected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("languagePicker.\(language.code)")
    }
}

#Preview {
    LanguagePickerView(onClose: {})
}
