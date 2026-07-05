// ParityDailyNumerologyView.swift
// Figma: "Daily Numberology" frame (321:1862) in Core App section —
// the Home screen dimmed behind the daily-insight bottom sheet.
// All geometry from fidelity/specs_new/dailynumerology.txt.

import SwiftUI

struct ParityDailyNumerologyView: View {
    var userName: String = "Ali"
    var dailyNumber: Int = 3
    /// Live mode: personalized content (DailyInsightManager). nil → the Figma
    /// mock copy, keeping the parity gallery pixel-identical.
    var insight: PersonalizedInsight? = nil
    var onClose: () -> Void = {}
    var parityMode: Bool = false
    /// Live overlay mode (MainTabView): the REAL Home screen is already
    /// behind this view, so skip the duplicated `HomeView().blur(7)` backdrop
    /// — a second fully-blurred Home is what made the sheet slide in with a
    /// visible stutter on device. A simple dim scrim reads the same.
    var liveOverlay: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                if liveOverlay {
                    Color(hex: "16062A").opacity(0.88)
                } else {
                    // Parity gallery: Figma Rectangle 39325 #16062A@0.8 + blur 14
                    HomeView(userName: userName, dailyNumber: dailyNumber, parityMode: parityMode)
                        .blur(radius: 7)
                    Color(hex: "16062A").opacity(0.8)
                }

                sheet(sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 42 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("dailynumerology.root")
    }

    // MARK: - Sheet (Figma Frame 215: (0,42) 393×810, top corners r16)

    private func sheet(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // texture — unsplash rel (-180,-118) like other panels, op 0.2
            Image("AbstractGradient")
                .resizable()
                .frame(width: 713 * 1.2086 * sx, height: 635 * sy)
                .parityPosition(x: 713 * -0.0276 * sx, y: 0)
                .blur(radius: 28)
                .frame(width: 713 * sx, height: 635 * sy, alignment: .topLeading)
                .clipped()
                .opacity(0.20)
                .parityPosition(x: -180 * sx, y: -118 * sy)

            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
                .frame(width: 393 * sx, height: 810 * sy)

            // cosmic strip — rel (0,1) 392×246, op 0.2;
            // imageTransform window → rendered 496.3×331.7 at (-98.9,-85.7)
            Image("CosmicTexture")
                .resizable()
                .frame(width: 496.3 * sx, height: 331.7 * sy)
                .parityPosition(x: -98.9 * sx, y: -85.7 * sy)
                .frame(width: 392 * sx, height: 246 * sy, alignment: .topLeading)
                .clipped()
                .opacity(0.20)
                .parityPosition(x: 0, y: 1 * sy)

            // close button — abs (336,59) → rel (336,17), 40×40 r~59(circle-ish)
            ZStack {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 20)
                CloseXShape()
                    .stroke(DesignTokens.Colors.lightGrey,
                            style: StrokeStyle(lineWidth: 1.64, lineCap: .round))
                    .frame(width: 13.5, height: 13.5)
            }
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
            .onTapGesture { onClose() }
            .parityPosition(x: 336 * sx, y: 17 * sy)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Close")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("dailynumerology.closeButton")

            // big gold Elemento — drawn live (frosted surface must blend)
            bigGoldElemento(sx: sx, sy: sy)
                .parityPosition(x: 162 * sx, y: 57 * sy)

