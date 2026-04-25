import Foundation
import SwiftUI

class SharedDataManager {
    static let shared = SharedDataManager()
    
    // MARK: - CONFIGURATION
    // ⚠️ CRITICAL: Must match the App Group ID created in Xcode -> Signing & Capabilities
    let appGroupId = "group.com.manifestai.journal"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    // MARK: - KEYS
    private let keyAffirmation = "dailyAffirmation"
    private let keyNumerologyNumber = "dailyNumerologyNumber"
    private let keyNumerologyTitle = "dailyNumerologyTitle"
    
    // MARK: - WRITERS (Called by Main App)
    func saveDailyData(affirmation: String, numerologyNumber: Int, numerologyTitle: String) {
        userDefaults?.set(affirmation, forKey: keyAffirmation)
        userDefaults?.set(numerologyNumber, forKey: keyNumerologyNumber)
        userDefaults?.set(numerologyTitle, forKey: keyNumerologyTitle)
        
        // Debug
        print("💾 SharedDataManager: Saved data to \(appGroupId)")
    }
    
    // MARK: - READERS (Called by Widget)
    func getDailyAffirmation() -> String {
        return userDefaults?.string(forKey: keyAffirmation) ?? "I am aligned with my highest self."
    }
    
    func getDailyNumerology() -> (number: Int, title: String) {
        let number = userDefaults?.integer(forKey: keyNumerologyNumber) ?? 0
        let title = userDefaults?.string(forKey: keyNumerologyTitle) ?? "Manifestation"
        
        // If 0 (not set), return defaults
        if number == 0 {
            return (1, "New Beginnings")
        }
        
        return (number, title)
    }
}

