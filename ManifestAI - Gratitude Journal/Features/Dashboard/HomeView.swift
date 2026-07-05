// HomeView.swift
// Figma: "Home" frame (300:2058) in Core App section
// All geometry from the Figma REST spec — do not eyeball values.

import SwiftUI

struct HomeView: View {
    var userName: String = "Ali"
    var dailyNumber: Int = 3
    var streak: Int = 2
    var totalEntries: Int = 12
    var boardCount: Int = 0
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    var onOpenNumerology: () -> Void = {}
    var onOpenJournal: () -> Void = {}
    var onOpenVision: () -> Void = {}
    var onOpen369: () -> Void = {}
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 307:1240: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 307:1238: cosmic texture (0,0,393,396) op 0.12,
                // imageTransform window → rendered 956×637 at (-334,-241), clipped
                Image("CosmicTexture")
                    .resizable()
                    .frame(width: 956 * sx, height: 637 * sy)
                    .parityPosition(x: -334 * sx, y: -241 * sy)
                    .frame(width: 393 * sx, height: 396 * sy, alignment: .topLeading)
                    .clipped()
                    .opacity(0.12)

                header(sx: sx, sy: sy)

                numerologyCard(sx: sx, sy: sy)
                    .contentShape(Rectangle())
                    .onTapGesture { onOpenNumerology() }
                    .parityPosition(x: 20 * sx, y: 145 * sy)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Daily Numerology — read full insight")
                    .accessibilityIdentifier("home.numerologyCard")

                streakCard(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 278 * sy)

