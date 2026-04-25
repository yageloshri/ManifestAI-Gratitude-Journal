import SwiftUI
import UIKit
import SwiftData
import SuperwallKit

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            // Today (Home)
            TodayView(viewModel: viewModel, tabSelection: $selection)
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }
                .tag(0)
            
            // Journal
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
                .tag(1)
            
            // Vision Board
            VisionHomeView()
                .tabItem {
                    Label("Vision", systemImage: "eye")
                }
                .tag(2)
            
            // 369 Manifestation
            Manifest369View()
                .tabItem {
                    Label("369", systemImage: "sparkles")
                }
                .tag(3)
            
            // Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
        .tint(Theme.Colors.primary)
        .onAppear {
            print("🎬 DashboardView appeared")
            
            // Customize TabBar appearance for dark theme
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "0f0c29"))
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Check if we should show paywall after onboarding
            checkAndShowPaywall()
        }
    }
    
    // MARK: - Paywall Check
    private func checkAndShowPaywall() {
        // בודק אם הדגל קיים ומוגדר כ-True
        if UserDefaults.standard.bool(forKey: "should_show_paywall_after_onboarding") {
            print("🔍 DashboardView: Paywall flag detected! Will show paywall after onboarding")
            
            // עיכוב קטנטן כדי לתת לאנימציית המעבר להסתיים (חווית משתמש טובה יותר)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("📱 DashboardView: Triggering Superwall paywall NOW...")
                
                // 1. קריאה ל-Superwall עם register placement
                Superwall.shared.register(placement: "campaign_trigger")
                
                // 2. איפוס הדגל כדי שזה לא יקרה בכל פעם שנכנסים לאפליקציה
                UserDefaults.standard.set(false, forKey: "should_show_paywall_after_onboarding")
                
                print("✅ DashboardView: Paywall triggered - staying on Dashboard when dismissed")
            }
        } else {
            print("ℹ️ DashboardView: No paywall flag - normal dashboard load")
        }
    }
}

struct TodayView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var tabSelection: Int
    @State private var showNumberDetail = false
    @Query(sort: \JournalEntry.date, order: .reverse) var journalEntries: [JournalEntry]
    @Query var visionBoards: [VisionBoardEntity]
    
    var body: some View {
        ZStack {
            // Background - Deep Indigo to Black gradient
            LinearGradient(
                colors: [
                    Color(hex: "0a0e27"),
                    Color(hex: "000000")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // ✨ HEADER - Centered Greeting
                    VStack(spacing: 0) {
                        Text("\(viewModel.greeting), \(viewModel.userName)")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // 🎯 COMPACT NUMEROLOGY HERO (3:1 Horizontal Card)
                    CompactNumerologyCard(viewModel: viewModel, showDetail: $showNumberDetail)
                        .padding(.horizontal, 20)
                    
                    // ✨ DAILY STREAK (Below Numerology)
                    HStack(spacing: 4) {
                        LottieView(
                            name: "Fire animation",
                            loopMode: .loop,
                            animationSpeed: 1.0
                        )
                        .frame(width: 20, height: 20)
                        
                        Text("\(calculateStreak()) Day Streak")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "FFD700").opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // 🎨 BENTO GRID - Premium Manifestation Hub
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR MANIFESTATION HUB")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 20)
                        
                        HStack(alignment: .top, spacing: 12) {
                            // LEFT: Tall Gratitude Journal Card
                            GratitudeJournalCard(
                                entryCount: journalEntries.count,
                                action: { tabSelection = 1 }
                            )
                            
                            // RIGHT: Stacked Cards
                            VStack(spacing: 12) {
                                // Vision Board Card
                                VisionBoardCard(
                                    boards: visionBoards,
                                    action: { tabSelection = 2 }
                                )
                                
                                // 369 Method Card
                                Method369Card(
                                    action: { tabSelection = 3 }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showNumberDetail) {
            NumberDetailSheet(viewModel: viewModel, showNumberDetail: $showNumberDetail)
        }
    }
    
    private func calculateStreak() -> Int {
        // Calculate consecutive days with journal entries
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for entry in journalEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            if calendar.isDate(entryDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if entryDate < currentDate {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Compact Numerology Card (3:1 Horizontal)
struct CompactNumerologyCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var showDetail: Bool
    
    var body: some View {
        Button(action: { showDetail = true }) {
            HStack(spacing: 20) {
                // LEFT: Compact Number Ring
            ZStack {
                    // Glow rings
                    Circle()
                        .stroke(Color(hex: "FFD700").opacity(0.15), lineWidth: 1)
                        .frame(width: 90, height: 90)
                
                Circle()
                        .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1.5)
                        .frame(width: 75, height: 75)
                
                    // The Number
                Text("\(viewModel.animatedDailyNumber)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFF5B3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                        .shadow(color: Color(hex: "FFD700").opacity(0.6), radius: 20, x: 0, y: 0)
                    .contentTransition(.numericText(value: Double(viewModel.animatedDailyNumber)))
            }
                .frame(width: 90)
                
                // RIGHT: Title + Description + Arrow
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "FFD700"))
                        Text("DAILY NUMEROLOGY")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Text(viewModel.dailyInsightTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text("Read Full Insight")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color(hex: "FFD700"))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "FFD700"))
                    }
                    .padding(.top, 4)
            }
            
            Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1a1a40"),
                                Color(hex: "0a0a20")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700").opacity(0.3), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
            )
            }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(duration: 1.5)) {
                viewModel.startNumberAnimation()
            }
        }
    }
}

