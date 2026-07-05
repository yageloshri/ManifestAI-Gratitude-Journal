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
    /// Fires once the user approves the elevated text at the end of the
    /// cinematic (with any edits they made), *before* `onElevate()` is
    /// called. Not wired by the current MainTabView call site — hook point
    /// for persisting the exact approved wording once that owner is ready
    /// to consume it, without changing today's `onElevate()` contract.
    var onElevateApproved: (String) -> Void = { _ in }
    /// Live mode: swatch hex driving the .color tint (default = Figma's #560E50)
    /// and the ring position in the picker. Defaults reproduce the Figma frames.
    var tintHex: String? = nil
    var selectedColorIndex: Int? = nil
    var parityMode: Bool = false

    // MARK: - Elevate cinematic state
    @State private var elevatePhase: ElevatePhase = .idle
    @State private var capturedOriginalText: String = ""
    @State private var elevatedDraft: String = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var effectiveTint: String { tintHex ?? "560E50" }
    /// Figma pairs bg #1C051A with tint #560E50 — exactly tint × 0.325.
    private var tintedBackground: Color {
        let v = Int(effectiveTint, radix: 16) ?? 0x560E50
        let r = Int((CGFloat((v >> 16) & 0xFF) * 0.325).rounded())
        let g = Int((CGFloat((v >> 8) & 0xFF) * 0.325).rounded())
        let b = Int((CGFloat(v & 0xFF) * 0.325).rounded())
        return Color(hex: String(format: "%02X%02X%02X", r, g, b))
    }

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Frame fill: #1C051A on .color (324:12068), #16062A otherwise
                (variant == .color ? tintedBackground : DesignTokens.Colors.background)

                // Ellipse 1: (0,12,578.7,677.5) layer blur 514
                // .color → fill #560E50 @1 (324:12069); else #4F31EC@0.29
                if variant == .color {
                    Ellipse()
                        .fill(Color(hex: effectiveTint))
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
                    .opacity(elevatePhase == .idle ? 1 : 0)
                    .allowsHitTesting(elevatePhase == .idle)

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
                        .opacity(elevatePhase == .idle ? 1 : 0)
                }

                // Entry text Bitter-Bold 18 #EBEBEB at (20,140,353,27)
                // (324:12078 / 324:12011 / 324:12316)
                Text(entryText)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 140 * sy)
                    .accessibilityIdentifier("journalEntry.entryText")
                    .opacity(elevatePhase == .idle ? 1 : 0)

                if variant != .elevated {
                    // Frame 279 (20,577,353,86): 'Color' label + swatch panel
                    // .color → swatch 1 selected, ring op 0.5 (324:12134/12135)
                    // .plain → swatch 0 selected, ring op 1   (324:12015/12016)
                    ParityColorPicker(selectedIndex: selectedColorIndex ?? (variant == .color ? 1 : 0),
                                      ringWidth: 1.5,
                                      ringOpacity: variant == .color ? 0.5 : 1.0,
                                      sx: sx, sy: sy, onSelect: onSelectColor)
                        .parityPosition(x: 20 * sx, y: 577 * sy)
                        .accessibilityIdentifier("journalEntry.colorPicker")
                        .opacity(elevatePhase == .idle ? 1 : 0)
                        .allowsHitTesting(elevatePhase == .idle)

                    // 'Elevate' button (20,714,353,56) — 324:12093 / 324:12026
                    ParityElevateButton(title: String(localized: "Elevate"), sx: sx, sy: sy, action: beginElevate)
                        .parityPosition(x: 20 * sx, y: 714 * sy)
                        .accessibilityIdentifier("journalEntry.elevateButton")
                        .opacity(elevatePhase == .idle ? 1 : 0)
                        .allowsHitTesting(elevatePhase == .idle)
                }

                if elevatePhase != .idle {
                    ElevateCinematicOverlay(
                        phase: elevatePhase,
                        originalText: capturedOriginalText,
                        elevatedText: $elevatedDraft,
                        errorMessage: "The AI rewrite didn't go through — your original entry is safe.",
                        sx: sx, sy: sy,
                        screenSize: geo.size,
                        onSave: { finalText in
                            withAnimation(ElevateMotion.settle(reduceMotion: reduceMotion)) {
                                elevatePhase = .idle
                            }
                            // The host persists the approved wording as-is and
                            // handles navigation — no second AI call.
                            onElevateApproved(finalText)
                        },
                        onRevert: {
                            withAnimation(ElevateMotion.settle(reduceMotion: reduceMotion)) {
                                elevatePhase = .idle
                            }
                        }
                    )
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("journalEntry.root")
    }

    /// Kicks off the Elevate cinematic on this saved entry's text. The
    /// original `entryText` is never mutated — a failed call, or the user
    /// tapping Revert, simply dismisses the overlay with nothing lost.
    private func beginElevate() {
        guard !parityMode else { onElevate(); return }
        let source = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else { return }

        capturedOriginalText = source
        elevatedDraft = ""

        withAnimation(ElevateMotion.spring(reduceMotion: reduceMotion)) {
            elevatePhase = .centering
        }

        Task {
            try? await Task.sleep(nanoseconds: reduceMotion ? 150_000_000 : 450_000_000)
            withAnimation(ElevateMotion.spring(reduceMotion: reduceMotion, response: 0.45, damping: 0.75)) {
                elevatePhase = .thinking
            }

            do {
                let result = try await GeminiService.shared.generateElevation(from: source)
                elevatedDraft = result.trimmingCharacters(in: .whitespacesAndNewlines)

                withAnimation(ElevateMotion.flight(reduceMotion: reduceMotion)) {
                    elevatePhase = .revealing
                }
                try? await Task.sleep(nanoseconds: reduceMotion ? 200_000_000 : 900_000_000)
                withAnimation(ElevateMotion.settle(reduceMotion: reduceMotion)) {
                    elevatePhase = .editing
                }
            } catch {
                withAnimation(.easeInOut(duration: 0.4)) {
                    elevatePhase = .failed
                }
                try? await Task.sleep(nanoseconds: 1_400_000_000)
                withAnimation(ElevateMotion.settle(reduceMotion: reduceMotion)) {
                    elevatePhase = .idle
                }
            }
        }
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
        .accessibilityLabel("Edit")
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
        .accessibilityLabel("Delete entry")
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
