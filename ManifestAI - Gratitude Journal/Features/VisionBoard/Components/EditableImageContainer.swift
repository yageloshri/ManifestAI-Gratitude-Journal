import SwiftUI

struct EditableImageContainer: View {
    let image: UIImage
    let onTap: () -> Void
    
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(currentScale)
                .offset(offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .contentShape(Rectangle()) // Ensure entire area is tappable/gesturable
                .gesture(
                    SimultaneousGesture(
                        // Zoom Gesture
                        MagnificationGesture()
                            .onChanged { amount in
                                let newScale = finalScale * amount
                                // Limit zoom range (e.g., 1x to 5x)
                                if newScale >= 1.0 && newScale <= 5.0 {
                                    currentScale = newScale
                                }
                            }
                            .onEnded { _ in
                                finalScale = currentScale
                            },
                        // Drag Gesture (Pan)
                        DragGesture()
                            .onChanged { value in
                                // Calculate new offset based on drag translation + previous offset
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                offset = newOffset
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .onTapGesture {
                    onTap()
                }
        }
    }
}

#Preview {
    EditableImageContainer(image: UIImage(systemName: "photo") ?? UIImage(), onTap: {})
        .frame(width: 300, height: 200)
        .border(Color.red)
}

