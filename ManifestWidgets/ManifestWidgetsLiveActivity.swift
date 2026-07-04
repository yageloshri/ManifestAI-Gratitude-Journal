//
//  ManifestWidgetsLiveActivity.swift
//  ManifestWidgets
//
//  Retention plan 3.11 — Lock Screen banner + Dynamic Island for an
//  in-progress 369 ritual phase. Fed by `RitualLiveActivityController` in
//  the app target via `Activity<RitualActivityAttributes>` — see
//  RitualActivityAttributes.swift (Core/Services/) for the attributes shape
//  and the ⚠️ dual-target-membership note that file needs.
//

import ActivityKit
import WidgetKit
import SwiftUI

private let deepPurple = Color(red: 15/255, green: 12/255, blue: 41/255)
private let gold = Color(red: 255/255, green: 217/255, blue: 0/255)

struct ManifestWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RitualActivityAttributes.self) { context in
            RitualLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(deepPurple)
                .activitySystemActionForegroundColor(gold)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(context.attributes.phaseName) Ritual")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                        Text("369 Manifestation")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.linesWritten)/\(context.attributes.target)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(gold)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    RitualProgressBar(written: context.state.linesWritten, target: context.attributes.target)
                        .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(gold)
            } compactTrailing: {
                // e.g. "6/9"
                Text("\(context.state.linesWritten)/\(context.attributes.target)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(gold)
            }
        }
    }
}

/// Lock Screen banner: phase title + gold progress bar, matching the app's
/// dark-purple/gold palette (hardcoded like `ManifestWidgets.swift`, since
/// asset catalog colors may not resolve inside the extension).
private struct RitualLockScreenView: View {
    let attributes: RitualActivityAttributes
    let state: RitualActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(attributes.phaseName) Ritual")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text("369 Manifestation Method")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Text("\(state.linesWritten)/\(attributes.target)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(gold)
            }
            RitualProgressBar(written: state.linesWritten, target: attributes.target)
        }
        .padding()
    }
}

/// Gold progress bar shared by the Lock Screen and Dynamic Island expanded
/// views, in the app's brand colors.
private struct RitualProgressBar: View {
    let written: Int
    let target: Int

    private var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(written) / Double(target))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.15))
                Capsule().fill(gold)
                    .frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - PREVIEWS

#Preview("Lock Screen", as: .content, using: RitualActivityAttributes(phaseName: "Evening", target: 9)) {
    ManifestWidgetsLiveActivity()
} contentStates: {
    RitualActivityAttributes.ContentState(linesWritten: 2)
    RitualActivityAttributes.ContentState(linesWritten: 6)
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: RitualActivityAttributes(phaseName: "Evening", target: 9)) {
    ManifestWidgetsLiveActivity()
} contentStates: {
    RitualActivityAttributes.ContentState(linesWritten: 6)
}
