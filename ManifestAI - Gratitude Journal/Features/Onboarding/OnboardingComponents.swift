// OnboardingComponents.swift
// Reusable UI components for the onboarding experience
// Updated to use Figma design tokens via Theme.swift

import SwiftUI

// MARK: - Onboarding Background
/// Standard background for all onboarding screens: solid #16062A + purple glow ellipse
struct OnboardingBackground: View {
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            // Decorative purple radial glow (matches Figma ellipse layer)
            GeometryReader { geo in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Theme.Colors.primary.opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.9
                        )
                    )
                    .frame(width: geo.size.width * 1.5, height: geo.size.height * 0.8)
                    .position(x: geo.size.width * 0.35, y: geo.size.height * 0.25)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Stepper
/// 6-segment progress stepper from Figma (6px tall, pill-shaped segments)
struct OnboardingStepper: View {
    /// Number of completed steps (0-6). The current step is shown as active.
    let currentStep: Int
    let totalSteps: Int

    init(currentStep: Int, totalSteps: Int = 6) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                    .fill(index < currentStep
                          ? Theme.Colors.primary
                          : Theme.Colors.lightGrey.opacity(0.3))
                    .frame(height: Theme.Sizes.stepperHeight)
            }
        }
        .padding(.horizontal, Theme.Sizes.screenPadding)
    }
}

// MARK: - Back + Continue Button Row
/// Bottom navigation row: glass back arrow (56x56) + gradient "Continue" button
struct OnboardingBottomBar: View {
    let buttonTitle: String
    let onContinue: () -> Void
    let onBack: (() -> Void)?

    init(_ buttonTitle: String = "Reveal My Path",
         onContinue: @escaping () -> Void,
         onBack: (() -> Void)? = nil) {
        self.buttonTitle = buttonTitle
        self.onContinue = onContinue
        self.onBack = onBack
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            // Back button (glass square)
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.text)
                        .frame(
                            width: Theme.Sizes.backButtonSize,
                            height: Theme.Sizes.backButtonSize
                        )
                        .glassPanel(
                            cornerRadius: Theme.Radius.backButton,
                            borderColor: Theme.Colors.glassBorder
                        )
                }
            }

            // Continue button (gradient)
            Button(action: onContinue) {
                Text(buttonTitle)
                    .font(Theme.Fonts.sansFallback(size: 16, weight: .medium))
                    .foregroundStyle(Theme.Colors.card)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Sizes.buttonHeight)
                    .background(Theme.Gradients.button)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
            }
        }
        .padding(.horizontal, Theme.Sizes.screenPadding)
    }
}

// MARK: - Star Dust Particles (decorative)
struct StarDustView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<80, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
}

// MARK: - Legacy alias (keep until MysticalBackground usages are removed)
struct MysticalBackground: View {
    var body: some View {
        OnboardingBackground()
    }
}
