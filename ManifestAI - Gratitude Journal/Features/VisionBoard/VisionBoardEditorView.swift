import SwiftUI
import PhotosUI
import SwiftData

struct VisionBoardEditorView: View {
    @ObservedObject var viewModel: VisionBoardViewModel
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    // Photo library save result (the in-app board save is tracked separately)
    @State private var showPhotoSaveError = false
    @State private var boardSavedDespitePhotoError = false

    // Single-photo picker scoped to a tapped empty cell (Task 2/3: fixed
    // templates can have more cells than photos; tapping an empty one fills
    // just that slot instead of forcing a full "Change Photos" re-pick).
    @State private var showSlotPicker = false
    @State private var slotPickerIndex: Int?
    @State private var slotPickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            // App design language: cosmic background + purple glow.
            // Glow as overlay+clipped so its oversized blur frame doesn't
            // inflate the ZStack union (that shifts centered siblings).
            DesignTokens.Colors.background
                .overlay(EllipseGlowBackground(sx: 1, sy: 1).allowsHitTesting(false))
                .clipped()
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
                            PaywallManager.shared.present()
                            return
                        }
                        
                        // Ensure we have items to save
                        guard !viewModel.gridItems.isEmpty else {
                            dlog("❌ Cannot save: No images in board")
                            return
                        }
                        
                        dlog("🎨 Starting snapshot capture with \(viewModel.gridItems.count) items")
                        
                        // Render at the SAME reference canvas the on-screen grid is
                        // laid out in (390x844 — every cell in viewModel.templateCells
                        // is already computed in this space), explicitly opaque and at
                        // 3x scale. This is what guarantees screen/export parity
                        // (Task 3): there's no separate "device size" to reconcile —
                        // preview and export share one coordinate space — and an
                        // explicit opaque format + full background fill means there's
                        // no code path that can leave a transparent (black) gap.
                        let size = CGSize(width: viewModel.screenWidth, height: viewModel.screenHeight)
                        let format = UIGraphicsImageRendererFormat()
                        format.opaque = true
                        format.scale = 3
                        let renderer = UIGraphicsImageRenderer(size: size, format: format)

                        let image = renderer.image { context in
                            let ctx = context.cgContext

                            // Draw background first — same fill the on-screen canvas
                            // shows — so every pixel is covered before anything else
                            // is drawn; nothing can show through as black.
                            ctx.setFillColor(UIColor(viewModel.backgroundColor).cgColor)
                            ctx.fill(CGRect(origin: .zero, size: size))

                            // Walk every template cell (not just occupied ones) — the
                            // same array `viewModel.templateCells` the on-screen canvas
                            // iterates — so an empty cell renders the identical
                            // placeholder card fill on screen and in the export,
                            // instead of leaving the background showing through
                            // unexpectedly or (with a non-opaque format) black.
                            let cells = viewModel.templateCells
                            for (index, cell) in cells.enumerated() {
                                let cellRect = CGRect(x: cell.x, y: cell.y, width: cell.width, height: cell.height)
                                ctx.saveGState()
                                ctx.addRect(cellRect)
                                ctx.clip()

                                if let item = viewModel.gridItems.first(where: { $0.gridPosition == index }) {
                                    // Calculate image frame with zoom and offset (matches
                                    // GridImageCellView's Image(...).frame(width:height:) on screen).
                                    // zoom == 1.0 here already covers the whole cell (no
                                    // letterboxing) because `imageWidth`/`imageHeight` equal
                                    // the cell's own size and the draw below is aspect-FILL,
                                    // not stretch-to-fit — true for every template, including
                                    // the new non-square/mosaic cells.
                                    let imageWidth = cell.width * item.zoom
                                    let imageHeight = cell.height * item.zoom
                                    let imageX = cell.x + (cell.width - imageWidth) / 2 + item.offsetX
                                    let imageY = cell.y + (cell.height - imageHeight) / 2 + item.offsetY
                                    let imageRect = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)

                                    // Clip to that frame too, then draw the source image using
                                    // aspect-FILL (preserve aspect ratio, crop overflow, centered)
                                    // instead of UIImage.draw(in:)'s default stretch-to-fit.
                                    ctx.saveGState()
                                    ctx.addRect(imageRect)
                                    ctx.clip()

                                    let sourceSize = item.image.size
                                    if sourceSize.width > 0, sourceSize.height > 0 {
                                        let fillScale = max(imageRect.width / sourceSize.width, imageRect.height / sourceSize.height)
                                        let scaledWidth = sourceSize.width * fillScale
                                        let scaledHeight = sourceSize.height * fillScale
                                        let drawRect = CGRect(
                                            x: imageRect.midX - scaledWidth / 2,
                                            y: imageRect.midY - scaledHeight / 2,
                                            width: scaledWidth,
                                            height: scaledHeight
                                        )
                                        item.image.draw(in: drawRect)
                                    } else {
                                        item.image.draw(in: imageRect)
                                    }
                                    ctx.restoreGState()
                                } else {
                                    // Empty cell — draw the same card placeholder
                                    // `EmptyGridCellView` shows on screen. Never skip
                                    // this: an un-drawn cell is exactly what produced
                                    // the reported black regions.
                                    UIColor(DesignTokens.Colors.surfaceDark).withAlphaComponent(0.6).setFill()
                                    ctx.fill(cellRect)
                                    if let icon = UIImage(systemName: "photo")?
                                        .withTintColor(UIColor.white.withAlphaComponent(0.3), renderingMode: .alwaysOriginal) {
                                        let iconSize = min(cellRect.width, cellRect.height) * 0.22
                                        let iconRect = CGRect(
                                            x: cellRect.midX - iconSize / 2,
                                            y: cellRect.midY - iconSize / 2,
                                            width: iconSize,
                                            height: iconSize
                                        )
                                        icon.draw(in: iconRect)
                                    }
                                }

                                ctx.restoreGState()
                            }

                            // Draw separators — a border stroke per cell, the exact
                            // same approach `GridSeparatorsView` uses on screen, driven
                            // by the same `cells` array. Because both share one source
                            // of truth, the lines can never drift out of sync with the
                            // actual cell geometry (previously a hand-maintained
                            // per-template switch here could — and did — disagree with
                            // the on-screen version).
                            if viewModel.showSeparators && cells.count > 1 {
                                ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.25).cgColor)
                                ctx.setLineWidth(1)
                                for cell in cells {
                                    ctx.stroke(CGRect(x: cell.x, y: cell.y, width: cell.width, height: cell.height))
                                }
                            }
                        }

                        dlog("✅ Successfully rendered image: \(image.size)")
                        // Save in-app first, but defer the success alert until we
                        // know whether the photo library write also succeeded.
                        let boardSaved = viewModel.saveBoard(context: modelContext, previewImage: image, showSuccessAlert: false)
                        PhotoAlbumSaver(onComplete: { error in
                            if let error {
                                dlog("❌ Failed to save wallpaper to Photos: \(error)")
                                boardSavedDespitePhotoError = boardSaved
                                showPhotoSaveError = true
                            } else if boardSaved {
                                viewModel.showSaveSuccess = true
                                // Exporting a finished vision board is a proud
                                // moment — eligible to prompt for a rating.
                                AnalyticsManager.log("vision_board_saved")
                                ReviewRequestManager.registerWowMoment("vision_board_saved")
                            }
                        }).save(image)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Save")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(DesignTokens.Gradients.golden)
                        .clipShape(Capsule())
                        .shadow(color: DesignTokens.Colors.secondary.opacity(0.4), radius: 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .zIndex(1000) // Make sure it's above everything

                // === GRID TEMPLATE PICKER (Task 2) — above the canvas ===
                if !viewModel.gridItems.isEmpty {
                    GridTemplatePickerView(viewModel: viewModel)
                        .transition(.opacity)
                }

                // === IPHONE FRAME (Middle - Smaller) ===
                iPhoneFrameView {
                    // Main container - EXACT size, no flexible space
                    ZStack {
                        // Layer 1: Background + Grid (Edge-to-Edge)
                        ZStack {
                            viewModel.backgroundColor

                            // Container for images - STRICTLY constrained.
                            // Iterates every template cell (not just occupied
                            // ones) so cells with no photo still render a
                            // placeholder instead of leaving a gap (Task 3).
                            ZStack(alignment: .topLeading) {
                                ForEach(Array(viewModel.templateCells.enumerated()), id: \.offset) { index, cell in
                                    if let item = viewModel.gridItems.first(where: { $0.gridPosition == index }) {
                                        GridImageCellView(item: item, viewModel: viewModel)
                                    } else if !viewModel.gridItems.isEmpty {
                                        // Only show per-cell placeholders once the
                                        // board has at least one photo — with zero
                                        // photos the big centered "Add photos"
                                        // empty state below covers that case.
                                        EmptyGridCellView(cell: cell) {
                                            slotPickerIndex = index
                                            showSlotPicker = true
                                        }
                                    }
                                }

                                if viewModel.showSeparators && viewModel.templateCells.count > 1 {
                                    GridSeparatorsView(
                                        cells: viewModel.templateCells,
                                        canvasSize: CGSize(width: viewModel.screenWidth, height: viewModel.screenHeight)
                                    )
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
                    .background(DesignTokens.Gradients.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.button))
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
        .photosPicker(isPresented: $showSlotPicker, selection: $slotPickerItem, matching: .images)
        .onChange(of: slotPickerItem) { newItem in
            guard let newItem, let index = slotPickerIndex else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.insertPhoto(at: index, image: image, data: data)
                }
                slotPickerItem = nil
                slotPickerIndex = nil
            }
        }
        .alert("Vision Board Saved!", isPresented: $viewModel.showSaveSuccess) {
            Button("Done", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your vision board has been saved to your gallery and is ready to be set as your lock screen wallpaper!")
        }
        .alert("Couldn't Save to Photos", isPresented: $showPhotoSaveError) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(boardSavedDespitePhotoError
                 ? "Couldn't save to Photos — check permission in Settings. Your board was still saved in the app."
                 : "Couldn't save to Photos — check permission in Settings.")
        }
    }
}

/// Completion target for UIImageWriteToSavedPhotosAlbum so photo library
/// write errors (e.g. Photos permission denied) aren't silently discarded.
/// Keeps itself alive until the write callback fires, then reports on main.
private final class PhotoAlbumSaver: NSObject {
    private let onComplete: (Error?) -> Void
    private var selfRetain: PhotoAlbumSaver?

    init(onComplete: @escaping (Error?) -> Void) {
        self.onComplete = onComplete
        super.init()
    }

    func save(_ image: UIImage) {
        selfRetain = self
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async { [onComplete] in
            onComplete(error)
        }
        selfRetain = nil
    }
}

// Extension for selective corner radius
extension RoundedRectangle {
    init(cornerRadius: CGFloat, corners: UIRectCorner) {
        self.init(cornerRadius: cornerRadius, style: .continuous)
    }
}

// Grid Separators View — strokes each cell's own border rather than a
// hand-maintained set of lines per template. This is the same array of
// cells (`viewModel.templateCells`) the canvas renders images into and the
// exporter draws from, so separators can never drift out of sync with the
// actual cell geometry — including the new mosaic/asymmetric templates,
// which don't have simple "n evenly-spaced lines" separators to hand-code.
struct GridSeparatorsView: View {
    let cells: [GridCell]
    let canvasSize: CGSize

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                Rectangle()
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    .frame(width: cell.width, height: cell.height)
                    .offset(x: cell.x, y: cell.y)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .topLeading)
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
                GridSeparatorsView(cells: layout.cells(in: frameSize), canvasSize: frameSize)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }
}
