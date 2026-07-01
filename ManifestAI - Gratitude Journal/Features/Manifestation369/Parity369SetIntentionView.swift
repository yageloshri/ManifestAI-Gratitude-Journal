// Parity369SetIntentionView.swift
// Figma: "Set Your Intention" frame (341:3336) in Core App section.
// All geometry from the Figma REST spec dump (fidelity/specs/setintention.txt)
// — do not eyeball values.

import SwiftUI

struct Parity369SetIntentionView: View {
    // mock-friendly inputs with defaults matching the Figma content exactly
    var title: String = "Set Your Intention"
    // Figma 341:3581
    var subtitle: String = "What do you want to manifest? Write it in the present tense, as if you already have it."
    // Figma 341:3576 (placeholder, rendered at 50% opacity)
    var placeholder: String = "e.g I am so happy and grateful now that I am\nearning $10,000 a month."
    // Figma I341:3603;12:4957
    var buttonTitle: String = "Start Manifesting"
    /// Live mode: editable intention text.
    var liveText: Binding<String>? = nil
    var onStart: () -> Void = {}
    var onSkip: () -> Void = {}
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background // frame fill #16062A

                // Figma 341:3337: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 341:3339: rawpixel cosmic texture (0,145,392,382) STRETCH op 0.2
                Image("CosmicTexture")
                    .resizable()
                    .frame(width: 392 * sx, height: 382 * sy)
                    .opacity(0.2)
                    .parityPosition(x: 0, y: 145 * sy)

