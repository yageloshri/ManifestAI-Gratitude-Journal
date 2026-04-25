import SwiftUI
import Combine
import SwiftData
import PhotosUI

enum VisionBoardStep {
    case energySelection
    case guidance
    case editor
}

// Cell size options for flexible layout
enum CellSize: Int, CaseIterable {
    case small = 0   // 33% width
    case medium = 1  // 50% width
    case large = 2   // 100% width
    
    var widthRatio: CGFloat {
        switch self {
        case .small: return 0.33
        case .medium: return 0.5
        case .large: return 1.0
        }
    }
    
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}

enum GridLayoutTemplate {
    case single // 1 image: full screen
    case splitHorizontal // 2 images: left/right 50/50
    case threeTop // 3 images: 2 top (50% each) + 1 bottom (100%)
    case grid2x2 // 4 images: 2x2 grid (all equal)
    case fiveAsymmetric // 5 images: 2 top + 3 bottom
    case grid3x2 // 6 images: 3x2 grid (all equal)
    case flexible // New: flexible masonry layout
    
    static func templateFor(count: Int) -> GridLayoutTemplate {
        switch count {
        case 1: return .single
        case 2: return .splitHorizontal
        case 3: return .threeTop
        case 4: return .grid2x2
        case 5: return .fiveAsymmetric
        default: return .grid3x2
        }
    }
}

struct GridCell {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
}

@MainActor
class VisionBoardViewModel: ObservableObject {
    // MARK: - Navigation State
    @Published var currentStep: VisionBoardStep = .energySelection
    
    // MARK: - Step A: Energy Selection
    @Published var selectedEnergies: Set<String> = []
    let availableEnergies = [
        ("Love", "heart.fill"),
        ("Wealth", "dollarsign.circle.fill"),
        ("Health", "leaf.fill"),
        ("Travel", "airplane"),
        ("Career", "briefcase.fill"),
        ("Peace", "figure.mind.and.body"),
        ("Family", "person.3.fill")
    ]
    
    // MARK: - Step B: Guidance
    var guidanceText: String {
        guard !selectedEnergies.isEmpty else {
            return "Select an energy to receive guidance."
        }
        
        if selectedEnergies.contains("Love") {
            return "Find a photo that represents the partnership you crave. Is it a wedding? A quiet moment at home? Holding hands?"
        } else if selectedEnergies.contains("Wealth") {
            return "Find an image of the lifestyle, home, or number you wish to see in your bank account."
        } else if selectedEnergies.contains("Career") {
            return "Visualize your dream workspace, an award you want to win, or the impact you want to make."
        } else if selectedEnergies.contains("Health") {
            return "What does vitality look like to you? Running on a beach? Fresh food? Strong body?"
        } else if selectedEnergies.contains("Travel") {
            return "Where is your soul calling you? Find a photo of that specific street, view, or feeling."
        } else if selectedEnergies.contains("Peace") {
            return "Find an image that makes your shoulders drop and your breath deepen."
        } else if selectedEnergies.contains("Family") {
            return "Who do you want around your table? Find a photo of connection and laughter."
        }
        
        return "Find images that speak to your soul for these energies."
    }
    
    // MARK: - Step C: Grid-Based Editor
    @Published var gridItems: [VisionBoardGridItemModel] = []
    @Published var showPhotoPicker = false
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var showSaveSuccess = false
    @Published var currentLayout: GridLayoutTemplate = .single
    @Published var showSeparators = true
    
    // Swap Overlay State
    @Published var showSwapOverlay = false
    @Published var swapSourceIndex: Int = 0
    
    // Resize Overlay State
    @Published var showResizeOverlay = false
    @Published var resizeTargetItemID: UUID?
    
    // Selected item for edit menu (outside simulator)
    @Published var selectedItemForMenu: VisionBoardGridItemModel?
    
    // Background Options
    @Published var backgroundColor: Color = Color(hex: "050510")
    
    private var existingBoardID: UUID?
    
    // Screen dimensions
    let screenWidth: CGFloat = 390
    let screenHeight: CGFloat = 844
    
    // MARK: - Actions
    
    func toggleEnergy(_ energy: String) {
        if selectedEnergies.contains(energy) {
            selectedEnergies.remove(energy)
        } else {
            selectedEnergies.insert(energy)
        }
    }
    
    func advanceToGuidance() {
        if !selectedEnergies.isEmpty {
            currentStep = .guidance
        }
    }
    
