// ScienceStepView.swift
// Onboarding step 4 — "Did you know?"
// Figma node: 257:1658 — pixel-perfect from Figma inspect

import SwiftUI

struct ScienceStepView: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / 393.0

            ZStack {
                // ── 1. Background: solid #16062A ──
                Theme.Colors.background

                // ── 2. Purple glow ellipse ──
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0x4F/255.0, green: 0x31/255.0, blue: 0xEC/255.0).opacity(0.35),
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
                // Figma: (20, 76), w=353, h=6, step 4 of 6
                HStack(spacing: 2 * s) {
                    // Steps 1-4 — active
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                            .fill(Theme.Colors.primary)
                            .frame(height: Theme.Sizes.stepperHeight * s)
                    }
                    // Steps 5-6 — inactive
                    ForEach(0..<2, id: \.self) { _ in
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

                // ── 4. Glass card ──
                // Figma: (13, 151), 353x484, cornerRadius 16, border #63507A 2px
                ZStack(alignment: .top) {
                    // Stars background image at top of card
                    Image("StarsBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 353 * s, height: 329 * s)
                        .clipped()
                        .opacity(0.6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    VStack(spacing: 0) {
                        // Owl illustration: 194x194, centered, top=18
                        Image("OwlIllustration")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 194 * s, height: 194 * s)
                            .padding(.top, 18 * s)

                        // "Did you know?" — serif semibold 26px, #FCD471
                        // y≈246 inside card → after owl (18+194=212), gap ≈ 34
                        Text("Did you know?")
                            .font(.system(size: 26 * s, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.Colors.secondary)
                            .padding(.top, 34 * s)

                        // Body text — sans medium 16px, #EBEBEB, w=307
                        Text("Neuroscience shows that practicing gratitude for 21 days physically rewires your brain.")
                            .font(.system(size: 16 * s, weight: .medium))
                            .foregroundStyle(Theme.Colors.text)
                            .multilineTextAlignment(.center)
                            .frame(width: 307 * s)
                            .padding(.top, 16 * s)

                        // Sub-text — sans medium 16px, #B9B9B9, w=323
                        Text("It boosts happiness levels by 25% and improves long-term mental clarity.")
                            .font(.system(size: 16 * s, weight: .medium))
                            .foregroundStyle(Theme.Colors.labels)
                            .multilineTextAlignment(.center)
                            .frame(width: 323 * s)
                            .padding(.top, 12 * s)

                        Spacer()
                    }
                }
                .frame(width: 353 * s, height: 484 * s)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .fill(.ultraThinMaterial)
                        .opacity(0.01)
                )
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .fill(Color.white.opacity(0.01))
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                )
                .shadow(color: Theme.Colors.glassShadowBlue.opacity(0.5), radius: 35, x: 0, y: 24)
                .shadow(color: Theme.Colors.glassShadowMid.opacity(0.3), radius: 11, x: 0, y: 5)
                .shadow(color: Theme.Colors.glassShadowDeep.opacity(0.8), radius: 25, x: 0, y: 1)
                .position(
                    x: (13 + 353.0 / 2) * s,
                    y: (151 + 484.0 / 2) * s
                )

                // ── 5. Bottom bar ──
                // Figma: (20, 703)
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
                    y: (703 + 28) * s
                )

                // Continue button: "Wow Tell Me More"
                Button {
                    onContinue()
                } label: {
                    Text("Wow Tell Me More")
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
                    y: (703 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    ScienceStepView(
        onContinue: {},
        onBack: {}
    )
}