                // Figma 341:3340: SKIP (327,70,34,24) Poppins-Medium 16 #B9B9B9
                Text("SKIP")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 34 * sx, alignment: .center)
                    .contentShape(Rectangle())
                    .onTapGesture { onSkip() }
                    .parityPosition(x: 327 * sx, y: 70 * sy + 1.33 * sy)
                    .accessibilityIdentifier("setintention369.skip")

                // Figma 341:3572: stray 'Label' (25.5,353,353,21) #9F9E9E Poppins-Medium 14
                // (sits behind Frame 1000003731 in the Figma z-order)
                Text("Label")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.lightGrey)
                    .frame(width: 353 * sx, alignment: .leading)
                    .parityPosition(x: 25.5 * sx, y: 353 * sy)

                // Figma 341:3397: progress dots (159,107,75,9), active = 2
                Parity369ProgressDots(activeIndex: 2)
                    .parityPosition(x: 159 * sx, y: 107 * sy)

                handsElemento(sx: sx, sy: sy)
                    .parityPosition(x: 148 * sx, y: 211 * sy)
                    .accessibilityHidden(true)

                // Figma 341:3580: title (19,328,356,27) Bitter-Bold 18 centered
                Text(title)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 356 * sx, alignment: .center)
                    .parityPosition(x: 19 * sx, y: 328 * sy + 3.33 * sy)

                // Figma 341:3581: subtitle (41,363,312,42) Poppins 14 lh21 #B9B9B9 centered
                Text(subtitle)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineSpacing(parity369Poppins14LineSpacing)
                    .multilineTextAlignment(.center)
                    .frame(width: 312 * sx, alignment: .top)
                    .parityPosition(x: 41 * sx, y: 363 * sy + 0.33 * sy)

                intentionCard(sx: sx, sy: sy)
                    .parityPosition(x: 24 * sx, y: 432 * sy)

                startButton(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 641 * sy)

                // Figma 341:3352: tab bar at (0,774), "369" active
                FigmaTabBar(active: .method369, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("setintention369.root")
    }

    // MARK: - Intention input card (Figma 341:3573: (24,432,345,132) r16 glass)

    private func intentionCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 341:3574: glass rect, full inset-shadow stack + fading border
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            // Figma 341:3576: placeholder rel (15,16) 316×42, op 0.5, Poppins 14 lh21
            if let liveText {
                TextEditor(text: liveText)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .tint(DesignTokens.Colors.primary)
                    .frame(width: 316 * sx, height: 100 * sy, alignment: .topLeading)
                    .parityPosition(x: 11 * sx, y: 8 * sy)
                    .overlay(alignment: .topLeading) {
                        if liveText.wrappedValue.isEmpty {
                            Text(placeholder)
                                .font(DesignTokens.Typography.smallText)
                                .foregroundStyle(DesignTokens.Colors.textPrimary)
                                .opacity(0.5)
                                .lineSpacing(parity369Poppins14LineSpacing)
                                .frame(width: 316 * sx, alignment: .topLeading)
                                .parityPosition(x: 15 * sx, y: 16 * sy + 0.33 * sy)
                                .allowsHitTesting(false)
                        }
                    }
                    .accessibilityIdentifier("setintention369.editor")
            } else {
                Text(placeholder)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .opacity(0.5)
                    .lineSpacing(parity369Poppins14LineSpacing)
                    .frame(width: 316 * sx, alignment: .topLeading)
                    .parityPosition(x: 15 * sx, y: 16 * sy + 0.33 * sy)
            }

            // Figma 341:3577: Arrow_Left_MD vector rel (309,22) 14×12, #685EF5 2pt
            ArrowRightShape()
                .stroke(DesignTokens.Colors.primary,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 14 * sx, height: 12 * sy)
                .parityPosition(x: 309 * sx, y: 22 * sy)
        }
        .frame(width: 345 * sx, height: 132 * sy, alignment: .topLeading)
        .accessibilityIdentifier("setintention369.input")
    }

    // MARK: - Praying-hands Elemento (Figma 341:3723: (148,211,86,86))
    // Frosted container + glows DRAWN live (translucent surfaces must blend
    // with the real background — baked crops show square seams); only the
    // opaque gold-hands glyph is a baked reference crop (GlyphIntentionHands).

    private func handsElemento(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 341:3724: back glow rect (rel 6,6) 75×75 #7D42C3, layer blur 64
            // (this one is NOT clipped — it forms the purple halo around the
            // container; fig bg near the container reads ~(55,27,102) vs base)
            Rectangle()
                .fill(Color(hex: "7D42C3"))
                .frame(width: 75, height: 75)
                .parityPosition(x: 6, y: 6)
                .blur(radius: 30)
                .opacity(0.85)

            // Figma 341:3730: bottom pool 47.1×26.62 rel (26.6,84) #0089FF —
            // CLIPPED by the Elemento frame in Figma (fig dies right below
            // the container); the 'youtube' inner glow is baked in the crop
            ZStack(alignment: .topLeading) {
                Ellipse()
                    .fill(Color(hex: "0089FF"))
                    .frame(width: 47.1, height: 26.62)
                    .parityPosition(x: 26.6, y: 84)
                    .blur(radius: 14)
                    .opacity(0.85)
            }
            .frame(width: 86, height: 86, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: 24.57))

            // Figma 341:3726: Elemento 86×86 r24.57, frost fill + #0089FF inner glow
            RoundedRectangle(cornerRadius: 24.57)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "F8FBFF").opacity(0.08), location: 0),
                            .init(color: Color.white.opacity(0), location: 1)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24.57)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "D8D8D8").opacity(0.05), location: 0),
                                    .init(color: Color.white.opacity(0.07), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    // INNER_SHADOW(#0089FF@0.32 blur 16.38)
                    RoundedRectangle(cornerRadius: 24.57)
                        .stroke(Color(hex: "0089FF").opacity(0.30), lineWidth: 17)
                        .blur(radius: 8.5)
                        .clipShape(RoundedRectangle(cornerRadius: 24.57))
                )
                .frame(width: 86, height: 86)
                .shadow(color: Color.black.opacity(0.08), radius: 16.38, x: 16.38, y: 8.19)

            // glyph + in-container glow baked TOGETHER (hearts sit on the
            // bright 'youtube' glow) — 76×76 interior crop at rel (5,5)
            Image("GlyphIntentionHands")
                .resizable()
                .frame(width: 76, height: 76)
                .parityPosition(x: 5, y: 5)
        }
        .frame(width: 86, height: 86, alignment: .topLeading)
        .scaleEffect(x: sx, y: sy, anchor: .topLeading)
    }

    // MARK: - CTA (Figma 341:3603: Button Default (20,641,353,56) op 0.3)

    private func startButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onStart) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma I341:3603;12:4957: label rel (16,16) 321×24 white centered
                Text(buttonTitle)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 321 * sx, alignment: .center)
                    .parityPosition(x: 16 * sx, y: 16 * sy + 1.33 * sy)

                // Figma I341:3603;14:13869: chevron rel (306.9,20.1) 7.1×15.84 white 1.5pt
                ChevronRightSmallShape()
                    .stroke(.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.1 * sx, height: 15.84 * sy)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 353 * sx, height: 56 * sy, alignment: .topLeading)
        .opacity(0.3) // Figma instance op=0.3 (disabled state)
        .accessibilityIdentifier("setintention369.start")
    }
}

#Preview {
    Parity369SetIntentionView(parityMode: true)
}
