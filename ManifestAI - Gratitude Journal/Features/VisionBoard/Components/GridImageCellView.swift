import SwiftUI

struct GridImageCellView: View {
    let item: VisionBoardGridItemModel
    @ObservedObject var viewModel: VisionBoardViewModel
    
    @State private var localOffsetX: CGFloat = 0
    @State private var localOffsetY: CGFloat = 0
    @State private var localZoom: CGFloat = 1.0
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        // The actual cell content with absolute positioning
        Color.clear
            .frame(width: item.cell.width, height: item.cell.height)
            .overlay(
                ZStack {
                    // Background fill
                    Rectangle()
                        .fill(Color.black)
                    
                    // The image - aspect fill to cover entire cell
                    Image(uiImage: item.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: item.cell.width * (item.zoom + localZoom - 1),
                            height: item.cell.height * (item.zoom + localZoom - 1)
                        )
                        .offset(
                            x: item.offsetX + localOffsetX,
                            y: item.offsetY + localOffsetY
                        )
                    
                    // Selection border
                    if viewModel.selectedItemForMenu?.id == item.id {
                        Rectangle()
                            .stroke(Color(hex: "FFD700"), lineWidth: 3)
                    }
                }
            )
            .clipped()
            .contentShape(Rectangle())
            .offset(x: item.cell.x, y: item.cell.y)
            .gesture(
                SimultaneousGesture(
                    // Drag gesture for pan
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            localOffsetX = value.translation.width
                            localOffsetY = value.translation.height
                        }
                        .onEnded { value in
                            // Commit pan
                            impactLight.impactOccurred()
                            viewModel.updateItemCrop(
                                item,
                                offsetX: item.offsetX + localOffsetX,
                                offsetY: item.offsetY + localOffsetY,
                                zoom: item.zoom
                            )
                            localOffsetX = 0
                            localOffsetY = 0
                        },
                    // Pinch to zoom
                    MagnificationGesture()
                        .onChanged { value in
                            localZoom = value
                        }
                        .onEnded { value in
                            impactLight.impactOccurred()
                            let newZoom = max(0.8, min(3.0, item.zoom * value))
                            viewModel.updateItemCrop(
                                item,
                                offsetX: item.offsetX,
                                offsetY: item.offsetY,
                                zoom: newZoom
                            )
                            localZoom = 1.0
                        }
                )
            )
            .onLongPressGesture(minimumDuration: 0.6) {
                // Open resize overlay
                impactMedium.impactOccurred()
                withAnimation {
                    viewModel.resizeTargetItemID = item.id
                    viewModel.showResizeOverlay = true
                }
            }
            .onTapGesture {
                impactMedium.impactOccurred()
                withAnimation(.spring(response: 0.3)) {
                    if viewModel.selectedItemForMenu?.id == item.id {
                        viewModel.selectedItemForMenu = nil
                    } else {
                        viewModel.selectedItemForMenu = item
                    }
                }
            }
    }
}
