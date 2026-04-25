/// NotificationManager369.swift
/// Manages local notifications for the 369 Manifestation Method.
/// Schedules daily reminders for morning, afternoon, and evening writing sessions.

import Foundation
import UserNotifications

class NotificationManager369 {
    static let shared = NotificationManager369()
    
    private let morningIdentifier = "com.manifestai.369.morning"
    private let afternoonIdentifier = "com.manifestai.369.afternoon"
    private let eveningIdentifier = "com.manifestai.369.evening"
    
    // UserDefaults keys
    private let morningTimeKey = "manifestation369_morning_time"
    private let afternoonTimeKey = "manifestation369_afternoon_time"
    private let eveningTimeKey = "manifestation369_evening_time"
    private let notificationsEnabledKey = "manifestation369_notifications_enabled"
    
    // Default times
    private let defaultMorningTime = DateComponents(hour: 8, minute: 0)  // 8:00 AM
    private let defaultAfternoonTime = DateComponents(hour: 14, minute: 0) // 2:00 PM
    private let defaultEveningTime = DateComponents(hour: 20, minute: 0)   // 8:00 PM
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.setNotificationsEnabled(true)
                }
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Enable/Disable
    
    func setNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: notificationsEnabledKey)
        if enabled {
            scheduleAllNotifications()
        } else {
            cancelAllNotifications()
        }
    }
    
    func areNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }
    
    // MARK: - Time Management
    
    func setMorningTime(hour: Int, minute: Int) {
        let dict = ["hour": hour, "minute": minute]
        UserDefaults.standard.set(dict, forKey: morningTimeKey)
        if areNotificationsEnabled() {
            scheduleMorningNotification()
        }
    }
    
    func setAfternoonTime(hour: Int, minute: Int) {
        let dict = ["hour": hour, "minute": minute]
        UserDefaults.standard.set(dict, forKey: afternoonTimeKey)
        if areNotificationsEnabled() {
            scheduleAfternoonNotification()
        }
    }
    
    func setEveningTime(hour: Int, minute: Int) {
        let dict = ["hour": hour, "minute": minute]
        UserDefaults.standard.set(dict, forKey: eveningTimeKey)
        if areNotificationsEnabled() {
            scheduleEveningNotification()
        }
    }
    
    func getMorningTime() -> DateComponents {
        if let dict = UserDefaults.standard.dictionary(forKey: morningTimeKey),
           let hour = dict["hour"] as? Int,
           let minute = dict["minute"] as? Int {
            return DateComponents(hour: hour, minute: minute)
        }
        return defaultMorningTime
    }
    
    func getAfternoonTime() -> DateComponents {
        if let dict = UserDefaults.standard.dictionary(forKey: afternoonTimeKey),
           let hour = dict["hour"] as? Int,
           let minute = dict["minute"] as? Int {
            return DateComponents(hour: hour, minute: minute)
        }
        return defaultAfternoonTime
    }
    
    func getEveningTime() -> DateComponents {
        if let dict = UserDefaults.standard.dictionary(forKey: eveningTimeKey),
           let hour = dict["hour"] as? Int,
           let minute = dict["minute"] as? Int {
            return DateComponents(hour: hour, minute: minute)
        }
        return defaultEveningTime
    }
    
    // MARK: - Scheduling
    
    func scheduleAllNotifications() {
        scheduleMorningNotification()
        scheduleAfternoonNotification()
        scheduleEveningNotification()
    }
    
    private func scheduleMorningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "☀️ Morning Ritual"
        content.body = "Time to write your affirmation 3 times. Start your day with powerful intentions!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MANIFESTATION_369"
        
        let timeComponents = getMorningTime()
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: morningIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling morning notification: \(error)")
            }
        }
    }
    
    private func scheduleAfternoonNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🌤 Afternoon Ritual"
        content.body = "Time for your afternoon manifestation. Write your affirmation 6 times!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MANIFESTATION_369"
        
        let timeComponents = getAfternoonTime()
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: afternoonIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [afternoonIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling afternoon notification: \(error)")
            }
        }
    }
    
    private func scheduleEveningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🌙 Evening Ritual"
        content.body = "Complete your manifestation journey today. Write your affirmation 9 times!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MANIFESTATION_369"
        
        let timeComponents = getEveningTime()
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: eveningIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eveningIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling evening notification: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Specific Phase
    
    func cancelMorningNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
    }
    
    func cancelAfternoonNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [afternoonIdentifier])
    }
    
    func cancelEveningNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eveningIdentifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [morningIdentifier, afternoonIdentifier, eveningIdentifier]
        )
    }
    
    // MARK: - Badge Management
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}