// MARK: - Gratitude Journal Card (Tall Vertical)
struct GratitudeJournalCard: View {
    let entryCount: Int
    let action: () -> Void
    
    // Daily prompts to rotate through
    private let prompts = [
        "What made you smile today?",
        "Who inspired you recently?",
        "What are you proud of?",
        "What brought you peace today?",
        "What opportunity are you grateful for?"
    ]
    
    private var todaysPrompt: String {
        let day = Calendar.current.component(.day, from: Date())
        return prompts[day % prompts.count]
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Lottie Animation at top
                LottieView(
                    name: "Write Icon loop",
                    loopMode: .loop,
                    animationSpeed: 1.0
                )
                .frame(width: 60, height: 60)
                .padding(.bottom, 20)
                
                // Title
                Text("Gratitude\nJournal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .padding(.bottom, 6)
                
                // CTA
                Text("Write today's entry")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 20)
                
                // Daily Suggestion Section (NEW - adds content density)
                VStack(alignment: .leading, spacing: 6) {
                    Text("TODAY'S SUGGESTION")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Text(todaysPrompt)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(2)
                        .italic()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                // Stats at bottom
                HStack {
                    Text("Total Entries:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(entryCount)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "FFD700"))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "252545").opacity(0.95),
                                Color(hex: "0f0f20")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
        .frame(height: 340)
    }
}

// MARK: - Vision Board Card (Square with Preview)
struct VisionBoardCard: View {
    let boards: [VisionBoardEntity]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background with blurred preview or placeholder collage
                if let latestBoard = boards.first,
                   let items = latestBoard.items,
                   let firstItem = items.first,
                   let uiImage = UIImage(data: firstItem.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 164, height: 164)
                        .blur(radius: 20)
                        .opacity(0.3)
                        .clipped()
                } else {
                    // Placeholder: Collage of 3 overlapping rectangles
                    ZStack {
                        // Background gradient
                        LinearGradient(
                            colors: [
                                Color(hex: "1f1f38").opacity(0.95),
                                Color(hex: "0f0f20")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Collage effect - 3 overlapping image placeholders
                        GeometryReader { geometry in
                            ZStack {
                                // Back rectangle
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 1)
                                    .offset(x: 30, y: 45)
                                    .rotationEffect(.degrees(-8))
                                
                                // Middle rectangle
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.pink.opacity(0.35), Color.pink.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 1)
                                    .offset(x: 50, y: 50)
                                    .rotationEffect(.degrees(5))
                                
                                // Front rectangle
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.25)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 1)
                                    .offset(x: 70, y: 55)
                                    .rotationEffect(.degrees(-3))
                            }
                        }
                    }
                }
                
