// PainPointsStepView.swift
// Figma: "Problems" frame (256:1133) in Registration Screens section
// All geometry from fidelity/problems spec — do not eyeball values.

import SwiftUI

struct PainPointsStepView: View {
    @Binding var selected: [String]
    let userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    /// Parity gallery: fixed mock state, full-opacity bottom bar.
    var parityMode: Bool = false

    // Figma rows 256:1517…256:1590, top to bottom
    static let options = [
        "Select All",
        "Procrastination",
        "Self-Doubt",
        "Lack of Direction",
        "Don’t know where to Start ",
        "Emotional Fatigue",
        "Impostor Syndrome"
    ]

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 256:1134: ellipse x -30, #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, xOffset: -30)

                // Figma 256:1284: step 3/6
                OnboardingStepper(currentStep: 3)
                    .frame(width: 353 * sx)
                    .parityPosition(x: 20 * sx, y: 76 * sy)

                // Figma 256:1140: Bitter SemiBold 26/1.2 #EBEBEB
                Text("\(displayName), What is holding you back right now?")
                    .font(DesignTokens.Typography.h1)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 122 * sy)

                // Figma 256:1141: rows at y 208, 353×52, gap 12
                VStack(spacing: 12 * sy) {
                    ForEach(Self.options, id: \.self) { option in
                        pillRow(option, sx: sx, sy: sy)
                            .onTapGesture { toggle(option) }
                            .accessibilityIdentifier("problems.row.\(option.trimmingCharacters(in: .whitespaces))")
                    }
                }
                .parityPosition(x: 20 * sx, y: 208 * sy)

                // Figma 282:2334: bottom bar at (19,736), w 355, gap 16
                HStack(spacing: 16 * sx) {
                    GlassBackButton(action: onBack)
                        .accessibilityIdentifier("problems.backButton")

                    PrimaryButton(title: "Reveal My Path", icon: nil) {
                        onContinue()
                    }
                    .accessibilityIdentifier("problems.continueButton")
                }
                .frame(width: 355 * sx)
                .parityPosition(x: 19 * sx, y: 736 * sy)
                .opacity(parityMode || !selected.isEmpty ? 1 : 0.4)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("problems.root")
    }

    private var displayName: String {
        userName.isEmpty ? "Friend" : userName
    }

    private func isSelected(_ option: String) -> Bool {
        selected.contains(option)
    }

    private func toggle(_ option: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if option == "Select All" {
                selected = selected.count == Self.options.count - 1
                    ? [] : Array(Self.options.dropFirst())
            } else if let i = selected.firstIndex(of: option) {
                selected.remove(at: i)
            } else {
                selected.append(option)
            }
        }
    }

    // MARK: - Pill row (Figma: 353×52, r200 capsule, glass)

    private func pillRow(_ option: String, sx: CGFloat, sy: CGFloat) -> some View {
        let on = isSelected(option)
        return ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: 26 * sy)
                .overlay(
                    // Figma selected stroke: #685EF5, handles (0.5,-0.45)→(0.53,2.37)
                    // → effective alpha 0.84 top, 0.48 bottom
                    RoundedRectangle(cornerRadius: 26 * sy)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: DesignTokens.Colors.primary.opacity(0.84), location: 0),
                                    .init(color: DesignTokens.Colors.primary.opacity(0.48), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .opacity(on ? 1 : 0)
                )

            // label — Figma rel (15,16), Poppins Regular 14/21, #EBEBEB
            Text(option)
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .frame(height: 21 * sy)
                .parityPosition(x: 15 * sx, y: 16 * sy)

            // selector circle — Figma rel (305,14), 24×24
            selectorCircle(on: on)
                .frame(width: 24, height: 24)
                .parityPosition(x: 305 * sx, y: 14 * sy)
        }
        .frame(width: 353 * sx, height: 52 * sy, alignment: .topLeading)
    }

    @ViewBuilder
    private func selectorCircle(on: Bool) -> some View {
        if on {
            // Figma: glass circle filled by #685EF5 inset shadows → muted dark
            // purple body (≈#4A3C96 center, ≈#4E42AD edge) with a light
            // lavender rim (≈#B6B2D4) and a white check 8×5.5 @2pt.
            // Values sampled from the reference export.
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: Color(hex: "463896"), location: 0),
                            .init(color: Color(hex: "4E41AD"), location: 1)
                        ],
                        center: .center, startRadius: 0, endRadius: 12
                    )
                )
                .overlay(
                    Circle().stroke(Color(hex: "B6B2D4").opacity(0.85), lineWidth: 1.2)
                )
                .overlay(
                    CheckmarkShape()
                        .stroke(Color(hex: "FAFAFB"),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .frame(width: 8, height: 5.5)
                )
        } else {
            // Figma: glass circle, stroke #BA9DDE@0.73 → #7C5F9F@0, 1pt
            Circle()
                .fill(Color.white.opacity(0.01))
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            stops: [
                                .init(color: DesignTokens.Colors.unselectedBorder.opacity(0.73), location: 0),
                                .init(color: Color(hex: "7C5F9F").opacity(0), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                )
        }
    }
}

/// ✓ check, matches Figma check icon vector (8×5.5).
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.55))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

#Preview {
    PainPointsStepView(
        selected: .constant(["Self-Doubt"]),
        userName: "Ali",
        onContinue: {},
        onBack: {}
    )
}
