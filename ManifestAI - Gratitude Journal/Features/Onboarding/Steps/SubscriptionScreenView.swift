// SubscriptionScreenView.swift
// Figma: "Subscription" frame (294:691) in Registration Screens section
// All geometry from fidelity/subscription spec — do not eyeball values.

import SwiftUI

struct SubscriptionScreenView: View {
    var onStartTrial: () -> Void = {}
    var onRestore: () -> Void = {}
    /// Parity gallery: yearly plan selected (matches the Figma mock).
    var parityMode: Bool = false

    @State private var selectedPlan: Plan = .yearly

    enum Plan { case yearly, weekly }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 294:692: ellipse #4F31EC@0.51, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.51)

                // Figma 294:694: full panel with textures (cosmic at op 0.2)
                ZStack(alignment: .topLeading) {
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
                        .frame(width: 392 * sx, height: 853 * sy)

                    Image("CosmicTexture")
                        .resizable()
                        .frame(width: 955 * sx, height: 637 * sy)
                        .parityPosition(x: -334 * sx, y: -241 * sy)
                        .opacity(0.20)
                }
                .frame(width: 392 * sx, height: 853 * sy, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
                .parityPosition(x: 1 * sx, y: 0)

                // Figma 294:775: mixed spans (characterStyleOverrides):
                // "Start your " #EBEBEB / "3- days Free " Bitter-BoldItalic #FCD471 /
                // "Trial to continue" #EBEBEB — Bitter SemiBold 26/1.2, centered
                (
                    Text("Start your ")
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                    + Text("3- days Free ")
                        .font(.custom("Bitter-BoldItalic", size: 26))
                        .foregroundColor(DesignTokens.Colors.secondary)
                    + Text("Trial to continue")
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                )
                .font(DesignTokens.Typography.h1)
                .multilineTextAlignment(.center)
                .frame(width: 307 * sx)
                .parityPosition(x: 43 * sx, y: 96 * sy)

                // Figma 295:778: sheet (21,172) 352×707, r16, border only + blur
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .fill(Color.white.opacity(0.01))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: DesignTokens.Colors.glassBorder.opacity(0.73), location: 0),
                                        .init(color: Color(hex: "332643").opacity(0), location: 1)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    )
                    .frame(width: 352 * sx, height: 707 * sy)
                    .parityPosition(x: 21 * sx, y: 172 * sy)

                timeline(sx: sx, sy: sy)

                planCards(sx: sx, sy: sy)

                // Figma 300:1004: "No payment due now" white 12, centered (37,666,320)
                Text("No payment due now")
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(.white)
                    .frame(width: 320 * sx)
                    .multilineTextAlignment(.center)
                    .parityPosition(x: 37 * sx, y: 666 * sy)

                // Figma 300:996: CTA (37,696) 320×56
                ctaButton(sx: sx, sy: sy)
                    .parityPosition(x: 37 * sx, y: 697.33 * sy)

                // Figma 300:1002: footnote #B9B9B9 12 centered (37,764,320)
                Text("3 days free, then Rs 6,900 per year (Rs 575/mo)")
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 320 * sx)
                    .multilineTextAlignment(.center)
                    .parityPosition(x: 37 * sx, y: 764 * sy)

                // Figma 300:1009: links row (31,806,331), op 0.7
                HStack {
                    Text("Privacy")
                    Spacer()
                    Text("Restore").onTapGesture { onRestore() }
                    Spacer()
                    Text("Terms")
                }
                .font(DesignTokens.Typography.label)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .opacity(0.7)
                .frame(width: 331 * sx)
                .parityPosition(x: 31 * sx, y: 806 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("subscription.root")
    }

    // MARK: - Timeline (Figma 299:885)

    private func timeline(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // connector lines x57, solid #8E5BEB 4pt (Figma gradient runs across
            // the width — soft edges — not along the length)
            ForEach([243.0, 343.0], id: \.self) { y in
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "8E5BEB").opacity(0), location: 0),
                        .init(color: Color(hex: "8E5BEB"), location: 0.45),
                        .init(color: Color(hex: "8E5BEB").opacity(0), location: 1)
                    ],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 4, height: 56 * sy)
                .parityPosition(x: 55 * sx, y: y * sy)
            }

            // icon squares — baked reference crops (lock / bell / crown), 50×50
            // at (33,199)/(33,296)/(33,403) incl. 4pt margin around the 42pt box
            ForEach(Array([199.0, 296.0, 403.0].enumerated()), id: \.offset) { i, y in
                Image("SubTimelineIcon\(i + 1)")
                    .resizable()
                    .frame(width: 50 * sx, height: 50 * sy)
                    .parityPosition(x: 33 * sx, y: y * sy)
            }

            // text rows x93 w244
            timelineText(title: "Today",
                         body: "Unlock AI Insights, Unlimited Journalism & Daily Affirmations.",
                         sx: sx).parityPosition(x: 93 * sx, y: 189.67 * sy)
            timelineText(title: "In 2 Days",
                         body: "We’ll send you a reminder that your trial is ending soon.",
                         sx: sx).parityPosition(x: 93 * sx, y: 286.67 * sy)
            timelineText(title: "In 3 Days",
                         body: "You’ll be charged on 27 Jan 2026 unless you cancel anytime before.",
                         sx: sx).parityPosition(x: 93 * sx, y: 393.67 * sy)
        }
    }

    private func timelineIcon(systemName: String, gold: Bool) -> some View {
        ZStack {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.smallCard)
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(gold ? DesignTokens.Colors.secondary : DesignTokens.Colors.textPrimary)
        }
        .frame(width: 42, height: 42)
    }

    private func timelineText(title: String, body: String, sx: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(DesignTokens.Typography.smallTextSemibold)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
            Text(body)
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .frame(width: 244 * sx, alignment: .topLeading)
    }

    // MARK: - Plan cards (Figma 300:991)

    private func planCards(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Yearly — (37,495) 320×79, gold border 3pt fading to ~0.4
            // (surface is subtle: faint fill + weak vignette, NO glass border
            //  underneath the gold one — Figma shows only the gold stroke)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .fill(Color.white.opacity(0.01))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                            .stroke(DesignTokens.Colors.innerShadow1.opacity(0.8), lineWidth: 10)
                            .blur(radius: 5)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: DesignTokens.Colors.secondary.opacity(0.85), location: 0),
                                        .init(color: DesignTokens.Colors.secondary.opacity(0.4), location: 1)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 3
                            )
                    )

                // gold check circle 24 at rel (16,16)
                Circle()
                    .fill(
                        RadialGradient(
                            stops: [
                                .init(color: Color(hex: "A8842F"), location: 0),
                                .init(color: Color(hex: "C7A14B"), location: 1)
                            ],
                            center: .center, startRadius: 0, endRadius: 12
                        )
                    )
                    .overlay(Circle().stroke(Color(hex: "E9C378").opacity(0.85), lineWidth: 1))
                    .overlay(
                        CheckmarkShape()
                            .stroke(Color(hex: "FAFAFB"),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 8, height: 5.5)
                    )
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                Text("Yearly")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 52 * sx, y: 16 * sy)

                Text("Billed Rs, 6900")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .parityPosition(x: 52 * sx, y: 42 * sy)

                Text("Rs 133/week")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 84 * sx, alignment: .leading)
                    .parityPosition(x: 220 * sx, y: 16 * sy)
            }
            .frame(width: 320 * sx, height: 79 * sy, alignment: .topLeading)
            .onTapGesture { selectedPlan = .yearly }
            .parityPosition(x: 37 * sx, y: 495 * sy)
            .accessibilityIdentifier("subscription.plan.yearly")

            // Weekly — (37,582) 320×56 (same subtle surface + glass border)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .fill(Color.white.opacity(0.01))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                            .stroke(DesignTokens.Colors.innerShadow1.opacity(0.8), lineWidth: 10)
                            .blur(radius: 5)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: DesignTokens.Colors.glassBorder.opacity(0.73), location: 0),
                                        .init(color: Color(hex: "332643").opacity(0), location: 1)
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    )

                Circle()
                    .fill(Color.white.opacity(0.01))
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: DesignTokens.Colors.unselectedBorder.opacity(0.73), location: 0),
                                    .init(color: Color(hex: "7C5F9F").opacity(0), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                    )
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                Text("Weekly")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 52 * sx, y: 16 * sy)

                Text("Rs 11,00/week")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 92 * sx, alignment: .leading)
                    .parityPosition(x: 213 * sx, y: 16 * sy)
            }
            .frame(width: 320 * sx, height: 56 * sy, alignment: .topLeading)
            .onTapGesture { selectedPlan = .weekly }
            .parityPosition(x: 37 * sx, y: 582 * sy)
            .accessibilityIdentifier("subscription.plan.weekly")
        }
    }

    // MARK: - CTA (Figma 300:996)

    private func ctaButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onStartTrial) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                Text("Start my 3-Day Free Trial")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 288 * sx, alignment: .center)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // thin white chevron at rel (299,12), vuesax arrow 7.1×15.8 @1.5pt
                VuesaxChevronShape()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.1, height: 15.84)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
            .frame(width: 320 * sx, height: 56 * sy)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("subscription.startTrialButton")
    }
}

/// › chevron, matches the vuesax arrow vector (7.1×15.84).
struct VuesaxChevronShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return p
    }
}

#Preview {
    SubscriptionScreenView(parityMode: true)
}
