import Foundation
import SwiftData

@Model
final class VisionBoardItemEntity {
    var id: UUID
    var xPosition: Double
    var yPosition: Double
    var scale: Double
    var rotation: Double
    var zIndex: Int
    var isSticker: Bool
    @Attribute(.externalStorage) var imageData: Data
    var cellSizeRawValue: Int // 0 = small, 1 = medium, 2 = large
    
    // Relationship back to the board (optional but good for traversing)
    var board: VisionBoardEntity?
    
    init(id: UUID = UUID(), xPosition: Double, yPosition: Double, scale: Double, rotation: Double, zIndex: Int, isSticker: Bool, imageData: Data, cellSizeRawValue: Int = 1) {
        self.id = id
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.scale = scale
        self.rotation = rotation
        self.zIndex = zIndex
        self.isSticker = isSticker
        self.imageData = imageData
        self.cellSizeRawValue = cellSizeRawValue
    }
}