                // Figma 312:1446
                // Centered app-wide per product decision (owner override —
                // same treatment as the profile's gray section heading).
                Text("Your Manifestation Hub")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 353 * sx, alignment: .center)
                    .parityPosition(x: 20 * sx, y: 366 * sy)

                journalCard(sx: sx, sy: sy)
                    .contentShape(Rectangle())
                    .onTapGesture { onOpenJournal() }
                    .parityPosition(x: 20 * sx, y: 402 * sy)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Gratitude Journal — write today's entry")
                    .accessibilityIdentifier("home.journalCard")

                visionCard(sx: sx, sy: sy)
                    .contentShape(Rectangle())
                    .onTapGesture { onOpenVision() }
                    .parityPosition(x: 20 * sx, y: 607 * sy)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Vision Board")
                    .accessibilityIdentifier("home.visionCard")

                method369Card(sx: sx, sy: sy)
                    .contentShape(Rectangle())
                    .onTapGesture { onOpen369() }
                    .parityPosition(x: 202 * sx, y: 607 * sy)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("369 Method — start session")
                    .accessibilityIdentifier("home.369Card")

                // Figma 318:1814: tab bar at (0,774)
                FigmaTabBar(active: .today, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("home.root")
    }

    // MARK: - Header (Figma 307:1314)

    // No avatar — greeting and subtitle are centered across the screen.
    private func header(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Text("\(timeGreeting), \(userName)")
                .font(DesignTokens.Typography.h4)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 353 * sx, alignment: .center)
                .parityPosition(x: 20 * sx, y: 70.67 * sy)

            Text(timeSubtitle)
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .frame(width: 353 * sx, alignment: .center)
                .parityPosition(x: 20 * sx, y: 100 * sy)
        }
    }

    /// Greeting follows the user's local time of day.
    private var timeGreeting: String {
        if parityMode { return "Good Morning" }
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return String(localized: "Good Morning")
        case 12..<17: return String(localized: "Good Afternoon")
        case 17..<22: return String(localized: "Good Evening")
        default: return String(localized: "Good Night")
        }
    }

    private var timeSubtitle: String {
        if parityMode { return "A calm start to your day." }
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return String(localized: "A calm start to your day.")
        case 12..<17: return String(localized: "A mindful pause in your day.")
        case 17..<22: return String(localized: "Time to reflect and manifest.")
        default: return String(localized: "Rest well — tomorrow is yours.")
        }
    }

    // MARK: - Daily Numerology card (Figma 307:1337, 353×133 r16)

    private func numerologyCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            // Figma 310:1342: art image (card-rel 180,29) 171×102 r12.
            // imageTransform window: u 0→0.709, v 0.269→0.552 →
            // rendered 241.1×359.9 at offset (-0.15,-96.64), clipped.
            Image("HomeNumerologyArt")
                .resizable()
                .frame(width: 241.1 * sx, height: 359.9 * sy)
                .parityPosition(x: -0.15 * sx, y: -96.64 * sy)
                .frame(width: 171 * sx, height: 102 * sy, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .parityPosition(x: 180 * sx, y: 29 * sy)
            // Figma 310:1345: gradient veil (card-rel 59,21) 292×115 —
            // handles run trailing→leading: dark #221546 over the art (right),
            // fading out toward the texts (left)
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "221546"), location: 0),
                    .init(color: Color(hex: "221443").opacity(0.587), location: 0.41),
                    .init(color: Color(hex: "22123E").opacity(0), location: 1)
                ],
                startPoint: .trailing, endPoint: .leading
            )
            .frame(width: 292 * sx, height: 115 * sy)
            .parityPosition(x: 59 * sx, y: 21 * sy)

            // Figma 310:1371
            Text("Daily Numerology")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .parityPosition(x: 16 * sx, y: 16 * sy)

            // Figma 310:1360: frosted gold Elemento — drawn live (translucent
            // surfaces must blend with the real background, never baked)
            goldNumberSmall(sx: sx, sy: sy)
                .parityPosition(x: 16.5 * sx, y: 55 * sy)

            // Figma 310:1368
            Text("Ignite Your Spark")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 82.5 * sx, y: 57.5 * sy)

            // Figma 310:1369 + chevron right #685EF5
            HStack(spacing: 4) {
                Text("Read Full Insight")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                ChevronRightSmallShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 5.83, height: 11.67)
                    .padding(.leading, 2)
            }
            .parityPosition(x: 82.5 * sx, y: 85.5 * sy)
        }
        .frame(width: 353 * sx, height: 133 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
        // (baked "HomeNumCardBottomCrop" strip removed — its hard top edge
        // drew a visible line across the bottom of the card)
        .accessibilityIdentifier("home.numerologyCard")
    }

    private func goldNumberSmall(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "5B430A").opacity(0.6))
                .frame(width: 36, height: 25.7)
                .parityPosition(x: 12.9, y: 22)
                .blur(radius: 15.4)
                .opacity(0.62)

            Ellipse()
                .fill(DesignTokens.Colors.secondary.opacity(0.5))
                .frame(width: 32, height: 17)
                .parityPosition(x: 15.5, y: 48)
                .blur(radius: 16)

            RoundedRectangle(cornerRadius: 15.43)
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
                    // Figma: stroke #EABD4E → #EABD4E@0.4, 2pt (gold rim)
                    RoundedRectangle(cornerRadius: 15.43)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "EABD4E").opacity(0.28), location: 0),
                                    .init(color: Color(hex: "EABD4E").opacity(0.10), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15.43)
                        .stroke(DesignTokens.Colors.secondary.opacity(0.10), lineWidth: 9)
                        .blur(radius: 5)
                        .clipShape(RoundedRectangle(cornerRadius: 15.43))
                )
                .frame(width: 54, height: 54)

            Text("\(dailyNumber)")
                .font(Font.custom("Bitter-Bold", size: 35.59))
                .foregroundStyle(DesignTokens.Gradients.golden)
                .frame(width: 54, height: 54, alignment: .center)
                .offset(y: 1.67)
        }
        .frame(width: 54, height: 54, alignment: .topLeading)
    }

    // MARK: - Streak card (Figma 311:1374, 355×64, #2C1855)

    private func streakCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(DesignTokens.Colors.streakCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: DesignTokens.Colors.streakCardBorder, location: 0),
                                    .init(color: DesignTokens.Colors.streakCardBorder.opacity(0), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )

            // (Figma's decorative tinted blocks 311:1394/1396 removed — they
            // rendered as odd lighter rectangles over the card)

            // flame + count (content block at card-rel 112,10)
            // flame baked from reference (126,287)-(170,337) → card-rel (106,9)
            Image("HomeFlameCrop")
                .resizable()
                .frame(width: 44 * sx, height: 50 * sy)
                .parityPosition(x: 106 * sx, y: 9 * sy)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(streak)")
                    .font(DesignTokens.Typography.bodySemibold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Text("Day Streak")
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
            }
            .parityPosition(x: 156 * sx, y: 10 * sy)
        }
        .frame(width: 355 * sx, height: 64 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .accessibilityIdentifier("home.streakCard")
    }

    @ViewBuilder
    private var flameIcon: some View {
        if UIImage(named: "HomeFlame") != nil {
            Image("HomeFlame").resizable()
        } else {
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color(hex: "FF6536"))
                    .blur(radius: 8)
                Image(systemName: "flame.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: "FF6536"), Color(hex: "FBBF00")],
                                       startPoint: .top, endPoint: .bottom)
                    )
            }
        }
    }

    // MARK: - Journal card (Figma 312:1464, 353×197 r16)

    private func journalCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Same dark translucent purple glass surface used by the other
            // Manifestation Hub cards (Vision Board / 369 Method) — the
            // previous baked "frost" asset rendered near-white and washed
            // out the "Total Entries" row.
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            elementoSmall(color: Color(hex: "3F36C3"), glyphAsset: "GlyphJournal")
                .parityPosition(x: 16 * sx, y: 19.5 * sy)

            Text("Gratitude Journal")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 70 * sx, y: 17.33 * sy)

            Text("Write today’s entry...")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 70 * sx, y: 45.33 * sy)

            // suggestion box (Figma 314:1510: card-rel 14,84, 326×62, #291846 r8)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8).fill(DesignTokens.Colors.surfaceDark)

                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "FFC107"))
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 12 * sx, y: 19 * sy)

                Text("Today’s Suggestion")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .parityPosition(x: 48 * sx, y: 8 * sy)

                Text("What opportunity are you grateful for? ")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary.opacity(0.7))
                    .parityPosition(x: 48 * sx, y: 33 * sy)
            }
            .frame(width: 326 * sx, height: 62 * sy, alignment: .topLeading)
            .parityPosition(x: 14 * sx, y: 85 * sy)

            // One flowing row (localized labels vary in width — absolute
            // positioning made long translations overlap the count).
            HStack(spacing: 6) {
                Text("Total Entries:")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                Text("\(totalEntries)")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .parityPosition(x: 17 * sx, y: 157.67 * sy)
        }
        .frame(width: 353 * sx, height: 197 * sy, alignment: .topLeading)
        .accessibilityIdentifier("home.journalCard")
    }

    // MARK: - Bottom cards (Figma 317:1625 / 317:1641, 172.5×135 r16)

    private func visionCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            elementoSmall(color: Color(hex: "0089FF"), glyphAsset: "GlyphVision")
                .parityPosition(x: 16 * sx, y: 16 * sy)

            Text("Vision Board")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 16 * sx, y: 70 * sy)

            // Two distinct keys — English "-s" suffixing doesn't localize.
            (boardCount == 1 ? Text("1 board") : Text("\(boardCount) boards"))
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 16 * sx, y: 98 * sy)
        }
        .frame(width: 172.5 * sx, height: 135 * sy, alignment: .topLeading)
        .accessibilityIdentifier("home.visionCard")
    }

    private func method369Card(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            elementoSmall(color: Color(hex: "F39E09"), glyphAsset: "Glyph369",
                          glyphIncludesGlow: true)
                .parityPosition(x: 15 * sx, y: 16 * sy)

            Text("369 Methods")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 15 * sx, y: 70 * sy)

            Text("Start Session")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 15 * sx, y: 98 * sy)
        }
        .frame(width: 172.5 * sx, height: 135 * sy, alignment: .topLeading)
        .accessibilityIdentifier("home.369Card")
    }

    /// 42×42 Elemento with colored glow (shared shape across Home cards).
    /// The frosted container is DRAWN (translucent → must blend live);
    /// only the opaque glyph artwork is a baked reference crop.
    private func elementoSmall(color: Color, glyphAsset: String,
                               glyphIncludesGlow: Bool = false) -> some View {
        ZStack(alignment: .topLeading) {
            if !glyphIncludesGlow {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.56))
                    .frame(width: 28, height: 20)
                    .parityPosition(x: 10, y: 19)
                    .blur(radius: 12)
                    .opacity(0.62)
            }

            Ellipse()
                .fill(color.opacity(0.45))
                .frame(width: 26, height: 14)
                .parityPosition(x: 11, y: 38)
                .blur(radius: 14)
                .opacity(glyphIncludesGlow ? 0.5 : 1)

            RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "F8FBFF").opacity(0.12), location: 0),
                            .init(color: Color.white.opacity(0), location: 1)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "D8D8D8").opacity(0.05), location: 0),
                                    .init(color: Color.white.opacity(0.4), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard)
                        .stroke(color.opacity(0.20), lineWidth: 8)
                        .blur(radius: 4)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard))
                )
                .frame(width: 42, height: 42)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 8, y: 4)

            Image(glyphAsset)
                .resizable()
                .frame(width: glyphIncludesGlow ? 37 : 26, height: glyphIncludesGlow ? 37 : 26)
                .parityPosition(x: glyphIncludesGlow ? 2.5 : 8, y: glyphIncludesGlow ? 2.5 : 8)
        }
        .frame(width: 42, height: 42, alignment: .topLeading)
    }
}

/// › small chevron (5.83×11.67), Figma Chevron rotated right.
struct ChevronRightSmallShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return p
    }
}

#Preview {
    HomeView(parityMode: true)
}
