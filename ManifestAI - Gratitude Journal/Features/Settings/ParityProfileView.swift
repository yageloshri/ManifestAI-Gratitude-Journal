// ParityProfileView.swift
// Figma: "Name" frame (326:13312) — My Profile screen, 393×951 (scrollable).
// All geometry from fidelity/specs/profile.txt — do not eyeball values.
// The frame is 951pt tall: content lives at exact Figma coordinates inside a
// ScrollView (scrolling disabled in parityMode) so the visible top 852pt
// match the frame's top 852pt. sy stays geo.height/852.

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
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                ScrollView(.vertical, showsIndicators: false) {
                    content(sx: sx, sy: sy)
                        .frame(width: 393 * sx, height: 951 * sy, alignment: .topLeading)
                }
                .scrollDisabled(parityMode)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("profile.root")
    }

    // MARK: - 951pt content canvas

    private func content(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 326:13313: ellipse #4F31EC@0.29, blur 514
            EllipseGlowBackground(sx: sx, sy: sy)

            // Figma 326:13316: "My Profile" Bitter SemiBold 26 #EBEBEB (20,68,353,31)
            Text("My Profile")
                .font(DesignTokens.Typography.h1)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 20 * sx, y: 68 * sy)

            // Figma 326:13431: profile card (20,123) 353×182
            profileCard(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 123 * sy)

            // Figma 326:13478: section label (20,340) Poppins Medium 16 #B9B9B9
            // (+1.67,+1.33pt: measured MSE shift vs reference)
            Text("What are you calling in?")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 20 * sx + 1.67, y: 340 * sy + 1.33)

            // Figma 326:13579: Personal Information row (20,380)
            settingsRow(sx: sx, sy: sy,
                        title: "Personal Information", subtitle: "Name, DOD",
                        icon: "ProfileIcon_Personal", // baked crop 326:13626 + glow
                        showArrow: true, rowId: "personalInfo")
                .parityPosition(x: 20 * sx, y: 380 * sy)

            // Figma 326:13580: Upgrade to Pro row (20,458)
            settingsRow(sx: sx, sy: sy,
                        title: "Upgrade to Pro", subtitle: "Unlock all features",
                        icon: "ProfileIcon_Crown", // baked crop 326:13635 + glow
                        showArrow: true, rowId: "upgradePro")
                .parityPosition(x: 20 * sx, y: 458 * sy)

            // Figma 326:13596 + 362:1821: Daily Reminders row (20,536) with Switch
            remindersRow(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 536 * sy)

            // Figma 326:13611: Support row (20,614)
            settingsRow(sx: sx, sy: sy,
                        title: "Support", subtitle: "Any question?",
                        icon: "ProfileIcon_Support", // baked crop 328:13717 + glow
                        showArrow: true, rowId: "support")
                .parityPosition(x: 20 * sx, y: 614 * sy)

            // Figma 326:13641: Privacy Policy row (20,692)
            settingsRow(sx: sx, sy: sy,
                        title: "Privacy Policy", subtitle: "Name, DOD",
                        icon: "ProfileIcon_Privacy", // baked crop 328:13731 + glow
                        showArrow: true, rowId: "privacyPolicy")
                .parityPosition(x: 20 * sx, y: 692 * sy)

            // Figma 328:13735: Log out row (20,770) — red icon, no subtitle, no arrow
            logoutRow(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 770 * sy)

            // Figma 326:13330: tab bar group at (0,873,393,78), Profile active
            FigmaTabBar(active: .profile, onSelect: onSelectTab, sx: sx, sy: sy)
                .parityPosition(x: 0, y: 873 * sy)
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
        .frame(width: 351 * sx, height: 70 * sy, alignment: .topLeading)
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
        .frame(width: 351 * sx, height: 70 * sy, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { onSelectRow("dailyReminders") }
        // a11y: shape-drawn switch → expose the whole row as a single toggle
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily Reminders")
        .accessibilityValue(remindersOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
        .accessibilityIdentifier("profile.row.dailyReminders")
    }

    // Log out (Figma 328:13735) — red glow icon, single label
    private func logoutRow(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card,
                                   compact: true, insetStroke: true)

            // Figma 328:13739: icon (frame 36,789 → row-rel 16,19) — baked
            bakedRowIcon("ProfileIcon_Logout", sx: sx, sy: sy, size: 44)
                .parityPosition(x: 10 * sx, y: 13 * sy)

            // Figma 328:13747 (frame 80,794.5 → row-rel 60,24.5)
            Text("Log out")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 60 * sx, y: 24.5 * sy)
        }
        .frame(width: 351 * sx, height: 70 * sy, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { onSelectRow("logout") }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Log out")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("profile.row.logout")
    }

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
