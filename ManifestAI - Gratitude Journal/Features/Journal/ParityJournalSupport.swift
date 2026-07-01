// ParityJournalSupport.swift
// Shared building blocks for the Journal parity screens
// (journal_empty / journal_list / journal_write / journal_entry_*).
// All geometry comes from the Figma spec dumps in fidelity/specs/.

import SwiftUI

// MARK: - 40×40 glass square (Figma 'Group 48095322', e.g. 324:2007 / 324:11860)
// fill #FBFBFB@0.01, 1pt fading #63507A border, r12, full inset-shadow stack.

struct ParityGlassSquare40: View {
    var sx: CGFloat = 1
    var sy: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "FBFBFB").opacity(0.01))
            .overlay(FigmaInnerShadows(cornerRadius: 12, compact: true))
            .overlay(
                // Figma stroke: #63507A → #332643@0, sw 1.0, fading top→bottom
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: DesignTokens.Colors.glassBorder.opacity(0.73), location: 0),
                                .init(color: Color(hex: "332643").opacity(0), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .frame(width: 40 * sx, height: 40 * sy)
    }
}

// MARK: - vuesax/linear glyphs (drawn as stroke paths in a 20×20 design box)

/// vuesax/linear/arrow-left (Figma e.g. 324:11861): chevron (2.92,4.94,5.06,10.12)
/// + horizontal shaft (3.06,10,14.02,0), stroke #685EF5 1.5pt.
struct ParityArrowLeftGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 20
        var p = Path()
        p.move(to: CGPoint(x: 7.98 * s, y: 4.94 * s))
        p.addLine(to: CGPoint(x: 2.92 * s, y: 10 * s))
        p.addLine(to: CGPoint(x: 7.98 * s, y: 15.06 * s))
        p.move(to: CGPoint(x: 3.06 * s, y: 10 * s))
        p.addLine(to: CGPoint(x: 17.08 * s, y: 10 * s))
        return p
    }
}

/// vuesax/linear/search-normal (Figma e.g. 324:2008): circle (1.67,1.67,15,15)
/// + handle (15.7,15.6 → ~18.3,18.3), stroke #685EF5 1.5pt.
struct ParitySearchGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 20
        var p = Path()
        p.addEllipse(in: CGRect(x: 1.67 * s, y: 1.67 * s, width: 15 * s, height: 15 * s))
        p.move(to: CGPoint(x: 15.7 * s, y: 15.6 * s))
        p.addLine(to: CGPoint(x: 18.34 * s, y: 18.34 * s))
        return p
    }
}

/// vuesax/linear/add (Figma e.g. 324:11809): 12pt cross centered in a 24×24 box,
/// stroke #FFFFFF 1.5pt (vectors at rel (6,12,12,0) and (12,6,0,12)).
struct ParityPlusGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 24
        var p = Path()
        p.move(to: CGPoint(x: 6 * s, y: 12 * s))
        p.addLine(to: CGPoint(x: 18 * s, y: 12 * s))
        p.move(to: CGPoint(x: 12 * s, y: 6 * s))
        p.addLine(to: CGPoint(x: 12 * s, y: 18 * s))
        return p
    }
}

// MARK: - 40×40 glass back button (glass square + arrow-left at (10,10,20,20))

struct ParityBackButton40: View {
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                ParityGlassSquare40(sx: sx, sy: sy)
                ParityArrowLeftGlyph()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 20 * sx, height: 20 * sy)
                    .parityPosition(x: 10 * sx, y: 10 * sy)
            }
            .frame(width: 40 * sx, height: 40 * sy, alignment: .topLeading)
        }
        .accessibilityLabel("Back")
    }
}

// MARK: - Free-entries banner (Figma 'Frame 246', e.g. 324:11837 / 324:12159)
// (20,128,353,48) fill #291846 r8; bulb at rel (62.5,12,24,24); text at rel (98.5,13.5).

struct ParityFreeEntriesBanner: View {
    var text: String = "3 Free entries left this week"
    var sx: CGFloat = 1
    var sy: CGFloat = 1

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(DesignTokens.Colors.surfaceDark)

