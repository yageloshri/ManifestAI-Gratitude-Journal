// ParityVisionCategoryView.swift
// Figma: Vision Board "Select Category" frame 325:12793 ("Name", Vision section)
// Spec: fidelity/specs/vision_category.txt — all geometry from the dump, do not eyeball.

import SwiftUI

struct ParityVisionCategoryView: View {
    var onBack: () -> Void = {}
    var onSelectCategory: (String) -> Void = { _ in }
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    /// Card grid (Figma 327:1339). Positions, icon offsets and ids from the spec.
    /// SF symbols are placeholders for the multi-path #685EF5 vector icons.
    private struct Category {
        let name: String
        let sfSymbol: String
        let cardNodeId: String
        let iconNodeId: String
        let x: CGFloat
        let y: CGFloat
        let iconY: CGFloat   // card-relative y of the 24×24 icon frame
    }

    private let categories: [Category] = [
        // Row 1 (Figma 327:1054, y=165)
        .init(name: "Love",   sfSymbol: "heart.fill",          cardNodeId: "327:1055", iconNodeId: "327:1246", x: 20,  y: 165, iconY: 24),
        .init(name: "Wealth", sfSymbol: "dollarsign",          cardNodeId: "327:1111", iconNodeId: "327:1276", x: 138, y: 165, iconY: 24),
        .init(name: "Health", sfSymbol: "cross.case.fill",     cardNodeId: "327:1098", iconNodeId: "327:1290", x: 256, y: 165, iconY: 24),
        // Row 2 (Figma 327:1124, y=271)
        .init(name: "Travel", sfSymbol: "airplane",            cardNodeId: "327:1125", iconNodeId: "327:1299", x: 20,  y: 271, iconY: 22.7),
        .init(name: "Career", sfSymbol: "briefcase.fill",      cardNodeId: "327:1137", iconNodeId: "327:1307", x: 138, y: 271, iconY: 22.7),
        .init(name: "Peace",  sfSymbol: "peacesign",           cardNodeId: "327:1149", iconNodeId: "327:1315", x: 256, y: 271, iconY: 22.7),
        // Row 3 (Figma 327:1161, y=377)
        .init(name: "Family", sfSymbol: "figure.2.and.child.holdinghands", cardNodeId: "327:1162", iconNodeId: "327:1329", x: 20, y: 377, iconY: 22.7)
    ]

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 325:12793: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 325:12794: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 325:12899: glass back button 40×40 r12 at (20,68)
                ParityVisionBackButton40(action: onBack)
                    .parityPosition(x: 20 * sx, y: 68 * sy)
                    .accessibilityIdentifier("visionCategory.back")

