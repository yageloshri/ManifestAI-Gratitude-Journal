// CommitmentStepView.swift
// Figma: "A promise to you self" frame (282:570) in Registration Screens section
// All geometry from fidelity/commitment spec — do not eyeball values.

import SwiftUI
import UIKit

struct CommitmentStepView: View {
    let onComplete: () -> Void
    let onBack: () -> Void
    /// Parity gallery: deterministic final state, no hold interaction running.
    var parityMode: Bool = false

    @State private var isHolding = false
    @State private var progress: CGFloat = 0
    @State private var committed = false

    /// How long the fingerprint must be held to commit.
    private static let holdDuration: Double = 3.0

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 282:571: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 282:690: step 6/6 (all active)
                OnboardingStepper(currentStep: 6)
                    .frame(width: 353 * sx)
                    .parityPosition(x: 20 * sx, y: 76 * sy)

                // Figma 282:676: inner glass card (21,135) 353×561, r16
                promiseCard(sx: sx, sy: sy)
                    .frame(width: 353 * sx, height: 564 * sy)
                    .parityPosition(x: 21 * sx, y: 135 * sy)

                // Bottom bar: back button only — committing happens by
                // holding the fingerprint for 3s, not via a Continue button.
                GlassBackButton(action: onBack)
                    .accessibilityIdentifier("commitment.backButton")
                    .parityPosition(x: 19.5 * sx, y: 737 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("commitment.root")
    }

    // MARK: - Promise card (Figma 282:676, card-relative geometry)

    private func promiseCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 282:677: abstract texture rel (-180,-118) 713×635, op 0.2
            Image("AbstractGradient")
                .resizable()
                .frame(width: 713 * 1.2086 * sx, height: 635 * sy)
                .parityPosition(x: 713 * -0.0276 * sx, y: 0)
                .blur(radius: 28)
                .frame(width: 713 * sx, height: 635 * sy, alignment: .topLeading)
                .clipped()
                // fade the bottom edge — a hard cut leaves a seam line
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
                .opacity(0.20)
                .parityPosition(x: -180 * sx, y: -118 * sy)

            // Figma 282:678: glass surface 353×561
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
                .frame(width: 353 * sx, height: 561 * sy)

            // Figma 282:684: cosmic texture rel (-98,-83) 493×329, op 0.6
            Image("CosmicTexture")
                .resizable()
                .frame(width: 493 * sx, height: 329 * sy)
                .parityPosition(x: -98 * sx, y: -83 * sy)
                .opacity(0.60)

            // Figma 282:685: owl rel (79,18) 195×195, FILL crop
            Image("CommitOwl")
                .resizable()
                .scaledToFill()
                .frame(width: 195 * sx, height: 195 * sy)
                .clipped()
                .parityPosition(x: 79 * sx, y: 18 * sy)

