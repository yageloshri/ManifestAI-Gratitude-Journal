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

    /// Persisted grid-template selection (`GridLayoutTemplate.rawValue`) so
    /// reopening a saved board for editing restores the exact layout the
    /// user chose, not just whatever template the item count happens to
    /// imply. `-1` = legacy/unset — boards saved before this field existed
    /// fall back to inferring a template from item count, same behavior as
    /// before. New attribute with a default value: additive and
    /// lightweight-migration-safe, no SwiftData schema version bump needed.
    var gridTemplateRawValue: Int = -1

    init(id: UUID = UUID(), date: Date = Date(), tags: [String], previewImageData: Data? = nil, items: [VisionBoardItemEntity] = [], gridTemplateRawValue: Int = -1) {
        self.id = id
        self.date = date
        self.tags = tags
        self.previewImageData = previewImageData
        self.items = items
        self.gridTemplateRawValue = gridTemplateRawValue
    }
}

