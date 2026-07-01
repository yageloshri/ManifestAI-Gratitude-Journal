// Parity369HowItWorksView.swift
// Figma: "How it works?" frame (340:3232) in Core App section.
// All geometry from the Figma REST spec dump (fidelity/specs/howitworks.txt)
// — do not eyeball values.

import SwiftUI

struct Parity369HowItWorksView: View {
    // mock-friendly inputs with defaults matching the Figma content exactly
    var title: String = "How it works?"
    var subtitle: String = "Write your affirmation"
    // Figma 367:2311 — the node is an unordered list, so each line renders
    // with a leading "• " bullet in the export.
    var scheduleText: String = "• 3 times in morning\n• 6 times in Afternoon\n• 9 times in night"
    // Figma 367:2325
    var tipText: String = "Consistency and feeling the emotion of already having your desire is key."
    var onNext: () -> Void = {}
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

                // Figma 340:3233: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 340:3235: rawpixel cosmic texture (0,145,392,382) STRETCH op 0.2
                Image("CosmicTexture")
                    .resizable()
                    .frame(width: 392 * sx, height: 382 * sy)
                    .opacity(0.2)
                    .parityPosition(x: 0, y: 145 * sy)

                // Figma 340:3236: SKIP (327,70,34,24) Poppins-Medium 16 #B9B9B9
                Text("SKIP")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 34 * sx, alignment: .center)
                    .contentShape(Rectangle())
                    .onTapGesture { onSkip() }
                    .parityPosition(x: 327 * sx, y: 70 * sy + 1.33 * sy)
                    .accessibilityIdentifier("howitworks369.skip")

                // Figma 340:3293: progress dots (159,107,75,9), active = 1
                Parity369ProgressDots(activeIndex: 1)
                    .parityPosition(x: 159 * sx, y: 107 * sy)

                // Figma 340:3238 + 340:3239: ground shadow + owl, baked from the
                // reference export (pt rect 74,160 — 320,379, incl. 6pt margin).
                owlImage
                    .frame(width: 246 * sx, height: 219 * sy)
                    .parityPosition(x: 74 * sx, y: 160 * sy)

                // Figma 341:3440: title (18,407,356,27) Bitter-Bold 18 centered
                Text(title)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 356 * sx, alignment: .center)
                    .parityPosition(x: 18 * sx, y: 407 * sy + 3.33 * sy)

                // Figma 341:3441: 'Write your affirmation' (52,442,288,21) #EBEBEB centered
                Text(subtitle)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 288 * sx, alignment: .center)
                    .parityPosition(x: 52 * sx, y: 442 * sy)

                // Figma 367:2311: schedule (52,473,288,63) Poppins 14 lh21 #B9B9B9 centered
                Text(scheduleText)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineSpacing(parity369Poppins14LineSpacing)
                    .multilineTextAlignment(.center)
                    .frame(width: 288 * sx, alignment: .top)
                    .parityPosition(x: 52 * sx, y: 473 * sy + 0.33 * sy)

                tipBox(sx: sx, sy: sy)
                    .parityPosition(x: 36 * sx, y: 562 * sy)

                // Figma 340:3243/340:3244: Next pill (151,690,104,40)
                Parity369NextPill(sx: sx, sy: sy, action: onNext)
                    .parityPosition(x: 151 * sx, y: 690 * sy)
                    .accessibilityIdentifier("howitworks369.next")

                // Figma 340:3248: tab bar at (0,774), "369" active
                FigmaTabBar(active: .method369, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("howitworks369.root")
    }

    // MARK: - Tip box (Figma 367:2318: (36,562,321,66) #291846 r8)

    private func tipBox(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(DesignTokens.Colors.surfaceDark)

            // Figma 367:2327: owl glyph 24×24 at rel (12,21), baked crop
            // Tip369OwlGlyph (30×30pt incl. 3pt margin over the #291846 box).
            tipGlyph
                .frame(width: 30 * sx, height: 30 * sy)
                .parityPosition(x: 9 * sx, y: 18 * sy)

            // Figma 367:2325: tip copy rel (48,12) 261×42, Poppins-Medium 14 lh21
            Text(tipText)
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .lineSpacing(parity369PoppinsMedium14LineSpacing)
                .frame(width: 261 * sx, alignment: .topLeading)
                .parityPosition(x: 48 * sx, y: 12 * sy + 0.33 * sy)
        }
        .frame(width: 321 * sx, height: 66 * sy, alignment: .topLeading)
        .accessibilityIdentifier("howitworks369.tip")
    }

    // Figma 340:3239: 'ChatGPT Image Jan 27, 2026, 04_38_15 PM 1' ref=91c87929aeba
    // Baked crop from fidelity/howitworks/figma.png (HowItWorks369OwlCrop).
    @ViewBuilder
    private var owlImage: some View {
        if UIImage(named: "HowItWorks369OwlCrop") != nil {
            Image("HowItWorks369OwlCrop").resizable()
        } else if UIImage(named: "Method369Owl") != nil {
            Image("Method369Owl").resizable()
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var tipGlyph: some View {
        if UIImage(named: "Tip369OwlGlyph") != nil {
            Image("Tip369OwlGlyph").resizable()
        } else {
            Image(systemName: "bird.fill")
                .font(.system(size: 18))
                .foregroundStyle(DesignTokens.Colors.tabInactive)
        }
    }
}

#Preview {
    Parity369HowItWorksView(parityMode: true)
}
