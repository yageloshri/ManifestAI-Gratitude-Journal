// OnboardingContainerView.swift
// Single container that manages all onboarding steps without NavigationStack
// Uses simple state machine to prevent navigation memory issues

import SwiftUI
import SuperwallKit

enum OnboardingStep {
    case welcome
    case name
    case breakthrough
    case painPoints
    case science
    case numerology
    case analyzing
    case analysis
    case commitment
}

struct OnboardingContainerView: View {
    @ObservedObject private var appState = AppState.shared
    @State private var currentStep: OnboardingStep = .welcome
    @State private var userName = ""
    @State private var selectedBreakthrough: String?
    @State private var selectedPainPoints: [String] = []
    @State private var birthDate: Date
    
    init() {
        var components = DateComponents()
        components.year = 1990
        components.month = 1
        components.day = 1
        let defaultDate = Calendar.current.date(from: components) ?? Date()
        _birthDate = State(initialValue: defaultDate)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                switch currentStep {
                case .welcome:
                    WelcomeStepView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .name
                        }
                    }
                    
                case .name:
                    NameStepView(userName: $userName) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .breakthrough
                        }
                    } onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .welcome
                        }
                    }
                    
                case .breakthrough:
                    BreakthroughStepView(selected: $selectedBreakthrough) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .painPoints
                        }
                    } onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .name
                        }
                    }
                    
                case .painPoints:
                    PainPointsStepView(selected: $selectedPainPoints, userName: userName) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .science
                        }
                    } onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .breakthrough
                        }
                    }
                    
                case .science:
                    ScienceStepView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .numerology
                        }
                    } onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .painPoints
                        }
                    }
                    
                case .numerology:
                    NumerologyStepView(birthDate: $birthDate) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .analyzing
                        }
                    } onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .science
                        }
                    }

                case .analyzing:
                    AnalyzingStepView(birthDate: birthDate) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .analysis
                        }
                    }

                case .analysis:
                    AnalysisStepView(birthDate: birthDate, userName: userName) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .commitment
                        }
                    }
                    
                case .commitment:
                    CommitmentStepView {
                        completeOnboarding()
                    } onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep = .analysis
                        }
                    }
                }
            }
            // Soft forward-slide crossfade. (The previous 0.95 scale-in made
            // every new screen visibly "shrink then snap" for a beat.)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity
            ))
        }
    }
    
    private func completeOnboarding() {
        dlog("🎉 Onboarding Complete! Saving user data...")
        
        // Save persistent user data first
        UserManager.shared.saveUser(name: userName, birthDate: birthDate)
        
        // Set a flag for the Dashboard to show the paywall
        UserDefaults.standard.set(true, forKey: "should_show_paywall_after_onboarding")
        
        // Synchronize UserDefaults before updating app state
        UserDefaults.standard.synchronize()
        
        dlog("✅ Calling AppState.completeOnboarding()...")
        // Button actions are already on main thread, so we can call directly
        // This ensures immediate state update without async delay
        appState.completeOnboarding()
    }
}

#Preview {
    OnboardingContainerView()
}

