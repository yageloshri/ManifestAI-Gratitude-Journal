// ParityUpgradeProView.swift
// Figma: "Upgrade to Pro" frame (330:1770) in Core App section, 393×852.
// All geometry from fidelity/specs/upgradepro.txt — do not eyeball values.
// Same layout family as SubscriptionScreenView (294:691); panel/timeline
// treatments mirror the calibrations that passed that screen's pixel diff.

import SwiftUI

struct ParityUpgradeProView: View {
    var onStartTrial: () -> Void = {}
    var onRestore: () -> Void = {}
    var onPrivacy: () -> Void = {}
    var onTerms: () -> Void = {}
    /// Invoked with "yearly"/"weekly" when the user selects a plan.
    var onSelectPlan: ((String) -> Void)? = nil
    /// When non-nil, renders a visible back button top-left (nil keeps the
    /// debug ParityGallery pixel-identical to the Figma frame).
    var onBack: (() -> Void)? = nil
    /// Parity gallery: yearly plan selected (matches the Figma mock).
    var parityMode: Bool = false

    @State private var selectedPlan: Plan = .yearly

    enum Plan { case yearly, weekly }

    /// Trial length claimed by the on-screen copy ("3- days Free", "In 3 Days",
    /// "Start my 3-Day Free Trial", "3 days free, then …").
    private static let trialDays = 3

    /// First charge date: today + trial length, e.g. "2 Jul 2026".
    private var chargeDateString: String {
        let date = Calendar.current.date(byAdding: .day, value: Self.trialDays, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 330:1771: ellipse #4F31EC@0.51, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.51)

                // Figma 330:1773 'Frame 215': full panel (1,0,392,853) r16 with textures
                ZStack(alignment: .topLeading) {
                    // Figma 330:1774: milad-fakurian unsplash (-179,-118,713,635) op 0.2
                    Image("AbstractGradient")
                        .resizable()
                        .frame(width: 713 * 1.2086 * sx, height: 635 * sy)
                        .parityPosition(x: 713 * -0.0276 * sx, y: 0)
                        .blur(radius: 28)
                        .frame(width: 713 * sx, height: 635 * sy, alignment: .topLeading)
                        .clipped()
                        .opacity(0.20)
                        .parityPosition(x: -180 * sx, y: -118 * sy)

                    // Figma 330:1775: glass rect (1,0,392,853)
                    Color.clear
                        .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
                        .frame(width: 392 * sx, height: 853 * sy)

                    // Figma 330:1776: cosmic texture (-333,-241,955,637) op 0.2
                    Image("CosmicTexture")
                        .resizable()
                        .frame(width: 955 * sx, height: 637 * sy)
                        .parityPosition(x: -334 * sx, y: -241 * sy)
                        .opacity(0.20)
                }
                .frame(width: 392 * sx, height: 853 * sy, alignment: .topLeading)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
                .parityPosition(x: 1 * sx, y: 0)

                // Figma 330:1778: mixed spans (characterStyleOverrides):
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

                // Figma 330:1779: sheet (21,172) 352×707, r16, border only + blur
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

                // Figma 330:1786: "No payment due now" white 12, centered (37,666,320)
                Text("No payment due now")
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(.white)
                    .frame(width: 320 * sx)
                    .multilineTextAlignment(.center)
                    .parityPosition(x: 37 * sx, y: 666 * sy)

                // Figma 330:1788: CTA (37,696) 320×56
                ctaButton(sx: sx, sy: sy)
                    .parityPosition(x: 37 * sx, y: 697.33 * sy)

                // Figma 330:1789: footnote #B9B9B9 12 centered (37,764,320)
                Text("3 days free, then Rs 6,900 per year (Rs 575/mo)")
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 320 * sx)
                    .multilineTextAlignment(.center)
                    .parityPosition(x: 37 * sx, y: 764 * sy)

                // Figma 330:1780 'Frame 233': links row (31,806,331), op 0.7
                HStack {
                    Text("Privacy")                                   // 330:1781
                        .onTapGesture { onPrivacy() }
                        .accessibilityAddTraits(.isButton)
                    Spacer()
                    Text("Restore")                                   // 330:1782
                        .onTapGesture { onRestore() }
                        .accessibilityAddTraits(.isButton)
                    Spacer()
                    Text("Terms")                                     // 330:1783
                        .onTapGesture { onTerms() }
                        .accessibilityAddTraits(.isButton)
                }
                .font(DesignTokens.Typography.label)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .opacity(0.7)
                .frame(width: 331 * sx)
                .parityPosition(x: 31 * sx, y: 806 * sy)

                // Visible back control (optional — live app also has an
                // invisible top-left tap zone in MainTabView). Positioned to
                // match sibling screens (ParityJournalEntryView et al: 20,68).
                if let onBack {
                    ParityBackButton40(sx: sx, sy: sy, action: onBack)
                        .parityPosition(x: 20 * sx, y: 68 * sy)
                        .accessibilityLabel("Back")
                        .accessibilityIdentifier("upgradepro.backButton")
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("upgradepro.root")
    }

    // MARK: - Timeline (Figma 330:1814)

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
            // (identical glyphs to the Subscription frame — refs are pixel-equal)
            ForEach(Array([199.0, 296.0, 403.0].enumerated()), id: \.offset) { i, y in
                Image("SubTimelineIcon\(i + 1)")
                    .resizable()
                    .frame(width: 50 * sx, height: 50 * sy)
                    .parityPosition(x: 33 * sx, y: y * sy)
            }

            // Figma 330:1815: Today (93,188,244) +1.33 multi-line offset
            timelineText(title: "Today",
                         body: "Unlock AI Insights, Unlimited Journalism & Daily Affirmations.",
                         sx: sx).parityPosition(x: 93 * sx, y: 189.67 * sy)
            // Figma 330:1818: In 2 Days (93,285,244)
            timelineText(title: "In 2 Days",
                         body: "We’ll send you a reminder that your trial is ending soon.",
                         sx: sx).parityPosition(x: 93 * sx, y: 286.67 * sy)
            // Figma 330:1821: In 3 Days (93,392,244)
            timelineText(title: "In 3 Days",
                         body: "You’ll be charged on \(chargeDateString) unless you cancel anytime before.",
                         sx: sx).parityPosition(x: 93 * sx, y: 393.67 * sy)
        }
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