            // Figma 324:11848: 3-path crown glyph (#FFC107/#FFA000/#FFD54F),
            // baked 30×30pt crop (icon 24×24 + 3pt margin) from the reference.
            if UIImage(named: "JournalCrownIcon") != nil {
                Image("JournalCrownIcon")
                    .resizable()
                    .frame(width: 30 * sx, height: 30 * sy)
                    .parityPosition(x: 59.5 * sx, y: 9 * sy)
                    .accessibilityHidden(true) // decorative; banner text carries the meaning
            } else {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "FFC107"))
                    .frame(width: 24 * sx, height: 24 * sy)
                    .parityPosition(x: 62.5 * sx, y: 12 * sy)
                    .accessibilityHidden(true)
            }

            // Figma 324:11846: Poppins-Medium 14, #EBEBEB
            Text(text)
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .parityPosition(x: 98.5 * sx, y: 13.5 * sy)
        }
        .frame(width: 353 * sx, height: 48 * sy, alignment: .topLeading)
    }
}

// MARK: - "Write Entry" CTA (Figma 'Button Default', e.g. 324:11807 / 324:12458)
// 143×56 primary-gradient r13; plus icon at rel (16,16,24,24); label at rel (50,17.5).

struct ParityWriteEntryButton: View {
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                ParityPlusGlyph()
                    .stroke(Color.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .frame(width: 24 * sx, height: 24 * sy)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                Text("Write Entry")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(.white)
                    .frame(width: 77 * sx, alignment: .center)
                    .parityPosition(x: 50 * sx, y: 17.5 * sy)
            }
            .frame(width: 143 * sx, height: 56 * sy, alignment: .topLeading)
        }
    }
}

// MARK: - "Elevate" CTA (Figma 'Button Default', e.g. 324:11993 / 324:12026)
// 353×56 primary-gradient r13; label centered in rel (16,16,321,24);
// white chevron vector at rel (307.9,4.1 within icon box (299,16,24,24)).

struct ParityElevateButton: View {
    var title: String = "Elevate"
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                Text(title)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 321 * sx, alignment: .center)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // Figma vector I324:11993;14:13869;14:6322: (326.9,734.1,7.098,15.84) sw 1.5
                ChevronRightSmallShape()
                    .stroke(Color.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.098 * sx, height: 15.84 * sy)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
            .frame(width: 353 * sx, height: 56 * sy, alignment: .topLeading)
        }
    }
}

// MARK: - Color picker (Figma 'Frame 279', e.g. 324:11980 / 324:12079)
// 'Color' label at (0,0); panel at (0,30,353,56) #291846 r8; swatch row
// starting at panel-rel x16, HStack pitch 12, vertically centered.
// Selected swatch: 32×32 ring (primary-gradient stroke) around a 24×24 circle.

struct ParityColorPicker: View {
    /// Hexes from the spec (Ellipse 6..14): 324:11977 / 324:11984...324:11992
    var colors: [String] = ["32166E", "560E50", "28450C", "45260C",
                            "450C33", "0E4356", "403B4A", "365111", "13217A"]
    var selectedIndex: Int = 0
    /// Figma ring stroke width: 1.0 on journal_write (324:11976), 1.5 on entry screens.
    var ringWidth: CGFloat = 1.0
    /// Figma ring opacity: 1.0 normally, 0.5 on journal_entry_color (324:12135).
    var ringOpacity: CGFloat = 1.0
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var onSelect: (Int) -> Void = { _ in }

    /// VoiceOver names for the spec swatch hexes (fallback: positional name).
    private static let colorNamesByHex: [String: String] = [
        "32166E": "Indigo", "560E50": "Plum", "28450C": "Forest green",
        "45260C": "Brown", "450C33": "Berry", "0E4356": "Teal",
        "403B4A": "Charcoal", "365111": "Olive", "13217A": "Navy blue"
    ]

    private func colorName(_ i: Int) -> String {
        Self.colorNamesByHex[colors[i].uppercased()] ?? "Color \(i + 1)"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Figma 324:11979: 'Color' Poppins-Medium 14 #B9B9B9
            Text("Color")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)

