/// Manifest369ViewModel.swift
/// ViewModel for managing the 369 Manifestation Method state and persistence.
/// Handles saving/loading progress, midnight resets, and phase completion logic.

import Foundation
import Combine

class Manifest369ViewModel: ObservableObject {
    @Published var cycle: ManifestationCycle
    @Published var notificationsEnabled: Bool = false
    @Published var hasNotificationPermission: Bool = false
    @Published var isOnboardingComplete: Bool = false
    
    private let userDefaultsKey = "manifestationCycle369"
    private let onboardingKey = "manifestation369OnboardingComplete"
    private var midnightTimer: Timer?
    private let notificationManager = NotificationManager369.shared
    
    init() {
        // Load onboarding status
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)
        
        // Load saved cycle or create a new one
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedCycle = try? JSONDecoder().decode(ManifestationCycle.self, from: savedData) {
            
            // Check if we need to reset for a new day
            if !Calendar.current.isDateInToday(decodedCycle.lastUpdatedDate) {
                var newCycle = decodedCycle
                newCycle.reset()
                self.cycle = newCycle
                
                // Reschedule notifications for new day
                notificationManager.scheduleAllNotifications()
            } else {
                self.cycle = decodedCycle
            }
        } else {
            self.cycle = ManifestationCycle()
        }
        
        // Setup midnight reset timer
        setupMidnightTimer()
        
        // Check notification status
        checkNotificationStatus()
    }
    
    // MARK: - Persistence
    
    func saveCycle() {
        cycle.lastUpdatedDate = Date()
        if let encoded = try? JSONEncoder().encode(cycle) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Phase Actions
    
    func incrementMorning() {
        guard cycle.morningCount < 3 else { return }
        cycle.morningCount += 1
        
        // Cancel morning notification if phase is complete
        if cycle.isMorningDone {
            notificationManager.cancelMorningNotification()
        }
        
        saveCycle()
    }
    
    func incrementAfternoon() {
        guard cycle.isMorningDone && cycle.afternoonCount < 6 else { return }
        cycle.afternoonCount += 1
        
        // Cancel afternoon notification if phase is complete
        if cycle.isAfternoonDone {
            notificationManager.cancelAfternoonNotification()
        }
        
        saveCycle()
    }
    
    func incrementEvening() {
        guard cycle.isAfternoonDone && cycle.eveningCount < 9 else { return }
        cycle.eveningCount += 1
        
        // Cancel evening notification if phase is complete
        if cycle.isEveningDone {
            notificationManager.cancelEveningNotification()
            notificationManager.clearBadge()
        }
        
        saveCycle()
    }
    
    func updateAffirmation(_ newAffirmation: String) {
        cycle.affirmation = newAffirmation
        saveCycle()
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetCycle() {
        cycle.reset()
        saveCycle()
        
        // Reschedule all notifications for new day
        if notificationsEnabled {
            notificationManager.scheduleAllNotifications()
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        notificationManager.requestPermission { [weak self] granted in
            self?.hasNotificationPermission = granted
            if granted {
                self?.notificationsEnabled = true
                self?.notificationManager.scheduleAllNotifications()
            }
        }
    }
    
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        notificationManager.setNotificationsEnabled(enabled)
    }
    
    func checkNotificationStatus() {
        notificationsEnabled = notificationManager.areNotificationsEnabled()
        notificationManager.checkPermissionStatus { [weak self] granted in
            self?.hasNotificationPermission = granted
        }
    }
    
    func setNotificationTime(phase: RitualPhase, hour: Int, minute: Int) {
        switch phase {
        case .morning:
            notificationManager.setMorningTime(hour: hour, minute: minute)
        case .afternoon:
            notificationManager.setAfternoonTime(hour: hour, minute: minute)
        case .evening:
            notificationManager.setEveningTime(hour: hour, minute: minute)
        }
    }
    
    func getNotificationTime(phase: RitualPhase) -> DateComponents {
        switch phase {
        case .morning:
            return notificationManager.getMorningTime()
        case .afternoon:
            return notificationManager.getAfternoonTime()
        case .evening:
            return notificationManager.getEveningTime()
        }
    }
    
    // MARK: - Midnight Reset Logic
    
    private func setupMidnightTimer() {
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate next midnight
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
            
            let timeUntilMidnight = nextMidnight.timeIntervalSince(now)
            
            // Schedule timer for midnight
            midnightTimer = Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { [weak self] _ in
                self?.resetCycle()
                self?.setupMidnightTimer() // Reschedule for next midnight
                
                // Reschedule notifications for new day
                if let self = self, self.notificationsEnabled {
                    self.notificationManager.scheduleAllNotifications()
                }
            }
        }
    }
    
    deinit {
        midnightTimer?.invalidate()
    }
}

