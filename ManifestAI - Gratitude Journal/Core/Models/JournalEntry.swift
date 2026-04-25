import Foundation
import SwiftData

@Model
class JournalEntry {
    var id: UUID
    var date: Date
    var rawText: String
    var elevatedText: String?
    
    var isElevated: Bool {
        return elevatedText != nil && !elevatedText!.isEmpty
    }
    
    init(id: UUID = UUID(), date: Date = Date(), rawText: String, elevatedText: String? = nil) {
        self.id = id
        self.date = date
        self.rawText = rawText
        self.elevatedText = elevatedText
    }
}

