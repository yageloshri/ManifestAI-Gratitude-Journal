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
