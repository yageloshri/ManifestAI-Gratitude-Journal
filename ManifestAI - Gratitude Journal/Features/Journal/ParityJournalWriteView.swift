// ParityJournalWriteView.swift
// Figma: journal write frame 324:11854 ('Name', 393×852)
// Spec: fidelity/specs/journal_write.txt — all geometry from the spec, do not eyeball.

import SwiftUI

struct ParityJournalWriteView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var dateTitle: String = "24 January"                        // Figma 324:11858
    var placeholder: String = "What are you grateful for?"      // Figma 324:11956
    var entryText: String = ""                                  // empty → placeholder @0.4
    var selectedColorIndex: Int = 0                             // Figma 324:11975 (first swatch)
    /// Live mode: when set, the entry area becomes an editable TextEditor.
    var liveText: Binding<String>? = nil
    var onBack: () -> Void = {}
    var onElevate: () -> Void = {}
    /// Called when the user approves the elevated text in the cinematic:
    /// (originalText, approvedElevatedText). The host persists both directly —
    /// no second AI call should run on the approved wording.
    var onElevateApproved: (String, String) -> Void = { _, _ in }
    var onSelectColor: (Int) -> Void = { _ in }
    var parityMode: Bool = false

    // MARK: - Elevate cinematic state
    @State private var elevatePhase: ElevatePhase = .idle
    @State private var capturedOriginalText: String = ""
    @State private var elevatedDraft: String = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 324:11854: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 324:11855: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 324:11859: back glass square (20,68,40,40) + arrow-left
                ParityBackButton40(sx: sx, sy: sy, action: onBack)
                    .parityPosition(x: 20 * sx, y: 68 * sy)
                    .accessibilityIdentifier("journalWrite.backButton")
                    .opacity(elevatePhase == .idle ? 1 : 0)
                    .allowsHitTesting(elevatePhase == .idle)

                // Figma 324:11858: '24 January' Bitter-Bold 23 #EBEBEB at (138,74)
                Text(dateTitle)
                    .font(DesignTokens.Typography.h2Bold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 138 * sx, y: 74 * sy)
                    .opacity(elevatePhase == .idle ? 1 : 0)

                // Figma 324:11956: placeholder Bitter-Bold 18 #EBEBEB op 0.4 at (20,140,353,27)
                if let liveText {
                    TextEditor(text: liveText)
                        .font(DesignTokens.Typography.h4)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .tint(DesignTokens.Colors.primary)
                        .frame(width: 353 * sx, height: 420 * sy, alignment: .topLeading)
                        .parityPosition(x: 16 * sx, y: 132 * sy)
                        .overlay(alignment: .topLeading) {
                            if liveText.wrappedValue.isEmpty {
                                Text(placeholder)
                                    .font(DesignTokens.Typography.h4)
                                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                                    .opacity(0.4)
                                    .parityPosition(x: 20 * sx, y: 140 * sy)
                                    .allowsHitTesting(false)
                            }
                        }
                        .opacity(elevatePhase == .idle ? 1 : 0)
                        .allowsHitTesting(elevatePhase == .idle)
                        .accessibilityIdentifier("journalWrite.editor")
                } else {
                    Text(entryText.isEmpty ? placeholder : entryText)
                        .font(DesignTokens.Typography.h4)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .opacity(entryText.isEmpty ? 0.4 : 1)
                        .frame(width: 353 * sx, alignment: .topLeading)
                        .parityPosition(x: 20 * sx, y: 140 * sy)
                        .opacity(elevatePhase == .idle ? 1 : 0)
                        .accessibilityIdentifier("journalWrite.entryText")
                }

                // Figma 324:11980: Frame 279 — 'Color' label + swatch panel (20,577,353,86)
                // Figma 324:11976: selected ring stroke sw 1.0
                ParityColorPicker(selectedIndex: selectedColorIndex,
                                  ringWidth: 1.0, ringOpacity: 1.0,
                                  sx: sx, sy: sy, onSelect: onSelectColor)
                    .parityPosition(x: 20 * sx, y: 577 * sy)
                    .accessibilityIdentifier("journalWrite.colorPicker")
                    .opacity(elevatePhase == .idle ? 1 : 0)
                    .allowsHitTesting(elevatePhase == .idle)

                // Figma 324:11993: 'Elevate' button (20,714,353,56)
                ParityElevateButton(title: String(localized: "Elevate"), sx: sx, sy: sy, action: beginElevate)
                    .parityPosition(x: 20 * sx, y: 714 * sy)
                    .accessibilityIdentifier("journalWrite.elevateButton")
                    .opacity(elevatePhase == .idle ? 1 : 0)
                    .allowsHitTesting(elevatePhase == .idle)

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
                            // Hand both texts to the host — the approved
                            // wording is persisted as-is (no re-elevation).
                            onElevateApproved(capturedOriginalText, finalText)
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
        .accessibilityIdentifier("journalWrite.root")
    }

    /// Kicks off the Elevate cinematic: centers the user's text, shows the
    /// owl thinking while Gemini rewrites it, then reveals an editable
    /// result. The original text is never touched until the user taps
    /// Save, so a failed call (or a Revert) always leaves it exactly as
    /// written.
    private func beginElevate() {
        guard !parityMode else { onElevate(); return }
        let source = (liveText?.wrappedValue ?? entryText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else { return }
        guard liveText != nil else {
            // Non-live (preview/mock) context: no text to elevate in place —
            // preserve the previous direct-trigger behavior.
            onElevate()
            return
        }

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
}

#Preview {
    ParityJournalWriteView(parityMode: true)
}
