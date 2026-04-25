// OnboardingFlowView.swift
// Main onboarding flow with 7 mystical screens
// Created for ManifestAI - Premium Gratitude Journal

import SwiftUI

// MARK: - Main Onboarding Flow
struct OnboardingFlowView: View {
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var birthDate = Date()
    @State private var selectedGoals: Set<ManifestationGoal> = []
    
    var body: some View {
        ZStack {
            // Premium Background
            MysticalBackground()
            
            TabView(selection: $currentPage) {
                // Screen 1: The Hook
                TheHookScreen(currentPage: $currentPage)
                    .tag(0)
                
                // Screen 2: Name Input
                NameInputScreen(userName: $userName, currentPage: $currentPage)
                    .tag(1)
                
                // Screen 3: Birth Date
                BirthDateScreen(birthDate: $birthDate, currentPage: $currentPage)
                    .tag(2)
                
                // Screen 4: Goals Selection
                GoalsSelectionScreen(selectedGoals: $selectedGoals, currentPage: $currentPage)
                    .tag(3)
                
                // Screen 5: Time Commitment
                TimeCommitmentScreen(currentPage: $currentPage)
                    .tag(4)
                
                // Screen 6: Social Proof
                SocialProofScreen(currentPage: $currentPage)
                    .tag(5)
                
                // Screen 7: Commitment CTA
                CommitmentCTAScreen()
                    .tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }
}

// MARK: - Screen 1: The Hook
struct TheHookScreen: View {
    @Binding var currentPage: Int
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // Decorative Frame Top
                HStack {
                    Image(systemName: "flourish.left")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Image(systemName: "flourish.right")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.horizontal, 30)
                
                // Owl Mascot with Floating Animation
                Image("The Hook - 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 380, height: 380)
                    .offset(y: floatingOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            floatingOffset = -10
                        }
                    }
                
                Spacer()
                    .frame(height: 40)
                
                // Title
                Text("Ancient Wisdom Meets\nModern Science")
                    .font(.custom("NewYorkMedium-Semibold", size: 34))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .lineSpacing(2)
                
                Spacer()
                    .frame(height: 20)
                
                // Subtitle
                Text("The only method backed by\npsychology to rewire your\nsubconscious for success.")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Primary CTA Button
                GoldButton(title: "Begin Journey") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage = 1
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Screen 2: Name Input
struct NameInputScreen: View {
    @Binding var userName: String
    @Binding var currentPage: Int
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)
                
                // Owl Mascot
                Image("Name - 2 Input")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 280)
                    .offset(x: 30, y: floatingOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            floatingOffset = -8
                        }
                    }
                
                Spacer()
                    .frame(height: 60)
                
                // Title
                Text("Let's connect.")
                    .font(.custom("NewYorkMedium-Semibold", size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 10)
                
                // Subtitle
                Text("What should we call you?")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                    .frame(height: 40)
                
                // Name Input Field
                GlassTextField(
                    placeholder: "Your Name",
                    text: $userName
                )
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue Button
                GoldButton(title: "Continue") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage = 2
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(userName.isEmpty ? 0.5 : 1.0)
                .disabled(userName.isEmpty)
            }
        }
    }
}

