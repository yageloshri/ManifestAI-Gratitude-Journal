// AppState.swift
// Centralized app state management for onboarding and navigation

import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
            print("🔄 AppState: hasCompletedOnboarding changed to: \(hasCompletedOnboarding)")
        }
    }
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        print("🚀 AppState initialized - hasCompletedOnboarding: \(hasCompletedOnboarding)")
    }
    
    func completeOnboarding() {
        print("✅ AppState: Completing onboarding...")
        // Update state on main thread - critical for proper UI updates on iPad
        // Button actions are already on main thread, but we ensure it for safety
        if Thread.isMainThread {
            self.hasCompletedOnboarding = true
            // Force UserDefaults synchronization to ensure persistence
            UserDefaults.standard.synchronize()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.hasCompletedOnboarding = true
                UserDefaults.standard.synchronize()
            }
        }
        print("✅ AppState: Onboarding completed - hasCompletedOnboarding = \(hasCompletedOnboarding)")
    }
}



