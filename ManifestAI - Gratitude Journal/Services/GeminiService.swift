import Foundation

class GeminiService {
    static let shared = GeminiService()
    
    struct GeminiRequest: Codable {
        let contents: [Content]
        
        struct Content: Codable {
            let parts: [Part]
        }
        
        struct Part: Codable {
            let text: String
        }
    }
    
    struct GeminiResponse: Codable {
        let candidates: [Candidate]?
        
        struct Candidate: Codable {
            let content: Content
        }
        
        struct Content: Codable {
            let parts: [Part]
        }
        
        struct Part: Codable {
            let text: String
        }
    }
    
    func generateContent(prompt: String) async throws -> String {
        guard !Secrets.geminiKey.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(Secrets.geminiKey)") else {
            throw URLError(.badURL)
        }
        
        let requestBody = GeminiRequest(contents: [
            .init(parts: [.init(text: prompt)])
        ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let httpResponse = response as? HTTPURLResponse {
                print("Gemini API Error: \(httpResponse.statusCode)")
                if let errorText = String(data: data, encoding: .utf8) {
                    print("Gemini Error Details: \(errorText)")
                }
            }
            throw URLError(.badServerResponse)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        if let text = geminiResponse.candidates?.first?.content.parts.first?.text {
            return text
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    func generateElevation(from text: String) async throws -> String {
        let prompt = """
        You are a spiritual guide. Rewrite the user's journal entry into a **single**, concise, high-vibrational, and gratitude-focused paragraph.
        **STRICT RULES:**
        1. Do NOT provide options or variations.
        2. Do NOT include conversational filler like 'Here is a rewrite'.
        3. Output **ONLY** the final rewritten text.
        
        Entry: "\(text)"
        """
        return try await generateContent(prompt: prompt)
    }
}

