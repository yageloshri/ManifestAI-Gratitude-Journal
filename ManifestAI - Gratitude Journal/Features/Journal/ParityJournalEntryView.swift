// ParityJournalEntryView.swift
// Figma: journal entry frames —
//   .color    → 324:12068 (fidelity/specs/journal_entry_color.txt)  [DEFAULT]
//   .plain    → 324:11997 (fidelity/specs/journal_entry_plain.txt)
//   .elevated → 324:12306 (fidelity/specs/journal_entry_elevate.txt)
// Same screen in three states: background/glow tint + selected color swatch
// differ between .color and .plain; .elevated is the saved/read-only state
// (smaller title, edit + trash buttons, no color picker, no CTA).
// All geometry from the spec dumps, do not eyeball.

import SwiftUI

enum ParityJournalEntryVariant {
    /// Figma 324:12068: entry tinted #560E50 — bg #1C051A, glow #560E50,
    /// swatch 1 selected (ring sw 1.5 @ op 0.5).
    case color
    /// Figma 324:11997: default tint — bg #16062A, glow #4F31EC@0.29,
    /// swatch 0 selected (ring sw 1.5 @ op 1).
    case plain
    /// Figma 324:12306: elevated/saved — bg #16062A, title Bitter-Bold 18 at (78,74.5),
    /// edit (286,68) + trash (333,68) buttons, no picker/CTA.
    case elevated
}

struct ParityJournalEntryView: View {
    // mock-friendly inputs, defaults reproduce journal_entry_color.txt exactly
    var variant: ParityJournalEntryVariant = .color
    var dateTitle: String = "24 January"                        // Figma 324:12077
    /// Figma 324:12078 chars (leading space is in the Figma text node).
    var entryText: String = " I am very hardworking and confident."
    var onBack: () -> Void = {}
    var onElevate: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    var onSelectColor: (Int) -> Void = { _ in }
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Frame fill: #1C051A on .color (324:12068), #16062A otherwise
                (variant == .color ? Color(hex: "1C051A") : DesignTokens.Colors.background)

                // Ellipse 1: (0,12,578.7,677.5) layer blur 514
                // .color → fill #560E50 @1 (324:12069); else #4F31EC@0.29
                if variant == .color {
                    Ellipse()
                        .fill(Color(hex: "560E50"))
                        .frame(width: 578.67 * sx, height: 677.5 * sy)
                        .parityPosition(x: 0, y: 12 * sy)
                        .blur(radius: 257 * sx)
                } else {
                    EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)
                }

                // Back glass square (20,68,40,40) + arrow-left (324:12074/12003/12312)
                ParityBackButton40(sx: sx, sy: sy, action: onBack)
                    .parityPosition(x: 20 * sx, y: 68 * sy)
                    .accessibilityIdentifier("journalEntry.backButton")

                if variant == .elevated {
                    // Figma 324:12315: '24 January' Bitter-Bold 18 at (78,74.5)
                    Text(dateTitle)
                        .font(DesignTokens.Typography.h4)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .parityPosition(x: 78 * sx, y: 74.5 * sy)

                    // Figma 324:12401: edit glass square (286,68,40,40), edit-2 #685EF5
                    editButton(sx: sx, sy: sy)
                        .parityPosition(x: 286 * sx, y: 68 * sy)

                    // Figma 324:12380: trash glass square (333,68,40,40), trash #CC2123
                    deleteButton(sx: sx, sy: sy)
                        .parityPosition(x: 333 * sx, y: 68 * sy)
                } else {
                    // Figma 324:12077 / 324:12006: '24 January' Bitter-Bold 23 at (138,74)
                    Text(dateTitle)
                        .font(DesignTokens.Typography.h2Bold)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .parityPosition(x: 138 * sx, y: 74 * sy)
                }

                // Entry text Bitter-Bold 18 #EBEBEB at (20,140,353,27)
                // (324:12078 / 324:12011 / 324:12316)
                Text(entryText)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 140 * sy)
                    .accessibilityIdentifier("journalEntry.entryText")

                if variant != .elevated {
                    // Frame 279 (20,577,353,86): 'Color' label + swatch panel
                    // .color → swatch 1 selected, ring op 0.5 (324:12134/12135)
                    // .plain → swatch 0 selected, ring op 1   (324:12015/12016)
                    ParityColorPicker(selectedIndex: variant == .color ? 1 : 0,
                                      ringWidth: 1.5,
                                      ringOpacity: variant == .color ? 0.5 : 1.0,
                                      sx: sx, sy: sy, onSelect: onSelectColor)
                        .parityPosition(x: 20 * sx, y: 577 * sy)
                        .accessibilityIdentifier("journalEntry.colorPicker")

                    // 'Elevate' button (20,714,353,56) — 324:12093 / 324:12026
                    ParityElevateButton(title: "Elevate", sx: sx, sy: sy, action: onElevate)
                        .parityPosition(x: 20 * sx, y: 714 * sy)
                        .accessibilityIdentifier("journalEntry.elevateButton")
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("journalEntry.root")
    }

    // MARK: - Elevated-state header buttons

    // Figma 324:12403: vuesax/linear/edit-2, stroke #685EF5 1.5pt
    private func editButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onEdit) {
            ZStack(alignment: .topLeading) {
                ParityGlassSquare40(sx: sx, sy: sy)
                // PARITY-TODO: bake icon crop 324:12403
                Image(systemName: "pencil.line")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .frame(width: 20 * sx, height: 20 * sy)
                    .parityPosition(x: 10 * sx, y: 10 * sy)
            }
            .frame(width: 40 * sx, height: 40 * sy, alignment: .topLeading)
        }
        .accessibilityIdentifier("journalEntry.editButton")
    }

    // Figma 324:12382: vuesax/linear/trash, stroke #CC2123 1.5pt
    private func deleteButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onDelete) {
            ZStack(alignment: .topLeading) {
                ParityGlassSquare40(sx: sx, sy: sy)
                // PARITY-TODO: bake icon crop 324:12382
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.error)
                    .frame(width: 20 * sx, height: 20 * sy)
                    .parityPosition(x: 10 * sx, y: 10 * sy)
            }
            .frame(width: 40 * sx, height: 40 * sy, alignment: .topLeading)
        }
        .accessibilityIdentifier("journalEntry.deleteButton")
    }
}

#Preview("color") {
    ParityJournalEntryView(parityMode: true)
}

#Preview("plain") {
    ParityJournalEntryView(variant: .plain, parityMode: true)
}

#Preview("elevated") {
    ParityJournalEntryView(variant: .elevated, parityMode: true)
}
