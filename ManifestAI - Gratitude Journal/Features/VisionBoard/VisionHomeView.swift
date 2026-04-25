import SwiftUI
import SwiftData

struct VisionHomeView: View {
    @Query(sort: \VisionBoardEntity.date, order: .reverse) private var boards: [VisionBoardEntity]
    @State private var showCreator = false
    @State private var selectedBoardToEdit: VisionBoardEntity?
    
    var body: some View {
        ZStack {
            // Background
            Theme.Colors.mysticalGradient
                .ignoresSafeArea()
            
            if boards.isEmpty {
                // Empty State
                VStack(spacing: Theme.Spacing.xxl) {
                    Spacer()
                    
                    Image(systemName: "photo.stack")
                        .font(Theme.Fonts.system(size: 64))
                        .foregroundStyle(Theme.Colors.primary.opacity(0.8))
                        .padding(.bottom, Theme.Spacing.sm)
                    
                    VStack(spacing: Theme.Spacing.md) {
                        Text("Your Vision Gallery")
                            .font(Theme.Fonts.display(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Create your first Vision Board to start manifesting your dreams.")
                            .font(Theme.Fonts.body(size: 16))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40.responsive)
                    }
                    
                    Button {
                        selectedBoardToEdit = nil
                        showCreator = true
                    } label: {
                        Text("Create New Board")
                            .font(Theme.Fonts.display(size: 16, weight: .bold))
                            .foregroundStyle(Theme.Colors.backgroundDark)
                            .frame(maxWidth: .infinity)
                            .responsiveHeight(56)
                            .background(Theme.Colors.primary)
                            .clipShape(Capsule())
                            .shadow(color: Theme.Colors.primary.opacity(0.4), radius: 20, x: 0, y: 0)
                    }
                    .padding(.horizontal, 40.responsive)
                    .padding(.top, Theme.Spacing.xxl)
                    
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    // Header with instructions
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Your Vision Boards")
                            .font(Theme.Fonts.display(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Swipe to view • \(boards.count) \(boards.count == 1 ? "board" : "boards")")
                            .font(Theme.Fonts.body(size: 14))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.top, 60.responsive)
                    .padding(.bottom, Theme.Spacing.xl)
                    
                    // Swipeable Gallery
                    TabView {
                        ForEach(boards) { board in
                            VisionBoardDetailView(board: board) {
                                selectedBoardToEdit = board
                                showCreator = true
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            selectedBoardToEdit = nil
                            showCreator = true
                        } label: {
                            Image(systemName: "plus")
                                .font(Theme.Fonts.system(size: 24, weight: .bold))
                                .foregroundStyle(Theme.Colors.backgroundDark)
                                .frame(width: 56.responsive, height: 56.responsive)
                                .background(Theme.Colors.primary)
                                .clipShape(Circle())
                                .shadow(color: Theme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                        .padding(Theme.Spacing.xxl)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCreator) {
            VisionCreatorView(boardToEdit: selectedBoardToEdit)
        }
    }
}

struct VisionBoardDetailView: View {
    let board: VisionBoardEntity
    let onEdit: () -> Void
    
    // Screen dimensions (same as editor)
    private let screenWidth: CGFloat = 390
    private let screenHeight: CGFloat = 844
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1a1a2e"),
                    Color(hex: "16213e")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // iPhone Frame with Reconstructed Board (not just preview image)
                iPhoneFrameView {
                    // Rebuild the grid with actual images just like in the editor
                    if let items = board.items, !items.isEmpty {
                        ZStack {
                            // Background
                            Color(hex: "050510")
                            
                            // Rebuild grid layout from saved items
                            ForEach(Array(items.sorted(by: { $0.zIndex < $1.zIndex }).enumerated()), id: \.element.id) { index, item in
                                if let uiImage = UIImage(data: item.imageData) {
                                    // Calculate cell from layout template
                                    let layout = GridLayoutTemplate.templateFor(count: items.count)
                                    let cells = calculateGridCells(for: layout, count: items.count)
                                    
                                    if index < cells.count {
                                        let cell = cells[index]
                                        
                                        // Display image with saved crop/zoom/position
                                        GeometryReader { geo in
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                                .scaleEffect(item.scale)
                                                .offset(x: item.xPosition, y: item.yPosition)
                                                .frame(width: cell.width, height: cell.height)
                                .clipped()
                                        }
                                        .frame(width: cell.width, height: cell.height)
                                        .position(x: cell.x + cell.width / 2, y: cell.y + cell.height / 2)
                                    }
                                }
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight)
                        .clipped()
                    } else if let imageData = board.previewImageData, let uiImage = UIImage(data: imageData) {
                        // Fallback to preview image if items not available
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight)
                            .clipped()
                    } else {
                        // No data available
                        Color.gray
                            .frame(width: screenWidth, height: screenHeight)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white.opacity(0.3))
                                    Text("No Preview")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            )
                    }
                }
                
                // Board Info
                VStack(spacing: 12) {
                    Text(board.date.formatted(date: .abbreviated, time: .omitted))
                        .font(Theme.Fonts.body(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    if !board.tags.isEmpty {
                        Text(board.tags.joined(separator: " • "))
                            .font(Theme.Fonts.display(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    // Edit Button
                    Button(action: onEdit) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                            Text("Edit Board")
                        }
                        .font(Theme.Fonts.body(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Grid Calculation (same as in ViewModel)
    
    private func calculateGridCells(for layout: GridLayoutTemplate, count: Int) -> [GridCell] {
        var cells: [GridCell] = []
        
        switch layout {
        case .single:
            cells.append(GridCell(x: 0, y: 0, width: screenWidth, height: screenHeight))
            
        case .splitHorizontal:
            let halfWidth = screenWidth / 2
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: screenHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: screenHeight))
            
        case .threeTop:
            let halfWidth = screenWidth / 2
            let halfHeight = screenHeight / 2
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: 0, y: halfHeight, width: screenWidth, height: halfHeight))
            
        case .grid2x2:
            let halfWidth = screenWidth / 2
            let halfHeight = screenHeight / 2
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: 0, y: halfHeight, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight))
            
        case .fiveAsymmetric:
            let halfWidth = screenWidth / 2
            let thirdWidth = screenWidth / 3
            let halfHeight = screenHeight / 2
            cells.append(GridCell(x: 0, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: halfWidth, y: 0, width: halfWidth, height: halfHeight))
            cells.append(GridCell(x: 0, y: halfHeight, width: thirdWidth, height: halfHeight))
            cells.append(GridCell(x: thirdWidth, y: halfHeight, width: thirdWidth, height: halfHeight))
            cells.append(GridCell(x: thirdWidth * 2, y: halfHeight, width: thirdWidth, height: halfHeight))
            
        case .grid3x2:
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
            // For flexible layout, return empty
            break
        }
        
        return cells
    }
}

#Preview {
    VisionHomeView()
        .modelContainer(for: VisionBoardEntity.self, inMemory: true)
}