// MARK: - Screen 3: Birth Date
struct BirthDateScreen: View {
    @Binding var birthDate: Date
    @Binding var currentPage: Int
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                // Constellation and Moon Graphics
                HStack(alignment: .top) {
                    // Constellation
                    ConstellationView()
                        .frame(width: 120, height: 120)
                    
                    Spacer()
                    
                    // Owl Mascot
                    Image("Birth - 3 Date")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .offset(y: floatingOffset)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.8)
                                .repeatForever(autoreverses: true)
                            ) {
                                floatingOffset = -8
                            }
                        }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 40)
                
                // Title with Gradient "energy"
                HStack(spacing: 0) {
                    Text("Align your ")
                        .font(.custom("NewYorkMedium-Semibold", size: 36))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("energy.")
                        .font(.custom("NewYorkMedium-Semibold", size: 36))
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                    .frame(height: 10)
                
                // Subtitle
                Text("We use your birth date to calculate\nyour daily numerology and\npersonalized 369 prompts.")
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 30)
                
                // Date Picker in Glass Card
                GlassCard {
                    DatePicker(
                        "",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .environment(\.colorScheme, .dark)
                    .tint(Color(hex: "FFD700"))
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue Button
                GoldButton(title: "Calculate My Profile →") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage = 3
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Screen 4: Goals Selection
struct GoalsSelectionScreen: View {
    @Binding var selectedGoals: Set<ManifestationGoal>
    @Binding var currentPage: Int
    @State private var floatingOffset: CGFloat = 0
    
    let goals = ManifestationGoal.allCases
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                // Owl Mascot
                Image("Goals - 4 Selection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                    .offset(y: floatingOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.6)
                            .repeatForever(autoreverses: true)
                        ) {
                            floatingOffset = -10
                        }
                    }
                
                Spacer()
                    .frame(height: 30)
                
                // Title
                Text("What do you want\nto manifest?")
                    .font(.custom("NewYorkMedium-Semibold", size: 36))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineSpacing(2)
                
                Spacer()
                    .frame(height: 50)
                
                // Goals Grid (2x2)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(goals, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: selectedGoals.contains(goal)
                        ) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Next Button
                GoldButton(title: "Next") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage = 4
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Screen 5: Time Commitment
struct TimeCommitmentScreen: View {
    @Binding var currentPage: Int
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // Header Title
                Text("THE OBJECTION KILLER")
                    .font(.custom("NewYorkMedium-Regular", size: 22))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("(Time to Result)")
                    .font(.custom("NewYorkMedium-Regular", size: 18))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 2)
                
                Spacer()
                    .frame(height: 40)
                
                // Owl and Hourglass
                HStack(spacing: -30) {
                    Image("Time - 5 Commitment")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .offset(y: floatingOffset)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.7)
                                .repeatForever(autoreverses: true)
                            ) {
                                floatingOffset = -8
                            }
                        }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 20)
                
                // Main Content Card
                GlassCard {
                    VStack(spacing: 24) {
                        Text("Rewrite your brain\nin 3 minutes.")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .lineSpacing(4)
                        
                        Text("Morning: 1 min • Afternoon: 1 min • Night: 1 min")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                            .frame(height: 10)
                        
                        // Timeline Visual
                        TimelineView()
                            .frame(height: 120)
                    }
                    .padding(32)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue Button
                GoldButton(title: "Sounds Good") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage = 5
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Screen 6: Social Proof
struct SocialProofScreen: View {
    @Binding var currentPage: Int
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)
                
                // Owl Mascot
                Image("Social - 6 Proof")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260, height: 260)
                    .offset(x: -20, y: floatingOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.4)
                            .repeatForever(autoreverses: true)
                        ) {
                            floatingOffset = -8
                        }
                    }
                
                Spacer()
                    .frame(height: 40)
                
                // Headline
                Text("It really works.")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 30)
                
                // Testimonial Card
                GlassCard {
                    VStack(spacing: 20) {
                        // 5 Stars
                        HStack(spacing: 8) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                        }
                        
                        // Testimonial Text
                        Text(""I manifested my new job in just 3 weeks! The AI journal keeps me focused."")
                            .font(.custom("Georgia", size: 24))
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .lineSpacing(6)
                            .padding(.horizontal, 10)
                        
                        // Avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "4A90E2"),
                                        Color(hex: "7B2CBF"),
                                        Color(hex: "C77DFF")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Ready Button
                GoldButton(title: "I'm Ready") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPage = 6
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Screen 7: Commitment CTA
struct CommitmentCTAScreen: View {
    @State private var floatingOffset: CGFloat = 0
    @State private var glowPulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 120)
                
                // Hero Owl with Orb
                ZStack {
                    // Glow Effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFD700").opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 180
                            )
                        )
                        .frame(width: 360, height: 360)
                        .scaleEffect(glowPulse)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                            ) {
                                glowPulse = 1.2
                            }
                        }
                    
                    // Owl Image
                    Image("Commit - 7 CTA")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320, height: 320)
                        .offset(y: floatingOffset)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 3.0)
                                .repeatForever(autoreverses: true)
                            ) {
                                floatingOffset = -12
                            }
                        }
                }
                
                Spacer()
                    .frame(height: 50)
                
                // Title
                Text("The Universe Rewards\nConsistency.")
                    .font(.custom("NewYorkMedium-Semibold", size: 36))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 16)
                
                // Subtitle
                Text("Are you ready to commit 3\nminutes a day to yourself?")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                
                Spacer()
                
                // Final CTA with Pulsing Glow
                ZStack {
                    // Pulsing glow background
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .blur(radius: 20)
                        .scaleEffect(glowPulse * 1.05)
                    
                    GoldButton(title: "I Commit to Myself") {
                        // Navigate to main app
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Supporting Types
enum ManifestationGoal: String, CaseIterable {
    case financial = "Financial\nAbundance"
    case love = "Soulmate &\nLove"
    case peace = "Inner\nPeace"
    case career = "Career\nGrowth"
    
    var icon: String {
        switch self {
        case .financial: return "dollarsign.circle.fill"
        case .love: return "heart.fill"
        case .peace: return "leaf.fill"
        case .career: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingFlowView()
}

