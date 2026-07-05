// ParityJournalEmptyView.swift
// Figma: journal empty state frame 324:1938 ('Name', 393×852)
// Spec: fidelity/specs/journal_empty.txt — all geometry from the spec, do not eyeball.

import SwiftUI

struct ParityJournalEmptyView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var journeyCount: Int = 0                                   // 'My Journey (0)'
    var freeEntriesText: String = "3 Free entries left this week"
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    var onWriteEntry: () -> Void = {}
    var onSearch: () -> Void = {}
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 324:1938: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 324:1939: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 324:11822: rawpixel texture (1,205,392,382) mode=STRETCH op 0.2
                // NEEDS ASSET dc6e302d33a1 at JournalEmptyTexture
                textureImage(sx: sx, sy: sy)
                    .parityPosition(x: 1 * sx, y: 205 * sy)

                // Figma 324:1943: 'My Journey (0)' Bitter-SemiBold 26 #EBEBEB
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

                // Figma 324:11798: search glass square (333,68,40,40)
                searchButton(sx: sx, sy: sy)
                    .parityPosition(x: 333 * sx, y: 68 * sy)

                // Figma 324:11837: free-entries banner (20,128,353,48)
                ParityFreeEntriesBanner(text: freeEntriesText, sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 128 * sy)
                    .accessibilityIdentifier("journalEmpty.freeEntriesBanner")

                // Figma 324:11825: owl ground shadow (168,449,66,5) #000000@0.64 blur 5
                Ellipse()
                    .fill(Color.black.opacity(0.64))
                    .frame(width: 66 * sx, height: 5 * sy)
                    .parityPosition(x: 168 * sx, y: 449 * sy)
                    .blur(radius: 2.5 * sx)

                // Figma 324:11820: owl illustration (86,276,222,169.3) mode=STRETCH
                // NEEDS ASSET c6febec364e8 at OwlIllustration
                owlImage(sx: sx, sy: sy)
                    .parityPosition(x: 86 * sx, y: 276 * sy)

                // Figma 324:11831: 'Start your journey' Bitter-Bold 18, centered (19,471,356,27)
                Text("Start your journey")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 356 * sx, alignment: .center)
                    .parityPosition(x: 19 * sx, y: 471 * sy)

                // Figma 324:11832: subtitle Poppins-Regular 14 #B9B9B9, centered (26,506,342,21)
                Text("Capture your first moment of gratitude")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 342 * sx, alignment: .center)
                    .parityPosition(x: 26 * sx, y: 506 * sy)

                // Figma 324:11807: 'Write Entry' button (226,694,143,56)
                ParityWriteEntryButton(sx: sx, sy: sy, action: onWriteEntry)
                    .parityPosition(x: 226 * sx, y: 694 * sy)
                    .accessibilityIdentifier("journalEmpty.writeEntryButton")

                // Figma 324:12512: tab bar group (0,774,393,78), active Journal
                FigmaTabBar(active: .journal, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("journalEmpty.root")
    }

    // Figma 324:11798 / 324:2008: glass square + vuesax search-normal (#685EF5 1.5pt)
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
        .accessibilityIdentifier("journalEmpty.searchButton")
    }

    // Figma 324:11822: (1,205,392,382) op 0.2, STRETCH with
    // imageTransform [[0.78978,0,0.199276],[0,1.151654,-0.0551807]]
    // → rendered 392/0.78978 × 382/1.151654 = 496.3×331.7,
    //   offset (-0.199276, +0.0551807)·rendered = (-98.9, +18.3), clipped.
    @ViewBuilder
    private func textureImage(sx: CGFloat, sy: CGFloat) -> some View {
        if UIImage(named: "JournalEmptyTexture") != nil {
            Color.clear
                .frame(width: 392 * sx, height: 382 * sy)
                .overlay(alignment: .topLeading) {
                    Image("JournalEmptyTexture")
                        .resizable()
                        .frame(width: 496.3 * sx, height: 331.7 * sy)
                        .parityPosition(x: -98.9 * sx, y: 18.3 * sy)
                }
                .clipped()
                .opacity(0.2)
        } else {
            Color.clear
                .frame(width: 392 * sx, height: 382 * sy)
        }
    }

    // Figma 324:11820: (86,276,222,169.3), STRETCH with
    // imageTransform [[1,0,0],[0,0.508475,0.240113]]
    // → rendered 222 × 169.32/0.508475 = 222×333.0,
    //   offset (0, -0.240113·333.0) = (0, -79.96), clipped.
    @ViewBuilder
    private func owlImage(sx: CGFloat, sy: CGFloat) -> some View {
        if UIImage(named: "OwlIllustration") != nil {
            Color.clear
                .frame(width: 222 * sx, height: 169.3 * sy)
                .overlay(alignment: .topLeading) {
                    Image("OwlIllustration")
                        .resizable()
                        .frame(width: 222 * sx, height: 333.0 * sy)
                        .parityPosition(y: -79.96 * sy)
                }
                .clipped()
        } else {
            Color.clear
                .frame(width: 222 * sx, height: 169.3 * sy)
        }
    }
}

#Preview {
    ParityJournalEmptyView(parityMode: true)
}
