/// SubscriptionManager.swift
/// Manages user subscription status and feature access.
/// Determines what features are available based on subscription tier.

import Foundation
import SwiftUI
import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Published properties
    @Published var isPro: Bool = false
    
    // UserDefaults keys
    private let isProKey = "user_is_pro"
    
    private init() {
        // Load subscription status
        self.isPro = UserDefaults.standard.bool(forKey: isProKey)
    }
    
    // MARK: - Subscription Management
    
    func setProStatus(_ isPro: Bool) {
        self.isPro = isPro
        UserDefaults.standard.set(isPro, forKey: isProKey)
        objectWillChange.send()
    }
    
    func unlockPro() {
        setProStatus(true)
    }
    
    func resetToFree() {
        setProStatus(false)
    }
    
    // MARK: - Feature Access
    
    /// 369 Method - Requires Pro (no free access)
    var can369Method: Bool {
        return isPro
    }
    
    /// Vision Board Save - Can create but not save without Pro
    var canSaveVisionBoard: Bool {
        return isPro
    }
    
    /// Check if user can write journal entry this week
    func canWriteJournalEntry(entriesThisWeek: Int) -> Bool {
        if isPro {
            return true // Unlimited for Pro
        }
        return entriesThisWeek < 3 // Free: 3 per week
    }
    
    // MARK: - Journal Entry Tracking
    
    private let journalEntriesKey = "journal_entries_dates"
    
    /// Get journal entries count for current week
    func getJournalEntriesThisWeek() -> Int {
        guard let savedDates = UserDefaults.standard.array(forKey: journalEntriesKey) as? [TimeInterval] else {
            return 0
        }
        
        let dates = savedDates.map { Date(timeIntervalSince1970: $0) }
        let calendar = Calendar.current
        let now = Date()
        
        // Filter dates that are in current week
        let thisWeekDates = dates.filter { date in
            calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        }
        
        return thisWeekDates.count
    }
    
    /// Record a new journal entry
    func recordJournalEntry() {
        var savedDates = UserDefaults.standard.array(forKey: journalEntriesKey) as? [TimeInterval] ?? []
        savedDates.append(Date().timeIntervalSince1970)
        
        // Clean up old entries (older than 2 weeks)
        let twoWeeksAgo = Date().addingTimeInterval(-14 * 24 * 60 * 60)
        savedDates = savedDates.filter { Date(timeIntervalSince1970: $0) > twoWeeksAgo }
        
        UserDefaults.standard.set(savedDates, forKey: journalEntriesKey)
    }
}


