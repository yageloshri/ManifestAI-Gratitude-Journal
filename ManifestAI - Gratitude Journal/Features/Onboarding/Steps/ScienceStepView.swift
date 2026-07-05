// ScienceStepView.swift
// Figma: "Did you know" frame (257:1658) in Registration Screens section
// All geometry from fidelity/didyouknow spec — do not eyeball values.

import SwiftUI

struct ScienceStepView: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    /// Parity gallery: deterministic final state.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 257:1659: ellipse x -30, #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, xOffset: -30)

                // Figma 257:1760: step 4/6
                OnboardingStepper(currentStep: 4)
                    .frame(width: 353 * sx)
                    .parityPosition(x: 20 * sx, y: 76 * sy)

                // Figma 257:1833: glass card (13,151) 353×484, r16, clipped
                factCard(sx: sx, sy: sy)
                    .frame(width: 353 * sx, height: 484 * sy)
                    .parityPosition(x: 13 * sx, y: 151 * sy)

                // Figma 282:2343: bottom bar at (19,703), w 355, gap 16
                HStack(spacing: 16 * sx) {
                    GlassBackButton(action: onBack)
                        .accessibilityIdentifier("didyouknow.backButton")

                    PrimaryButton(title: String(localized: "Wow Tell Me More"), icon: nil) {
                        onContinue()
                    }
                    .accessibilityIdentifier("didyouknow.continueButton")
                }
                .frame(width: 355 * sx)
                .parityPosition(x: 19 * sx, y: 703 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("didyouknow.root")
    }

    // MARK: - Fact card (Figma 257:1833)

    private func factCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 257:1830: abstract texture, card-rel (-180,-118) 713×635,
            // flipped horizontally, op 0.2, softened by the panel backdrop-blur
            Image("AbstractGradient")
                .resizable()
                .frame(width: 713 * 1.2086 * sx, height: 635 * sy)
                .parityPosition(x: 713 * -0.0276 * sx, y: 0)
                .blur(radius: 28)
                .frame(width: 713 * sx, height: 635 * sy, alignment: .topLeading)
                .clipped()
                .scaleEffect(x: -1, y: 1)
                .opacity(0.20)
                .parityPosition(x: -180 * sx, y: -118 * sy)

            // Figma 257:1834: glass surface below texts/images
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
                .frame(width: 353 * sx, height: 484 * sy)

            // Figma 258:1840: cosmic texture, card-rel (-98,-83) 493×329, op 0.6
            Image("CosmicTexture")
                .resizable()
                .frame(width: 493 * sx, height: 329 * sy)
                .parityPosition(x: -98 * sx, y: -83 * sy)
                .opacity(0.60)

            // Figma 257:1836: owl illustration, card-rel (80,18) 194×194
            Image("ScienceOwl")
                .resizable()
                .frame(width: 194 * sx, height: 194 * sy)
                .parityPosition(x: 80 * sx, y: 18 * sy)

            // Figma 258:1843: Bitter SemiBold 26/1.2 #FCD471, centered
            Text("Did you know?")
                .font(DesignTokens.Typography.h1)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 323 * sx)
                .parityPosition(x: 15 * sx, y: 246 * sy)

            // Figma 258:1844: Poppins Medium 16/24 #EBEBEB, centered
            Text("Neuroscience shows that practicing gratitude for 21 days physically rewires your brain.")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(poppinsLineSpacing)
                .frame(width: 307 * sx)
                // 289 in Figma; +1.33 absorbs SwiftUI half-leading (measured)
                .parityPosition(x: 23 * sx, y: 290.33 * sy)

            // Figma 258:1845: Poppins Medium 16/24 #B9B9B9, centered
            Text("It boosts happiness levels by 25% and improves long-term mental clarity.")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(poppinsLineSpacing)
                .frame(width: 323 * sx)
                // 385 in Figma; +1.33 absorbs SwiftUI half-leading (measured)
                .parityPosition(x: 15 * sx, y: 386.33 * sy)
        }
        .frame(width: 353 * sx, height: 484 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
    }

    /// Poppins 16 with Figma line-height 24px.
    private var poppinsLineSpacing: CGFloat {
        let font = UIFont(name: "Poppins-Medium", size: 16) ?? .systemFont(ofSize: 16)
        return max(0, 24 - font.lineHeight)
    }
}

#Preview {
    ScienceStepView(onContinue: {}, onBack: {}, parityMode: true)
}
