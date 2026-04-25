import Foundation

/// Manages personalized daily numerology insights with strict "once-per-day" logic
class DailyInsightManager {
    static let shared = DailyInsightManager()
    
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cachedPersonalizedInsight"
    private let lastInsightDateKey = "lastInsightDate"
    
    private init() {}
    
    // MARK: - Public API
    
    /// Fetches personalized insight. Returns cached if already generated today, otherwise calls Gemini API.
    func fetchDailyInsight() async throws -> PersonalizedInsight {
        // 1. Check if we already generated insight today
        if let cachedInsight = loadCachedInsight(),
           Calendar.current.isDateInToday(cachedInsight.date) {
            print("✅ Using cached insight from today")
            return cachedInsight.insight
        }
        
        // 2. Generate new insight via Gemini
        print("🔮 Generating new insight via Gemini...")
        let newInsight = try await generateNewInsight()
        
        // 3. Save to cache
        saveCachedInsight(newInsight)
        
        return newInsight
    }
    
    /// Force refresh (useful for debugging or manual refresh)
    func forceRefresh() async throws -> PersonalizedInsight {
        let newInsight = try await generateNewInsight()
        saveCachedInsight(newInsight)
        return newInsight
    }
    
    // MARK: - Private Helpers
    
    private func generateNewInsight() async throws -> PersonalizedInsight {
        // Get user data
        let userName = UserManager.shared.userName
        let birthDate = UserManager.shared.birthDate
        let personalDayNumber = calculatePersonalDayNumber(birthDate: birthDate)
        let today = Date()
        
        // Build Gemini prompt
        let prompt = buildGeminiPrompt(
            userName: userName,
            personalDayNumber: personalDayNumber,
            date: today
        )
        
        // Call Gemini API
        let rawResponse = try await GeminiService.shared.generateContent(prompt: prompt)
        
        // Parse JSON response
        let insight = try parseGeminiResponse(rawResponse)
        
        return insight
    }
    
    private func buildGeminiPrompt(userName: String, personalDayNumber: Int, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: date)
        
