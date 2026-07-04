// AnalysisStepView.swift
// Figma: "Analysis" frame (270:437) in Registration Screens section
// All geometry from fidelity/analysis spec — do not eyeball values.

import SwiftUI

struct AnalysisStepView: View {
    let birthDate: Date
    let userName: String
    let onContinue: () -> Void
    var onBack: () -> Void = {}
    /// Parity gallery: fixed number 3, name "Ali".
    var parityMode: Bool = false

    var personalYear: Int {
        parityMode
            ? 3
            : NumerologyService.shared.calculatePersonalYearNumber(birthDate: birthDate)
    }

    private var displayName: String {
        userName.isEmpty ? "Friend" : userName
    }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 270:438: ellipse #4F31EC@0.51, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.51)

                // Figma 270:440: full glass panel (1,0) 392×853
                glassPanel(sx: sx, sy: sy)
                    .frame(width: 392 * sx, height: 853 * sy)
                    .parityPosition(x: 1 * sx, y: 0)

                // Figma 271:526: badge (82,111) h53, r14 — width hugs the text
                // (fixed 229pt clipped/wrapped longer names) and is truly
                // centered on the screen.
                Text("Analysis Complete, \(displayName)")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 24 * sx)
                    .frame(height: 53 * sy)
                    .figmaGlassSurface(cornerRadius: 14)
                    .frame(width: 393 * sx, alignment: .center)
                    .parityPosition(x: 0, y: 111 * sy)

                // Figma 276:538: owl illustration (56,184) 281×207.7 —
                // baked crop from the reference export (eliminates resampling
                // differences on the high-frequency illustration)
                Image("AnalysisOwlCrop")
                    .resizable()
                    .frame(width: 281 * sx, height: 207.74 * sy)
                    .parityPosition(x: 56 * sx, y: 184 * sy)

                // Figma 276:568: ground shadow under owl (136,399) 126×7
                Ellipse()
                    .fill(Color(hex: "D9D9D9").opacity(0.3))
                    .frame(width: 126 * sx, height: 7 * sy)
                    .parityPosition(x: 136 * sx, y: 399 * sy)
                    .blur(radius: 7)

                // Figma 270:522: Poppins SemiBold 18/27 #EBEBEB — centered
                // (Figma frame sat ~4.5pt right of center; "Numberology" was a
                // Figma typo, see docs/figma-typos-to-fix.md)
                Text("According to Numerology")
                    .font(DesignTokens.Typography.bodySemibold18)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(width: 393 * sx, alignment: .center)
                    .parityPosition(x: 0, y: 431 * sy)

                // Figma 276:558: gold Elemento 88×88 r25.14 with "3" — centered
                goldNumber(sx: sx, sy: sy)
                    .parityPosition(x: 152.5 * sx, y: 474 * sy)

                // Figma 270:523: Poppins Medium 16/24 #EBEBEB — centered
                Text("is your year of transformation")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(width: 393 * sx, alignment: .center)
                    .parityPosition(x: 0, y: 578 * sy)

                // Figma 282:2361: bottom bar (19.5,713)
                HStack(spacing: 16 * sx) {
                    GlassBackButton(action: onBack)
                        .accessibilityIdentifier("analysis.backButton")

                    PrimaryButton(title: "Continue", icon: nil) {
                        onContinue()
                    }
                    .accessibilityIdentifier("analysis.continueButton")
                }
                .frame(width: 355 * sx)
                .parityPosition(x: 19.5 * sx, y: 713 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("analysis.root")
    }

    // MARK: - Glass panel (Figma 270:440)

    private func glassPanel(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 270:441: abstract texture rel (-180,-118) 713×635, op 0.10,
            // imageTransform: 82.7% horizontal window starting at u=0.0228
            Image("AbstractGradient")
                .resizable()
                .frame(width: 713 * 1.2086 * sx, height: 635 * sy)
                .parityPosition(x: 713 * -0.0276 * sx, y: 0)
                .blur(radius: 28)
                .frame(width: 713 * sx, height: 635 * sy, alignment: .topLeading)
                .clipped()
                // fade the bottom edge — a hard cut left a visible seam line
                // across the screen where the texture ended
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white, location: 0.7),
                            .init(color: .white.opacity(0), location: 1)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .opacity(0.10)
                .parityPosition(x: -180 * sx, y: -118 * sy)

            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
                .frame(width: 392 * sx, height: 853 * sy)

            // Figma 270:443: cosmic texture rel (-334,-241) 955×637, op 0.70 —
            // bottom edge faded so the texture cut doesn't draw a seam line
            Image("CosmicTexture")
                .resizable()
                .frame(width: 955 * sx, height: 637 * sy)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white, location: 0.7),
                            .init(color: .white.opacity(0), location: 1)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .parityPosition(x: -334 * sx, y: -241 * sy)
                .opacity(0.70)
        }
        .frame(width: 392 * sx, height: 853 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
    }

    // MARK: - Gold number Elemento (Figma 276:558, 88×88 r25.14)

    private func goldNumber(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // blurred glow shapes
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "5B430A").opacity(0.6))
                .frame(width: 58.67, height: 41.9)
                .parityPosition(x: 21, y: 29.3)
                .blur(radius: 25.14)
                .opacity(0.5)

            // warm gold pool at the bottom (intensity matched to reference)
            Ellipse()
                .fill(DesignTokens.Colors.secondary.opacity(0.55))
                .frame(width: 48, height: 27)
                .parityPosition(x: 27, y: 86)
                .blur(radius: 34)

            // container (fill alpha matched to reference samples: +18..38 RGB over bg)
            RoundedRectangle(cornerRadius: 25.14)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "F8FBFF").opacity(0.07), location: 0),
                            .init(color: Color.white.opacity(0), location: 1)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25.14)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "D8D8D8").opacity(0.05), location: 0),
                                    .init(color: Color.white.opacity(0.22), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.3
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25.14)
                        .stroke(DesignTokens.Colors.secondary.opacity(0.18), lineWidth: 14)
                        .blur(radius: 9)
                        .clipShape(RoundedRectangle(cornerRadius: 25.14))
                )
                .frame(width: 88, height: 88)
                .shadow(color: Color.black.opacity(0.08), radius: 16.76, x: 16.76, y: 8.38)

            // Figma 276:564: "3" Bitter Bold 58, golden gradient, centered
            Text("\(personalYear)")
                .font(Font.custom("Bitter-Bold", size: 58))
                .foregroundStyle(DesignTokens.Gradients.golden)
                .frame(width: 88, height: 88, alignment: .center)
        }
        .frame(width: 88, height: 88, alignment: .topLeading)
    }
}

#Preview {
    AnalysisStepView(
        birthDate: Date(),
        userName: "Ali",
        onContinue: {},
        parityMode: true
    )
}
