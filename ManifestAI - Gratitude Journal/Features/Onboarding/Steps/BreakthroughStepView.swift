// BreakthroughStepView.swift
// Figma: "Category" frame (255:1247) in Registration Screens section
// All geometry from fidelity/category/spec — do not eyeball values.

import SwiftUI

struct BreakthroughStepView: View {
    @Binding var selected: String?
    let onContinue: () -> Void
    let onBack: () -> Void
    /// Parity gallery: full-opacity bottom bar, no selection state.
    var parityMode: Bool = false

    // Figma cards 255:1256 / 255:1364 / 255:1382 / 256:1000.
    // The frosted Elemento container is DRAWN live (baked crops show square
    // seams); the glyph sits on a colored in-container glow, so glyph+glow
    // are baked TOGETHER as one soft 37×37 crop of the container interior
    // (pattern: Glyph369 / elementoSmall(glyphIncludesGlow:) in Home).
    private let categories: [(name: String, asset: String, glow: Color)] = [
        ("Love & Relationship", "GlyphCatLove", Color(hex: "FC0D1B")),
        ("Financial Abundance", "GlyphCatFinance", Color(hex: "F39E09")),
        ("Inner Peace", "GlyphCatPeace", Color(hex: "579341")),
        ("Career Growth", "GlyphCatCareer", Color(hex: "0089FF"))
    ]

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 255:1248: ellipse at x -30, #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, xOffset: -30)

                // Figma 255:1258: step 2/6
                OnboardingStepper(currentStep: 2)
                    .frame(width: 353 * sx)
                    .parityPosition(x: 20 * sx, y: 76 * sy)

                // Figma 255:1255: Bitter SemiBold 26/1.2 #EBEBEB, 2 lines
                Text("Where do you need a breakthrough?")
                    .font(DesignTokens.Typography.h1)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 122 * sy)

                // Figma 255:1381: cards at y 208, 353×82, gap 12
                VStack(spacing: 12 * sy) {
                    ForEach(categories, id: \.name) { category in
                        categoryCard(category, sx: sx, sy: sy)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selected = category.name
                                }
                            }
                            .accessibilityIdentifier("category.card.\(category.asset)")
                    }
                }
                .parityPosition(x: 20 * sx, y: 208 * sy)

                // Figma 282:2321: bottom bar at (20,734), w 355, gap 16
                HStack(spacing: 16 * sx) {
                    GlassBackButton(action: onBack)
                        .accessibilityIdentifier("category.backButton")

                    PrimaryButton(title: String(localized: "Reveal My Path"), icon: nil) {
                        onContinue()
                    }
                    .accessibilityIdentifier("category.continueButton")
                }
                .frame(width: 355 * sx)
                .parityPosition(x: 20 * sx, y: 734 * sy)
                .opacity(parityMode || selected != nil ? 1 : 0.4)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("category.root")
    }

    // MARK: - Category Card (Figma: 353×82, r16, gradient border, glass)

    private func categoryCard(_ category: (name: String, asset: String, glow: Color),
                              sx: CGFloat, sy: CGFloat) -> some View {
        let isSelected = selected == category.name
        return ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                        .stroke(DesignTokens.Colors.primary, lineWidth: 2)
                        .opacity(isSelected ? 1 : 0)
                )

            // Elemento — drawn frosted container + baked glyph+glow crop,
            // container card-rel (15,20), 42×42
            elemento(asset: category.asset, glow: category.glow)
                .parityPosition(x: 15 * sx, y: 20 * sy)

            // Label — Figma rel (68, 27.33), Poppins Medium 16/24, #F2F2F2
            Text(category.name)
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(Color(hex: "F2F2F2"))
                .frame(width: 278 * sx, height: 28 * sy, alignment: .leading)
                .parityPosition(x: 68 * sx, y: 27.33 * sy)

            // Arrow → — Figma vector rel (314, 34.2), 14×13.67, #685EF5, 2pt
            ArrowRightShape()
                .stroke(DesignTokens.Colors.primary,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 14 * sx, height: 13.67 * sy)
                .parityPosition(x: 314 * sx, y: 34.2 * sy)
        }
        .frame(width: 353 * sx, height: 82 * sy, alignment: .topLeading)
    }

    // MARK: - Elemento (Figma: 42×42 r12 light-glass square with colored glow)

    private func elemento(asset: String, glow: Color) -> some View {
        ZStack(alignment: .topLeading) {
            // bottom pool (the inner-rect glow is baked into the glyph crop) —
            // CLIPPED by the Elemento frame in Figma: fig returns to bg
            // immediately below the container
            ZStack(alignment: .topLeading) {
                // soft inner blob — tops up the mid-glow the soft matte
                // under-captures (measured: app -15 R above the glyph)
                RoundedRectangle(cornerRadius: 4)
                    .fill(glow)
                    .frame(width: 28, height: 20)
                    .parityPosition(x: 10, y: 14)
                    .blur(radius: 12)
                    .opacity(0.25)

                Ellipse()
                    .fill(glow)
                    .frame(width: 23, height: 13)
                    .parityPosition(x: 13, y: 39)
                    .blur(radius: 9)
                    .opacity(1.0)
            }
            .frame(width: 42, height: 42, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard))

            // container — fill #F8FBFF→clear, stroke #D8D8D8@0.05→#FFF@0.4 (0.8pt),
            // inner glow color@0.32 blur 8, drop shadow #000@0.08 (8,4,16)
            RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
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
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "D8D8D8").opacity(0.05), location: 0),
                                    .init(color: Color.white.opacity(0.15), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                        .stroke(glow.opacity(0.12), lineWidth: 8)
                        .blur(radius: 4)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard))
                )
                .frame(width: 42, height: 42)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 8, y: 4)

            // baked glyph+glow crop (37×37 of the container interior)
            Image(asset)
                .resizable()
                .frame(width: 37, height: 37)
                .parityPosition(x: 2.5, y: 2.5)
        }
        .frame(width: 42, height: 42, alignment: .topLeading)
    }
}

/// → arrow, matches Figma Arrow vector (horizontal shaft + 45° head).
struct ArrowRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.midY
        p.move(to: CGPoint(x: rect.minX, y: midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: midY))
        let head = rect.height / 2
        p.move(to: CGPoint(x: rect.maxX - head, y: midY - head))
        p.addLine(to: CGPoint(x: rect.maxX, y: midY))
        p.addLine(to: CGPoint(x: rect.maxX - head, y: midY + head))
        return p
    }
}

#Preview {
    BreakthroughStepView(
        selected: .constant(nil),
        onContinue: {},
        onBack: {}
    )
}
