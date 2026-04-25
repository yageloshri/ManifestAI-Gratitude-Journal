/// ManifestationCycle.swift
/// Data model for tracking the 369 Manifestation Method progress.
/// This model stores the user's affirmation and tracks completion across three daily phases:
/// Morning (3 reps), Afternoon (6 reps), and Evening (9 reps).

import Foundation

struct ManifestationCycle: Codable {
    // The affirmation statement to be written
    var affirmation: String
    
    // Progress counters for each phase
    var morningCount: Int = 0      // 0 to 3
    var afternoonCount: Int = 0    // 0 to 6
    var eveningCount: Int = 0      // 0 to 9
    
    // Completion flags for each phase
    var isMorningDone: Bool {
        morningCount >= 3
    }
    
    var isAfternoonDone: Bool {
        afternoonCount >= 6
    }
    
    var isEveningDone: Bool {
        eveningCount >= 9
    }
    
    // Total progress out of 18 (3 + 6 + 9)
    var totalProgress: Int {
        morningCount + afternoonCount + eveningCount
    }
    
    var totalTarget: Int {
        18
    }
    
    // Check if all phases are complete
    var isFullyComplete: Bool {
        isMorningDone && isAfternoonDone && isEveningDone
    }
    
    // The date this cycle was last updated (for midnight reset logic)
    var lastUpdatedDate: Date = Date()
    
    // Initialize with a default or custom affirmation
    init(affirmation: String = "I am worthy of all my desires manifesting effortlessly") {
        self.affirmation = affirmation
    }
    
    // Reset all progress (for new day)
    mutating func reset() {
        morningCount = 0
        afternoonCount = 0
        eveningCount = 0
        lastUpdatedDate = Date()
    }
}


