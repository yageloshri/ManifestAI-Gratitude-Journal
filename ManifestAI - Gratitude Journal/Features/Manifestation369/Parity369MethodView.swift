// Parity369MethodView.swift
// Figma: "The 369 Method" frame (332:3006) in Core App section.
// All geometry from the Figma REST spec dump (fidelity/specs/method369.txt)
// — do not eyeball values.

import SwiftUI

struct Parity369MethodView: View {
    // mock-friendly inputs with defaults matching the Figma content exactly
    var title: String = "The 369 Method"
    // Figma 332:3020 chars (note trailing space after "universe." before the blank line)
    var bodyText: String = "Inspired by Nikola Tesla, Who believed the numbers 3, 6, and 9 hold the key to the universe. \n\nThis powerful manifestation technique uses these divine numbers to amplify your intentions."
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

                // Figma 332:3007: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 332:3013: rawpixel cosmic texture (0,145,392,382) STRETCH op 0.2
                Image("CosmicTexture")
                    .resizable()
                    .frame(width: 392 * sx, height: 382 * sy)
                    .opacity(0.2)
                    .parityPosition(x: 0, y: 145 * sy)
                    .accessibilityHidden(true) // decorative texture

                // Figma 340:3230: SKIP (327,70,34,24) Poppins-Medium 16 #B9B9B9
                Text("SKIP")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 34 * sx, alignment: .center)
                    // a11y/hit-target only: outset the 34pt frame to a ≥44pt tap area
                    .contentShape(Rectangle().inset(by: -10))
                    .onTapGesture { onSkip() }
                    .parityPosition(x: 327 * sx, y: 70 * sy + 1.33 * sy)
                    .accessibilityLabel("Skip")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("method369.skip")

                // Figma 340:3111: progress dots (159,107,75,9), active = 0
                Parity369ProgressDots(activeIndex: 0)
                    .parityPosition(x: 159 * sx, y: 107 * sy)

                // Figma 332:3016 + 332:3017: ground shadow + owl illustration,
                // baked from the reference export (pt rect 74,185 — 320,404,
                // includes 6pt glow margin + the blurred ground ellipse).
                owlImage
                    .frame(width: 246 * sx, height: 219 * sy)
                    .parityPosition(x: 74 * sx, y: 185 * sy)
                    .accessibilityHidden(true) // decorative illustration (raw asset name otherwise)

                // Figma 332:3019: title (18,432,356,27) Bitter-Bold 18 centered
                Text(title)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 356 * sx, alignment: .center)
                    .parityPosition(x: 18 * sx, y: 432 * sy + 3.33 * sy)

                // Figma 332:3020: body copy (52,467,288,147) Poppins 14 lh21 centered
                // characterStyleOverrides: 'Nikola Tesla,' / '3, 6, and 9 ' /
                // 'powerful manifestation' are Poppins-Bold spans.
                Text(attributedBody)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineSpacing(parity369Poppins14LineSpacing)
                    .multilineTextAlignment(.center)
                    .frame(width: 288 * sx, alignment: .top)
                    .parityPosition(x: 52 * sx, y: 467 * sy + 0.33 * sy)

                // Figma 340:3107/340:3117: Next pill (151,690,104,40)
                Parity369NextPill(sx: sx, sy: sy, action: onNext)
                    .parityPosition(x: 151 * sx, y: 690 * sy)
                    .accessibilityIdentifier("method369.next")

                // Figma 332:3024: tab bar at (0,774), "369" active
                FigmaTabBar(active: .method369, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("method369.root")
    }

    // Figma 332:3020 characterStyleOverrides → bold spans (style table 1 = Poppins-Bold 700)
    private var attributedBody: AttributedString {
        var attr = AttributedString(bodyText)
        let boldSpans = ["Nikola Tesla,", "3, 6, and 9 ", "powerful manifestation"]
        if let bold = UIFont(name: "Poppins-Bold", size: 14) {
            for span in boldSpans {
                if let range = attr.range(of: span) {
                    attr[range].font = Font(bold)
                }
            }
        }
        return attr
    }

    // Figma 332:3017: 'ChatGPT Image Jan 27, 2026, 04_38_15 PM 1' ref=91c87929aeba
    // Baked crop from fidelity/method369/figma.png (Method369OwlCrop).
    @ViewBuilder
    private var owlImage: some View {
        if UIImage(named: "Method369OwlCrop") != nil {
            Image("Method369OwlCrop").resizable()
        } else if UIImage(named: "Method369Owl") != nil {
            Image("Method369Owl").resizable()
        } else {
            Color.clear
        }
    }
}

// MARK: - Shared 369-onboarding pieces (used by Parity369MethodView + Parity369HowItWorksView)

/// Figma Frame 1000003730 (e.g. 340:3111): 3 pills, 9pt tall, 5pt gaps.
/// Active pill 41×9 golden gradient r30; inactive 12×9 #392564 r30.
struct Parity369ProgressDots: View {
    var activeIndex: Int = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 30)
                    .fill(i == activeIndex
                          ? AnyShapeStyle(DesignTokens.Gradients.golden)
                          : AnyShapeStyle(DesignTokens.Colors.indicatorInactive))
                    .frame(width: i == activeIndex ? 41 : 12, height: 9)
            }
        }
    }
}

/// Figma Group 48095322 (e.g. 340:3116): 104×40 "Next" pill, r12.
/// Rect 39318: fill #685EF5 + the standard glass inner-shadow stack +
/// 1pt fading #685EF5 border; label + vuesax arrow-right in #685EF5.
struct Parity369NextPill: View {
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                // Figma 340:3117: fill #685EF5 darkened by the glass inset-shadow stack
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignTokens.Colors.primary)
                    .overlay(FigmaInnerShadows(cornerRadius: 12, compact: true))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: DesignTokens.Colors.primary.opacity(0.73), location: 0),
                                        .init(color: DesignTokens.Colors.primary.opacity(0), location: 1)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Figma 340:3125: 'Next' rel (20,10) Poppins-Regular 14 #685EF5
                Text("Next")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .parityPosition(x: 20 * sx, y: 10 * sy)

                // Figma 340:3118: vuesax arrow-right strokes, rel (66.9,15.4) 14.16×10.12
                ArrowRightShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 14.16 * sx, height: 10.12 * sy)
                    .parityPosition(x: 66.9 * sx, y: 15.4 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 104 * sx, height: 40 * sy, alignment: .topLeading)
    }
}

/// Figma "Small-Text" line height is 21px; SwiftUI lineSpacing adds to the
/// font's natural line height, so derive the delta from UIFont.
var parity369Poppins14LineSpacing: CGFloat {
    let font = UIFont(name: "Poppins-Regular", size: 14) ?? .systemFont(ofSize: 14)
    return max(0, 21 - font.lineHeight)
}

var parity369PoppinsMedium14LineSpacing: CGFloat {
    let font = UIFont(name: "Poppins-Medium", size: 14) ?? .systemFont(ofSize: 14, weight: .medium)
    return max(0, 21 - font.lineHeight)
}

#Preview {
    Parity369MethodView(parityMode: true)
}
