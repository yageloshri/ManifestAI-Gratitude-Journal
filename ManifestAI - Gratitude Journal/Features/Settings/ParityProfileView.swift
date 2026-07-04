// ParityProfileView.swift
// Figma: "Name" frame (326:13312) — My Profile screen.
// The original Figma frame was 951pt tall (taller than the 852pt device
// canvas every other tab uses), which forced this screen alone into a
// ScrollView. Per product decision, Profile must fit on one screen with
// no scrolling like the rest of the tabs, so the layout below is compacted
// (tighter gaps + slightly shorter row height) to fit the same 852pt
// canvas — the tab bar lands at y=774 exactly like every other tab.
// sy stays geo.height/852.

import SwiftUI

struct ParityProfileView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var userName: String = "Ali Ahmad"
    var avatarInitial: String = "A"
    var personalDayNumber: Int = 1
    // Figma 331:1998 (new spec): the reminders Switch is OFF on this frame.
    var remindersOn: Bool = false
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    var onSelectRow: (String) -> Void = { _ in }
    /// Parity gallery: fixed mock data matching the Figma frame. The layout
    /// no longer scrolls, so this only affects the mock data callers pass in.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background
                content(sx: sx, sy: sy)
                    .frame(width: 393 * sx, height: 852 * sy, alignment: .topLeading)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("profile.root")
    }

    // MARK: - 852pt content canvas (no scroll — fits in one screen)

    private func content(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 326:13313: ellipse #4F31EC@0.29, blur 514
            EllipseGlowBackground(sx: sx, sy: sy)

            // Figma 326:13316: "My Profile" Bitter SemiBold 26 #EBEBEB
            Text("My Profile")
                .font(DesignTokens.Typography.h1)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 20 * sx, y: 44 * sy)

            // Figma 326:13431: profile card 353×182
            profileCard(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 92 * sy)

            // Figma 326:13478: section label, Poppins Medium 16 #B9B9B9
            Text("What are you calling in?")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 20 * sx + 1.67, y: 294 * sy + 1.33)

            // "Upgrade to Pro" removed — the app uses a hard paywall with a
            // 3-day trial, so every user already has an active subscription.
            // "Log out" removed — there is no sign-in; all data lives on the
            // device, so logging out would only destroy the user's data.

            // Figma 326:13579: Personal Information row
            settingsRow(sx: sx, sy: sy,
                        title: "Personal Information", subtitle: "Name, DOB",
                        icon: "ProfileIcon_Personal", // baked crop 326:13626 + glow
                        showArrow: true, rowId: "personalInfo")
                .parityPosition(x: 20 * sx, y: 340 * sy)

            // Figma 326:13596 + 362:1821: Daily Reminders row with Switch
            remindersRow(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 424 * sy)

            // Figma 326:13611: Support row
            settingsRow(sx: sx, sy: sy,
                        title: "Support", subtitle: "Any question?",
                        icon: "ProfileIcon_Support", // baked crop 328:13717 + glow
                        showArrow: true, rowId: "support")
                .parityPosition(x: 20 * sx, y: 508 * sy)

            // Figma 326:13641: Privacy Policy row
            settingsRow(sx: sx, sy: sy,
                        title: "Privacy Policy", subtitle: "How we protect your data",
                        icon: "ProfileIcon_Privacy", // baked crop 328:13731 + glow
                        showArrow: true, rowId: "privacyPolicy")
                .parityPosition(x: 20 * sx, y: 592 * sy)

            // Figma 326:13330: tab bar group, Profile active — y=774 matches
            // the tab bar position used by every other tab (0,774,393,78).
            FigmaTabBar(active: .profile, onSelect: onSelectTab, sx: sx, sy: sy)
                .parityPosition(x: 0, y: 774 * sy)
        }
    }

    // MARK: - Profile card (Figma 326:13431, 353×182 r16 #221542)

    private func profileCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                .fill(DesignTokens.Colors.profileCardBg)

            // Figma 326:13656: cosmic texture (frame 5,124 → card-rel -15,1) 353×181, op 0.09
            Image("CosmicTexture")
                .resizable()
                .frame(width: 353 * sx, height: 181 * sy)
                .opacity(0.09)
                .parityPosition(x: -15 * sx, y: 1 * sy)
                .accessibilityHidden(true) // decorative texture

            // Figma 326:13465: right light streaks, op 0.1 (#685EF5 vertical fades, rotated)
            Group {
                streakRect(sx: sx, sy: sy).parityPosition(x: 292.9 * sx, y: 67.4 * sy)   // 326:13466
                streakRect(sx: sx, sy: sy).parityPosition(x: 267.1 * sx, y: 31.7 * sy)   // 326:13467
            }
            .opacity(0.1)

            // Figma 326:13469: left light streaks, op 0.1
            Group {
                streakRect(sx: sx, sy: sy, w: 105.6, h: 174.5)
                    .parityPosition(x: -24.4 * sx, y: -10.9 * sy)                        // 326:13470
                streakRect(sx: sx, sy: sy, w: 105.6, h: 174.5)
                    .parityPosition(x: -52.0 * sx, y: -45.3 * sy)                        // 326:13471
            }
            .opacity(0.1)

            // Figma 330:1237: avatar back-glow #685EF5 op 0.8 blur 44 (card-rel 143,32)
            Rectangle()
                .fill(DesignTokens.Colors.primary.opacity(0.8))
                .frame(width: 68 * sx, height: 54 * sy)
                .blur(radius: 22)
                .parityPosition(x: 143 * sx, y: 32 * sy)

            // Figma 326:13437: avatar 72×72 r50 #2C1E49, stroke #45326D 2pt (card-rel 141,23)
            Circle()
                .fill(DesignTokens.Colors.avatarBg)
                .overlay(Circle().stroke(DesignTokens.Colors.avatarBorder, lineWidth: 2))
                .overlay(
                    // Figma 326:13438: 'A' Bitter SemiBold 30 #FFFFFF@0.68
                    Text(avatarInitial)
                        .font(Font.custom("Bitter-SemiBold", size: 30))
                        .foregroundStyle(Color.white.opacity(0.68))
                )
                .frame(width: 72, height: 72)
                .parityPosition(x: 141 * sx, y: 23 * sy)
                .accessibilityIdentifier("profile.avatar")

            // Figma 326:13440: name Poppins SemiBold 18, centered (card-rel 93,111,168)
            Text(userName)
                .font(DesignTokens.Typography.bodySemibold18)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .frame(width: 168 * sx, alignment: .center)
                .parityPosition(x: 93 * sx, y: 111 * sy)

            // Figma 326:13441: golden gradient Poppins Medium 14, centered (card-rel 93,144,168)
            Text("Personal Day Number: \(personalDayNumber)")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Gradients.golden)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 168 * sx, alignment: .center)
                .parityPosition(x: 93 * sx, y: 144 * sy)
        }
        .frame(width: 353 * sx, height: 182 * sy, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
        .overlay(
            // Figma 326:13431 stroke: #63507A → #63507A@0 top→bottom, 1pt
            RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: DesignTokens.Colors.glassBorder, location: 0),
                            .init(color: DesignTokens.Colors.glassBorder.opacity(0), location: 1)
                        ],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .accessibilityIdentifier("profile.card")
    }

    /// Decorative #685EF5 vertical-fade rect (Figma Rectangle 39331/39332, rotated streak).
    private func streakRect(sx: CGFloat, sy: CGFloat,
                            w: CGFloat = 112.7, h: CGFloat = 172) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.primary.opacity(0), location: 0),
                        .init(color: DesignTokens.Colors.primary, location: 0.4091),
                        .init(color: DesignTokens.Colors.primary.opacity(0), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: w * sx, height: h * sy)
            .rotationEffect(.degrees(15)) // group bbox > rect bbox → rotated streak
    }

    // MARK: - Settings rows (Figma Rectangle 39320, 351×70 r16 glass)

    private func settingsRow(sx: CGFloat, sy: CGFloat,
                             title: String, subtitle: String,
                             icon: String, showArrow: Bool, rowId: String) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card,
                                   compact: true, insetStroke: true)

            // icon group 'Group 48095317' (row-rel 16,17.5, 32×32) — baked
            // 44×45pt reference crop incl. the 6.5pt glow margin.
            bakedRowIcon(icon, sx: sx, sy: sy)
                .parityPosition(x: 10 * sx, y: 11 * sy)

            // 'Frame 241' title (row-rel 60,12) Poppins Medium 14 #EBEBEB
            Text(title)
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 60 * sx, y: 12 * sy)

            // subtitle (row-rel 60,37) Poppins Regular 12 #B9B9B9
            Text(subtitle)
                .font(DesignTokens.Typography.label)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 60 * sx, y: 37 * sy)

            if showArrow {
                // 'vuesax/linear/arrow-right' vector 5.9×13.2 #685EF5 1.5pt (row-rel 318.4,26.9)
                VuesaxChevronShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 5.915, height: 13.2)
                    .parityPosition(x: 318.4 * sx, y: 26.9 * sy)
            }
        }
        .frame(width: 351 * sx, height: 64 * sy, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { onSelectRow(rowId) }
        // a11y: single button element combining title + subtitle
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("profile.row.\(rowId)")
    }

    // Daily Reminders (Figma 326:13596 bg + 362:1821 content + 331:1998 Switch)
    private func remindersRow(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card,
                                   compact: true, insetStroke: true)

            // Figma 326:13599: icon (frame 36,553.5 → row-rel 16,17.5) — baked
            bakedRowIcon("ProfileIcon_Bell", sx: sx, sy: sy)
                .parityPosition(x: 10 * sx, y: 11 * sy)

            // Figma 326:13609 (frame 80,548 → row-rel 60,12)
            Text("Daily Reminders")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 60 * sx, y: 12 * sy)

            // Figma 326:13610 (frame 80,573 → row-rel 60,37)
            Text("Get All notifications")
                .font(DesignTokens.Typography.label)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 60 * sx, y: 37 * sy)

            // Figma 331:1998: Switch ON (frame 289,553.5 → row-rel 269,17.5) 56×32
            glassSwitch(on: remindersOn)
                .parityPosition(x: 269 * sx, y: 17.5 * sy)
                .accessibilityIdentifier("profile.remindersSwitch")
        }
        .frame(width: 351 * sx, height: 64 * sy, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { onSelectRow("dailyReminders") }
        // a11y: shape-drawn switch → expose the whole row as a single toggle
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily Reminders")
        .accessibilityValue(remindersOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
        .accessibilityIdentifier("profile.row.dailyReminders")
    }

    // (logoutRow removed — no sign-in exists; data lives on-device only.)

    /// Baked 44×45pt reference crop of 'Group 48095317' (glyph + glow margin).
    private func bakedRowIcon(_ name: String, sx: CGFloat, sy: CGFloat,
                              size: CGFloat = 45) -> some View {
        Image(name)
            .resizable()
            .frame(width: 44 * sx, height: size * sy)
            .accessibilityHidden(true) // decorative baked icon; row supplies the label
    }

    /// Glass toggle (Figma Switch component 331:1998, OFF on this frame):
    /// 56×32 r200 dark glass track (#150F6C inner shadows crush the interior
    /// to ≈#150F6B), 24pt knob at LEFT x rel 4 — #685EF5-tinted glass
    /// (sampled: edge ring ≈#6056E0 fading down, center ≈#463A95).
    private func glassSwitch(on: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            if on {
                Capsule()
                    .fill(DesignTokens.Colors.primary.opacity(0.32))
                    .overlay(
                        Capsule().stroke(
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
                Circle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white, location: 0),
                                .init(color: Color.white.opacity(0.78), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 28, y: 4)
            } else {
                // track: glass over #150F6C inset stack → flat deep navy,
                // 1pt #63507A stroke fading top→bottom
                Capsule()
                    .fill(Color(hex: "150F6B"))
                    .overlay(
                        Capsule().strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: DesignTokens.Colors.glassBorder.opacity(0.9), location: 0),
                                    .init(color: DesignTokens.Colors.glassBorder.opacity(0), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                    )
                // knob: #685EF5 inner-shadow glass — brighter rim, darker core
                Circle()
                    .fill(
                        RadialGradient(
                            stops: [
                                .init(color: Color(hex: "463A95"), location: 0),
                                .init(color: Color(hex: "4A3EA2"), location: 0.55),
                                .init(color: Color(hex: "5247B8"), location: 1)
                            ],
                            center: .center, startRadius: 0, endRadius: 12
                        )
                    )
                    .overlay(
                        Circle().strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "6056E0"), location: 0),
                                    .init(color: Color(hex: "564DC5").opacity(0.8), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 1.2
                        )
                    )
                    .frame(width: 24, height: 24)
                    .parityPosition(x: 4, y: 4)
            }
        }
        .frame(width: 56, height: 32, alignment: .topLeading)
    }
}

#Preview {
    ParityProfileView(parityMode: true)
}
