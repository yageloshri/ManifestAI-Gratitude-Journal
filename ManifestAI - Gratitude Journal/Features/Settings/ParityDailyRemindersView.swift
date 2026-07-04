// ParityDailyRemindersView.swift
// Figma: "Daily Reminders" frame (331:2779) — My Profile screen, 393×951
// (scrollable). Geometry below the profile card is a hand-reflowed layout
// (retention-plan.md §3.5): the single Figma "Daily Reminders" switch is
// replaced with 3 independent per-window toggles (Morning/Afternoon/Evening),
// so it intentionally departs from strict pixel parity from this point down
// — everything above (title, profile card, section label, the two settings
// rows) is untouched Figma-exact geometry. Content lives at fixed coordinates
// inside a ScrollView (scrolling disabled in parityMode). sy stays
// geo.height/852, matching the original frame's scale convention.
//
// This is the dedicated notification-settings screen for §3.5 — it isn't
// wired into live navigation yet (that's MainTabView/ParityProfileView,
// owned by another engineer mid-edit). It reads/writes real
// NotificationManager369 state directly so it's functional as soon as a
// route is added; see the integration note returned with this change.

import SwiftUI
import UserNotifications

struct ParityDailyRemindersView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var userName: String = "Ali Ahmad"
    var avatarInitial: String = "A"
    var personalDayNumber: Int = 1
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    var onSelectRow: (String) -> Void = { _ in }
    /// Parity gallery: fixed mock data matching the Figma frame (all 3
    /// reminder toggles ON, matching the original single-switch ON state).
    var parityMode: Bool = false

    // §3.5: three independent reminder toggles, backed by
    // NotificationManager369 (separate UserDefaults keys) instead of one
    // all-or-nothing switch. Seeded from real device state unless parityMode
    // asks for the fixed mock (all ON).
    @State private var morningOn: Bool
    @State private var afternoonOn: Bool
    @State private var eveningOn: Bool

    init(userName: String = "Ali Ahmad",
         avatarInitial: String = "A",
         personalDayNumber: Int = 1,
         onSelectTab: @escaping (FigmaTab) -> Void = { _ in },
         onSelectRow: @escaping (String) -> Void = { _ in },
         parityMode: Bool = false) {
        self.userName = userName
        self.avatarInitial = avatarInitial
        self.personalDayNumber = personalDayNumber
        self.onSelectTab = onSelectTab
        self.onSelectRow = onSelectRow
        self.parityMode = parityMode

        if parityMode {
            _morningOn = State(initialValue: true)
            _afternoonOn = State(initialValue: true)
            _eveningOn = State(initialValue: true)
        } else {
            _morningOn = State(initialValue: NotificationManager369.shared.isMorningEnabled())
            _afternoonOn = State(initialValue: NotificationManager369.shared.isAfternoonEnabled())
            _eveningOn = State(initialValue: NotificationManager369.shared.isEveningEnabled())
        }
    }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                ScrollView(.vertical, showsIndicators: false) {
                    content(sx: sx, sy: sy)
                        .frame(width: 393 * sx, height: 1130 * sy, alignment: .topLeading)
                }
                .scrollDisabled(parityMode)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("dailyreminders.root")
    }

    // MARK: - 1130pt content canvas
    // (was 951pt around the single Daily Reminders row; grown to fit the
    // 3-toggle notifications card added by §3.5 — see file header.)

    private func content(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 331:2780: ellipse #4F31EC@0.29, blur 514
            EllipseGlowBackground(sx: sx, sy: sy)

            // Figma 331:2829: "My Profile" Bitter SemiBold 26 #EBEBEB (20,68,353,31)
            Text("My Profile")
                .font(DesignTokens.Typography.h1)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 20 * sx, y: 68 * sy)

            // Figma 331:2830: profile card (20,123) 353×182
            profileCard(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 123 * sy)

            // Figma 331:2846: section label (20,340) Poppins Medium 16 #B9B9B9
            // (+1.67,+1.33pt: measured MSE shift vs reference on profile)
            Text("What are you calling in?")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 20 * sx + 1.67, y: 340 * sy + 1.33)

            // Figma 331:2849: Personal Information row (20,380)
            settingsRow(sx: sx, sy: sy,
                        title: "Personal Information", subtitle: "Name, DOD",
                        icon: "ProfileIcon_Personal", // baked crop (same glyph as profile)
                        showArrow: true, rowId: "personalInfo")
                .parityPosition(x: 20 * sx, y: 380 * sy)

            // Figma 331:2869: Upgrade to Pro row (20,458)
            settingsRow(sx: sx, sy: sy,
                        title: "Upgrade to Pro", subtitle: "Unlock all features",
                        icon: "ProfileIcon_Crown", // baked crop (same glyph as profile)
                        showArrow: true, rowId: "upgradePro")
                .parityPosition(x: 20 * sx, y: 458 * sy)

            // §3.5 replaces the single Figma 331:2886 "Daily Reminders" row
            // with a section label + a 3-row notifications card (Morning /
            // Afternoon / Evening), same visual language (glass card, same
            // fonts/switch) but no longer 1:1 with the Figma frame.
            Text("Notifications")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 20 * sx + 1.67, y: 536 * sy + 1.33)

            notificationWindowsCard(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 576 * sy)

            // Support row — shifted down from the original 614 to make room
            // for the 3-row notifications card above.
            settingsRow(sx: sx, sy: sy,
                        title: "Support", subtitle: "Any question?",
                        icon: "ProfileIcon_Support", // baked crop (same glyph as profile)
                        showArrow: true, rowId: "support")
                .parityPosition(x: 20 * sx, y: 784 * sy)

            // Privacy Policy row — shifted down from the original 692.
            settingsRow(sx: sx, sy: sy,
                        title: "Privacy Policy", subtitle: "Name, DOD",
                        icon: "ProfileIcon_Privacy", // baked crop (same glyph as profile)
                        showArrow: true, rowId: "privacyPolicy")
                .parityPosition(x: 20 * sx, y: 862 * sy)

            // Log out row — shifted down from the original 770.
            logoutRow(sx: sx, sy: sy)
                .parityPosition(x: 20 * sx, y: 940 * sy)

            // Tab bar group — shifted down from the original 873.
            FigmaTabBar(active: .profile, onSelect: onSelectTab, sx: sx, sy: sy)
                .parityPosition(x: 0, y: 1043 * sy)
        }
    }

    // MARK: - Profile card (Figma 331:2830, 353×182 r16 #221542)

    private func profileCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                .fill(DesignTokens.Colors.profileCardBg)

            // Figma 331:2831: cosmic texture (frame 5,124 → card-rel -15,1) 353×181, op 0.09
            Image("CosmicTexture")
                .resizable()
                .frame(width: 353 * sx, height: 181 * sy)
                .opacity(0.09)
                .parityPosition(x: -15 * sx, y: 1 * sy)

            // Figma 331:2832: right light streaks, op 0.1 (#685EF5 vertical fades, rotated)
            Group {
                streakRect(sx: sx, sy: sy).parityPosition(x: 292.9 * sx, y: 67.4 * sy)   // 331:2833
                streakRect(sx: sx, sy: sy).parityPosition(x: 267.1 * sx, y: 31.7 * sy)   // 331:2834
            }
            .opacity(0.1)

            // Figma 331:2835: left light streaks, op 0.1
            Group {
                streakRect(sx: sx, sy: sy, w: 105.6, h: 174.5)
                    .parityPosition(x: -24.4 * sx, y: -10.9 * sy)                        // 331:2836
                streakRect(sx: sx, sy: sy, w: 105.6, h: 174.5)
                    .parityPosition(x: -52.0 * sx, y: -45.3 * sy)                        // 331:2837
            }
            .opacity(0.1)

            // Figma 331:2840: avatar back-glow #685EF5 op 0.8 blur 44 (card-rel 143,32)
            Rectangle()
                .fill(DesignTokens.Colors.primary.opacity(0.8))
                .frame(width: 68 * sx, height: 54 * sy)
                .blur(radius: 22)
                .parityPosition(x: 143 * sx, y: 32 * sy)

            // Figma 331:2841: avatar 72×72 r50 #2C1E49, stroke #45326D 2pt (card-rel 141,23)
            Circle()
                .fill(DesignTokens.Colors.avatarBg)
                .overlay(Circle().stroke(DesignTokens.Colors.avatarBorder, lineWidth: 2))
                .overlay(
                    // Figma 331:2842: 'A' Bitter SemiBold 30 #FFFFFF@0.68
                    Text(avatarInitial)
                        .font(Font.custom("Bitter-SemiBold", size: 30))
                        .foregroundStyle(Color.white.opacity(0.68))
                )
                .frame(width: 72, height: 72)
                .parityPosition(x: 141 * sx, y: 23 * sy)
                .accessibilityIdentifier("dailyreminders.avatar")

            // Figma 331:2844: name Poppins SemiBold 18, centered (card-rel 93,111,168)
            Text(userName)
                .font(DesignTokens.Typography.bodySemibold18)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .frame(width: 168 * sx, alignment: .center)
                .parityPosition(x: 93 * sx, y: 111 * sy)

            // Figma 331:2845: golden gradient Poppins Medium 14, centered (card-rel 93,144,168)
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
            // Figma 331:2830 stroke: #63507A → #63507A@0 top→bottom, 1pt
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
        .accessibilityIdentifier("dailyreminders.card")
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
        .accessibilityIdentifier("dailyreminders.row.\(rowId)")
    }

    // MARK: - §3.5 notifications card (3 independent per-window toggles)
    // Not a Figma 1:1 — see file header. Same glass-card visual language as
    // the settings rows above; internal layout is row-relative like
    // `profileCard`.

    private func notificationWindowsCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card,
                                   compact: true, insetStroke: true)

            reminderWindowRow(sx: sx, sy: sy,
                               icon: "GlyphRitualMorning",
                               title: "Morning Ritual", subtitle: "8:00 AM · 3 lines",
                               isOn: morningOn, accessibilityId: "dailyreminders.morningSwitch",
                               onToggle: toggleMorning)
                .parityPosition(x: 0, y: 0)

            Rectangle()
                .fill(DesignTokens.Colors.glassBorder.opacity(0.35))
                .frame(width: 327 * sx, height: 1)
                .parityPosition(x: 12 * sx, y: 64 * sy)

            reminderWindowRow(sx: sx, sy: sy,
                               icon: "GlyphRitualAfternoon",
                               title: "Afternoon Ritual", subtitle: "2:00 PM · 6 lines",
                               isOn: afternoonOn, accessibilityId: "dailyreminders.afternoonSwitch",
                               onToggle: toggleAfternoon)
                .parityPosition(x: 0, y: 64 * sy)

            Rectangle()
                .fill(DesignTokens.Colors.glassBorder.opacity(0.35))
                .frame(width: 327 * sx, height: 1)
                .parityPosition(x: 12 * sx, y: 128 * sy)

            reminderWindowRow(sx: sx, sy: sy,
                               icon: "GlyphRitualNight",
                               title: "Evening Ritual", subtitle: "8:00 PM · 9 lines",
                               isOn: eveningOn, accessibilityId: "dailyreminders.eveningSwitch",
                               onToggle: toggleEvening)
                .parityPosition(x: 0, y: 128 * sy)
        }
        .frame(width: 351 * sx, height: 192 * sy, alignment: .topLeading)
        .accessibilityIdentifier("dailyreminders.row.notifications")
    }

    /// One 64pt-tall toggle row inside `notificationWindowsCard` — same
    /// title/subtitle/switch layout as the old single reminders row.
    private func reminderWindowRow(sx: CGFloat, sy: CGFloat,
                                    icon: String, title: String, subtitle: String,
                                    isOn: Bool, accessibilityId: String,
                                    onToggle: @escaping () -> Void) -> some View {
        ZStack(alignment: .topLeading) {
            Image(icon)
                .resizable()
                .frame(width: 38 * sx, height: 38 * sy)
                .parityPosition(x: 12 * sx, y: 13 * sy)
                .accessibilityHidden(true)

            Text(title)
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 60 * sx, y: 12 * sy)

            Text(subtitle)
                .font(DesignTokens.Typography.label)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .parityPosition(x: 60 * sx, y: 37 * sy)

            glassSwitch(on: isOn)
                .parityPosition(x: 271 * sx, y: 16 * sy)
        }
        .frame(width: 351 * sx, height: 64 * sy, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
        .accessibilityIdentifier(accessibilityId)
    }

    // MARK: - §3.5 toggle handlers
    // Same "denied → open Settings, undetermined → request, else flip"
    // pattern as MainTabView.toggleReminders(), applied per-window.

    private func toggleMorning() {
        setWindow(morningOn, apply: NotificationManager369.shared.setMorningEnabled) { morningOn = $0 }
    }

    private func toggleAfternoon() {
        setWindow(afternoonOn, apply: NotificationManager369.shared.setAfternoonEnabled) { afternoonOn = $0 }
    }

    private func toggleEvening() {
        setWindow(eveningOn, apply: NotificationManager369.shared.setEveningEnabled) { eveningOn = $0 }
    }

    private func setWindow(_ isOn: Bool, apply: @escaping (Bool) -> Void, update: @escaping (Bool) -> Void) {
        if isOn {
            update(false)
            apply(false)
            return
        }
        guard !parityMode else {
            update(true) // gallery/preview: no real permission plumbing
            return
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied:
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                case .authorized, .provisional:
                    update(true)
                    apply(true)
                default:
                    NotificationManager369.shared.requestPermission { granted in
                        DispatchQueue.main.async {
                            update(granted)
                            if granted { apply(true) }
                        }
                    }
                }
            }
        }
    }

    // Log out (Figma 331:2931) — red glow icon, single label
    private func logoutRow(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card,
                                   compact: true, insetStroke: true)

            // Figma 331:2935: icon (frame 36,789 → row-rel 16,19), red #CC2123
            bakedRowIcon("ProfileIcon_Logout", sx: sx, sy: sy, size: 44)
                .parityPosition(x: 10 * sx, y: 13 * sy)

            // Figma 331:2945 (frame 80,794.5 → row-rel 60,24.5)
            Text("Log out")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 60 * sx, y: 24.5 * sy)
        }
        .frame(width: 351 * sx, height: 70 * sy, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { onSelectRow("logout") }
        .accessibilityIdentifier("dailyreminders.row.logout")
    }

    /// Baked 44×45pt reference crop of 'Group 48095317' (glyph + glow margin).
    private func bakedRowIcon(_ name: String, sx: CGFloat, sy: CGFloat,
                              size: CGFloat = 45) -> some View {
        Image(name)
            .resizable()
            .frame(width: 44 * sx, height: size * sy)
    }

    /// Glass toggle (Figma Switch component 331:2946): 56×32 r200 purple glass,
    /// 24pt white knob; ON = knob at trailing edge.
    private func glassSwitch(on: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            // track: sampled interior #423689 ≈ primary@0.41 over the row,
            // 1pt inside stroke #685EF5 fading top→bottom (top edge ≈#6055E0)
            Capsule()
                .fill(DesignTokens.Colors.primary.opacity(0.41))
                .overlay(
                    Capsule().strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: DesignTokens.Colors.primary.opacity(0.9), location: 0),
                                .init(color: DesignTokens.Colors.primary.opacity(0), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                )

            // knob: white inner-shadow stack ≈ solid white (sampled 254-255)
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .parityPosition(x: on ? 28 : 4, y: 4)
        }
        .frame(width: 56, height: 32, alignment: .topLeading)
        // Figma fx: DROP_SHADOW #4C409F@0.33 blur 11.3
        .shadow(color: Color(hex: "4C409F").opacity(0.33), radius: 5.65)
    }
}

#Preview {
    ParityDailyRemindersView(parityMode: true)
}
