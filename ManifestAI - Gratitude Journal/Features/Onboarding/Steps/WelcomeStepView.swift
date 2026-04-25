// WelcomeStepView.swift
// First onboarding screen — "Welcome to Gratitude Journal: Manifest"
// Figma node: 258:1851 — pixel-perfect from Figma inspect

import SwiftUI

struct WelcomeStepView: View {
    let onContinue: () -> Void
    @State private var showContent = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let s = w / 393.0

            ZStack {
                // ── 1. Background: solid #16062A ──
                Theme.Colors.background

                // ── 2. Purple glow ellipse ──
                // Figma: position (0, 12), size 578.67×677.5
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
                            endRadius: 300 * s
                        )
                    )
                    .frame(width: 578.67 * s, height: 677.5 * s)
                    .position(
                        x: (0 + 578.67 / 2) * s,
                        y: (12 + 677.5 / 2) * s
                    )

                // ── 3. Stars texture ──
                // Figma: position (-1, 0), size 393×396, opacity 0.6
                Image("OnboardingStars")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 393 * s, height: 396 * s)
                    .clipped()
                    .position(
                        x: (-1 + 393.0 / 2) * s,
                        y: (0 + 396.0 / 2) * s
                    )
                    .opacity(0.6)

                // ── 4. Owl illustration ──
                // Figma: position (-1, 120), container 364×369
                // scaledToFit at full screen width, center at x=47%, y=310pt
                Image("OwlIllustration")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 393 * s)
                    .position(x: w * 0.47, y: 310 * s)

                // ── 5. Welcome badge glass ──
                // Figma: position (81, 65), size 229×75, cornerRadius 14
                // border #63507A 2px, ultraThinMaterial
                RoundedRectangle(cornerRadius: Theme.Radius.welcomeBadge)
                    .fill(.ultraThinMaterial)
                    .frame(width: 229 * s, height: 75 * s)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.welcomeBadge)
                            .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                    )
                    .shadow(
                        color: Theme.Colors.glassShadowBlue.opacity(0.5),
                        radius: 35 * s, y: 24 * s
                    )
                    .shadow(
                        color: Theme.Colors.glassShadowMid.opacity(0.8),
                        radius: 12 * s, y: 5 * s
                    )
                    .position(
                        x: (81 + 229.0 / 2) * s,
                        y: (65 + 75.0 / 2) * s
                    )

                // ── 6. Welcome badge text ──
                // Figma: position (98, 78), size 195×50
                // Bitter Bold 18px, color #FCD471, centered
                Text("Welcome to Gratitude\nJournal: Manifest")
                    .font(.system(size: 18 * s, weight: .bold, design: .serif))
                    .foregroundStyle(Theme.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3 * s)
                    .frame(width: 195 * s)
                    .position(
                        x: (98 + 195.0 / 2) * s,
                        y: (78 + 50.0 / 2) * s
                    )

                // ── 7. Title text ──
                // Figma: position (34, 508), width 330
                // "Turn your dreams " — serif light italic 37px
                // "in to reality in 5 mins a day." — serif semibold 37px
                // color #EBEBEB, lineHeight 1.2
                (
                    Text("Turn your dreams ")
                        .font(.system(size: 37 * s, weight: .light, design: .serif))
                        .italic()
                    +
                    Text("in to reality in 5 mins a day.")
                        .font(.system(size: 37 * s, weight: .semibold, design: .serif))
                )
                .foregroundStyle(Theme.Colors.text)
                .lineSpacing(37 * 0.2 * s)
                .frame(width: 330 * s, alignment: .leading)
                .position(
                    x: (34 + 330.0 / 2) * s,
                    y: (508 + 66) * s
                )

                // ── 8. CTA button ──
                // Figma: position (31, 690), size 332×56, cornerRadius 13
                // Gradient #3B2DF7 @31.858% → #7C38FF
                // Text: "Start My Journey", sans medium 16px, white
                // arrow.right icon 24×24
                Button(action: onContinue) {
                    HStack {
                        Spacer()
                        Text("Start My Journey")
                            .font(.system(size: 16 * s, weight: .medium))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16 * s, weight: .medium))
                            .frame(width: 24 * s, height: 24 * s)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16 * s)
                    .frame(width: 332 * s, height: Theme.Sizes.buttonHeight * s)
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
                .position(
                    x: (31 + 332.0 / 2) * s,
                    y: (690 + Theme.Sizes.buttonHeight / 2) * s
                )
            }
            .frame(width: w, height: h)
            .clipped()
            .opacity(showContent ? 1 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

#Preview {
    WelcomeStepView(onContinue: {})
}
