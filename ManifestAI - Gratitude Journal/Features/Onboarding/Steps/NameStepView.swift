// NameStepView.swift
// Figma: "Name" frame (255:1190) in Registration Screens section
// All geometry from fidelity/name/spec — do not eyeball values.

import SwiftUI
import UIKit

struct NameStepView: View {
    @Binding var userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    /// Parity gallery: render final state, no autofocus/keyboard, full opacity.
    var parityMode: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 255:1190 background — no glass panel on this screen
                DesignTokens.Colors.background

                // Ellipse glow — Figma 255:1191: (0,12) 578.67×677.5
                EllipseGlowBackground(sx: sx, sy: sy)

                // Stepper — Figma 255:1201: centered, top 76, w 353, step 1/6
                OnboardingStepper(currentStep: 1)
                    .frame(width: 353 * sx)
                    .parityPosition(x: 20 * sx, y: 76 * sy)

                // Title + field — Figma 255:1193: left 20, top 122, gap 24
                VStack(alignment: appIsRTL ? .trailing : .leading, spacing: 24 * sy) {
                    // Figma 255:1198: Bitter SemiBold 26/1.2 #EBEBEB
                    Text("What should we call you?")
                        .font(DesignTokens.Typography.h1)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .multilineTextAlignment(appIsRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: appIsRTL ? .trailing : .leading)

                    // Figma 268:1548: 353×56 glass capsule
                    GlassTextField(
                        text: $userName,
                        placeholder: String(localized: "Enter Name"),
                        isFocused: $isFocused
                    )
                    // Names must never be autocorrected (e.g. "Yagel" → "Tavel")
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("name.textField")
                }
                .frame(width: 353 * sx, alignment: .topLeading)
                .parityPosition(x: 20 * sx, y: 122 * sy)

                // Bottom bar — Figma 282:2320: left 20, top 734, w 355, gap 16
                HStack(spacing: 16 * sx) {
                    GlassBackButton(action: onBack)
                        .accessibilityIdentifier("name.backButton")

                    PrimaryButton(title: String(localized: "Reveal My Path"), icon: nil) {
                        isFocused = false
                        UserDefaults.standard.set(userName, forKey: "user_name")
                        onContinue()
                    }
                    .accessibilityIdentifier("name.continueButton")
                }
                .frame(width: 355 * sx)
                .parityPosition(x: 20 * sx, y: 734 * sy)
                .opacity(parityMode || userName.count >= 2 ? 1 : 0.4)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("name.root")
        .onAppear {
            guard !parityMode else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

#Preview {
    NameStepView(
        userName: .constant(""),
        onContinue: {},
        onBack: {}
    )
}