            // Figma 324:11958: Frame 246 (353×56) #291846 r8
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignTokens.Colors.surfaceDark)

                HStack(spacing: 12 * sx) {
                    ForEach(colors.indices, id: \.self) { i in
                        if i == selectedIndex {
                            // Figma Group 48095325/48095326: ring 32 + circle 24
                            ZStack {
                                Circle()
                                    .stroke(DesignTokens.Gradients.primary, lineWidth: ringWidth)
                                    .opacity(ringOpacity)
                                    .frame(width: 32 * sx, height: 32 * sy)
                                Circle()
                                    .fill(Color(hex: colors[i]))
                                    .frame(width: 24 * sx, height: 24 * sy)
                            }
                            .frame(width: 32 * sx, height: 32 * sy)
                            // a11y/hit-target only: 32pt swatch → 44pt tap area
                            .contentShape(Circle().inset(by: -6))
                            .onTapGesture { onSelect(i) }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(colorName(i))
                            .accessibilityAddTraits([.isButton, .isSelected])
                            .accessibilityIdentifier("journal.colorSwatch.\(i)")
                        } else {
                            Circle()
                                .fill(Color(hex: colors[i]))
                                .frame(width: 24 * sx, height: 24 * sy)
                                // a11y/hit-target only: 24pt swatch → 44pt tap area
                                .contentShape(Circle().inset(by: -10))
                                .onTapGesture { onSelect(i) }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(colorName(i))
                                .accessibilityAddTraits(.isButton)
                                .accessibilityIdentifier("journal.colorSwatch.\(i)")
                        }
                    }
                }
                .padding(.leading, 16 * sx)
            }
            .frame(width: 353 * sx, height: 56 * sy, alignment: .leading)
            .parityPosition(y: 30 * sy)
        }
        .frame(width: 353 * sx, height: 86 * sy, alignment: .topLeading)
    }
}

// MARK: - Tinted glass card surface (journal_list colored entry, Figma 324:12282)
// Same structure as figmaGlassSurface but with the entry-color tinted shadow
// stack (#3B0945) and a #4B2548 → #560E50@0 fading 2pt border.

struct ParityTintedGlassSurface: View {
    var cornerRadius: CGFloat = 16
    var shadowTint: Color = Color(hex: "3B0945")
    var borderTop: Color = Color(hex: "4B2548")
    var borderBottomClear: Color = Color(hex: "560E50")

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        shape
            .fill(Color(hex: "FBFBFB").opacity(0.01))
            .overlay(
                shape
                    .fill(Color.clear)
                    // all-edge vignette: 0 5.023 22.602 0
                    .overlay(shape.stroke(shadowTint, lineWidth: 23).blur(radius: 11))
                    // all-edge deep vignette: 0 1.256 50.226 0
                    .overlay(shape.stroke(shadowTint, lineWidth: 50).blur(radius: 25))
                    // top band: 0 123.053 125.565 -60.271
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: shadowTint, location: 0),
                                .init(color: shadowTint.opacity(0), location: 0.28)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    // top tint: 0 48.97 70.316 -45.203 @0.5
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: shadowTint.opacity(0.5), location: 0),
                                .init(color: shadowTint.opacity(0), location: 0.14)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    // bottom band: 0 -102.963 85.384 -80.361 @0.3
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: shadowTint.opacity(0), location: 0.86),
                                .init(color: shadowTint.opacity(0.3), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .clipShape(shape)
            )
            .overlay(
                // Figma strokes are INSIDE-aligned → strokeBorder
                shape.strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: borderTop.opacity(0.73), location: 0),
                            .init(color: borderBottomClear.opacity(0), location: 1)
                        ],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 2
                )
            )
    }
}

// MARK: - Standard glass card surface (journal_list entry cards, Figma 324:12248)
// Calibrated against the journal_list reference export: the card interior is a
// flat warm film over the background (ΔRGB ≈ +5,+10,+2 at the top drifting to
// +6,+9,−14 at the bottom — Figma's BACKGROUND_BLUR+inset stack net effect),
// with the usual 2pt inside-aligned #63507A→#332643@0 fading border.

struct ParityJournalCardSurface: View {
    var cornerRadius: CGFloat = 16

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        shape
            .fill(Color(hex: "FBFBFB").opacity(0.01))
            .overlay(
                // measured film: top ≈ rgb(54,61,77)@0.2, bottom ≈ rgb(59,56,0)@0.2
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 54/255, green: 61/255, blue: 77/255).opacity(0.2), location: 0),
                        .init(color: Color(red: 59/255, green: 56/255, blue: 0).opacity(0.2), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(shape)
            )
            .overlay(
                shape.strokeBorder(
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
    }
}
