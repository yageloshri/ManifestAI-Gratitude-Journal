import Foundation

// MARK: - Personalized Insight Model
struct PersonalizedInsight: Codable {
    let headline: String
    let generalVibe: String
    let loveAdvice: String
    let careerAdvice: String
    let luckyAttributes: LuckyAttributes
    
    struct LuckyAttributes: Codable {
        let color: String
        let crystal: String
        let time: String
    }
    
    enum CodingKeys: String, CodingKey {
        case headline
        case generalVibe = "general_vibe"
        case loveAdvice = "love_advice"
        case careerAdvice = "career_advice"
        case luckyAttributes = "lucky_attributes"
    }
}

// MARK: - Cached Insight (with metadata)
struct CachedInsight: Codable {
    let insight: PersonalizedInsight
    let date: Date
    let personalDayNumber: Int
}