                // Overlay content
                VStack(alignment: .leading, spacing: 10) {
                    // Lottie Animation
                    LottieView(
                        name: "Mission & Vision",
                        loopMode: .loop,
                        animationSpeed: 1.0
                    )
                    .frame(width: 45, height: 45)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vision\nBoard")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        
                        Text("\(boards.count) boards")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: 164, height: 164)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1f1f38").opacity(0.95),
                                Color(hex: "0f0f20")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.purple.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 369 Method Card (Square with Gold Glow)
struct Method369Card: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Lottie Animation
                LottieView(
                    name: "Shining Stars",
                    loopMode: .loop,
                    animationSpeed: 1.0
                )
                .frame(width: 45, height: 45)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("369\nMethod")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    
                    Text("Start Session")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(hex: "FFD700").opacity(0.9))
                }
            }
            .padding(16)
            .frame(width: 164, height: 164)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "2a2520").opacity(0.95),
                                Color(hex: "0f0f10")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color(hex: "FFD700").opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    // Soft gold glow effect (replaces hard border)
                    .shadow(color: Color(hex: "FFD700").opacity(0.25), radius: 20, x: 0, y: 0)
                    .shadow(color: Color(hex: "FFD700").opacity(0.15), radius: 12, x: 0, y: 0)
                    .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Number Detail Sheet
struct NumberDetailSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var showNumberDetail: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "0a0e27"),
                    Color(hex: "1a1147")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.isLoadingInsight {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(hex: "FFD700"))
                    Text("Channeling your energy...")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.7))
                }
            } else if let insight = viewModel.personalizedInsight {
                // Main content with personalized insight
                ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Drag indicator
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                
                        // Number Badge
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FFD700").opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Text("\(viewModel.dailyNumber)")
                                .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color(hex: "FFD700"))
                        }
                    .padding(.top, 8)
                
                        // Headline
                        Text(insight.headline.uppercased())
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .tracking(1)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                        
                        // General Vibe
                        Text(insight.generalVibe)
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                            .padding(.horizontal, 24)
                        
                        // Advice Cards
                        VStack(spacing: 16) {
                            // Love Advice
                            AdviceCard(
                                icon: "heart.fill",
                                title: "Love & Relationships",
                                advice: insight.loveAdvice,
                                color: Color.pink
                            )
                            
                            // Career Advice
                            AdviceCard(
                                icon: "briefcase.fill",
                                title: "Career & Goals",
                                advice: insight.careerAdvice,
                                color: Color.blue
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Lucky Attributes
                        VStack(alignment: .leading, spacing: 16) {
                            Text("✨ YOUR LUCKY ATTRIBUTES")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.horizontal, 24)
                            
                            HStack(spacing: 16) {
                                LuckyAttributeChip(
                                    icon: "paintpalette.fill",
                                    label: "Color",
                                    value: insight.luckyAttributes.color
                                )
                                
                                LuckyAttributeChip(
                                    icon: "sparkles",
                                    label: "Crystal",
                                    value: insight.luckyAttributes.crystal
                                )
                                
                                LuckyAttributeChip(
                                    icon: "clock.fill",
                                    label: "Time",
                                    value: insight.luckyAttributes.time
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 8)
                        
                        // Refresh Button (if there's an error or user wants new insight)
                        if viewModel.insightError != nil {
                            Button {
                                viewModel.refreshInsight()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(hex: "FFD700"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(hex: "FFD700").opacity(0.15))
                                .clipShape(Capsule())
                            }
                }
                
                // Close button
                Button {
                    showNumberDetail = false
                } label: {
                    Text("Close")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                        .padding(.top, 8)
                    }
                }
            } else {
                // Error state (fallback should have loaded)
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Unable to load insight")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Button("Retry") {
                        viewModel.loadPersonalizedInsight()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "FFD700"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "FFD700").opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Advice Card
struct AdviceCard: View {
    let icon: String
    let title: String
    let advice: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text(advice)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Lucky Attribute Chip
struct LuckyAttributeChip: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: "FFD700"))
            
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DashboardView()
}
