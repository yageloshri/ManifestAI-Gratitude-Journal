// BreakthroughStepView.swift
// Onboarding step 2 — "Where do you need a breakthrough?"
// Figma node: 255:1247 — pixel-perfect from Figma inspect

import SwiftUI

struct BreakthroughStepView: View {
    @Binding var selected: String?
    let onContinue: () -> Void
    let onBack: () -> Void

    private let categories: [(icon: String, iconColor: Color, glowColor: Color, title: String)] = [
        ("heart.fill", Theme.Colors.glowLove, Color(red: 252/255, green: 13/255, blue: 27/255).opacity(0.32), "Love & Relationship"),
        ("dollarsign.circle.fill", Theme.Colors.glowFinance, Color(red: 243/255, green: 158/255, blue: 9/255).opacity(0.32), "Financial Abundance"),
        ("leaf.fill", Theme.Colors.glowPeace, Color(red: 87/255, green: 147/255, blue: 65/255).opacity(0.32), "Inner Peace"),
        ("target", Theme.Colors.glowCareer, Color(red: 0/255, green: 137/255, blue: 255/255).opacity(0.32), "Career Growth")
    ]

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
                // Figma: (20, 76), w=353, h=6, step 2 of 6
                HStack(spacing: 2 * s) {
                    // Steps 1-2 — active
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                            .fill(Theme.Colors.primary)
                            .frame(height: Theme.Sizes.stepperHeight * s)
                    }
                    // Steps 3-6 — inactive
                    ForEach(0..<4, id: \.self) { _ in
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
                // Figma: (20, 122), w=353, serif semibold 26px, #EBEBEB
                Text("Where do you need a\nbreakthrough?")
                    .font(.system(size: 26 * s, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.Colors.text)
                    .lineSpacing(26 * 0.2 * s)
                    .frame(width: 353 * s, alignment: .leading)
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (122 + 20) * s
                    )

                // ── 5. Category cards ──
                // Figma: starting at (20, ~194), each 353x82, 12px gap
                ForEach(Array(categories.enumerated()), id: \.element.title) { index, category in
                    let cardY = 194.0 + Double(index) * (82.0 + 12.0)
                    CategoryCard(
                        icon: category.icon,
                        iconColor: category.iconColor,
                        glowColor: category.glowColor,
                        title: category.title,
                        isSelected: selected == category.title,
                        s: s
                    ) {
                        selected = category.title
                    }
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (cardY + 41) * s
                    )
                }

                // ── 6. Bottom bar ──
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
                Button {
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
                .opacity(selected != nil ? 1.0 : 0.4)
                .disabled(selected == nil)
                .position(
                    x: (20 + 56 + 16 + (355.0 - 56 - 16) / 2) * s,
                    y: (734 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let icon: String
    let iconColor: Color
    let glowColor: Color
    let title: String
    let isSelected: Bool
    let s: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Icon container: 42x42, r=12, glassmorphic with colored glow
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.iconContainer)
                        .fill(glowColor)
                        .frame(
                            width: Theme.Sizes.iconContainer * s,
                            height: Theme.Sizes.iconContainer * s
                        )
                        .blur(radius: 4 * s)

                    RoundedRectangle(cornerRadius: Theme.Radius.iconContainer)
                        .fill(.ultraThinMaterial)
                        .frame(
                            width: Theme.Sizes.iconContainer * s,
                            height: Theme.Sizes.iconContainer * s
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.iconContainer)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 20 * s, weight: .medium))
                        .foregroundStyle(iconColor)
                }
                .frame(
                    width: Theme.Sizes.iconContainer * s,
                    height: Theme.Sizes.iconContainer * s
                )
                .padding(.leading, 15 * s)

                // Title text
                Text(title)
                    .font(.system(size: 16 * s, weight: .medium))
                    .foregroundStyle(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF2/255.0))
                    .padding(.leading, 12 * s)

                Spacer()

                // Right arrow
                Image(systemName: "arrow.left")
                    .font(.system(size: 14 * s, weight: .medium))
                    .foregroundStyle(Theme.Colors.text.opacity(0.5))
                    .rotationEffect(.degrees(180))
                    .frame(width: 24 * s, height: 24 * s)
                    .padding(.trailing, 15 * s)
            }
            .frame(width: 353 * s, height: Theme.Sizes.categoryCardHeight * s)
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
                    .stroke(
                        isSelected ? Theme.Colors.selectedBorder : Theme.Colors.glassBorder,
                        lineWidth: isSelected ? 3 : 2
                    )
            )
            .shadow(color: Theme.Colors.glassShadowBlue.opacity(0.5), radius: 35, x: 0, y: 24)
            .shadow(color: Theme.Colors.glassShadowMid.opacity(0.3), radius: 11, x: 0, y: 5)
            .shadow(color: Theme.Colors.glassShadowDeep.opacity(0.8), radius: 25, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    BreakthroughStepView(
        selected: .constant(nil),
        onContinue: {},
        onBack: {}
    )
}
