// ParityJournalListView.swift
// Figma: journal list frame 324:12139 ('Name', 393×852)
// Spec: fidelity/specs/journal_list.txt — all geometry from the spec, do not eyeball.

import SwiftUI

/// One row of the journal list (Figma 'Frame 280/281/282').
struct ParityJournalListEntry: Identifiable {
    var id = UUID()
    var date: String = "Jan 26, 2026 at 02:00 PM"
    var title: String = "Elevated Entry"
    var body: String
    /// Card height from Figma (127 for 3-line body, 81 for 1-line body).
    var cardHeight: CGFloat = 127
    /// true → entry-color tinted card (Figma 324:12282: #3B0945 shadows,
    /// #4B2548→#560E50@0 border); false → standard glass.
    var tinted: Bool = false
}

struct ParityJournalListView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var journeyCount: Int = 0                                   // 'My Journey (0)'
    var freeEntriesText: String = "3 Free entries left this week"
    var entries: [ParityJournalListEntry] = [
        // Figma Frame 280 (324:12277): standard glass, 127pt card
        ParityJournalListEntry(
            body: "Initiate a new conversation or express a deeply held desire to your loved on with confidence and clarity.",
            cardHeight: 127, tinted: false),
        // Figma Frame 281 (324:12278): tinted glass, 127pt card
        ParityJournalListEntry(
            body: "Initiate a new conversation or express a deeply held desire to your loved on with confidence and clarity.",
            cardHeight: 127, tinted: true),
        // Figma Frame 282 (324:12288): standard glass, 81pt card
        ParityJournalListEntry(
            body: "I am hardworking and confident",
            cardHeight: 81, tinted: false)
    ]
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    var onWriteEntry: () -> Void = {}
    var onSearch: () -> Void = {}
    var onSelectEntry: (ParityJournalListEntry) -> Void = { _ in }
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 324:12139: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 324:12140: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 324:12143: 'My Journey (0)' Bitter-SemiBold 26 #EBEBEB
                // Centered app-wide per product decision (owner override —
                // the search button at (333,68) stays put; the title is
                // centered across the full canvas independent of it).
                Text("My Journey (\(journeyCount))")
                    .font(DesignTokens.Typography.h1)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 353 * sx, alignment: .center)
                    .parityPosition(x: 20 * sx, y: 68 * sy)

                // Figma 324:12144: search glass square (333,68,40,40)
                searchButton(sx: sx, sy: sy)
                    .parityPosition(x: 333 * sx, y: 68 * sy)

                // Figma 324:12159: free-entries banner (20,128,353,48)
                ParityFreeEntriesBanner(text: freeEntriesText, sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 128 * sy)
                    .accessibilityIdentifier("journalList.freeEntriesBanner")

                // Figma 324:12287: entries column starting at (19,192);
                // pitch = 21 (date) + 8 gap + cardHeight + 16 gap
                entriesColumn(sx: sx, sy: sy)

                // Figma 324:12458: 'Write Entry' button (226,694,143,56)
                ParityWriteEntryButton(sx: sx, sy: sy, action: onWriteEntry)
                    .parityPosition(x: 226 * sx, y: 694 * sy)
                    .accessibilityIdentifier("journalList.writeEntryButton")

                // Figma 324:12513: tab bar group (0,774,393,78), active Journal
                FigmaTabBar(active: .journal, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("journalList.root")
    }

    // MARK: - Search button (Figma 324:12144 / 324:12146)

    private func searchButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onSearch) {
            ZStack(alignment: .topLeading) {
                ParityGlassSquare40(sx: sx, sy: sy)
                ParitySearchGlyph()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .frame(width: 20 * sx, height: 20 * sy)
                    .parityPosition(x: 10 * sx, y: 10 * sy)
            }
            .frame(width: 40 * sx, height: 40 * sy, alignment: .topLeading)
        }
        .accessibilityLabel("Search")
        .accessibilityIdentifier("journalList.searchButton")
    }

    // MARK: - Entries (Figma Frame 282, rows at y 192 / 364 / 536)

    @ViewBuilder
    private func entriesColumn(sx: CGFloat, sy: CGFloat) -> some View {
        let ys = rowOffsets()
        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
            entryRow(entry, index: index, sx: sx, sy: sy)
                .parityPosition(x: 19 * sx, y: ys[index] * sy)
        }
    }

    /// y 192, then +21 (date) +8 +cardHeight +16 per row (192 → 364 → 536 in the spec).
    private func rowOffsets() -> [CGFloat] {
        var ys: [CGFloat] = []
        var y: CGFloat = 192
        for entry in entries {
            ys.append(y)
            y += 21 + 8 + entry.cardHeight + 16
        }
        return ys
    }

    private func entryRow(_ entry: ParityJournalListEntry, index: Int,
                          sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 324:12273: date Poppins-Medium 14 #B9B9B9
            Text(entry.date)
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)

            // Figma 324:12248 / 324:12282 / 324:12292: card 353×h r16, date +29
            ZStack(alignment: .topLeading) {
                if entry.tinted {
                    // Figma 324:12282: tinted shadows #3B0945, border #4B2548→#560E50@0
                    ParityTintedGlassSurface(cornerRadius: DesignTokens.Radii.card)
                } else {
                    // Figma 324:12248: calibrated flat-film glass card surface
                    ParityJournalCardSurface(cornerRadius: DesignTokens.Radii.card)
                }

                // Figma 324:12260: title Poppins-Medium 16 #EBEBEB at card-rel (16,16)
                // (+1.33pt: measured 4px high vs the reference)
                Text(entry.title)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 16 * sx, y: 16 * sy + 1.33 * sy)

                // Figma 324:12261: body Poppins-Regular 14 lh21 #B9B9B9 at card-rel (16,44)
                // (net +0.33pt: the usual +1.33 measured 3px low here)
                Text(entry.body)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineSpacing(bodyLineSpacing)
                    .frame(width: 322 * sx, alignment: .topLeading)
                    .parityPosition(x: 16 * sx, y: 44 * sy + 0.33 * sy)
            }
            .frame(width: 353 * sx, height: entry.cardHeight * sy, alignment: .topLeading)
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
            .onTapGesture { onSelectEntry(entry) }
            .parityPosition(y: 29 * sy)
            // a11y: tappable card → single button announcing title, date, body
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(entry.title), \(entry.date)")
            .accessibilityValue(entry.body)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("journalList.entry.\(index)")
        }
        .frame(width: 353 * sx,
               height: (29 + entry.cardHeight) * sy,
               alignment: .topLeading)
    }

    /// Figma line height 21px vs the UIFont's natural line height (Poppins 14).
    private var bodyLineSpacing: CGFloat {
        let font = UIFont(name: "Poppins-Regular", size: 14) ?? .systemFont(ofSize: 14)
        return max(0, 21 - font.lineHeight)
    }
}

#Preview {
    ParityJournalListView(parityMode: true)
}