        return """
        Role: You are a mystical Numerology Expert and Life Coach.
        
        User Profile:
        - Name: \(userName)
        - Personal Day Number: \(personalDayNumber)
        - Date: \(dateString)
        
        Task: Create a deeply personalized daily numerology reading for \(userName). The reading must be based on the vibration of the number \(personalDayNumber).
        
        Output Format: Return ONLY a raw JSON object (no markdown formatting, no code blocks, no ```json tags). Follow this exact schema:
        
        {
          "headline": "A short, 3-word empowering title (e.g. 'Embrace Creative Flow')",
          "general_vibe": "A warm, engaging paragraph (30 words max) speaking directly to \(userName). Use their name once.",
          "love_advice": "Specific actionable advice for relationships today (1 sentence).",
          "career_advice": "Specific actionable advice for work/goals today (1 sentence).",
          "lucky_attributes": {
            "color": "A specific color",
            "crystal": "A specific crystal",
            "time": "A specific time (e.g. 14:22)"
          }
        }
        
        IMPORTANT: Return ONLY the JSON. No extra text, no markdown, no explanations.
        """
    }
    
    private func parseGeminiResponse(_ rawResponse: String) throws -> PersonalizedInsight {
        // Clean up response (remove markdown code blocks if present)
        var cleanedResponse = rawResponse
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to parse JSON
        guard let jsonData = cleanedResponse.data(using: .utf8) else {
            throw NSError(domain: "DailyInsightManager", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to convert response to data"
            ])
        }
        
        let decoder = JSONDecoder()
        let insight = try decoder.decode(PersonalizedInsight.self, from: jsonData)
        
        return insight
    }
    
    private func calculatePersonalDayNumber(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let birthDay = calendar.component(.day, from: birthDate)
        let birthMonth = calendar.component(.month, from: birthDate)
        let currentDay = calendar.component(.day, from: now)
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        let sum = birthDay + birthMonth + currentDay + currentMonth + currentYear
        return reduceToSingleDigit(sum)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var result = number
        while result > 9 {
            result = String(result).compactMap { Int(String($0)) }.reduce(0, +)
        }
        return result
    }
    
    // MARK: - Local Storage
    
    private func saveCachedInsight(_ insight: PersonalizedInsight) {
        let birthDate = UserManager.shared.birthDate
        let personalDayNumber = calculatePersonalDayNumber(birthDate: birthDate)
        
        let cached = CachedInsight(
            insight: insight,
            date: Date(),
            personalDayNumber: personalDayNumber
        )
        
        if let encoded = try? JSONEncoder().encode(cached) {
            userDefaults.set(encoded, forKey: cacheKey)
            userDefaults.set(Date(), forKey: lastInsightDateKey)
            print("💾 Saved insight to cache")
        }
    }
    
    private func loadCachedInsight() -> CachedInsight? {
        guard let data = userDefaults.data(forKey: cacheKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(CachedInsight.self, from: data)
    }
    
    // MARK: - Fallback (for errors)
    
    func getFallbackInsight(for number: Int) -> PersonalizedInsight {
        // Generic fallback based on number vibration
        let fallbacks: [Int: PersonalizedInsight] = [
            1: PersonalizedInsight(
                headline: "Lead with Confidence",
                generalVibe: "Today's energy supports new beginnings and bold initiatives. Trust your instincts and take the first step.",
                loveAdvice: "Be honest about your feelings and take initiative in your relationships.",
                careerAdvice: "This is your day to lead—propose that new idea or start that project.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Red", crystal: "Ruby", time: "09:00")
            ),
            2: PersonalizedInsight(
                headline: "Find Your Balance",
                generalVibe: "Cooperation and patience are your superpowers today. Listen deeply to others and seek harmony.",
                loveAdvice: "Practice active listening and show empathy to strengthen your bonds.",
                careerAdvice: "Collaborate with others and find win-win solutions.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Orange", crystal: "Moonstone", time: "14:00")
            ),
            3: PersonalizedInsight(
                headline: "Express Your Joy",
                generalVibe: "Creativity and self-expression flow effortlessly. Share your unique gifts with the world.",
                loveAdvice: "Let playfulness and laughter bring you closer to loved ones.",
                careerAdvice: "Present your ideas with enthusiasm and watch them inspire others.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Yellow", crystal: "Citrine", time: "11:11")
            ),
            4: PersonalizedInsight(
                headline: "Build Your Foundation",
                generalVibe: "Focus on structure and discipline. Steady effort today leads to lasting results.",
                loveAdvice: "Show reliability and commitment in your relationships.",
                careerAdvice: "Organize your tasks and tackle them methodically.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Green", crystal: "Jade", time: "16:00")
            ),
            5: PersonalizedInsight(
                headline: "Embrace The Change",
                generalVibe: "Adventure and freedom call to you. Welcome new experiences and adapt with ease.",
                loveAdvice: "Try something new together to reignite the spark.",
                careerAdvice: "Be flexible and open to unexpected opportunities.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Blue", crystal: "Aquamarine", time: "17:30")
            ),
            6: PersonalizedInsight(
                headline: "Nurture with Love",
                generalVibe: "Service and compassion define today. Your caring nature makes a real difference.",
                loveAdvice: "Show appreciation and create moments of comfort for loved ones.",
                careerAdvice: "Support your team and prioritize harmony in the workplace.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Pink", crystal: "Rose Quartz", time: "18:00")
            ),
            7: PersonalizedInsight(
                headline: "Seek Inner Wisdom",
                generalVibe: "Introspection and spiritual connection are highlighted. Trust your inner voice.",
                loveAdvice: "Have a deep, meaningful conversation with your partner.",
                careerAdvice: "Step back and reflect before making important decisions.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Purple", crystal: "Amethyst", time: "21:00")
            ),
            8: PersonalizedInsight(
                headline: "Claim Your Power",
                generalVibe: "Abundance and achievement are within reach. Own your authority and take decisive action.",
                loveAdvice: "Set healthy boundaries while remaining generous with your love.",
                careerAdvice: "Negotiate confidently and pursue ambitious goals.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "Gold", crystal: "Tiger's Eye", time: "12:00")
            ),
            9: PersonalizedInsight(
                headline: "Release and Transform",
                generalVibe: "Completion and letting go bring peace. Trust that endings create space for new beginnings.",
                loveAdvice: "Forgive past hurts and choose compassion over resentment.",
                careerAdvice: "Finish outstanding projects and clear your slate for fresh starts.",
                luckyAttributes: PersonalizedInsight.LuckyAttributes(color: "White", crystal: "Clear Quartz", time: "19:00")
            )
        ]
        
        return fallbacks[number] ?? fallbacks[1]!
    }
}