                // Figma 325:12902: 'Select Category' Bitter-Bold 18, #EBEBEB (84,74.5,133,27)
                // Centered app-wide per product decision (owner override —
                // the back button at x:20 stays put).
                Text("Select Category")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 353 * sx, alignment: .center)
                    .parityPosition(x: 20 * sx, y: 74.5 * sy)

                // Figma 327:1340: 'What are you calling in?' Poppins-Medium 16, #B9B9B9 (20,125,346,24)
                // Centered app-wide per product decision (owner override).
                Text("What are you calling in?")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 353 * sx, alignment: .center)
                    .parityPosition(x: 20 * sx, y: 125 * sy)

                // Figma 327:1339: category grid, 110×98 glass cards
                ForEach(categories, id: \.name) { category in
                    categoryCard(category, sx: sx, sy: sy)
                        .parityPosition(x: category.x * sx, y: category.y * sy)
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("visionCategory.root")
    }

    /// English identifiers are what's used for routing/persistence
    /// (`onSelectCategory`, `MainTabView.photosPrompt(for:)`, editor category);
    /// this maps them to a localized display string without touching the
    /// value passed through routing.
    static func localizedName(for rawName: String) -> String {
        switch rawName {
        case "Love": return String(localized: "Love")
        case "Wealth": return String(localized: "Wealth")
        case "Health": return String(localized: "Health")
        case "Travel": return String(localized: "Travel")
        case "Career": return String(localized: "Career")
        case "Peace": return String(localized: "Peace")
        case "Family": return String(localized: "Family")
        default: return rawName
        }
    }

    // MARK: - Category card (Figma 'Group 48095318' etc., 110×98 r16, 2px glass border)

    private func categoryCard(_ category: Category, sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: { onSelectCategory(category.name) }) {
            ZStack(alignment: .topLeading) {
                // Figma 'Rectangle 39320': #FBFBFB@0.01, stroke #63507A→#332643@0 2px,
                // r16 + full inset-shadow stack + backdrop blur
                Color.clear
                    .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: true)

                // Figma 'youtube' glow frame: 32×32 at card-rel (39,20), op 0.3, blur 16
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .frame(width: 32, height: 32)
                    .opacity(0.3)
                    .blur(radius: 16)
                    .parityPosition(x: 39 * sx, y: 20 * sy)

                // Figma icon vector frame: 24×24 #685EF5 at card-rel (43, iconY)
                // PARITY-TODO: bake icon crop \(category.iconNodeId) — see node ids in list above
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 19))
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 43 * sx, y: category.iconY * sy)

                // Figma 'Frame 241' label: Poppins-Medium 14, #EBEBEB, card-rel y 58, centered
                // NOTE: `category.name` is the English identifier used for
                // routing/persistence (onSelectCategory, photosPrompt(for:));
                // only the on-screen label is localized here.
                Text(Self.localizedName(for: category.name))
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 110 * sx, alignment: .top)
                    .parityPosition(x: 0, y: 58 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 110 * sx, height: 98 * sy, alignment: .topLeading)
        .accessibilityIdentifier("visionCategory.card.\(category.name.lowercased())")
    }
}
// PARITY-TODO: bake icon crop 327:1246 (Love)
// PARITY-TODO: bake icon crop 327:1276 (Wealth)
// PARITY-TODO: bake icon crop 327:1290 (Health)
// PARITY-TODO: bake icon crop 327:1299 (Travel)
// PARITY-TODO: bake icon crop 327:1307 (Career)
// PARITY-TODO: bake icon crop 327:1315 (Peace)
// PARITY-TODO: bake icon crop 327:1329 (Family)

// MARK: - 40×40 glass back button (Figma 'Group 48095322', r12, 1px fading border)

/// Smaller sibling of the shared 56×56 GlassBackButton: 40×40, 1px stroke,
/// vuesax/linear/arrow-left 20×20 #685EF5. Internal so the Upload/Photos
/// parity screens (same Figma group 48095322) can reuse it.
struct ParityVisionBackButton40: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                    .fill(Color.white.opacity(0.01))
                    .overlay(FigmaInnerShadows(cornerRadius: DesignTokens.Radii.smallCard,
                                               compact: true))
                    // Figma stroke: #63507A → #332643@0, sw=1 (fades to bottom)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: DesignTokens.Colors.glassBorder.opacity(0.73), location: 0),
                                        .init(color: Color(hex: "332643").opacity(0), location: 1)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )

                // Figma arrow-left vectors: head (rel 2.92,4.94,5.06,10.12) + shaft y=10,
                // stroke #685EF5 1.5
                ParityVisionArrowLeftShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 20, height: 20)
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }
}

/// ← arrow in a 20×20 box, matching vuesax/linear/arrow-left
/// (Figma vectors I325:12901;324:4139 / 324:4140).
struct ParityVisionArrowLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width / 20
        let h = rect.height / 20
        var p = Path()
        // shaft: (3.06,10) → (17.08,10)
        p.move(to: CGPoint(x: rect.minX + 3.06 * w, y: rect.minY + 10 * h))
        p.addLine(to: CGPoint(x: rect.minX + 17.08 * w, y: rect.minY + 10 * h))
        // head: (7.98,4.94) → (2.92,10) → (7.98,15.06)
        p.move(to: CGPoint(x: rect.minX + 7.98 * w, y: rect.minY + 4.94 * h))
        p.addLine(to: CGPoint(x: rect.minX + 2.92 * w, y: rect.minY + 10 * h))
        p.addLine(to: CGPoint(x: rect.minX + 7.98 * w, y: rect.minY + 15.06 * h))
        return p
    }
}

#Preview {
    ParityVisionCategoryView(parityMode: true)
}
