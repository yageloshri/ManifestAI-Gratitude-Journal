import WidgetKit
import SwiftUI
import AppIntents

// MARK: - 1. PROVIDER
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), affirmation: "Manifest your dreams.", numerologyNumber: 7, numerologyTitle: "Wisdom", streak: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let data = SharedDataManager.shared.getDailyNumerology()
        let affirmation = SharedDataManager.shared.getDailyAffirmation()
        let streak = SharedDataManager.shared.getStreak()

        let entry = SimpleEntry(
            date: Date(),
            affirmation: affirmation,
            numerologyNumber: data.number,
            numerologyTitle: data.title,
            streak: streak
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Fetch fresh data from SharedDefaults
        let data = SharedDataManager.shared.getDailyNumerology()
        let affirmation = SharedDataManager.shared.getDailyAffirmation()
        let streak = SharedDataManager.shared.getStreak()

        let entry = SimpleEntry(
            date: Date(),
            affirmation: affirmation,
            numerologyNumber: data.number,
            numerologyTitle: data.title,
            streak: streak
        )

        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - 2. ENTRY
struct SimpleEntry: TimelineEntry {
    let date: Date
    let affirmation: String
    let numerologyNumber: Int
    let numerologyTitle: String
    let streak: Int
}

// MARK: - 3. WIDGET VIEW
struct ManifestWidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    // Theme Colors (Hardcoded to match main app since Assets might not be linked)
    let deepPurple = Color(red: 15/255, green: 12/255, blue: 41/255)
    let gold = Color(red: 255/255, green: 217/255, blue: 0/255)

    var body: some View {
        Group {
            switch family {
            // Lock Screen / StandBy families (retention plan 3.8) — no
            // interactive button here, just streak + today's number, tap
            // anywhere opens the app via widgetURL below.
            case .accessoryRectangular:
                AccessoryRectangularView(entry: entry)
            case .accessoryCircular:
                AccessoryCircularView(entry: entry)
            case .accessoryInline:
                AccessoryInlineView(entry: entry)
            default:
                homeScreenBody
            }
        }
        // Deep-links to the 369 tab. Requires the app to register the
        // "manifestai" URL scheme (CFBundleURLTypes) and handle it via
        // `.onOpenURL` — see report for exact plist/code needed.
        .widgetURL(URL(string: "manifestai://ritual"))
    }

    /// Original Small/Medium home-screen layout, unchanged, plus the one
    /// interactive "Start Ritual" button (retention plan 3.8) on Medium.
    @ViewBuilder
    private var homeScreenBody: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 26/255, green: 22/255, blue: 56/255), Color(red: 12/255, green: 10/255, blue: 32/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if family == .systemSmall {
                // Small Layout
                VStack(spacing: 8) {
                    Text("\(entry.numerologyNumber)")
                        .font(.system(size: 64, weight: .bold, design: .serif))
                        .foregroundStyle(gold)
                        .shadow(color: gold.opacity(0.3), radius: 10)

                    Text(entry.numerologyTitle.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                // Medium Layout
                VStack(spacing: 10) {
                    HStack(spacing: 20) {
                        // Left: Number
                        VStack {
                            Text("\(entry.numerologyNumber)")
                                .font(.system(size: 64, weight: .bold, design: .serif))
                                .foregroundStyle(gold)
                                .shadow(color: gold.opacity(0.3), radius: 10)

                            Text(entry.numerologyTitle.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(width: 100)

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Right: Affirmation
                        VStack(alignment: .leading) {
                            Text("DAILY AFFIRMATION")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.5))

                            Text("\"\(entry.affirmation)\"")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .italic()
                                .foregroundStyle(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Retention plan 3.8 — the one interactive element:
                    // sets a shared flag without opening the app (see
                    // StartRitualWidgetIntent); tapping the rest of the
                    // widget still opens the app via widgetURL.
                    Button(intent: StartRitualWidgetIntent()) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("START RITUAL")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(0.5)
                        }
                        .foregroundStyle(deepPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(gold, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 15/255, green: 12/255, blue: 41/255)
        }
    }
}

// MARK: - 3b. LOCK SCREEN / STANDBY ACCESSORY VIEWS (retention plan 3.8)
// These render inside the system's tinted/vibrant material on the Lock
// Screen and StandBy, so custom colors are mostly ignored — only
// `.widgetAccentable()` content picks up the user's chosen tint. Keep
// layouts simple; no interactive elements (only the home-screen widget
// gets the "Start Ritual" button per the retention plan).

/// `.accessoryRectangular` — streak (left) + today's personal day number
/// (right), the two headline stats from the retention plan.
struct AccessoryRectangularView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text("STREAK")
                    .font(.system(size: 9, weight: .semibold))
                    .opacity(0.7)
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                    Text("\(entry.streak)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .widgetAccentable()

            Divider()

            VStack(alignment: .leading, spacing: 1) {
                Text("DAY NUMBER")
                    .font(.system(size: 9, weight: .semibold))
                    .opacity(0.7)
                Text("\(entry.numerologyNumber)")
                    .font(.system(size: 17, weight: .bold, design: .serif))
            }
            .widgetAccentable()
        }
    }
}

/// `.accessoryCircular` — a single ring; today's personal day number wins
/// over streak at this size (matches the small home-screen widget's focus).
struct AccessoryCircularView: View {
    let entry: SimpleEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.numerologyNumber)")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                Text("DAY")
                    .font(.system(size: 8, weight: .semibold))
                    .opacity(0.7)
            }
            .widgetAccentable()
        }
    }
}

/// `.accessoryInline` — a single line of text next to the Lock Screen clock.
struct AccessoryInlineView: View {
    let entry: SimpleEntry

    var body: some View {
        Label("\(entry.streak)-day streak · Day \(entry.numerologyNumber)", systemImage: "flame.fill")
    }
}

// MARK: - 4. WIDGET CONFIGURATION
struct ManifestWidgets: Widget {
    let kind: String = "ManifestWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ManifestWidgetsEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // Accessory (Lock Screen/StandBy) families ignore this
                    // and render inside system material regardless, so one
                    // background works for every family.
                    Color(red: 15/255, green: 12/255, blue: 41/255)
                }
        }
        .configurationDisplayName("Daily Manifestation")
        .description("Your daily numerology, streak, and affirmation at a glance.")
        // Home screen (existing) + Lock Screen/StandBy (retention plan 3.8).
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryRectangular, .accessoryCircular, .accessoryInline
        ])
    }
}

// MARK: - PREVIEWS
#Preview(as: .systemSmall) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power", streak: 5)
}

#Preview(as: .systemMedium) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power", streak: 5)
}

#Preview(as: .accessoryRectangular) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power", streak: 5)
}

#Preview(as: .accessoryCircular) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power", streak: 5)
}

#Preview(as: .accessoryInline) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power", streak: 5)
}

