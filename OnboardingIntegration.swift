// OnboardingIntegration.swift
// Integration helpers and data persistence for onboarding
// Created for ManifestAI - Premium Gratitude Journal

import SwiftUI
import Foundation

// MARK: - Onboarding Manager
/// Manages onboarding state and user data persistence
class OnboardingManager: ObservableObject {
    // MARK: - Published Properties
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var birthDate: Date {
        didSet {
            UserDefaults.standard.set(birthDate, forKey: "birthDate")
        }
    }
    
    @Published var selectedGoals: [String] {
        didSet {
            UserDefaults.standard.set(selectedGoals, forKey: "selectedGoals")
        }
    }
    
    // MARK: - Initialization
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.birthDate = UserDefaults.standard.object(forKey: "birthDate") as? Date ?? Date()
        self.selectedGoals = UserDefaults.standard.stringArray(forKey: "selectedGoals") ?? []
    }
    
    // MARK: - Methods
    func completeOnboarding() {
        hasCompletedOnboarding = true
        
        // Calculate numerology
        let numerology = calculateNumerology(from: birthDate)
        UserDefaults.standard.set(numerology, forKey: "userNumerology")
        
        // Track analytics (integrate your analytics here)
        trackOnboardingCompletion()
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        userName = ""
        birthDate = Date()
        selectedGoals = []
    }
    
    // MARK: - Private Helpers
    private func calculateNumerology(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return 0
        }
        
        // Simple life path number calculation
        let sum = day + month + year
        return reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 && result != 11 && result != 22 && result != 33 {
            result = String(result).compactMap { Int(String($0)) }.reduce(0, +)
        }
        return result
    }
    
    private func trackOnboardingCompletion() {
        // TODO: Integrate with your analytics service
        // Example: Analytics.logEvent("onboarding_completed", parameters: [...])
        print("✅ Onboarding completed for: \(userName)")
        print("📅 Birth Date: \(birthDate)")
        print("🎯 Goals: \(selectedGoals)")
    }
}

// MARK: - Main App Integration Example
/*
 
 How to use in your main App file:
 
 @main
 struct ManifestAIApp: App {
     @StateObject private var onboardingManager = OnboardingManager()
     
     var body: some Scene {
         WindowGroup {
             if onboardingManager.hasCompletedOnboarding {
                 MainAppView()
                     .environmentObject(onboardingManager)
             } else {
                 OnboardingFlowViewWithManager()
                     .environmentObject(onboardingManager)
             }
         }
     }
 }
 
 */

// MARK: - Enhanced Onboarding Flow with Manager
struct OnboardingFlowViewWithManager: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var birthDate = Date()
    @State private var selectedGoals: Set<ManifestationGoal> = []
    
    var body: some View {
        ZStack {
            MysticalBackground()
            
            TabView(selection: $currentPage) {
                TheHookScreen(currentPage: $currentPage)
                    .tag(0)
                
                NameInputScreen(userName: $userName, currentPage: $currentPage)
                    .tag(1)
                
                BirthDateScreen(birthDate: $birthDate, currentPage: $currentPage)
                    .tag(2)
                
                GoalsSelectionScreen(selectedGoals: $selectedGoals, currentPage: $currentPage)
                    .tag(3)
                
                TimeCommitmentScreen(currentPage: $currentPage)
                    .tag(4)
                
                SocialProofScreen(currentPage: $currentPage)
                    .tag(5)
                
                CommitmentCTAScreenWithManager(
                    userName: userName,
                    birthDate: birthDate,
                    selectedGoals: selectedGoals
                )
                .tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }
}

// MARK: - Enhanced Commitment Screen
struct CommitmentCTAScreenWithManager: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    let userName: String
    let birthDate: Date
    let selectedGoals: Set<ManifestationGoal>
    
    @State private var floatingOffset: CGFloat = 0
    @State private var glowPulse: CGFloat = 1.0
    @State private var isCommitting = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 120)
                
                // Hero Owl with Orb
                ZStack {
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
                
                Text("The Universe Rewards\nConsistency.")
                    .font(.custom("NewYorkMedium-Semibold", size: 36))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 16)
                
                Text("Are you ready to commit 3\nminutes a day to yourself?")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                
                Spacer()
                
                ZStack {
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
                    
                    GoldButton(title: isCommitting ? "✨ Manifesting..." : "I Commit to Myself") {
                        commitToJourney()
                    }
                    .disabled(isCommitting)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
    
    private func commitToJourney() {
        isCommitting = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Save data to manager
        onboardingManager.userName = userName
        onboardingManager.birthDate = birthDate
        onboardingManager.selectedGoals = selectedGoals.map { $0.rawValue }
        
        // Delay for animation effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                onboardingManager.completeOnboarding()
            }
        }
    }
}

// MARK: - Preview Provider
#Preview {
    OnboardingFlowViewWithManager()
        .environmentObject(OnboardingManager())
}

