import SwiftUI
import PhotosUI
import SwiftData
import SuperwallKit

struct VisionBoardEditorView: View {
    @ObservedObject var viewModel: VisionBoardViewModel
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
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
            
            VStack(spacing: 16) {
                // === TOP CONTROLS (Above iPhone Frame) ===
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white.opacity(0.9))
                            .font(.system(size: 20))
                            .padding(14)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain) // Prevent any gesture conflicts
                    
                    Spacer()
                    
                    Button(action: {
                        // Check if user can save
                        if !subscriptionManager.canSaveVisionBoard {
                            Task {
                                await Superwall.shared.register(placement: "campaign_trigger")
                            }
                            return
                        }
                        
                        // Ensure we have items to save
                        guard !viewModel.gridItems.isEmpty else {
                            print("❌ Cannot save: No images in board")
                            return
                        }
                        
                        print("🎨 Starting snapshot capture with \(viewModel.gridItems.count) items")
                        
                        // Create preview image using UIGraphicsImageRenderer
                        let size = CGSize(width: 390, height: 844)
                        let renderer = UIGraphicsImageRenderer(size: size)
                        
                        let image = renderer.image { context in
                            let ctx = context.cgContext
                            
                            // Draw background
                            ctx.setFillColor(UIColor(viewModel.backgroundColor).cgColor)
                            ctx.fill(CGRect(origin: .zero, size: size))
                            
                            // Draw each image
                            for item in viewModel.gridItems {
                                ctx.saveGState()
                                
                                // Clip to cell bounds
                                let cellRect = CGRect(x: item.cell.x, y: item.cell.y, width: item.cell.width, height: item.cell.height)
                                ctx.addRect(cellRect)
                                ctx.clip()
                                
                                // Calculate image rect with zoom and offset
                                let imageWidth = item.cell.width * item.zoom
                                let imageHeight = item.cell.height * item.zoom
                                let imageX = item.cell.x + (item.cell.width - imageWidth) / 2 + item.offsetX
                                let imageY = item.cell.y + (item.cell.height - imageHeight) / 2 + item.offsetY
                                
                                let imageRect = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
                                item.image.draw(in: imageRect)
                                
                                ctx.restoreGState()
                            }
                            
                            // Draw separators if needed
                            if viewModel.showSeparators && viewModel.gridItems.count > 1 {
                                ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
                                ctx.setLineWidth(2)
                                
                                // Draw separators based on layout
                                switch viewModel.currentLayout {
                                case .splitHorizontal:
                                    ctx.move(to: CGPoint(x: 195, y: 0))
                                    ctx.addLine(to: CGPoint(x: 195, y: 844))
                                case .threeTop:
                                    ctx.move(to: CGPoint(x: 195, y: 0))
                                    ctx.addLine(to: CGPoint(x: 195, y: 422))
                                    ctx.move(to: CGPoint(x: 0, y: 422))
                                    ctx.addLine(to: CGPoint(x: 390, y: 422))
                                case .grid2x2:
                                    ctx.move(to: CGPoint(x: 195, y: 0))
                                    ctx.addLine(to: CGPoint(x: 195, y: 844))
                                    ctx.move(to: CGPoint(x: 0, y: 422))
                                    ctx.addLine(to: CGPoint(x: 390, y: 422))
                                case .fiveAsymmetric:
                                    ctx.move(to: CGPoint(x: 195, y: 0))
                                    ctx.addLine(to: CGPoint(x: 195, y: 422))
                                    ctx.move(to: CGPoint(x: 0, y: 422))
                                    ctx.addLine(to: CGPoint(x: 390, y: 422))
                                    ctx.move(to: CGPoint(x: 130, y: 422))
                                    ctx.addLine(to: CGPoint(x: 130, y: 844))
                                    ctx.move(to: CGPoint(x: 260, y: 422))
                                    ctx.addLine(to: CGPoint(x: 260, y: 844))
                                case .grid3x2:
                                    ctx.move(to: CGPoint(x: 195, y: 0))
                                    ctx.addLine(to: CGPoint(x: 195, y: 844))
                                    ctx.move(to: CGPoint(x: 0, y: 281))
                                    ctx.addLine(to: CGPoint(x: 390, y: 281))
                                    ctx.move(to: CGPoint(x: 0, y: 563))
                                    ctx.addLine(to: CGPoint(x: 390, y: 563))
                                default:
                                    break
                                }
                                ctx.strokePath()
                            }
                        }
                        
                        print("✅ Successfully rendered image: \(image.size)")
                        viewModel.saveBoard(context: modelContext, previewImage: image)
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Save")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: "FFD700"))
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .zIndex(1000) // Make sure it's above everything
                
                // === IPHONE FRAME (Middle - Smaller) ===
                iPhoneFrameView {
                    // Main container - EXACT size, no flexible space
                    ZStack {
                        // Layer 1: Background + Grid (Edge-to-Edge)
                        ZStack {
                            viewModel.backgroundColor
                            
                            // Container for images - STRICTLY constrained
                            ZStack(alignment: .topLeading) {
                                ForEach(viewModel.gridItems) { item in
                                    GridImageCellView(item: item, viewModel: viewModel)
                                }
                                
                                if viewModel.showSeparators && viewModel.gridItems.count > 1 {
                                    GridSeparatorsView(layout: viewModel.currentLayout)
                                        .allowsHitTesting(false)
                                }
                            }
                            .frame(width: 390, height: 844, alignment: .topLeading)
                        }
                        .frame(width: 390, height: 844)
                        .clipped() // Strict clipping
                        
                        // Layer 2: Lock Screen Overlay
                        VisionBoardLockScreenOverlay()
                            .allowsHitTesting(false)
                        
                        // Layer 3: Empty State
                        if viewModel.gridItems.isEmpty {
                            VStack(spacing: 16) {
                                Spacer()
                                
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white.opacity(0.3))
                                
                                Text("Add photos")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Text("Tap to swap\nPinch to zoom")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                            }
                            .frame(width: 390, height: 844)
                            .allowsHitTesting(false)
                        }
                    }
                    .frame(width: 390, height: 844)
                }
                
                // === EDIT MENU (Below iPhone Frame) - Always visible ===
                ZStack {
                    if let selectedItem = viewModel.selectedItemForMenu {
                        HStack(spacing: 12) {
                            // Swap Mode Button
                            Button(action: {
                                let impactMedium = UIImpactFeedbackGenerator(style: .medium)
                                impactMedium.impactOccurred()
                                withAnimation {
                                    viewModel.selectedItemForMenu = nil
                                    viewModel.showSwapOverlay = true
                                    viewModel.swapSourceIndex = selectedItem.gridPosition
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                                        .font(.system(size: 22))
                                    Text("Swap")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 54)
                                .background(Color.blue.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            // Reset Crop/Zoom
                            Button(action: {
                                let impactLight = UIImpactFeedbackGenerator(style: .light)
                                impactLight.impactOccurred()
                                withAnimation {
                                    viewModel.updateItemCrop(selectedItem, offsetX: 0, offsetY: 0, zoom: 1.0)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 22))
                                    Text("Reset")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 54)
                                .background(Color.black.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            // Delete
                            Button(action: {
                                let impactMedium = UIImpactFeedbackGenerator(style: .medium)
                                impactMedium.impactOccurred()
                                withAnimation {
                                    viewModel.deleteItem(selectedItem)
                                    viewModel.selectedItemForMenu = nil
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 22))
                                    Text("Delete")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 54)
                                .background(Color.red.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.3), radius: 12)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // Placeholder to maintain spacing
                        Color.clear
                            .frame(height: 74)
                    }
                }
                .frame(height: 74) // Fixed height for menu area
                
                // === BOTTOM CONTROLS (Below iPhone Frame) ===
                PhotosPicker(selection: $viewModel.selectedPhotos,
                             maxSelectionCount: 6,
                             matching: .images,
                             photoLibrary: .shared()) {
                    HStack(spacing: 10) {
                        Image(systemName: viewModel.gridItems.isEmpty ? "photo.on.rectangle.angled" : "arrow.triangle.2.circlepath")
                            .font(.system(size: 20))
                        
                        Text(viewModel.gridItems.isEmpty ? "Add Photos" : "Change Photos")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .onChange(of: viewModel.selectedPhotos) { newItems in
                    viewModel.loadPhotos(from: newItems)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
            }
            
            // === SWAP OVERLAY ===
            if viewModel.showSwapOverlay {
                GridSwapOverlay(
                    currentLayout: viewModel.currentLayout,
                    items: viewModel.gridItems,
                    sourceIndex: viewModel.swapSourceIndex,
                    onSelectTarget: { targetIndex in
                        withAnimation {
                            viewModel.swapItems(from: viewModel.swapSourceIndex, to: targetIndex)
                            viewModel.showSwapOverlay = false
                            viewModel.selectedItemForMenu = nil
                        }
                    },
                    onCancel: {
                        withAnimation {
                            viewModel.showSwapOverlay = false
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
            
            // === RESIZE OVERLAY ===
            if viewModel.showResizeOverlay,
               let targetItemID = viewModel.resizeTargetItemID,
               let targetItem = viewModel.gridItems.first(where: { $0.id == targetItemID }) {
                ResizeCellOverlay(
                    currentSize: targetItem.cellSize,
                    itemImage: targetItem.image,
                    onSelectSize: { newSize in
                        withAnimation {
                            viewModel.updateCellSize(targetItem, newSize: newSize)
                            viewModel.showResizeOverlay = false
                            viewModel.resizeTargetItemID = nil
                        }
                    },
                    onCancel: {
                        withAnimation {
                            viewModel.showResizeOverlay = false
                            viewModel.resizeTargetItemID = nil
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(1001)
            }
        }
        .alert("Vision Board Saved!", isPresented: $viewModel.showSaveSuccess) {
            Button("Done", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your vision board has been saved to your gallery and is ready to be set as your lock screen wallpaper!")
        }
    }
}

// Extension for selective corner radius
extension RoundedRectangle {
    init(cornerRadius: CGFloat, corners: UIRectCorner) {
        self.init(cornerRadius: cornerRadius, style: .continuous)
    }
}

// Grid Separators View
struct GridSeparatorsView: View {
    let layout: GridLayoutTemplate
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            switch layout {
            case .single:
                EmptyView()
                
            case .splitHorizontal:
                // 2 תמונות: קו אנכי במרכז
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 844)
                    .offset(x: 195, y: 0)
                
            case .threeTop:
                // 3 תמונות: קו אנכי באמצע למעלה + קו אופקי באמצע
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 422)
                    .offset(x: 195, y: 0)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 390, height: 2)
                    .offset(x: 0, y: 422)
                
            case .grid2x2:
                // 4 תמונות: קו אנכי במרכז + קו אופקי במרכז
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 844)
                    .offset(x: 195, y: 0)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 390, height: 2)
                    .offset(x: 0, y: 422)
                
            case .fiveAsymmetric:
                // 5 תמונות: קו אנכי למעלה + קו אופקי + 2 קווים אנכיים למטה
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 422)
                    .offset(x: 195, y: 0)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 390, height: 2)
                    .offset(x: 0, y: 422)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 422)
                    .offset(x: 130, y: 422)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 422)
                    .offset(x: 260, y: 422)
                
            case .grid3x2:
                // 6 תמונות: קו אנכי במרכז + 2 קווים אופקיים
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 844)
                    .offset(x: 195, y: 0)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 390, height: 2)
                    .offset(x: 0, y: 281)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 390, height: 2)
                    .offset(x: 0, y: 563)
                
            case .flexible:
                // Flexible layout - no fixed separators
                EmptyView()
            }
        }
        .frame(width: 390, height: 844)
        .allowsHitTesting(false)
    }
}

// Snapshot view for grid system
struct GridCanvasSnapshotView: View {
    let items: [VisionBoardGridItemModel]
    let backgroundColor: Color
    let showSeparators: Bool
    let layout: GridLayoutTemplate
    let frameSize: CGSize
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            backgroundColor
                .frame(width: frameSize.width, height: frameSize.height)
            
            // Render each grid item using the same method as the editor
            ForEach(items) { item in
                Color.clear
                    .frame(width: item.cell.width, height: item.cell.height)
                    .overlay(
                        ZStack {
                            // Background
                            Rectangle()
                                .fill(Color.black)
                            
                            // The image
                            Image(uiImage: item.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: item.cell.width * item.zoom,
                                    height: item.cell.height * item.zoom
                                )
                                .offset(x: item.offsetX, y: item.offsetY)
                        }
                    )
                    .clipped()
                    .offset(x: item.cell.x, y: item.cell.y)
            }
            
            // Separators
            if showSeparators && items.count > 1 {
                GridSeparatorsView(layout: layout)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }
}
