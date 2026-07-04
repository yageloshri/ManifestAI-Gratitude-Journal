// WelcomeStepView.swift
// Figma: "Onboarding" frame (258:1851) in Registration Screens section
// All geometry from fidelity/onboarding/spec.json — do not eyeball values.

import SwiftUI
import UIKit

struct WelcomeStepView: View {
    let onContinue: () -> Void
    /// When true (parity gallery), renders the final state immediately:
    /// no typewriter animation, button fully visible.
    var parityMode: Bool = false

    @State private var titleLine1: String
    @State private var titleLine2: String
    @State private var showContent: Bool

    // Figma 264:874 — exact span text from the design
    private static let fullLine1 = "Turn your dreams "
    private static let fullLine2 = "into reality in 5 mins a day."

    init(onContinue: @escaping () -> Void, parityMode: Bool = false) {
        self.onContinue = onContinue
        self.parityMode = parityMode
        _titleLine1 = State(initialValue: parityMode ? Self.fullLine1 : "")
        _titleLine2 = State(initialValue: parityMode ? Self.fullLine2 : "")
        _showContent = State(initialValue: parityMode)
    }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Purple ellipse glow — Figma 258:1852: (0,12) 578.67×677.5, #4F31EC @51%
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.51)

                // Glass panel — Figma 264:857/859: (1,0) 392×853, radius 16, clipped contents
                glassPanel(sx: sx, sy: sy)
                    .frame(width: 392 * sx, height: 853 * sy)
                    .parityPosition(x: 1 * sx, y: 0)

                // Welcome badge — Figma 268:1015: centered-1, top 65, 229×75, radius 14
                welcomeBadge(sx: sx, sy: sy)
                    .frame(width: 229 * sx, height: 75 * sy)
                    .parityPosition(x: (393 / 2 - 1 - 229 / 2) * sx, y: 65 * sy)

                // Headline — Figma 264:874: left 34, top 508, width 330, Bitter 37/1.2
                headlineText
                    .lineSpacing(headlineLineSpacing)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(width: 330 * sx, alignment: .topLeading)
                    // 508 in Figma; -1.33 absorbs Bitter's first-baseline offset
                    // (measured via pixel diff against the reference export)
                    .parityPosition(x: 34 * sx, y: 506.67 * sy)
                    .accessibilityIdentifier("welcome.headline")

                // CTA — Figma 264:879: centered+0.5, top 690, 332×56
                PrimaryButton(title: "Start My Journey", icon: "arrow.right") {
                    onContinue()
                }
                .frame(width: 332 * sx)
                // center+0.5 / 690 in Figma; ±1pt nudges measured via pixel diff
                .parityPosition(x: (393 / 2 - 0.5 - 332 / 2) * sx, y: 689.33 * sy)
                .opacity(showContent ? 1 : 0)
                .accessibilityIdentifier("welcome.startButton")
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("welcome.root")
        .onAppear {
            if !parityMode { runTypewriterAnimation() }
        }
    }

    // MARK: - Headline (single wrapped paragraph, two font spans)

    private var headlineText: Text {
        Text(titleLine1)
            .font(.custom("Bitter-LightItalic", size: 37))
        + Text(titleLine2)
            .font(.custom("Bitter-SemiBold", size: 37))
    }

    /// Figma line-height is 1.2 (44.4pt). SwiftUI lineSpacing adds to the
    /// font's natural line height, so derive the delta from UIFont.
    private var headlineLineSpacing: CGFloat {
        let font = UIFont(name: "Bitter-SemiBold", size: 37) ?? .systemFont(ofSize: 37)
        return max(0, 37 * 1.2 - font.lineHeight)
    }

    private var badgeLineSpacing: CGFloat {
        let font = UIFont(name: "Bitter-Bold", size: 18) ?? .systemFont(ofSize: 18)
        return max(0, 18 * 1.38 - font.lineHeight)
    }

    // MARK: - Glass panel with clipped texture/illustration layers

    private func glassPanel(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Abstract gradient texture — Figma 264:858: box 713×635 at (-180,-118),
            // inner image 120.86% wide offset -2.76%, flipped horizontally, opacity 0.20
            // The Figma panel (264:859) applies backdrop-blur 56.5 to everything
            // beneath it — this texture and the ellipse glow. Bake that blur in here.
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

            // Figma z-order: the border rect (264:859) with its inset shadows and
            // #63507A stroke sits BELOW the cosmic texture and owl — they are
            // drawn over it, unshadowed.
            glassInnerShadows(sx: sx, sy: sy)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                        .stroke(DesignTokens.Colors.glassBorder, lineWidth: 2)
                )
                .frame(width: 392 * sx, height: 853 * sy)

            // Cosmic texture — Figma 264:865: box 393×396 at (-1,0),
            // inner image 243.28%×160.86% offset (-84.87%, -60.86%), opacity 0.60
            Image("CosmicTexture")
                .resizable()
                .frame(width: 393 * 2.4328 * sx, height: 396 * 1.6086 * sy)
                .parityPosition(x: 393 * -0.8487 * sx, y: 396 * -0.6086 * sy)
                .frame(width: 393 * sx, height: 396 * sy, alignment: .topLeading)
                .clipped()
                .opacity(0.60)
                .parityPosition(x: -1 * sx, y: 0)

            // Owl illustration — Figma 265:960: box 364×369 at (-1,120),
            // inner image 121.25%×179.4% offset (-21.2%, -33.33%)
            Image("WelcomeOwl")
                .resizable()
                .frame(width: 364 * 1.2125 * sx, height: 369 * 1.794 * sy)
                .parityPosition(x: 364 * -0.212 * sx, y: 369 * -0.3333 * sy)
                .frame(width: 364 * sx, height: 369 * sy, alignment: .topLeading)
                .clipped()
                .parityPosition(x: -1 * sx, y: 120 * sy)
        }
        .frame(width: 392 * sx, height: 853 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
    }

    /// Approximation of Figma 264:859 inset-shadow stack.
    /// Figma shadows (inset): 0/48.97/70.3/-45.2 rgba(21,15,108,.5);
    /// 0/8.79/13.8/-5 #271839; 0/123/125.6/-60.3 #271839;
    /// 0/5/22.6/0 #271839; 0/1.26/50.2/0 #1A0B2C; plus bottom-band shadows.
    private func glassInnerShadows(sx: CGFloat, sy: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
        return shape
            .fill(Color.clear)
            // all-edge vignette: 0 5.023 22.602 0 #271839
            .overlay(
                shape.stroke(DesignTokens.Colors.innerShadow1, lineWidth: 23)
                    .blur(radius: 11)
            )
            // all-edge deep vignette: 0 1.256 50.226 0 #1A0B2C
            .overlay(
                shape.stroke(DesignTokens.Colors.innerShadow3, lineWidth: 50)
                    .blur(radius: 25)
            )
            // top band: 0 123.053 125.565 -60.271 #271839
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.innerShadow1, location: 0),
                        .init(color: DesignTokens.Colors.innerShadow1.opacity(0), location: 0.28)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            // top tint: 0 48.97 70.316 -45.203 rgba(21,15,108,0.5)
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.innerShadow2.opacity(0.5), location: 0),
                        .init(color: DesignTokens.Colors.innerShadow2.opacity(0), location: 0.14)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            // bottom band: 0 -102.963 85.384 -80.361 rgba(39,24,57,0.3)
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.innerShadow1.opacity(0), location: 0.86),
                        .init(color: DesignTokens.Colors.innerShadow1.opacity(0.3), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(shape)
    }

    // MARK: - Welcome badge

    private func welcomeBadge(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.headerBadge)
                .fill(Color.white.opacity(0.01))
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: DesignTokens.Radii.headerBadge))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.headerBadge)
                        .stroke(DesignTokens.Colors.glassBorder, lineWidth: 2)
                )

            Text("Welcome to Gratitude Journal: Manifest")
                .font(DesignTokens.Typography.h4)
                .lineSpacing(badgeLineSpacing)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 195 * sx)
                // Figma text top is y78 in a y65/h75 box (+0.34pt off-center);
                // remainder absorbs Bitter metrics, measured via pixel diff
                .parityPosition(y: 1 * sy)
        }
    }

    // MARK: - Typewriter Animation (live app only)

    private func runTypewriterAnimation() {
        guard titleLine1.isEmpty else { return }

        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()

        for (index, char) in Self.fullLine1.enumerated() {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleLine1.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
        }

        let line2StartDelay = Double(Self.fullLine1.count) * 0.05 + 0.2
        for (index, char) in Self.fullLine2.enumerated() {
            let delay = line2StartDelay + Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleLine2.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
        }

        let finalDelay = line2StartDelay + Double(Self.fullLine2.count) * 0.05 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + finalDelay) {
            withAnimation(.easeIn(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

#Preview {
    WelcomeStepView(onContinue: {})
}

#Preview("Parity") {
    WelcomeStepView(onContinue: {}, parityMode: true)
}
