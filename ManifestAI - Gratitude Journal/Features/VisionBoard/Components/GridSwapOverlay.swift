import SwiftUI

struct GridSwapOverlay: View {
    let currentLayout: GridLayoutTemplate
    let items: [VisionBoardGridItemModel]
    let sourceIndex: Int
    let onSelectTarget: (Int) -> Void
    let onCancel: () -> Void
    
    var sortedItems: [VisionBoardGridItemModel] {
        items.sorted { $0.gridPosition < $1.gridPosition }
    }
    
    var body: some View {
        ZStack {
            // Dark backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                // Title
                Text("Choose where to move this photo")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 40)
                
                // Mini grid preview
                ZStack(alignment: .topLeading) {
                    // Background
                    Color(hex: "050510")
                    
                    // All grid cells
                    ForEach(sortedItems) { item in
                        SwapCellView(
                            item: item,
                            isSource: item.gridPosition == sourceIndex,
                            onTap: {
                                if item.gridPosition != sourceIndex {
                                    onSelectTarget(item.gridPosition)
                                }
                            }
                        )
                    }
                    
                    // Separators
                    GridSeparatorsView(layout: currentLayout)
                        .opacity(0.3)
                        .scaleEffect(0.5)
                        .frame(width: 195, height: 422, alignment: .topLeading)
                }
                .frame(width: 195, height: 422)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.5), radius: 30)
                
                // Instructions
                Text("Tap a cell to swap")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
                
                // Cancel button
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            print("🔄 GridSwapOverlay:")
            print("   sourceIndex: \(sourceIndex)")
            print("   items: \(items.count)")
            for item in sortedItems {
                print("   [\(item.gridPosition)]: cell=(\(item.cell.x), \(item.cell.y), \(item.cell.width)x\(item.cell.height))")
            }
        }
    }
}

struct SwapCellView: View {
    let item: VisionBoardGridItemModel
    let isSource: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    // Scale to half size for mini preview
    private var scaledCell: (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        (
            x: item.cell.x / 2,
            y: item.cell.y / 2,
            width: item.cell.width / 2,
            height: item.cell.height / 2
        )
    }
    
    var body: some View {
        Button(action: {
            print("🔘 Tapped: gridPosition=\(item.gridPosition), isSource=\(isSource)")
            onTap()
        }) {
            ZStack {
                // Image thumbnail
                Image(uiImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: scaledCell.width, height: scaledCell.height)
                    .clipped()
                    .opacity(isSource ? 1.0 : 0.6)
                
                // Dark overlay
                Rectangle()
                    .fill(Color.black.opacity(isSource ? 0.3 : 0.4))
                
                // Icon and label
                if isSource {
                    VStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(hex: "FFD700"))
                        
                        Text("Current")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 2)
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        Text("Swap")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                }
            }
            .frame(width: scaledCell.width, height: scaledCell.height)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSource ? Color(hex: "FFD700") : Color.white.opacity(0.5), lineWidth: isSource ? 3 : 1.5)
            )
            .shadow(color: isSource ? Color(hex: "FFD700").opacity(0.5) : .clear, radius: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: scaledCell.x, y: scaledCell.y)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            print("📍 Cell[\(item.gridPosition)] at: (\(scaledCell.x), \(scaledCell.y)), size: (\(scaledCell.width)x\(scaledCell.height)), isSource: \(isSource)")
        }
    }
}