            // Figma 282:681: Bitter SemiBold 26/1.2 #FCD471, centered, rel (23,234)
            Text("A promise to you self")
                .font(DesignTokens.Typography.h1)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 307 * sx)
                .parityPosition(x: 23 * sx, y: 234 * sy)

            // Figma 282:682: Poppins Medium 16/24 #EBEBEB, rel (23,277) — bulleted list
            Text("• Change requires consistency.")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .frame(width: 307 * sx)
                .parityPosition(x: 23 * sx, y: 278.33 * sy)

            // Figma 282:703: Poppins Medium 16/24 #EBEBEB, rel (23,313) — bulleted list
            Text("• Can you commit to investing 3 minutes a day in yourself?")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(poppinsLineSpacing)
                .frame(width: 307 * sx)
                .parityPosition(x: 23 * sx, y: 314.33 * sy)

            // Figma 282:704: purple Elemento 88×88 — frosted container DRAWN
            // live (baked crops show square seams); abs (154,548) → card-rel (133,413)
            commitElemento(sx: sx, sy: sy)
                .parityPosition(x: 133 * sx, y: 413 * sy)

            // Figma 282:734: Poppins Regular 14/21 #B9B9B9, rel (84,515)
            Text("Touch and hold for 3 seconds to commit")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(width: 186 * sx)
                .parityPosition(x: 84 * sx, y: 515 * sy)
        }
        .frame(width: 353 * sx, height: 564 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
    }

    // MARK: - Purple hold-to-commit Elemento (Figma 282:704)

    private func commitElemento(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // gold pool under (Figma 282:709: 48.19×27.24 rel (27.2,85.9),
            // layer blur 37.71) — CLIPPED by the Elemento frame in Figma:
            // fig returns to bg immediately below the container
            ZStack(alignment: .topLeading) {
                Ellipse()
                    .fill(DesignTokens.Colors.secondary)
                    .frame(width: 48.19, height: 27.24)
                    .parityPosition(x: 27.2, y: 85.9)
                    .blur(radius: 15)
                    .opacity(0.6)
            }
            .frame(width: 88, height: 88, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: 25.14))

            // container — fill #685EF5→clear, purple inner glow
            RoundedRectangle(cornerRadius: 25.14)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: DesignTokens.Colors.primary.opacity(0.18), location: 0),
                            .init(color: DesignTokens.Colors.primary.opacity(0), location: 1)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25.14)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "D8D8D8").opacity(0.05), location: 0),
                                    .init(color: Color.white.opacity(0.22), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.68
                        )
                )
                .overlay(
                    // INNER_SHADOW(#685EF5@1 blur 16.76)
                    RoundedRectangle(cornerRadius: 25.14)
                        .stroke(DesignTokens.Colors.primary.opacity(0.36), lineWidth: 17.6)
                        .blur(radius: 8.8)
                        .clipShape(RoundedRectangle(cornerRadius: 25.14))
                )
                .frame(width: 88, height: 88)
                .shadow(color: Color.black.opacity(0.08), radius: 16.76, x: 16.76, y: 8.38)

            // fingerprint glyph + in-container glow baked TOGETHER —
            // 80×80 interior crop at rel (4,4)
            Image("GlyphCommitHands")
                .resizable()
                .frame(width: 80, height: 80)
                .parityPosition(x: 4, y: 4)

            // gold takeover: a hue-shifted duplicate of the glyph fades in
            // while the finger is held, turning the fingerprint golden.
            Image("GlyphCommitHands")
                .resizable()
                .frame(width: 80, height: 80)
                .hueRotation(.degrees(150))
                .saturation(1.4)
                .brightness(0.08)
                .opacity(progress)
                .parityPosition(x: 4, y: 4)

            // gold inner glow that builds with the hold
            RoundedRectangle(cornerRadius: 25.14)
                .stroke(DesignTokens.Colors.secondary.opacity(0.5), lineWidth: 17.6)
                .blur(radius: 8.8)
                .clipShape(RoundedRectangle(cornerRadius: 25.14))
                .frame(width: 88, height: 88)
                .opacity(progress)

            // hold progress ring
            if progress > 0 {
                RoundedRectangle(cornerRadius: 25.14)
                    .trim(from: 0, to: progress)
                    .stroke(DesignTokens.Colors.secondary, lineWidth: 3)
                    .frame(width: 88, height: 88)
            }
        }
        .frame(width: 88, height: 88, alignment: .topLeading)
        .contentShape(Rectangle())
        .scaleEffect(committed ? 1.12 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: committed)
        .onLongPressGesture(minimumDuration: Self.holdDuration, perform: {
            guard !parityMode, !committed else { return }
            committed = true
            withAnimation(.easeOut(duration: 0.2)) { progress = 1 }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            // let the gold state land for a beat before moving on
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                onComplete()
            }
        }, onPressingChanged: { pressing in
            guard !parityMode, !committed else { return }
            withAnimation(.linear(duration: pressing ? Self.holdDuration : 0.25)) {
                progress = pressing ? 1 : 0
            }
        })
        .accessibilityIdentifier("commitment.holdButton")
        .scaleEffect(x: sx, y: sy, anchor: .topLeading)
    }

    private var poppinsLineSpacing: CGFloat {
        let font = UIFont(name: "Poppins-Medium", size: 16) ?? .systemFont(ofSize: 16)
        return max(0, 24 - font.lineHeight)
    }
}

#Preview {
    CommitmentStepView(onComplete: {}, onBack: {}, parityMode: true)
}