    // MARK: - Plan cards (Figma 330:1790)

    private func planCards(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 330:1791: Yearly — (37,495) 320×79, gold border 3pt fading
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

                // Figma 330:1795: gold check circle 24 (card-rel 16,16); check 330:1797
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
                    .overlay(Circle().stroke(DesignTokens.Colors.selectedBorderGold.opacity(0.85), lineWidth: 1))
                    .overlay(
                        CheckmarkShape()
                            .stroke(Color(hex: "FAFAFB"),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 8, height: 5.5)
                    )
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // Figma 330:1799 (card-rel 52,16)
                Text("Yearly")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 52 * sx, y: 16 * sy)

                // Figma 330:1800 (card-rel 52,42)
                Text("Billed Rs, 6900")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .parityPosition(x: 52 * sx, y: 42 * sy)

                // Figma 330:1802 (card-rel 220,16,84)
                Text("Rs 133/week")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(width: 84 * sx, alignment: .leading)
                    .parityPosition(x: 220 * sx, y: 16 * sy)
            }
            .frame(width: 320 * sx, height: 79 * sy, alignment: .topLeading)
            .onTapGesture {
                if !parityMode {
                    selectedPlan = .yearly
                    onSelectPlan?("yearly")
                }
            }
            .parityPosition(x: 37 * sx, y: 495 * sy)
            .accessibilityIdentifier("upgradepro.plan.yearly")

            // Figma 330:1803: Weekly — (37,582) 320×56
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

                // Figma 330:1809: empty radio 24, stroke #BA9DDE fading (card-rel 16,16)
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

                // Figma 330:1811 (card-rel 52,16)
                Text("Weekly")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 52 * sx, y: 16 * sy)

                // Figma 330:1813 (card-rel 213,16,92)
                Text("Rs 11,00/week")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(width: 92 * sx, alignment: .leading)
                    .parityPosition(x: 213 * sx, y: 16 * sy)
            }
            .frame(width: 320 * sx, height: 56 * sy, alignment: .topLeading)
            .onTapGesture {
                if !parityMode {
                    selectedPlan = .weekly
                    onSelectPlan?("weekly")
                }
            }
            .parityPosition(x: 37 * sx, y: 582 * sy)
            .accessibilityIdentifier("upgradepro.plan.weekly")
        }
    }

    // MARK: - CTA (Figma 330:1788)

    private func ctaButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onStartTrial) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma I330:1788;12:4957: 'Start my 3-Day Free Trial' (btn-rel 16,16,288)
                Text("Start my 3-Day Free Trial")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 288 * sx, alignment: .center)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // Figma I330:1788;14:13869: white vuesax arrow 7.1×15.84 (btn-rel 306.9,20.1)
                VuesaxChevronShape()
                    .stroke(Color.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.098, height: 15.84)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
            .frame(width: 320 * sx, height: 56 * sy)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("upgradepro.startTrialButton")
    }
}

#Preview {
    ParityUpgradeProView(parityMode: true)
}
