// PremiumComponents.swift
// Reusable glass-style UI components for onboarding screens
// Updated to use Figma design tokens via Theme.swift

import SwiftUI

// MARK: - Glass Text Field (Figma: capsule-shaped, border #63507A)
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt:
            Text(placeholder)
                .foregroundColor(Theme.Colors.text.opacity(0.4))
        )
        .font(Theme.Fonts.sansFallback(size: 14, weight: .regular))
        .foregroundColor(Theme.Colors.text)
        .accentColor(Theme.Colors.primary)
        .padding(.horizontal, Theme.Spacing.lg)
        .frame(height: Theme.Sizes.textFieldHeight)
        .glassPill()
        .environment(\.colorScheme, .dark)
    }
}

// MARK: - Glass Card (generic glass panel container)
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Theme.Radius.card
    var borderColor: Color = Theme.Colors.glassBorder
    let content: Content

    init(
        cornerRadius: CGFloat = Theme.Radius.card,
        borderColor: Color = Theme.Colors.glassBorder,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .glassPanel(cornerRadius: cornerRadius, borderColor: borderColor)
    }
}

// MARK: - Info Box (Figma: rounded rect, bg #251540, icon + text)
struct InfoBox: View {
    let icon: String
    let text: String

    init(icon: String = "info.circle", text: String) {
        self.icon = icon
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Theme.Colors.lightGrey)
                .frame(width: 24, height: 24)

            Text(text)
                .font(Theme.Fonts.sansFallback(size: 14, weight: .regular))
                .foregroundStyle(Theme.Colors.lightGrey)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.infoBox)
                .fill(Theme.Colors.surface)
        )
    }
}

// MARK: - Legacy aliases (keep until old usages are migrated)

struct PremiumButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.sansFallback(size: 16, weight: .medium))
                .foregroundColor(Theme.Colors.card)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Sizes.buttonHeight)
                .background(Theme.Gradients.button)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
        }
    }
}

struct PremiumTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        GlassTextField(placeholder: placeholder, text: $text)
    }
}

struct PremiumGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GlassCard { content }
    }
}
