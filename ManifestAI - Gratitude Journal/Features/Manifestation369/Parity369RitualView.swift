// Parity369RitualView.swift
// Figma: "Morning Ritual" (364:2234), "Afternoon Ritual" (364:3878),
// "Night Ritual" (364:4226) — same layout, parameterized by RitualPhase.
// All geometry from the Figma REST spec dumps
// (fidelity/specs/ritual_morning.txt / ritual_afternoon.txt / ritual_night.txt)
// — do not eyeball values.

import SwiftUI

struct Parity369RitualView: View {
    /// Phase of the 369 ritual. Nested to avoid clashing with the app's
    /// existing top-level `RitualPhase` (WritingRitualView.swift).
    enum RitualPhase: String, CaseIterable {
        case morning, afternoon, night

        // Figma 364:2290 / 364:3947 / 364:4302
        var title: String {
            switch self {
            case .morning: return "Morning Ritual"
            case .afternoon: return "Afternoon Ritual"
            case .night: return "Night Ritual"
            }
        }

        /// Number of 28pt progress circles (Frame 1000003735).
        var dotCount: Int {
            switch self {
            case .morning: return 3      // Figma 364:2404 (149,125,94,28)
            case .afternoon: return 6    // Figma 364:3928 (99.5,121,193,28)
            case .night: return 9        // Figma 364:4276 (50,125,292,28)
            }
        }

        var dotsOriginX: CGFloat {
            switch self {
            case .morning: return 149
            case .afternoon: return 99.5
            case .night: return 50
            }
        }

        var dotsY: CGFloat {
            switch self {
            case .morning: return 125
            case .afternoon: return 121
            case .night: return 125
            }
        }

        // Figma I364:2314;12:4957 / I364:3953;12:4957 / I364:4308;12:4957
        var saveButtonTitle: String {
            switch self {
            case .morning: return "Save Manifestation (1/3)"
            case .afternoon: return "Save Manifestation (1/6)"
            case .night: return "Save Manifestation (1/9)"
            }
        }

        /// SF-symbol placeholder for the phase glyph inside the Elemento.
        var iconSystemName: String {
            switch self {
            case .morning: return "hands.and.sparkles.fill"  // praying hands
            case .afternoon: return "sun.max.fill"
            case .night: return "moon.stars.fill"
            }
        }

        var iconTint: Color {
            switch self {
            case .morning: return Color(hex: "F2BF42")   // Figma 364:2392
            case .afternoon: return Color(hex: "E66F00") // Figma 364:4141
            case .night: return Color(hex: "6783DF")     // Figma 364:4508
            }
        }

        /// Elemento accent (inner shadow + glow color).
        var elementoAccent: Color {
            switch self {
            case .morning, .afternoon: return Color(hex: "6F5B28")
            case .night: return Color(hex: "2950CE")
            }
        }

        // Figma 364:2385 r=17.71; 364:4133 / 364:4501 r=12
        var elementoCornerRadius: CGFloat {
            switch self {
            case .morning: return 17.71
            case .afternoon, .night: return 12
            }
        }

        /// Figma node id of the Elemento group, for the icon-bake TODO.
        var elementoNodeId: String {
            switch self {
            case .morning: return "364:2384"
            case .afternoon: return "364:4132"
            case .night: return "364:4500"
            }
        }
    }

    // mock-friendly inputs with defaults matching the Figma content exactly
    var phase: RitualPhase = .morning // parity default
    // Figma 364:3361 / 364:3957 / 364:4312
    var affirmation: String = "I am so happy and grateful now that I am earning $10,000 a month."
    // Figma 364:2295 / 364:4123 / 364:4306
    var placeholder: String = "Type your affirmation here..."
    /// Live mode: editable affirmation typing area.
    var liveText: Binding<String>? = nil
    /// Live mode: how many writings are already saved this phase today.
    /// nil = parity default (first dot done, static "(1/3)" button title).
    var completedCount: Int? = nil
    /// Live mode: phase target (3/6/9). Used with `completedCount`.
    var targetCount: Int? = nil
    /// Live mode: "Day X of 33" line under the title.
    var dayText: String? = nil
    /// Live mode: when set, the input card + save button are replaced by a
    /// locked/done card (phase finished or window closed). (title, message).
    var lockedInfo: (String, String)? = nil
    /// Live mode: with `lockedInfo`, also show the primary CTA with this
    /// title (e.g. "Start a New 33-Day Challenge"); tapping it calls onSave.
    var lockedActionTitle: String? = nil
    var onBack: () -> Void = {}
    var onSave: () -> Void = {}
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    @FocusState private var editorFocused: Bool

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background // frame fill #16062A

