import WidgetKit
import SwiftUI

// MARK: - 1. PROVIDER
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), affirmation: "Manifest your dreams.", numerologyNumber: 7, numerologyTitle: "Wisdom")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let data = SharedDataManager.shared.getDailyNumerology()
        let affirmation = SharedDataManager.shared.getDailyAffirmation()
        
        let entry = SimpleEntry(
            date: Date(),
            affirmation: affirmation,
            numerologyNumber: data.number,
            numerologyTitle: data.title
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Fetch fresh data from SharedDefaults
        let data = SharedDataManager.shared.getDailyNumerology()
        let affirmation = SharedDataManager.shared.getDailyAffirmation()
        
        let entry = SimpleEntry(
            date: Date(),
            affirmation: affirmation,
            numerologyNumber: data.number,
            numerologyTitle: data.title
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
}

// MARK: - 3. WIDGET VIEW
struct ManifestWidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    // Theme Colors (Hardcoded to match main app since Assets might not be linked)
    let deepPurple = Color(red: 15/255, green: 12/255, blue: 41/255)
    let gold = Color(red: 255/255, green: 217/255, blue: 0/255)
    
    var body: some View {
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
                .padding()
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 15/255, green: 12/255, blue: 41/255)
        }
    }
}

// MARK: - 4. WIDGET CONFIGURATION
@main
struct ManifestWidgets: Widget {
    let kind: String = "ManifestWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ManifestWidgetsEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color(red: 15/255, green: 12/255, blue: 41/255)
                    }
            } else {
                ManifestWidgetsEntryView(entry: entry)
                    .padding()
                    .background(Color(red: 15/255, green: 12/255, blue: 41/255))
            }
        }
        .configurationDisplayName("Daily Manifestation")
        .description("Your daily numerology and affirmation at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - PREVIEWS
#Preview(as: .systemSmall) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power")
}

#Preview(as: .systemMedium) {
    ManifestWidgets()
} timeline: {
    SimpleEntry(date: .now, affirmation: "I am a magnet for miracles.", numerologyNumber: 8, numerologyTitle: "Power")
}

