// PainPointsStepView.swift
// Onboarding step 3 — "[userName], What is holding you back right now?"
// Figma node: 256:1133 — pixel-perfect from Figma inspect

import SwiftUI

struct PainPointsStepView: View {
    @Binding var selected: [String]
    let userName: String
    let onContinue: () -> Void
    let onBack: () -> Void

    private let allOptions: [String] = [
        "Select All",
        "Procrastination",
        "Self-Doubt",
        "Lack of Direction",
        "Don't know where to Start",
        "Emotional Fatigue",
        "Impostor Syndrome"
    ]

    /// Options excluding "Select All" — the real data values
    private var realOptions: [String] {
        Array(allOptions.dropFirst())
    }

    private var isAllSelected: Bool {
        realOptions.allSatisfy { selected.contains($0) }
    }

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
                // Figma: (20, 76), w=353, h=6, step 3 of 6
                HStack(spacing: 2 * s) {
                    // Steps 1-3 — active
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                            .fill(Theme.Colors.primary)
                            .frame(height: Theme.Sizes.stepperHeight * s)
                    }
                    // Steps 4-6 — inactive
                    ForEach(0..<3, id: \.self) { _ in
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
                Text("\(userName), What is holding\nyou back right now?")
                    .font(.system(size: 26 * s, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.Colors.text)
                    .lineSpacing(26 * 0.2 * s)
                    .frame(width: 353 * s, alignment: .leading)
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (122 + 20) * s
                    )

                // ── 5. Pill checkboxes ──
                // Figma: starting at (20, ~194), each 353x52, 12px gap
                ForEach(Array(allOptions.enumerated()), id: \.element) { index, option in
                    let pillY = 194.0 + Double(index) * (52.0 + 12.0)
                    let isOptionSelected = option == "Select All" ? isAllSelected : selected.contains(option)

                    PillCheckbox(
                        title: option,
                        isSelected: isOptionSelected,
                        s: s
                    ) {
                        toggleOption(option)
                    }
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (pillY + 26) * s
                    )
                }

                // ── 6. Bottom bar ──
                // Figma: (20, 736)
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
                    y: (736 + 28) * s
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
                .position(
                    x: (20 + 56 + 16 + (355.0 - 56 - 16) / 2) * s,
                    y: (736 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }

    // MARK: - Toggle logic

    private func toggleOption(_ option: String) {
        if option == "Select All" {
            if isAllSelected {
                selected.removeAll()
            } else {
                selected = realOptions
            }
        } else {
            if selected.contains(option) {
                selected.removeAll { $0 == option }
            } else {
                selected.append(option)
            }
        }
    }
}

// MARK: - Pill Checkbox

private struct PillCheckbox: View {
    let title: String
    let isSelected: Bool
    let s: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Text label: Poppins Regular 14px, #EBEBEB, left-padded 15px
                Text(title)
                    .font(.system(size: 14 * s, weight: .regular))
                    .foregroundStyle(Theme.Colors.text)
                    .padding(.leading, 15 * s)

                Spacer()

                // Checkbox circle: 24x24 at right, padded 15px from edge
                ZStack {
                    if isSelected {
                        // Selected: filled circle with primary glow
                        Circle()
                            .fill(Theme.Colors.primary)
                            .frame(width: 24 * s, height: 24 * s)
                            .shadow(
                                color: Color(red: 0x4F/255.0, green: 0x31/255.0, blue: 0xEC/255.0).opacity(0.6),
                                radius: 6 * s, x: 0, y: 2 * s
                            )

                        // Check icon: 12x12, white
                        Image(systemName: "checkmark")
                            .font(.system(size: 12 * s, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        // Unselected: border circle, glassmorphic
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.01)
                            .frame(width: 24 * s, height: 24 * s)
                            .overlay(
                                Circle()
                                    .stroke(Theme.Colors.subtleBorder, lineWidth: 1)
                            )
                    }
                }
                .frame(width: 24 * s, height: 24 * s)
                .padding(.trailing, 15 * s)
            }
            .frame(width: 353 * s, height: Theme.Sizes.checkboxPillHeight * s)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.checkboxPill)
                    .fill(.ultraThinMaterial)
                    .opacity(0.01)
            )
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.checkboxPill)
                    .fill(Color.white.opacity(0.01))
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.checkboxPill))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.checkboxPill)
                    .stroke(
                        isSelected ? Theme.Colors.selectedBorder : Theme.Colors.glassBorder,
                        lineWidth: 2
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
    PainPointsStepView(
        selected: .constant(["Procrastination"]),
        userName: "Yagel",
        onContinue: {},
        onBack: {}
    )
}
