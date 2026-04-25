import Foundation
import SwiftUI

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @AppStorage("user_name") var userName: String = "Dreamer"
    @AppStorage("user_birth_date") private var birthDateTimestamp: Double = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var birthDate: Date {
        get { Date(timeIntervalSince1970: birthDateTimestamp) }
        set { birthDateTimestamp = newValue.timeIntervalSince1970 }
    }
    
    private init() {}
    
    func saveUser(name: String, birthDate: Date) {
        self.userName = name
        self.birthDate = birthDate
    }
    
    // DEPRECATED: Use NumerologyService.shared.calculatePersonalDayNumber(birthDate:) instead
    // This method used modulo 9 which is not the correct numerology calculation
    func calculateDailyNumber() -> Int {
        // Redirect to the correct calculation
        return NumerologyService.shared.calculatePersonalDayNumber(birthDate: birthDate)
    }
}

