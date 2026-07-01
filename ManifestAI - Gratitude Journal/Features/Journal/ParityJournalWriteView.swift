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
    var onSelectColor: (Int) -> Void = { _ in }
    var parityMode: Bool = false

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

                // Figma 324:11858: '24 January' Bitter-Bold 23 #EBEBEB at (138,74)
                Text(dateTitle)
                    .font(DesignTokens.Typography.h2Bold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 138 * sx, y: 74 * sy)

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
                        .accessibilityIdentifier("journalWrite.editor")
                } else {
                    Text(entryText.isEmpty ? placeholder : entryText)
                        .font(DesignTokens.Typography.h4)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .opacity(entryText.isEmpty ? 0.4 : 1)
                        .frame(width: 353 * sx, alignment: .topLeading)
                        .parityPosition(x: 20 * sx, y: 140 * sy)
                        .accessibilityIdentifier("journalWrite.entryText")
                }

                // Figma 324:11980: Frame 279 — 'Color' label + swatch panel (20,577,353,86)
                // Figma 324:11976: selected ring stroke sw 1.0
                ParityColorPicker(selectedIndex: selectedColorIndex,
                                  ringWidth: 1.0, ringOpacity: 1.0,
                                  sx: sx, sy: sy, onSelect: onSelectColor)
                    .parityPosition(x: 20 * sx, y: 577 * sy)
                    .accessibilityIdentifier("journalWrite.colorPicker")

                // Figma 324:11993: 'Elevate' button (20,714,353,56)
                ParityElevateButton(title: "Elevate", sx: sx, sy: sy, action: onElevate)
                    .parityPosition(x: 20 * sx, y: 714 * sy)
                    .accessibilityIdentifier("journalWrite.elevateButton")
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("journalWrite.root")
    }
}

#Preview {
    ParityJournalWriteView(parityMode: true)
}
