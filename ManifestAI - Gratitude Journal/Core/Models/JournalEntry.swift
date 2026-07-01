import Foundation
import SwiftData

@Model
class JournalEntry {
    var id: UUID
    var date: Date
    var rawText: String
    var elevatedText: String?
    /// Index into the journal color-swatch palette (0 = default/plain tint).
    /// Optional with nil-as-0 so existing stores migrate without a schema bump.
    var colorIndex: Int?

    var isElevated: Bool {
        return elevatedText != nil && !elevatedText!.isEmpty
    }

    var tintIndex: Int { colorIndex ?? 0 }

    init(id: UUID = UUID(), date: Date = Date(), rawText: String, elevatedText: String? = nil, colorIndex: Int? = nil) {
        self.id = id
        self.date = date
        self.rawText = rawText
        self.elevatedText = elevatedText
        self.colorIndex = colorIndex
    }
}

