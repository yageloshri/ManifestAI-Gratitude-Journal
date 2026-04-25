import SwiftUI
import SwiftData

struct JournalListView: View {
    @State private var showInput = false
    // Fetch real data sorted by date
    @Query(sort: \JournalEntry.date, order: .reverse) var entries: [JournalEntry]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.mysticalGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    JournalHeader()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                            // Headline & Stats
                            JournalStats(count: entries.count)
                            
                            if entries.isEmpty {
                                // Empty State
                                JournalEmptyState()
                            } else {
                                // Real Timeline
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                        NavigationLink(destination: JournalDetailView(entry: entry)) {
                                            TimelineEntryView(
                                                date: entry.date.formatted(date: .abbreviated, time: .shortened),
                                                title: entry.isElevated ? "Elevated Entry" : "Daily Gratitude",
                                                content: entry.elevatedText ?? entry.rawText,
                                                icon: entry.isElevated ? "sparkles" : "pencil",
                                                iconColor: entry.isElevated ? Theme.Colors.primary : Color.white,
                                                isFirst: index == 0,
                                                isLast: index == entries.count - 1
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle()) // Prevent default button styling
                                    }
                                }
                                .padding(.horizontal, Theme.Spacing.xxl)
                            }
                        }
                        .padding(.bottom, 100.responsive)
                    }
                }
                
                // FAB
                JournalFAB(showInput: $showInput)
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showInput) {
                JournalInputView()
            }
        }
    }
}

// Subviews to fix compiler complexity
struct JournalHeader: View {
    var body: some View {
        HStack {
            Text("MY GRATITUDE")
                .font(Theme.Fonts.display(size: 12, weight: .bold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            Button {
                // Search action
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.Colors.primary)
                    .frame(width: 40.responsive, height: 40.responsive)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.top, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm)
        .background(Theme.Colors.backgroundDark.opacity(0.8))
    }
}

struct JournalStats: View {
    let count: Int
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("My Journey")
                .font(Theme.Fonts.display(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "efe6c1"), Color(hex: "cbc290")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            HStack(spacing: Theme.Spacing.xs * 1.5) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.primary)
                
                Text("\(count) entries")
                    .font(Theme.Fonts.display(size: 12, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(Color(hex: "cbc290"))
                    .textCase(.uppercase)
            }
            
            // Free User Limit Indicator
            if !subscriptionManager.isPro {
                let entriesThisWeek = subscriptionManager.getJournalEntriesThisWeek()
                let remaining = max(0, 3 - entriesThisWeek)
                
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: remaining > 0 ? "hourglass" : "lock.fill")
                        .font(.caption)
                        .foregroundColor(remaining > 0 ? Color(hex: "FFD700") : .red)
                    
                    if remaining > 0 {
                        Text("\(remaining) free \(remaining == 1 ? "entry" : "entries") left this week")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Weekly limit reached")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundColor(Color(hex: "FFD700"))
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Spacing.sm)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Spacing.sm)
                                .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.top, Theme.Spacing.xxl)
    }
}

struct JournalEmptyState: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "book.pages")
                .font(Theme.Fonts.system(size: 48))
                .foregroundStyle(Theme.Colors.primary.opacity(0.5))
            
            Text("Start your journey")
                .font(Theme.Fonts.display(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
            
            Text("Capture your first moment of gratitude.")
                .font(Theme.Fonts.body(size: 14))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60.responsive)
    }
}

struct JournalFAB: View {
    @Binding var showInput: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showInput = true
                } label: {
                    Image(systemName: "plus")
                        .font(Theme.Fonts.system(size: 32, weight: .semibold))
                        .foregroundStyle(Theme.Colors.backgroundDark)
                        .frame(width: 64.responsive, height: 64.responsive)
                        .background(Theme.Colors.primary)
                        .clipShape(Circle())
                        .shadow(color: Theme.Colors.primary.opacity(0.4), radius: 25, x: 0, y: 0)
                }
                .padding(.trailing, Theme.Spacing.xxl)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
    }
}

struct TimelineEntryView: View {
    let date: String
    let title: String
    let content: String
    let icon: String
    let iconColor: Color
    var hasImage: Bool = false
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.lg) {
            // Timeline Line
            VStack(alignment: .center, spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1, height: 20.responsive)
                } else {
                    Spacer().frame(height: 20.responsive)
                }
                
                ZStack {
                    if isFirst {
                        Circle()
                            .stroke(Theme.Colors.primary, lineWidth: 1)
                            .background(Theme.Colors.primary.opacity(0.2))
                            .frame(width: 32.responsive, height: 32.responsive)
                            .clipShape(Circle())
                            .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 15)
                    } else {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .background(Color.white.opacity(0.05))
                            .frame(width: 32.responsive, height: 32.responsive)
                            .clipShape(Circle())
                    }
                    
                    Image(systemName: icon)
                        .font(Theme.Fonts.system(size: 14))
                        .foregroundStyle(isFirst ? Theme.Colors.primary : .white)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isFirst ? Theme.Colors.primary.opacity(0.5) : Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 32.responsive)
            
            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(date)
                    .font(Theme.Fonts.display(size: 12, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .padding(.top, Theme.Spacing.xxl) // Align with icon center roughly
                
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Text(title)
                            .font(Theme.Fonts.display(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: icon)
                            .foregroundStyle(iconColor)
                    }
                    
                    Text(content)
                        .font(Theme.Fonts.body(size: 14))
                        .foregroundStyle(Color(hex: "e2e2e2").opacity(0.9))
                        .lineLimit(3)
                        .lineSpacing(4)
                    
                    if hasImage {
                        RoundedRectangle(cornerRadius: Theme.Spacing.md)
                            .fill(Color.black.opacity(0.3))
                            .responsiveHeight(120)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.white.opacity(0.2))
                            )
                            .overlay(
                                Text("Meditation Scene")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.4))
                            )
                    }
                }
                .padding(Theme.Spacing.lg)
                .glassPanel()
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    JournalListView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
