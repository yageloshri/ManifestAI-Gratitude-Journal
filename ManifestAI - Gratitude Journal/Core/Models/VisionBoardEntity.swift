import Foundation
import SwiftData
import SwiftUI

@Model
final class VisionBoardEntity {
    var id: UUID
    var date: Date
    var tags: [String]
    @Attribute(.externalStorage) var previewImageData: Data? // Flattened preview
    @Relationship(deleteRule: .cascade) var items: [VisionBoardItemEntity]? = []
    
    init(id: UUID = UUID(), date: Date = Date(), tags: [String], previewImageData: Data? = nil, items: [VisionBoardItemEntity] = []) {
        self.id = id
        self.date = date
        self.tags = tags
        self.previewImageData = previewImageData
        self.items = items
    }
}