    func advanceToEditor() {
        currentStep = .editor
        if gridItems.isEmpty {
        showPhotoPicker = true
        }
    }
    
    func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            var loadedImages: [(UIImage, Data)] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loadedImages.append((image, data))
                }
            }
            
            if !loadedImages.isEmpty {
                applyGridLayout(images: loadedImages)
            }
        }
    }
    
    private func applyGridLayout(images: [(UIImage, Data)]) {
        let count = images.count
        currentLayout = GridLayoutTemplate.templateFor(count: count)
        let cells = calculateGridCells(for: currentLayout, count: count)
        
        gridItems = []
        for (index, (image, data)) in images.enumerated() {
            guard index < cells.count else { break }
            
            let cell = cells[index]
            let item = VisionBoardGridItemModel(
                image: image,
                imageData: data,
                gridPosition: index,
                cell: cell,
                offsetX: 0,
                offsetY: 0,
                zoom: 1.0,
                cellSize: .medium // Default to medium size
            )
            gridItems.append(item)
        }
    }
    
    private func calculateGridCells(for layout: GridLayoutTemplate, count: Int) -> [GridCell] {
        var cells: [GridCell] = []
        
        switch layout {
        case .single:
            // 1 תמונה: מסך מלא
            cells.append(GridCell(x: 0, y: 0, width: screenWidth, height: screenHeight))
            
        case .splitHorizontal:
            // 2 תמונות: שמאל וימין 50/50 (שווה בגודל)
            let halfWidth = screenWidth / 2
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: screenHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: screenHeight))
            
        case .threeTop:
            // 3 תמונות: 2 למעלה (כל אחת 50% רוחב) + 1 למטה (100% רוחב)
            let halfWidth = screenWidth / 2
            let halfHeight = screenHeight / 2
            
            // שתי תמונות למעלה
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: halfHeight))
            // תמונה אחת למטה
            cells.append(GridCell(x: 0, y: halfHeight, width: screenWidth, height: halfHeight))
            
        case .grid2x2:
            // 4 תמונות: 2x2 רשת (כולן שוות בגודל)
            let halfWidth = screenWidth / 2
            let halfHeight = screenHeight / 2
            
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: 0, y: halfHeight, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight))
            
        case .fiveAsymmetric:
            // 5 תמונות: 2 למעלה (50% כל אחת) + 3 למטה (33% כל אחת)
            let halfWidth = screenWidth / 2
            let thirdWidth = screenWidth / 3
            let halfHeight = screenHeight / 2
            
            // שתיים למעלה
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: halfHeight))
            
            // שלוש למטה
            cells.append(GridCell(x: 0, y: halfHeight, width: thirdWidth, height: halfHeight))
            cells.append(GridCell(x: thirdWidth, y: halfHeight, width: thirdWidth, height: halfHeight))
            cells.append(GridCell(x: thirdWidth * 2, y: halfHeight, width: thirdWidth, height: halfHeight))
            
        case .grid3x2:
            // 6 תמונות: 3 שורות x 2 עמודות (כולן שוות בגודל)
            let halfWidth = screenWidth / 2
            let thirdHeight = screenHeight / 3
            
            for row in 0..<3 {
                for col in 0..<2 {
                    cells.append(GridCell(
                        x: CGFloat(col) * halfWidth,
                        y: CGFloat(row) * thirdHeight,
                        width: halfWidth,
                        height: thirdHeight
                    ))
                }
            }
            
        case .flexible:
            // For flexible layout, return empty - will be calculated by calculateFlexibleLayout
            break
        }
        
        return cells
    }
    
    func swapItems(from fromPosition: Int, to toPosition: Int) {
        guard fromPosition != toPosition else { return }
        
        // Find array indices by gridPosition
        guard let fromIndex = gridItems.firstIndex(where: { $0.gridPosition == fromPosition }),
              let toIndex = gridItems.firstIndex(where: { $0.gridPosition == toPosition }) else {
            return
        }
        
        // Save the cells before swap
        let fromCell = gridItems[fromIndex].cell
        let toCell = gridItems[toIndex].cell
        
        // Swap the images and data in the array
        gridItems.swapAt(fromIndex, toIndex)
        
        // Update the cells after swap (positions stay the same)
        gridItems[fromIndex].cell = fromCell
        gridItems[fromIndex].gridPosition = fromPosition
        
        gridItems[toIndex].cell = toCell
        gridItems[toIndex].gridPosition = toPosition
    }
    
    func updateItemCrop(_ item: VisionBoardGridItemModel, offsetX: CGFloat, offsetY: CGFloat, zoom: CGFloat) {
        if let index = gridItems.firstIndex(where: { $0.id == item.id }) {
            gridItems[index].offsetX = offsetX
            gridItems[index].offsetY = offsetY
            gridItems[index].zoom = zoom
        }
    }
    
    func updateCellSize(_ item: VisionBoardGridItemModel, newSize: CellSize) {
        guard let index = gridItems.firstIndex(where: { $0.id == item.id }) else {
            print("❌ updateCellSize: Could not find item with ID \(item.id)")
            return
        }
        
        print("📏 updateCellSize:")
        print("   Item ID: \(item.id)")
        print("   Array index: \(index)")
        print("   gridPosition: \(gridItems[index].gridPosition)")
        print("   Old size: \(gridItems[index].cellSize.displayName)")
        print("   New size: \(newSize.displayName)")
        
        gridItems[index].cellSize = newSize
        
        // Recalculate flexible layout
        recalculateFlexibleLayout()
        
        print("   ✅ Layout recalculated, \(gridItems.count) items")
    }
    
    // MARK: - Flexible Masonry Layout Algorithm
    
    private func recalculateFlexibleLayout() {
        // Keep existing items but recalculate their cells
        let items = gridItems
        
        // Calculate new cells based on current cell sizes
        let cells = calculateFlexibleLayout(items: items)
        
        // Update each item's cell
        for (index, cell) in cells.enumerated() {
            if index < gridItems.count {
                gridItems[index].cell = cell
                gridItems[index].gridPosition = index
            }
        }
    }
    
    private func calculateFlexibleLayout(items: [VisionBoardGridItemModel]) -> [GridCell] {
        var cells: [GridCell] = []
        
        // Organize items into rows based on their widths
        struct Row {
            var items: [(index: Int, size: CellSize)]
            var totalWidth: CGFloat
        }
        
        var rows: [Row] = []
        var currentRow = Row(items: [], totalWidth: 0)
        
        for (index, item) in items.enumerated() {
            let itemWidth = item.cellSize.widthRatio
            
            // Check if item fits in current row (allowing small margin for rounding)
            if currentRow.totalWidth + itemWidth <= 1.01 {
                currentRow.items.append((index, item.cellSize))
                currentRow.totalWidth += itemWidth
            } else {
                // Start new row
                if !currentRow.items.isEmpty {
                    rows.append(currentRow)
                }
                currentRow = Row(items: [(index, item.cellSize)], totalWidth: itemWidth)
            }
        }
        
        // Add last row
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        
        // Calculate row heights to fill screen exactly
        let totalHeight = screenHeight
        let rowHeight = totalHeight / CGFloat(rows.count)
        
        // Build cells from rows
        var yOffset: CGFloat = 0
        var cellsByIndex: [Int: GridCell] = [:]
        
        for row in rows {
            var xOffset: CGFloat = 0
            
            // Normalize widths if row doesn't fill exactly
            let actualTotalWidth = row.items.reduce(0) { $0 + $1.size.widthRatio }
            let widthScale = actualTotalWidth < 0.99 ? 1.0 / actualTotalWidth : 1.0
            
            for (itemIndex, size) in row.items {
                let cellWidth = screenWidth * size.widthRatio * widthScale
                
                let cell = GridCell(
                    x: xOffset,
                    y: yOffset,
                    width: cellWidth,
                    height: rowHeight
                )
                
                cellsByIndex[itemIndex] = cell
                xOffset += cellWidth
            }
            
            yOffset += rowHeight
        }
        
        // Convert to array sorted by index
        for index in 0..<items.count {
            if let cell = cellsByIndex[index] {
                cells.append(cell)
            }
        }
        
        return cells
    }
    
    func deleteItem(_ item: VisionBoardGridItemModel) {
        if let index = gridItems.firstIndex(where: { $0.id == item.id }) {
            gridItems.remove(at: index)
            // Clear selection if we deleted the selected item
            if selectedItemForMenu?.id == item.id {
                selectedItemForMenu = nil
            }
            // Recalculate layout
            let images = gridItems.map { ($0.image, $0.imageData) }
            if !images.isEmpty {
                applyGridLayout(images: images)
            }
        }
    }
    
    func loadBoard(_ entity: VisionBoardEntity) {
        self.existingBoardID = entity.id
        self.selectedEnergies = Set(entity.tags)
        
        if let items = entity.items, !items.isEmpty {
            // Sort by zIndex to maintain order
            let sortedItems = items.sorted { $0.zIndex < $1.zIndex }
            
            // Determine layout based on count
            let count = sortedItems.count
            self.currentLayout = GridLayoutTemplate.templateFor(count: count)
            let cells = calculateGridCells(for: currentLayout, count: count)
            
            // Restore items with their saved positions and adjustments
            self.gridItems = sortedItems.enumerated().compactMap { index, itemEntity in
                guard let image = UIImage(data: itemEntity.imageData),
                      index < cells.count else { return nil }
                
                // Restore cell size from saved data
                let cellSize = CellSize(rawValue: itemEntity.cellSizeRawValue) ?? .medium
                
                return VisionBoardGridItemModel(
                    image: image,
                    imageData: itemEntity.imageData,
                    gridPosition: index,
                    cell: cells[index],
                    offsetX: itemEntity.xPosition, // Restore crop offset X
                    offsetY: itemEntity.yPosition, // Restore crop offset Y
                    zoom: itemEntity.scale, // Restore zoom level
                    cellSize: cellSize // Restore cell size
                )
            }
        }
        
        self.currentStep = .editor
    }
    
    func saveBoard(context: ModelContext, previewImage: UIImage?) {
        print("💾 Saving board...")
        print("   Preview image: \(previewImage != nil ? "✅ \(previewImage!.size)" : "❌ nil")")
        print("   Grid items: \(gridItems.count)")
        
        if let id = existingBoardID {
            print("   Updating existing board: \(id)")
            do {
                let descriptor = FetchDescriptor<VisionBoardEntity>(predicate: #Predicate { $0.id == id })
                if let existing = try context.fetch(descriptor).first {
                    existing.tags = Array(selectedEnergies)
                    
                    if let imageData = previewImage?.jpegData(compressionQuality: 0.7) {
                        existing.previewImageData = imageData
                        print("   Preview data size: \(imageData.count) bytes")
                    } else {
                        print("   ⚠️ No preview data to save")
                    }
                    
                    existing.date = Date()
                    
                    let newItemEntities = gridItems.map { item in
                        VisionBoardItemEntity(
                            xPosition: item.offsetX,
                            yPosition: item.offsetY,
                            scale: item.zoom,
                            rotation: 0,
                            zIndex: item.gridPosition,
                            isSticker: false,
                            imageData: item.imageData,
                            cellSizeRawValue: item.cellSize.rawValue
                        )
                    }
                    existing.items = newItemEntities
                    
                    try context.save()
                    print("✅ Board updated successfully")
                    showSaveSuccess = true
                    return
                }
            } catch {
                print("❌ Error updating board: \(error)")
            }
        }
        
        // Create New
        print("   Creating new board")
        let imageData = previewImage?.jpegData(compressionQuality: 0.7)
        if let data = imageData {
            print("   Preview data size: \(data.count) bytes")
        } else {
            print("   ⚠️ No preview data")
        }
        
        let boardEntity = VisionBoardEntity(
                tags: Array(selectedEnergies),
            previewImageData: imageData
        )
        
        let itemEntities = gridItems.map { item in
            VisionBoardItemEntity(
                xPosition: item.offsetX,
                yPosition: item.offsetY,
                scale: item.zoom,
                rotation: 0,
                zIndex: item.gridPosition,
                isSticker: false,
                imageData: item.imageData,
                cellSizeRawValue: item.cellSize.rawValue
            )
        }
        
        boardEntity.items = itemEntities
        context.insert(boardEntity)
        existingBoardID = boardEntity.id
        
        // CRITICAL: Save the context
        do {
            try context.save()
            print("✅ New board saved successfully with ID: \(boardEntity.id)")
            showSaveSuccess = true
        } catch {
            print("❌ Error saving new board: \(error)")
        }
    }
}

// New Grid-Based Model
struct VisionBoardGridItemModel: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage
    var imageData: Data
    var gridPosition: Int // Position in grid (0, 1, 2, 3...)
    var cell: GridCell // The fixed cell dimensions
    var offsetX: CGFloat // Pan offset for cropping
    var offsetY: CGFloat // Pan offset for cropping
    var zoom: CGFloat // Zoom level for the image
    var cellSize: CellSize // Size of the cell (small, medium, large)
    
    static func == (lhs: VisionBoardGridItemModel, rhs: VisionBoardGridItemModel) -> Bool {
        lhs.id == rhs.id
    }
}
