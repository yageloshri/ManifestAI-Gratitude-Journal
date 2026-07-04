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

/// A fixed grid template. Each case owns a set of cell rects in a 0...1
/// normalized unit square (`normalizedCells`) — the single source of truth
/// both the live on-screen canvas and the `UIGraphicsImageRenderer` export
/// multiply by the same canvas size. That shared source is what guarantees
/// the exported image can never drift out of sync with what's on screen
/// (previously cell math and separator-line math were duplicated in three
/// different places and could disagree).
///
/// `Int` raw values are persisted on `VisionBoardEntity.gridTemplateRawValue`
/// so reopening a saved board restores the exact template the user picked
/// (Task 2 persistence). Never reorder/reuse existing raw values.
enum GridLayoutTemplate: Int, CaseIterable {
    case single = 0 // 1 image: full screen
    case splitHorizontal = 1 // 2 images: left/right 50/50
    case threeTop = 2 // 3 images: 2 top (50% each) + 1 bottom (100%)
    case grid2x2 = 3 // 4 images: 2x2 grid (all equal)
    case fiveAsymmetric = 4 // 5 images: 2 top + 3 bottom
    case grid3x2 = 5 // 6 images: 2 columns x 3 rows (all equal)
    case flexible = 6 // legacy per-photo masonry sizing (long-press resize)
    case threeByThree = 7 // 9 cells: 3x3 grid
    case bigPlusTwoSmall = 8 // 3 cells: 1 big (left) + 2 small stacked (right)
    case bigTopThreeBottom = 9 // 4 cells: 1 big top + 3 small bottom
    case mosaic = 10 // 5 cells: mixed sizes

    /// Auto-picks a starting template from photo count — used only until the
    /// user explicitly chooses one from `GridTemplatePickerView` (Task 2),
    /// after which the chosen template sticks even as photos are added or
    /// removed. Kept for backward compatibility with existing saved boards
    /// and the original "just start adding photos" flow.
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

    /// The templates offered in the new grid-template picker (Task 2), in
    /// display order. Six distinct layouts as required: 2×2, 3×3, 2×3,
    /// "1 big + 2 small", "1 big top + 3 bottom", and a mixed-size mosaic.
    static let pickerTemplates: [GridLayoutTemplate] = [
        .grid2x2, .threeByThree, .grid3x2, .bigPlusTwoSmall, .bigTopThreeBottom, .mosaic
    ]

    var displayName: String {
        switch self {
        case .single: return "Single"
        case .splitHorizontal: return "Split"
        case .threeTop: return "3 Photos"
        case .grid2x2: return "2×2"
        case .fiveAsymmetric: return "5 Photos"
        case .grid3x2: return "2×3"
        case .flexible: return "Flexible"
        case .threeByThree: return "3×3"
        case .bigPlusTwoSmall: return "1 Big + 2"
        case .bigTopThreeBottom: return "1 Big + 3"
        case .mosaic: return "Mosaic"
        }
    }

    /// Fixed number of cells this template renders, independent of how many
    /// photos are currently loaded. Selecting a template with more cells
    /// than photos leaves the extra cells empty (rendered as placeholders,
    /// never black); fewer cells than photos overflows the extras into
    /// `VisionBoardViewModel.overflowItems`, kept in memory so switching
    /// back restores them (Task 2).
    var cellCount: Int {
        switch self {
        case .single: return 1
        case .splitHorizontal: return 2
        case .threeTop: return 3
        case .grid2x2: return 4
        case .fiveAsymmetric: return 5
        case .grid3x2: return 6
        case .flexible: return 0 // variable — handled by calculateFlexibleLayout
        case .threeByThree: return 9
        case .bigPlusTwoSmall: return 3
        case .bigTopThreeBottom: return 4
        case .mosaic: return 5
        }
    }

