// NameStepView.swift
// Onboarding step 1 — "What should we call you?"
// Figma node: 255:1190 — pixel-perfect from Figma inspect

import SwiftUI

struct NameStepView: View {
    @Binding var userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / 393.0

            ZStack {
                // ── 1. Background: solid #16062A ──
                Theme.Colors.background

                // ── 2. Purple glow ellipse ──
                // Figma: position (0, 12), size 578.67x677.5
                // Radial gradient #4F31EC opacity 0.35
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0x4F/255, green: 0x31/255, blue: 0xEC/255).opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 289 * s
                        )
                    )
                    .frame(width: 578.67 * s, height: 677.5 * s)
                    .position(x: (0 + 578.67 / 2) * s, y: (12 + 677.5 / 2) * s)

                // ── 3. Stepper ──
                // Figma: (20, 76), w=353, h=6, step 1 of 6
                HStack(spacing: 2 * s) {
                    // Step 1 — active
                    RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                        .fill(Theme.Colors.primary)
                        .frame(height: Theme.Sizes.stepperHeight * s)
                    // Steps 2-6 — inactive
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                            .fill(Theme.Colors.lightGrey.opacity(0.3))
                            .frame(height: Theme.Sizes.stepperHeight * s)
                    }
                }
                .frame(width: 353 * s)
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (76 + 3) * s
                )

                // ── 4. Title ──
                // Figma: (20, 122), w=353, serif semibold 26px, #EBEBEB, lineHeight 1.2
                Text("What should we call you?")
                    .font(.system(size: 26 * s, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.Colors.text)
                    .lineSpacing(26 * 0.2 * s)
                    .frame(width: 353 * s, alignment: .leading)
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (122 + 16) * s
                    )

                // ── 5. Text Field ──
                // Figma: (20, 177), 353x56, capsule, border #63507A 2px
                // Placeholder: "Enter Name", regular 14px, #EBEBEB 40%
                TextField("", text: $userName, prompt:
                    Text("Enter Name")
                        .foregroundColor(Theme.Colors.text.opacity(0.4))
                )
                .focused($isFocused)
                .font(.system(size: 14 * s, weight: .regular))
                .foregroundStyle(Theme.Colors.text)
                .accentColor(Theme.Colors.text)
                .padding(.horizontal, 16 * s)
                .frame(width: 353 * s, height: Theme.Sizes.textFieldHeight * s)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.01))
                        .background(.ultraThinMaterial.opacity(0.01))
                        .clipShape(Capsule())
                )
                .overlay(
                    Capsule()
                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                )
                .shadow(
                    color: Theme.Colors.glassShadowBlue.opacity(0.3),
                    radius: 20 * s, y: 10 * s
                )
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (177 + 28) * s
                )
                .environment(\.colorScheme, .dark)

                // ── 6. Bottom bar ──
                // Figma: (20, 734), w=355, h=56

                // Back button: 56x56, cornerRadius 12, border #63507A 2px
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14 * s, weight: .medium))
                        .foregroundStyle(Theme.Colors.text)
                        .frame(
                            width: Theme.Sizes.backButtonSize * s,
                            height: Theme.Sizes.backButtonSize * s
                        )
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.backButton)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Radius.backButton)
                                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                                )
                        )
                        .shadow(
                            color: Theme.Colors.glassShadowBlue.opacity(0.3),
                            radius: 15 * s, y: 10 * s
                        )
                }
                .position(
                    x: (20 + 28) * s,
                    y: (734 + 28) * s
                )

                // Continue button: fills remaining width, height 56, cornerRadius 13
                // Width = 355 - 56 (back) - 16 (gap) = 283
                Button {
                    isFocused = false
                    UserDefaults.standard.set(userName, forKey: "user_name")
                    onContinue()
                } label: {
                    Text("Reveal My Path")
                        .font(.system(size: 16 * s, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Sizes.buttonHeight * s)
                        .background(
                            LinearGradient(
                                stops: [
                                    .init(color: Theme.Colors.buttonGradientStart, location: 0.31858),
                                    .init(color: Theme.Colors.buttonGradientEnd, location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                }
                .frame(width: (355 - 56 - 16) * s)
                .position(
                    x: (20 + 56 + 16 + (355.0 - 56 - 16) / 2) * s,
                    y: (734 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear {
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
