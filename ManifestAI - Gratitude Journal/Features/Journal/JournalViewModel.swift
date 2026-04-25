import SwiftUI
import SwiftData

@MainActor
class JournalViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var elevatedText: String?
    @Published var errorMessage: String?
    @Published var showResult = false
    
    // We don't hold the entries array here anymore, the View does via @Query
    
    func elevateEntry(text: String) async {
        guard !text.isEmpty else { return }
        
        isAnalyzing = true
        errorMessage = nil
        showResult = false
        
        do {
            let result = try await GeminiService.shared.generateElevation(from: text)
            elevatedText = result
            showResult = true
        } catch {
            print("Error elevating entry: \(error)")
            errorMessage = "The stars were clouded. Please try again."
        }
        
        isAnalyzing = false
    }
    
    func saveEntry(context: ModelContext, rawText: String) {
        let entry = JournalEntry(
            rawText: rawText,
            elevatedText: elevatedText
        )
        context.insert(entry)
        // Reset state handled by view dismissing or new entry start
    }
}

