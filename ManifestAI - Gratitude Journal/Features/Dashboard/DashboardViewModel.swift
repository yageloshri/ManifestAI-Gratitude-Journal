import SwiftUI
import Combine
import WidgetKit

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var userName: String = "Dreamer"
    @Published var greeting: String = "Good Morning"
    @Published var currentDateString: String = ""
    
    @Published var dailyNumber: Int = 1
    @Published var dailyInsightTitle: String = ""
    @Published var dailyInsightDescription: String = ""
    @Published var animatedDailyNumber: Int = 0 // For animation
    
    @Published var dailyAffirmation: String = "I am open to the abundance of the universe."
    @Published var isLoadingAffirmation: Bool = false
    
    // Personalized Insight (Gemini)
    @Published var personalizedInsight: PersonalizedInsight?
    @Published var isLoadingInsight: Bool = false
    @Published var insightError: String?
    
    // Navigation Action
    @Published var selectedTab: Int = 0 // Binding to parent TabView if passed
    
    init() {
        loadUserData()
        updateTimeData()
        calculateNumerology() // This now also sets the affirmation from numerology
        loadPersonalizedInsight() // Load Gemini insight
    }
    
    func loadUserData() {
        self.userName = UserManager.shared.userName
    }
    
    func updateTimeData() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if hour < 12 {
            greeting = "Good Morning"
        } else if hour < 18 {
            greeting = "Good Afternoon"
        } else {
            greeting = "Good Evening"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        currentDateString = formatter.string(from: date)
    }
    
    func calculateNumerology() {
        // Use the correct numerology calculation from NumerologyService
        let birthDate = UserManager.shared.birthDate
        let number = NumerologyService.shared.calculatePersonalDayNumber(birthDate: birthDate)
        
        // Get the full daily message (deterministic - same message throughout the day)
        let message = NumerologyService.shared.getDailyMessageDeterministic(for: number)
        
        self.dailyNumber = number
        self.dailyInsightTitle = message.title
        self.dailyInsightDescription = message.body
        self.dailyAffirmation = message.affirmation // Use numerology affirmation instead of Gemini
        
        // Update Shared Data & Widget
        saveToWidget()
    }
    
    func startNumberAnimation() {
        // Simple counter animation
        animatedDailyNumber = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.animatedDailyNumber < self.dailyNumber {
                self.animatedDailyNumber += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func loadDailyAffirmation() {
        let todayKey = Date().formatted(date: .numeric, time: .omitted)
        let savedDate = UserDefaults.standard.string(forKey: "affirmation_date")
        
        if savedDate == todayKey, let savedText = UserDefaults.standard.string(forKey: "daily_affirmation") {
            // Load cached
            self.dailyAffirmation = savedText
        } else {
            // Generate new
            generateAffirmation(for: todayKey)
        }
    }
    
    func generateAffirmation(for dateKey: String) {
        isLoadingAffirmation = true
        Task {
            do {
                let prompt = "Write a short, powerful daily affirmation for abundance and gratitude. Max 15 words. STRICTLY return ONLY the text, no quotes."
                let text = try await GeminiService.shared.generateContent(prompt: prompt)
                
                self.dailyAffirmation = text.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                UserDefaults.standard.set(self.dailyAffirmation, forKey: "daily_affirmation")
                UserDefaults.standard.set(dateKey, forKey: "affirmation_date")
                
                // Update Shared Data & Widget
                self.saveToWidget()
                
            } catch {
                print("Affirmation gen error: \(error)")
                self.dailyAffirmation = "I attract success and joy into my life effortlessly."
                self.saveToWidget()
            }
            self.isLoadingAffirmation = false
        }
    }
    
    private func saveToWidget() {
        SharedDataManager.shared.saveDailyData(
            affirmation: dailyAffirmation,
            numerologyNumber: dailyNumber,
            numerologyTitle: dailyInsightTitle
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Personalized Insight (Gemini)
    
    func loadPersonalizedInsight() {
        isLoadingInsight = true
        insightError = nil
        
        Task {
            do {
                let insight = try await DailyInsightManager.shared.fetchDailyInsight()
                self.personalizedInsight = insight
                print("✨ Loaded personalized insight: \(insight.headline)")
            } catch {
                print("❌ Failed to load insight: \(error.localizedDescription)")
                self.insightError = error.localizedDescription
                
                // Fallback to generic insight
                let fallback = DailyInsightManager.shared.getFallbackInsight(for: self.dailyNumber)
                self.personalizedInsight = fallback
            }
            self.isLoadingInsight = false
        }
    }
    
    func refreshInsight() {
        isLoadingInsight = true
        insightError = nil
        
        Task {
            do {
                let insight = try await DailyInsightManager.shared.forceRefresh()
                self.personalizedInsight = insight
            } catch {
                print("❌ Failed to refresh insight: \(error.localizedDescription)")
                self.insightError = error.localizedDescription
            }
            self.isLoadingInsight = false
        }
    }
}