                // Figma 364:2235: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 364:2237: rawpixel cosmic texture (0,145,392,382) STRETCH op 0.2
                Image("CosmicTexture")
                    .resizable()
                    .frame(width: 392 * sx, height: 382 * sy)
                    .opacity(0.2)
                    .parityPosition(x: 0, y: 145 * sy)

                // Figma 364:4144: glass back button (20,68,40,40) r12
                backButton(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 68 * sy)

                // Figma Frame 1000003735: progress circles, first one completed
                progressCircles(sx: sx, sy: sy)
                    .parityPosition(x: phase.dotsOriginX * sx, y: phase.dotsY * sy)

                // Figma 'Elemento' 62×62 at (165,177)
                phaseElemento(sx: sx, sy: sy)
                    .parityPosition(x: 165 * sx, y: 177 * sy)

                // Figma 364:2290: title (18,257,356,27) Bitter-Bold 18 centered
                Text(phase.title)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 356 * sx, alignment: .center)
                    .parityPosition(x: 18 * sx, y: 257 * sy + 3.33 * sy)

                // Live mode only: 33-day cycle progress under the title.
                if let dayText {
                    Text(dayText)
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                        .frame(width: 356 * sx, alignment: .center)
                        .parityPosition(x: 18 * sx, y: 288 * sy)
                }

                affirmationChip(sx: sx, sy: sy)
                    .parityPosition(x: 44 * sx, y: 324 * sy)

                if let lockedInfo {
                    lockedCard(title: lockedInfo.0, message: lockedInfo.1, sx: sx, sy: sy)
                        .parityPosition(x: 26 * sx, y: 429 * sy)

                    if lockedActionTitle != nil {
                        saveButton(sx: sx, sy: sy)
                            .parityPosition(x: 20 * sx, y: 598 * sy)
                    }
                } else {
                    inputCard(sx: sx, sy: sy)
                        .parityPosition(x: 26 * sx, y: 429 * sy)

                    saveButton(sx: sx, sy: sy)
                        .parityPosition(x: 20 * sx, y: 598 * sy)
                }

                // Figma 364:2240: tab bar at (0,774), "369" active
                FigmaTabBar(active: .method369, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            // lift the whole layout above the keyboard while typing
            .offset(y: editorFocused ? -150 * sy : 0)
            .animation(.easeOut(duration: 0.25), value: editorFocused)
            // tapping anywhere outside the editor dismisses the keyboard
            .contentShape(Rectangle())
            .onTapGesture { editorFocused = false }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("ritual369.root")
    }

    // MARK: - Back button (Figma 364:4144: 40×40 glass r12, arrow-left #685EF5)

    private func backButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onBack) {
            ZStack(alignment: .topLeading) {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 12, compact: true)
                    .frame(width: 40 * sx, height: 40 * sy)

                // Figma I364:4147: arrow strokes, rel (12.92,14.94) 14.16×10.12
                Parity369ArrowLeftShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 14.16 * sx, height: 10.12 * sy)
                    .parityPosition(x: 12.92 * sx, y: 14.94 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 40 * sx, height: 40 * sy, alignment: .topLeading)
        .accessibilityIdentifier("ritual369.back")
    }

    // MARK: - Progress circles (Figma Frame 1000003735, 28pt circles, 33pt pitch)

    /// How many dots render as "done": live count when provided, else the
    /// Figma frame's single completed circle.
    private var doneDots: Int { min(completedCount ?? 1, phase.dotCount) }

    private func progressCircles(sx: CGFloat, sy: CGFloat) -> some View {
        HStack(spacing: 5 * sx) {
            ForEach(0..<phase.dotCount, id: \.self) { i in
                if i < doneDots {
                    // Figma Group 48095333 (e.g. 364:3345): completed circle —
                    // baked crop (Ritual369CircleDone, 32×32pt incl. 2pt margin)
                    if UIImage(named: "Ritual369CircleDone") != nil {
                        Image("Ritual369CircleDone")
                            .resizable()
                            .frame(width: 32 * sx, height: 32 * sy)
                            .frame(width: 28 * sx, height: 28 * sy)
                    } else {
                        ZStack {
                            Circle()
                                .stroke(DesignTokens.Colors.outlines, lineWidth: 1.1666667)
                            Circle()
                                .fill(DesignTokens.Gradients.golden)
                                .frame(width: 14 * sx, height: 14 * sy)
                        }
                        .frame(width: 28 * sx, height: 28 * sy)
                    }
                } else {
                    // Figma Group 48095332/48095288 (e.g. 364:3339): pending circle —
                    // baked crop (Ritual369CirclePending)
                    if UIImage(named: "Ritual369CirclePending") != nil {
                        Image("Ritual369CirclePending")
                            .resizable()
                            .frame(width: 32 * sx, height: 32 * sy)
                            .frame(width: 28 * sx, height: 28 * sy)
                    } else {
                        Color.clear
                            .figmaGlassSurface(cornerRadius: 14, compact: true)
                            .clipShape(Circle())
                            .frame(width: 28 * sx, height: 28 * sy)
                    }
                }
            }
        }
        .accessibilityIdentifier("ritual369.progress")
    }

    // MARK: - Phase Elemento (62×62, e.g. Figma 364:2385 / 364:4133 / 364:4501)
    // Frosted container DRAWN live (translucent surfaces must blend with the
    // real background — baked crops show square seams); the glyph sits on a
    // bright in-container glow, so glyph+glow are baked TOGETHER as one soft
    // crop (55×55 of the container interior) and the drawn inner-rect glow is
    // skipped (pattern: Glyph369 / elementoSmall(glyphIncludesGlow:) in Home).

    /// Baked glyph+glow crop name per phase (55×55pt at rel (3.5,3.5)).
    private var glyphCropName: String {
        switch phase {
        case .morning: return "GlyphRitualMorning"
        case .afternoon: return "GlyphRitualAfternoon"
        case .night: return "GlyphRitualNight"
        }
    }

    /// Bottom pool ellipse geometry per phase (Figma 364:2389 / 4137 / 4505).
    private var poolRect: CGRect {
        switch phase {
        case .morning: return CGRect(x: 19.2, y: 60.5, width: 33.95, height: 19.19)
        case .afternoon, .night: return CGRect(x: 13, y: 41, width: 23, height: 13)
        }
    }

    private var poolBlur: CGFloat {
        switch phase {
        case .morning: return 13.3
        case .afternoon, .night: return 9
        }
    }

    private func phaseElemento(sx: CGFloat, sy: CGFloat) -> some View {
        let accent = phase.elementoAccent
        let r = phase.elementoCornerRadius
        return ZStack(alignment: .topLeading) {
            // bottom pool (Figma 'Ellipse 1') — CLIPPED by the Elemento frame
            // in Figma: fig returns to bg immediately below the container
            ZStack(alignment: .topLeading) {
                Ellipse()
                    .fill(accent)
                    .frame(width: poolRect.width, height: poolRect.height)
                    .parityPosition(x: poolRect.minX, y: poolRect.minY)
                    .blur(radius: poolBlur)
                    .opacity(0.95)
            }
            .frame(width: 62, height: 62, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: r))

            RoundedRectangle(cornerRadius: r)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "F8FBFF").opacity(0.06), location: 0),
                            .init(color: Color.white.opacity(0), location: 1)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: r)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "D8D8D8").opacity(0.02), location: 0),
                                    .init(color: Color.white.opacity(0.03), location: 1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    // INNER_SHADOW(accent@0.32)
                    RoundedRectangle(cornerRadius: r)
                        .stroke(accent.opacity(0.13), lineWidth: 12.4)
                        .blur(radius: 6.2)
                        .clipShape(RoundedRectangle(cornerRadius: r))
                )
                .frame(width: 62, height: 62)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 10, y: 5)

            // baked glyph+glow crop (55×55 of the container interior)
            Image(glyphCropName)
                .resizable()
                .frame(width: 55, height: 55)
                .parityPosition(x: 3.5, y: 3.5)
        }
        .frame(width: 62, height: 62, alignment: .topLeading)
        .scaleEffect(x: sx, y: sy, anchor: .topLeading)
    }

    // MARK: - Affirmation chip (Figma 364:3363: (44,324,309,83) #2A1B47 r16)

    private func affirmationChip(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                .fill(Color(hex: "2A1B47"))

            // Figma 364:3360: 'My Affirmation' rel (10,8) 289×21 #B9B9B9 centered
            Text("My Affirmation")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .frame(width: 289 * sx, alignment: .center)
                .parityPosition(x: 10 * sx, y: 8 * sy)

            // Figma 364:3361: affirmation rel (10,33) 289×42 #FCD471 lh21 centered
            Text(affirmation)
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .lineSpacing(parity369PoppinsMedium14LineSpacing)
                .multilineTextAlignment(.center)
                .frame(width: 289 * sx, alignment: .top)
                .parityPosition(x: 10 * sx, y: 33 * sy + 0.33 * sy)
        }
        .frame(width: 309 * sx, height: 83 * sy, alignment: .topLeading)
        .accessibilityIdentifier("ritual369.affirmation")
    }

    // MARK: - Input card (Figma 364:2292: (26,429,345,132) r16 glass)

    private func inputCard(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 364:2293: glass rect, full inset-shadow stack + fading border
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            // Figma 364:2295: placeholder rel (15,16) 194×21, op 0.5
            if let liveText {
                TextEditor(text: liveText)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .tint(DesignTokens.Colors.primary)
                    .focused($editorFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") { editorFocused = false }
                        }
                    }
                    .frame(width: 316 * sx, height: 100 * sy, alignment: .topLeading)
                    .parityPosition(x: 11 * sx, y: 8 * sy)
                    .overlay(alignment: .topLeading) {
                        if liveText.wrappedValue.isEmpty {
                            Text(placeholder)
                                .font(DesignTokens.Typography.smallText)
                                .foregroundStyle(DesignTokens.Colors.textPrimary)
                                .opacity(0.5)
                                .frame(width: 194 * sx, alignment: .leading)
                                .parityPosition(x: 15 * sx, y: 16 * sy)
                                .allowsHitTesting(false)
                        }
                    }
                    .accessibilityIdentifier("ritual369.editor")
            } else {
                Text(placeholder)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .opacity(0.5)
                    .frame(width: 194 * sx, alignment: .leading)
                    .parityPosition(x: 15 * sx, y: 16 * sy)
            }

            // Figma 364:2296: Arrow_Left_MD vector rel (309,22) 14×12, #685EF5 2pt
            ArrowRightShape()
                .stroke(DesignTokens.Colors.primary,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 14 * sx, height: 12 * sy)
                .parityPosition(x: 309 * sx, y: 22 * sy)
        }
        .frame(width: 345 * sx, height: 132 * sy, alignment: .topLeading)
        .accessibilityIdentifier("ritual369.input")
    }

    // MARK: - Locked / phase-done card (live mode only — replaces the input
    // card + save CTA when the phase window is closed or finished; reuses the
    // glass surface + token typography so it stays in the design language)

    private func lockedCard(title: String, message: String,
                            sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)

            VStack(spacing: 10 * sy) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DesignTokens.Colors.secondary)
                Text(title)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 345 * sx, height: 132 * sy)
        }
        .frame(width: 345 * sx, height: 132 * sy, alignment: .topLeading)
        .accessibilityIdentifier("ritual369.locked")
    }

    /// Save button label: live "(done+1/target)" when counts are provided,
    /// else the static Figma string.
    private var liveButtonTitle: String {
        if let lockedActionTitle { return lockedActionTitle }
        if let completedCount, let targetCount {
            return "Save Manifestation (\(min(completedCount + 1, targetCount))/\(targetCount))"
        }
        return phase.saveButtonTitle
    }

    // MARK: - Save CTA (Figma 364:2314: Button Default (20,598,353,56) r13)

    private func saveButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onSave) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma I364:2314;12:4957: label rel (16,16) 321×24 white centered
                Text(liveButtonTitle)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 321 * sx, alignment: .center)
                    .parityPosition(x: 16 * sx, y: 16 * sy + 1.33 * sy)

                // Figma I364:2314;14:13869: chevron rel (306.9,20.1) 7.1×15.84 white 1.5pt
                ChevronRightSmallShape()
                    .stroke(.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.1 * sx, height: 15.84 * sy)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 353 * sx, height: 56 * sy, alignment: .topLeading)
        .accessibilityIdentifier("ritual369.save")
    }
}

/// ← arrow (shaft + left head), matches the vuesax arrow-left vectors
/// (e.g. I364:4147;324:4139/324:4140).
private struct Parity369ArrowLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.midY
        let head = rect.height / 2
        p.move(to: CGPoint(x: rect.maxX, y: midY))
        p.addLine(to: CGPoint(x: rect.minX, y: midY))
        p.move(to: CGPoint(x: rect.minX + head, y: midY - head))
        p.addLine(to: CGPoint(x: rect.minX, y: midY))
        p.addLine(to: CGPoint(x: rect.minX + head, y: midY + head))
        return p
    }
}

#Preview("Morning") {
    Parity369RitualView(phase: .morning, parityMode: true)
}

#Preview("Afternoon") {
    Parity369RitualView(phase: .afternoon, parityMode: true)
}

#Preview("Night") {
    Parity369RitualView(phase: .night, parityMode: true)
}
