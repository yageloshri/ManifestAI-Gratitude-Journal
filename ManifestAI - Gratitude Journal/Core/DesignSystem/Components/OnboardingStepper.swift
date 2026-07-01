import SwiftUI

/// Figma: "Stepper" component (node 255:1201)
/// 6-segment progress bar used across onboarding steps 1-6.
/// Active step filled with primary color, inactive steps grey at 30% opacity.
///
/// Figma specs:
/// - Total width: 353px (fills available), height: 6px
/// - 6 equal segments, gap: 2px
/// - Active: #685EF5 (primary), rounded 50px
/// - Inactive: #9F9E9E (light grey) at 30% opacity, rounded 50px
struct OnboardingStepper: View {
    let totalSteps: Int
    let currentStep: Int // 1-based

    init(totalSteps: Int = 6, currentStep: Int) {
        self.totalSteps = totalSteps
        self.currentStep = currentStep
    }

    var body: some View {
        HStack(spacing: 2) { // Figma: gap 2px
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: DesignTokens.Radii.pill) // 50px → fully rounded
                    .fill(index < currentStep
                          ? DesignTokens.Colors.primary
                          : DesignTokens.Colors.lightGrey.opacity(0.30))
                    .frame(height: 6) // Figma: height 6px
            }
        }
    }
}

#Preview("OnboardingStepper") {
    ZStack {
        DesignTokens.Colors.background.ignoresSafeArea()
        VStack(spacing: 24) {
            OnboardingStepper(currentStep: 1)
            OnboardingStepper(currentStep: 3)
            OnboardingStepper(currentStep: 6)
        }
        .padding(.horizontal, DesignTokens.Spacing.screenPadding)
    }
}
