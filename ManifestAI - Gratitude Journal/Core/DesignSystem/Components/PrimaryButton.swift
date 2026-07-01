import SwiftUI

/// Shared "Button Default" component from Figma, used across all onboarding screens.
///
/// Figma specs (instance node e.g. 264:879):
/// - Height: 56px
/// - Corner radius: 13px
/// - Background: primary gradient (#3B2DF7 → #7C38FF)
/// - Text: Poppins Medium 16px, white, centered
/// - Optional trailing icon: 24×24, white
/// - Padding: 16px horizontal, 10px vertical
struct PrimaryButton: View {
    let title: String
    var icon: String? = "arrow.right"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Figma: text centered with flex-1, icon at trailing edge
                Text(title)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: DesignTokens.Sizes.iconSize,
                               height: DesignTokens.Sizes.iconSize) // 24×24
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.cardPadding) // 16
            .frame(height: DesignTokens.Sizes.buttonHeight) // 56
            .background(DesignTokens.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.button)) // 13
        }
    }
}

#Preview("PrimaryButton") {
    ZStack {
        DesignTokens.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 24) {
            PrimaryButton(title: "Start My Journey") {}

            PrimaryButton(title: "Continue") {}

            PrimaryButton(title: "Skip", icon: nil) {}
        }
        .padding(.horizontal, DesignTokens.Spacing.screenPadding)
    }
}
