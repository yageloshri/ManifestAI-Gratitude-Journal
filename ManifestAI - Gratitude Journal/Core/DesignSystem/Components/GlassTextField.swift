import SwiftUI

/// Figma: "Text Field" component (node 268:1548)
/// Glass capsule text input with placeholder.
///
/// Figma specs:
/// - Width: fills parent, height: 56px
/// - Corner radius: 150px (capsule)
/// - Border: 2px #63507A
/// - Glass: ultraThinMaterial + rgba(251,251,251,0.01)
/// - Placeholder: Poppins Regular 14, #EBEBEB at 40% opacity
/// - Text padding: left 16px
struct GlassTextField: View {
    @Binding var text: String
    let placeholder: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        ZStack(alignment: .leading) {
            // Glass background — Figma inset-shadow stack + 2px #63507A border
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Sizes.buttonHeight / 2)

            // Text field
            TextField("", text: $text)
                .multilineTextAlignment(appIsRTL ? .trailing : .leading)
                .focused(isFocused)
                .font(DesignTokens.Typography.smallText) // Poppins Regular 14
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .tint(DesignTokens.Colors.primary)
                .padding(.horizontal, DesignTokens.Spacing.cardPadding) // 16
                .overlay(alignment: appIsRTL ? .trailing : .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(DesignTokens.Typography.smallText)
                            .foregroundStyle(DesignTokens.Colors.textPrimary.opacity(0.40))
                            .multilineTextAlignment(appIsRTL ? .trailing : .leading)
                            .padding(.horizontal, DesignTokens.Spacing.cardPadding)
                            .allowsHitTesting(false)
                    }
                }
        }
        .frame(height: DesignTokens.Sizes.buttonHeight) // 56
    }
}

#Preview("GlassTextField") {
    ZStack {
        DesignTokens.Colors.background.ignoresSafeArea()
        VStack(spacing: 16) {
            GlassTextField(
                text: .constant(""),
                placeholder: "Enter Name",
                isFocused: FocusState<Bool>().projectedValue
            )
            GlassTextField(
                text: .constant("Ali"),
                placeholder: "Enter Name",
                isFocused: FocusState<Bool>().projectedValue
            )
        }
        .padding(.horizontal, DesignTokens.Spacing.screenPadding)
    }
}