            // title — abs (17,180) → rel (17,138), Bitter Bold 18/27 #FCD471.
            // AI headline length varies — one line only, scale down to fit
            // (a wrapped headline would overlap the vibe text below).
            Text(insight?.headline ?? "Initiate Bold Action")
                .font(DesignTokens.Typography.h4)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: 356 * sx)
                .parityPosition(x: 17 * sx, y: 141.33 * sy)

            // insight — abs (24,215) → rel (24,173), Poppins Regular 14/21 #EBEBEB.
            // The slot below (until the first card at y=274) fits 4 lines —
            // longer AI text scales down instead of overlapping the cards.
            Text(insight?.generalVibe ?? "Today, \(userName), is a powerful fresh start! The universe aligns to empower your independence and leadership. Seize energy to initiate new paths and confidently step into your unique potential.")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(smallLineSpacing)
                .lineLimit(4)
                .minimumScaleFactor(0.75)
                .frame(width: 342 * sx, height: 96 * sy, alignment: .top)
                .parityPosition(x: 24 * sx, y: 173.33 * sy)

            // insight cards — abs y317/460 → rel 275/418, 355×131, accent strokes
            insightCard(accent: Color(hex: "DE1212"),
                        elementoColor: Color(hex: "FC0D1B"),
                        icon: "GlyphDNHeart", iconTint: Color(hex: "FA2F2F"),
                        title: String(localized: "Love & Relationship"),
                        body: insight?.loveAdvice ?? "Initiate a new conversation or express a deeply held desire to your loved on with confidence and clarity.",
                        sx: sx, sy: sy)
                .parityPosition(x: 17 * sx, y: 274 * sy)

            // Figma mock titles both cards "Love & Relationship"; live content
            // is career advice, so the live title says what the card contains.
            insightCard(accent: Color(hex: "0089FF"),
                        elementoColor: Color(hex: "0089FF"),
                        icon: "GlyphDNTarget", iconTint: Color(hex: "FF405C"),
                        title: insight == nil ? String(localized: "Love & Relationship") : String(localized: "Career & Goals"),
                        body: insight?.careerAdvice ?? "Launch that new idea or project you’ve been contemplating, stepping forward as a confident leader.",
                        sx: sx, sy: sy)
                .parityPosition(x: 17 * sx, y: 417 * sy)

            // lucky attributes — abs (17,609) → rel (17,567)
            Text("Your Lucky Attributes")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 17 * sx, y: 567 * sy)

            attributeCard(label: String(localized: "Color"), value: insight?.luckyAttributes.color ?? "Crimson",
                          icon: "paintpalette.fill", sx: sx, sy: sy)
                .parityPosition(x: 17 * sx, y: 604.67 * sy)
            attributeCard(label: String(localized: "Crystal"), value: insight?.luckyAttributes.crystal ?? "Carnelian",
                          icon: "diamond.fill", sx: sx, sy: sy)
                .parityPosition(x: 135 * sx, y: 604.67 * sy)
            attributeCard(label: String(localized: "Time"), value: insight?.luckyAttributes.time ?? "11:11",
                          icon: "clock.fill", sx: sx, sy: sy)
                .parityPosition(x: 253 * sx, y: 604.67 * sy)

            // Close CTA — abs (23,769) → rel (23,727), 347×56, white, #4E47A9
            Button(action: onClose) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                        .fill(Color.white.opacity(0.01))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                                .strokeBorder(Color(hex: "4E47A9"), lineWidth: 1)
                        )
                    Text("Close")
                        .font(DesignTokens.Typography.bodyMedium)
                        .foregroundStyle(Color(hex: "4E47A9"))
                    VuesaxChevronShape()
                        .stroke(Color(hex: "292D32"),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                        .frame(width: 7.1, height: 15.84)
                        .parityPosition(x: (347 / 2 - 25) * sx)
                }
                .frame(width: 347 * sx, height: 56 * sy)
            }
            .buttonStyle(.plain)
            .parityPosition(x: 23 * sx, y: 727 * sy)
            .accessibilityIdentifier("dailynumerology.closeCTA")
        }
        .frame(width: 393 * sx, height: 810 * sy, alignment: .topLeading)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
    }

    // MARK: - Big gold Elemento (66×66 r18.86, "3" Bitter Bold 43.5)

    private func bigGoldElemento(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // back glow: gold gradient rect 56×56 @0.4 blur 90 (rel 4.9,4.9)
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignTokens.Gradients.golden)
                .frame(width: 56.2, height: 56.2)
                .parityPosition(x: 4.9, y: 4.9)
                .blur(radius: 45)
                .opacity(0.4)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "5B430A").opacity(0.6))
                .frame(width: 44, height: 31.4)
                .parityPosition(x: 15.7, y: 22)
                .blur(radius: 18.9)
                .opacity(0.5)

            Ellipse()
                .fill(DesignTokens.Colors.secondary.opacity(0.8))
                .frame(width: 36.1, height: 20.4)
                .parityPosition(x: 20.4, y: 56)
                .blur(radius: 18)
                .frame(width: 66, height: 66, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: 18.86))

            RoundedRectangle(cornerRadius: 18.86)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "230E3A"), location: 0),
                            .init(color: Color(hex: "230E3A").opacity(0), location: 1)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18.86)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "EABD4E").opacity(0.28), location: 0),
                                    .init(color: Color(hex: "EABD4E").opacity(0.10), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.8
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18.86)
                        .stroke(DesignTokens.Colors.secondary.opacity(0.10), lineWidth: 12)
                        .blur(radius: 6.3)
                        .clipShape(RoundedRectangle(cornerRadius: 18.86))
                )
                .frame(width: 66, height: 66)

            Text("\(dailyNumber)")
                .font(Font.custom("Bitter-Bold", size: 43.5))
                .foregroundStyle(DesignTokens.Gradients.golden)
                .frame(width: 66, height: 66, alignment: .center)
        }
        .frame(width: 66, height: 66, alignment: .topLeading)
    }

    // MARK: - Insight card (355×131 r16, colored top-fading stroke)

    private func insightCard(accent: Color, elementoColor: Color,
                             icon: String, iconTint: Color,
                             title: String = String(localized: "Love & Relationship"),
                             body bodyText: String,
                             sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: accent.opacity(0.5), location: 0),
                                    .init(color: accent.opacity(0), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                )

            // small Elemento — drawn frosted container + baked glyph crop
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(elementoColor)
                    .frame(width: 18.7, height: 13.3)
                    .parityPosition(x: 6.7, y: 9.3)
                    .blur(radius: 8)
                    .opacity(0.5)
                RoundedRectangle(cornerRadius: 8)
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
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(elementoColor.opacity(0.20), lineWidth: 5.3)
                            .blur(radius: 2.7)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                    .frame(width: 32, height: 32)
                Image(icon)
                    .resizable()
                    .frame(width: 21 * sx, height: (icon == "GlyphDNHeart" ? 19 : 21) * sy)
                    .parityPosition(x: 5.5, y: 6)
            }
            .frame(width: 32, height: 32, alignment: .topLeading)
            .parityPosition(x: 16 * sx, y: 16 * sy)

            // Figma: both cards titled "Love & Relationship"
            Text(title)
                .font(DesignTokens.Typography.smallTextSemibold)
                .foregroundStyle(Color(hex: "F2F2F2"))
                .parityPosition(x: 59.33 * sx, y: 22.5 * sy)

            // AI advice length varies — the card fits 3 lines; longer text
            // scales down instead of spilling out of the 131pt card.
            Text(bodyText)
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textPrimary.opacity(0.8))
                .lineSpacing(smallLineSpacing)
                .lineLimit(3)
                .minimumScaleFactor(0.75)
                .frame(width: 322 * sx, height: 64 * sy, alignment: .topLeading)
                .parityPosition(x: 15.33 * sx, y: 57.33 * sy)
        }
        .frame(width: 355 * sx, height: 131 * sy, alignment: .topLeading)
    }

    // MARK: - Attribute card (110×98 r16)

    private func attributeCard(label: String, value: String, icon: String,
                               sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .frame(width: 24, height: 24)
                Text(label)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                // AI values ("Emerald Green"…) vary in length — one line,
                // scaled to fit the 110pt card.
                Text(value)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 6)
                    .padding(.top, -7)
            }
            .padding(.top, 14)
        }
        .frame(width: 110 * sx, height: 98 * sy)
    }

    private var smallLineSpacing: CGFloat {
        let font = UIFont(name: "Poppins-Regular", size: 14) ?? .systemFont(ofSize: 14)
        return max(0, 21 - font.lineHeight)
    }
}

/// ✕ close glyph (13.5×13.5).
struct CloseXShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return p
    }
}

#Preview {
    ParityDailyNumerologyView(parityMode: true)
}