    /// Cell rects in a 0...1 normalized unit square, top-left origin.
    var normalizedCells: [CGRect] {
        switch self {
        case .single:
            return [CGRect(x: 0, y: 0, width: 1, height: 1)]

        case .splitHorizontal:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 1),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 1)
            ]

        case .threeTop:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0, y: 0.5, width: 1.0, height: 0.5)
            ]

        case .grid2x2:
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0, y: 0.5, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
            ]

        case .fiveAsymmetric:
            let third = 1.0 / 3.0
            return [
                CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0.5, y: 0, width: 0.5, height: 0.5),
                CGRect(x: 0, y: 0.5, width: third, height: 0.5),
                CGRect(x: third, y: 0.5, width: third, height: 0.5),
                CGRect(x: 2 * third, y: 0.5, width: third, height: 0.5)
            ]

        case .grid3x2:
            var cells: [CGRect] = []
            for row in 0..<3 {
                for col in 0..<2 {
                    cells.append(CGRect(x: CGFloat(col) * 0.5, y: CGFloat(row) / 3.0, width: 0.5, height: 1.0 / 3.0))
                }
            }
            return cells

        case .flexible:
            return []

        case .threeByThree:
            var cells: [CGRect] = []
            for row in 0..<3 {
                for col in 0..<3 {
                    cells.append(CGRect(x: CGFloat(col) / 3.0, y: CGFloat(row) / 3.0, width: 1.0 / 3.0, height: 1.0 / 3.0))
                }
            }
            return cells

        case .bigPlusTwoSmall:
            return [
                CGRect(x: 0, y: 0, width: 0.6, height: 1.0),
                CGRect(x: 0.6, y: 0, width: 0.4, height: 0.5),
                CGRect(x: 0.6, y: 0.5, width: 0.4, height: 0.5)
            ]

        case .bigTopThreeBottom:
            let third = 1.0 / 3.0
            return [
                CGRect(x: 0, y: 0, width: 1.0, height: 0.55),
                CGRect(x: 0, y: 0.55, width: third, height: 0.45),
                CGRect(x: third, y: 0.55, width: third, height: 0.45),
                CGRect(x: 2 * third, y: 0.55, width: third, height: 0.45)
            ]

        case .mosaic:
            return [
                CGRect(x: 0, y: 0, width: 0.6, height: 0.6),
                CGRect(x: 0.6, y: 0, width: 0.4, height: 0.3),
                CGRect(x: 0.6, y: 0.3, width: 0.4, height: 0.3),
                CGRect(x: 0, y: 0.6, width: 0.5, height: 0.4),
                CGRect(x: 0.5, y: 0.6, width: 0.5, height: 0.4)
            ]
        }
    }

    /// `normalizedCells` scaled up to a concrete canvas size. Used by the
    /// on-screen editor (390x844 reference canvas), the exporter (same
    /// canvas, 3x render scale), the swap overlay's mini preview, and the
    /// template-picker's schematic icons — always the same math.
    func cells(in size: CGSize) -> [GridCell] {
        normalizedCells.map {
            GridCell(x: $0.minX * size.width, y: $0.minY * size.height,
                     width: $0.width * size.width, height: $0.height * size.height)
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

    /// Photos that don't fit in the current template's `cellCount` (Task 2:
    /// switching to a smaller template overflows extras here instead of
    /// discarding them; switching to a bigger template pulls them back in).
    /// Intentionally in-memory only, not persisted — matches the spec of
    /// "preserve the rest in memory" for in-session template switching.
    @Published var overflowItems: [VisionBoardGridItemModel] = []

    /// Once the user explicitly taps a template in `GridTemplatePickerView`,
    /// that choice sticks — adding/removing photos no longer silently swaps
    /// the template out from under them (the old auto `templateFor(count:)`
    /// behavior is only used before any explicit choice has been made).
    private var didUserSelectTemplate = false

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
        // Auto-pick a template from photo count only until the user has
        // explicitly chosen one from the picker (Task 2) — after that the
        // chosen template sticks across "Change Photos".
        if !didUserSelectTemplate {
            currentLayout = GridLayoutTemplate.templateFor(count: images.count)
        }
        let cells = calculateGridCells(for: currentLayout)

        var newItems: [VisionBoardGridItemModel] = []
        for (index, (image, data)) in images.enumerated() where index < cells.count {
            newItems.append(VisionBoardGridItemModel(
                image: image,
                imageData: data,
                gridPosition: index,
                cell: cells[index],
                offsetX: 0,
                offsetY: 0,
                zoom: 1.0,
                cellSize: .medium // Default to medium size
            ))
        }
        gridItems = newItems

        // Extra photos beyond the template's cell count are kept in memory
        // (Task 2) so switching to a bigger template restores them.
        overflowItems = images.count > cells.count
            ? images[cells.count...].map { image, data in
                VisionBoardGridItemModel(image: image, imageData: data, gridPosition: -1,
                                          cell: GridCell(x: 0, y: 0, width: 0, height: 0),
                                          offsetX: 0, offsetY: 0, zoom: 1.0, cellSize: .medium)
              }
            : []
    }

    /// All cells (occupied or empty) for the current template, at the
    /// editor's reference canvas size. Single source of truth used by the
    /// on-screen canvas, the empty-cell placeholders, and the exporter.
    var templateCells: [GridCell] {
        calculateGridCells(for: currentLayout)
    }

    private func calculateGridCells(for layout: GridLayoutTemplate) -> [GridCell] {
        layout.cells(in: CGSize(width: screenWidth, height: screenHeight))
    }

    /// Called by `GridTemplatePickerView` when the user taps a template
    /// (Task 2). Re-flows existing photos into the new cells, preserving
    /// photo order; this is the only way `currentLayout` changes after the
    /// first auto-pick, and it locks in `didUserSelectTemplate` so future
    /// photo adds/removals no longer silently swap the template.
    func selectTemplate(_ template: GridLayoutTemplate) {
        didUserSelectTemplate = true
        guard template != currentLayout else { return }
        currentLayout = template
        reflowItemsForCurrentTemplate()
    }

    /// Re-assigns cells for `currentLayout`, pulling from both the visible
    /// items and anything previously overflowed, preserving relative photo
    /// order. Extra photos beyond the new template's `cellCount` go back
    /// into `overflowItems`; per-photo zoom/pan/cellSize state travels with
    /// each photo untouched.
    private func reflowItemsForCurrentTemplate() {
        let cells = templateCells
        var pool = gridItems.sorted { $0.gridPosition < $1.gridPosition }
        pool.append(contentsOf: overflowItems)
        overflowItems = []

        guard !pool.isEmpty else {
            gridItems = []
            return
        }

        let visibleCount = min(pool.count, cells.count)
        var newVisible: [VisionBoardGridItemModel] = []
        newVisible.reserveCapacity(visibleCount)
        for index in 0..<visibleCount {
            var item = pool[index]
            item.gridPosition = index
            item.cell = cells[index]
            newVisible.append(item)
        }
        gridItems = newVisible

        if pool.count > visibleCount {
            overflowItems = Array(pool[visibleCount...])
        }
    }

    /// Fills a specific empty cell (tapped `EmptyGridCellView`) with a newly
    /// picked photo, without disturbing any other cell.
    func insertPhoto(at gridPosition: Int, image: UIImage, data: Data) {
        let cells = templateCells
        guard gridPosition >= 0, gridPosition < cells.count else { return }
        gridItems.removeAll { $0.gridPosition == gridPosition }
        gridItems.append(VisionBoardGridItemModel(
            image: image,
            imageData: data,
            gridPosition: gridPosition,
            cell: cells[gridPosition],
            offsetX: 0,
            offsetY: 0,
            zoom: 1.0,
            cellSize: .medium
        ))
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
            dlog("❌ updateCellSize: Could not find item with ID \(item.id)")
            return
        }
        
        dlog("📏 updateCellSize:")
        dlog("   Item ID: \(item.id)")
        dlog("   Array index: \(index)")
        dlog("   gridPosition: \(gridItems[index].gridPosition)")
        dlog("   Old size: \(gridItems[index].cellSize.displayName)")
        dlog("   New size: \(newSize.displayName)")
        
        gridItems[index].cellSize = newSize
        
        // Recalculate flexible layout
        recalculateFlexibleLayout()
        
        dlog("   ✅ Layout recalculated, \(gridItems.count) items")
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
        guard let index = gridItems.firstIndex(where: { $0.id == item.id }) else { return }
        let freedPosition = gridItems[index].gridPosition
        gridItems.remove(at: index)
        // Clear selection if we deleted the selected item
        if selectedItemForMenu?.id == item.id {
            selectedItemForMenu = nil
        }

        if didUserSelectTemplate {
            // The user explicitly chose this template (Task 2) — keep it
            // rather than auto-shrinking. Pull the next overflowed photo (if
            // any) into the cell that just opened up; otherwise leave it
            // empty (renders as a placeholder, never black).
            if !overflowItems.isEmpty {
                var promoted = overflowItems.removeFirst()
                let cells = templateCells
                if freedPosition >= 0, freedPosition < cells.count {
                    promoted.gridPosition = freedPosition
                    promoted.cell = cells[freedPosition]
                    gridItems.append(promoted)
                }
            }
        } else {
            // No explicit template chosen yet — keep the original "auto-fit
            // a smaller template to the remaining photo count" behavior.
            relayoutPreservingItemState()
        }
    }

    /// Reassigns grid cells for the current item count without recreating the
    /// items, so per-photo state (zoom, pan offsets, cell size) survives
    /// layout changes like deleting a photo.
    private func relayoutPreservingItemState() {
        guard !gridItems.isEmpty else { return }

        currentLayout = GridLayoutTemplate.templateFor(count: gridItems.count)
        let cells = calculateGridCells(for: currentLayout)

        for index in gridItems.indices {
            guard index < cells.count else { break }
            let cell = cells[index]
            gridItems[index].cell = cell
            gridItems[index].gridPosition = index

            // Clamp pan offsets so the image still covers its new cell
            let maxOffsetX = max(0, cell.width * (gridItems[index].zoom - 1) / 2)
            let maxOffsetY = max(0, cell.height * (gridItems[index].zoom - 1) / 2)
            gridItems[index].offsetX = min(max(gridItems[index].offsetX, -maxOffsetX), maxOffsetX)
            gridItems[index].offsetY = min(max(gridItems[index].offsetY, -maxOffsetY), maxOffsetY)
        }
    }
    
    /// Reopens a saved board for editing (Task 1): restores every photo with
    /// its saved crop/zoom, and restores the exact grid template the user
    /// picked (Task 2 persistence) rather than re-inferring one from item
    /// count, so re-saving updates the same board losslessly.
    func loadBoard(_ entity: VisionBoardEntity) {
        self.existingBoardID = entity.id
        self.selectedEnergies = Set(entity.tags)
        self.overflowItems = []

        if let items = entity.items, !items.isEmpty {
            // Sort by zIndex to maintain order
            let sortedItems = items.sorted { $0.zIndex < $1.zIndex }
            let count = sortedItems.count

            if let savedTemplate = GridLayoutTemplate(rawValue: entity.gridTemplateRawValue) {
                // Board was saved with an explicit template (Task 2) — restore
                // it exactly and keep it locked in going forward.
                self.currentLayout = savedTemplate
                self.didUserSelectTemplate = true
            } else {
                // Legacy board saved before `gridTemplateRawValue` existed —
                // fall back to the original count-based inference.
                self.currentLayout = GridLayoutTemplate.templateFor(count: count)
                self.didUserSelectTemplate = false
            }
            let cells = calculateGridCells(for: currentLayout)

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

            // Shouldn't normally happen (we only ever persist visible items),
            // but if a board somehow has more saved items than the restored
            // template's cell count, keep the extras in memory rather than
            // silently dropping them — consistent with the overflow behavior
            // everywhere else (Task 2).
            if sortedItems.count > cells.count {
                self.overflowItems = sortedItems[cells.count...].compactMap { itemEntity in
                    guard let image = UIImage(data: itemEntity.imageData) else { return nil }
                    let cellSize = CellSize(rawValue: itemEntity.cellSizeRawValue) ?? .medium
                    return VisionBoardGridItemModel(
                        image: image, imageData: itemEntity.imageData, gridPosition: -1,
                        cell: GridCell(x: 0, y: 0, width: 0, height: 0),
                        offsetX: itemEntity.xPosition, offsetY: itemEntity.yPosition,
                        zoom: itemEntity.scale, cellSize: cellSize
                    )
                }
            }
        } else {
            self.gridItems = []
        }

        self.currentStep = .editor
    }
    
    /// Saves the board to SwiftData. Returns true if the in-app save
    /// succeeded. Pass `showSuccessAlert: false` when the caller wants to
    /// present its own alert (e.g. after also writing to the photo library).
    @discardableResult
    func saveBoard(context: ModelContext, previewImage: UIImage?, showSuccessAlert: Bool = true) -> Bool {
        dlog("💾 Saving board...")
        dlog("   Preview image: \(previewImage != nil ? "✅ \(previewImage!.size)" : "❌ nil")")
        dlog("   Grid items: \(gridItems.count)")
        
        if let id = existingBoardID {
            dlog("   Updating existing board: \(id)")
            do {
                let descriptor = FetchDescriptor<VisionBoardEntity>(predicate: #Predicate { $0.id == id })
                if let existing = try context.fetch(descriptor).first {
                    existing.tags = Array(selectedEnergies)
                    existing.gridTemplateRawValue = currentLayout.rawValue

                    if let imageData = previewImage?.jpegData(compressionQuality: 0.7) {
                        existing.previewImageData = imageData
                        dlog("   Preview data size: \(imageData.count) bytes")
                    } else {
                        dlog("   ⚠️ No preview data to save")
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
                    dlog("✅ Board updated successfully")
                    if showSuccessAlert {
                        showSaveSuccess = true
                    }
                    return true
                }
            } catch {
                dlog("❌ Error updating board: \(error)")
            }
        }
        
        // Create New
        dlog("   Creating new board")
        let imageData = previewImage?.jpegData(compressionQuality: 0.7)
        if let data = imageData {
            dlog("   Preview data size: \(data.count) bytes")
        } else {
            dlog("   ⚠️ No preview data")
        }
        
        let boardEntity = VisionBoardEntity(
                tags: Array(selectedEnergies),
            previewImageData: imageData,
            gridTemplateRawValue: currentLayout.rawValue
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
            dlog("✅ New board saved successfully with ID: \(boardEntity.id)")
            if showSuccessAlert {
                showSaveSuccess = true
            }
            return true
        } catch {
            dlog("❌ Error saving new board: \(error)")
            return false
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
