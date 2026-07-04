import SwiftUI

// Figma tab bar (Group 48095315, e.g. Home 318:1814):
// 393×78 at screen bottom, fill = primary gradient, top corner radius 12,
// gold active indicator 38×4 under the active tab, 5 items at x 22/96/170/244/318
// (53pt wide): 24pt icon + 12pt Poppins label; active #FCD471, inactive #8D7CD3.

enum FigmaTab: Int, CaseIterable {
    case today, journal, vision, method369, profile

    var label: String {
        switch self {
        case .today: return "Today"
        case .journal: return "Journal"
        case .vision: return "Vision"
        case .method369: return "369"
        case .profile: return "Profile"
        }
    }

    /// SF approximations; swapped for baked Figma glyph crops during parity passes.
    var systemImage: String {
        switch self {
        case .today: return "sun.max.fill"
        case .journal: return "book.closed.fill"
        case .vision: return "safari.fill"
        case .method369: return "hands.and.sparkles.fill"
        case .profile: return "person.crop.circle"
        }
    }
}

struct FigmaTabBar: View {
    var active: FigmaTab
    var onSelect: (FigmaTab) -> Void = { _ in }
    var sx: CGFloat = 1
    var sy: CGFloat = 1

    /// Landing animation: the gold indicator grows in and the active icon
    /// springs up slightly every time a screen (and its bar) appears.
    @State private var landed = false

    private let itemXs: [CGFloat] = [22, 96, 170, 244, 318]

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Figma: the bar rect's inset-shadow stack crushes the gradient to
            // ~0.30 brightness; items above it are dimmed separately (~0.68).
            UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                .fill(DesignTokens.Gradients.primary)
                .overlay(
                    // Figma inset-shadow stack darkens hardest at the top edge and
                    // relaxes toward the bottom (sampled: top ≈0.78, bottom ≈0.62).
                    UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: "1A0B2C").opacity(0.78), location: 0),
                                    .init(color: Color(hex: "1A0B2C").opacity(0.62), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "271839").opacity(0.5), location: 0),
                            .init(color: Color(hex: "271839").opacity(0), location: 0.25)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            // gold active indicator — Figma: 38×4, bottom corners r12,
            // x = itemX + 7.5 (e.g. 29.5 for tab 0, 251.5 for 369).
            // Grows out from the center when the bar lands.
            UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12)
                .fill(DesignTokens.Gradients.golden)
                .frame(width: 38 * sx, height: 4)
                .scaleEffect(x: landed ? 1 : 0.15, anchor: .center)
                .opacity(landed ? 1 : 0)
                .parityPosition(x: (itemXs[active.rawValue] + (53 - 38) / 2) * sx, y: 0)

            ForEach(FigmaTab.allCases, id: \.rawValue) { tab in
                let isActive = tab == active
                VStack(spacing: 6) {
                    tabIcon(tab, isActive: isActive)
                        .frame(width: 24, height: 24)
                        .scaleEffect(isActive && !landed ? 0.7 : 1)
                        .offset(y: isActive && !landed ? 3 : 0)
                    Text(tab.label)
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(isActive
                                         ? DesignTokens.Colors.secondary
                                         : DesignTokens.Colors.tabInactive)
                }
                .frame(width: 53 * sx, height: 48 * sy)
                // a11y/hit-target only: outset shape enlarges the tap area to
                // ≥44pt without touching layout (item pitch is 74pt, no overlap).
                .contentShape(Rectangle().inset(by: -10))
                .onTapGesture {
                    guard tab != active else { return }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSelect(tab)
                }
                .parityPosition(x: itemXs[tab.rawValue] * sx, y: 13 * sy)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(isActive ? [.isButton, .isSelected] : [.isButton])
                .accessibilityIdentifier("tabbar.\(tab.label.lowercased())")
            }
        }
        .frame(width: 393 * sx, height: 78 * sy, alignment: .topLeading)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.66)) {
                landed = true
            }
        }
    }

    /// Figma icon glyphs are bespoke vectors; where a baked reference crop
    /// exists (TabIcon_<label>_<a|i>, 30×30pt incl. 3pt margin over the bar
    /// background) use it, otherwise fall back to the SF approximation.
    @ViewBuilder
    private func tabIcon(_ tab: FigmaTab, isActive: Bool) -> some View {
        let baked = "TabIcon_\(tab.label)_\(isActive ? "a" : "i")"
        if UIImage(named: baked) != nil {
            Image(baked)
                .resizable()
                .frame(width: 30 * sx, height: 30 * sy)
                .accessibilityHidden(true) // decorative baked glyph; item supplies the label
        } else {
            Image(systemName: tab.systemImage)
                .font(.system(size: 19))
                .foregroundStyle(
                    isActive
                    ? AnyShapeStyle(DesignTokens.Gradients.golden)
                    : AnyShapeStyle(DesignTokens.Colors.tabInactive)
                )
                .accessibilityHidden(true)
        }
    }
}
