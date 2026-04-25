import SwiftUI

struct ResizeCellOverlay: View {
    let currentSize: CellSize
    let itemImage: UIImage
    let onSelectSize: (CellSize) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Dark backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 30) {
                // Title
                Text("Choose Photo Size")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                
                // Image preview
                Image(uiImage: itemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10)
                
                // Size options
                VStack(spacing: 16) {
                    ForEach(CellSize.allCases, id: \.self) { size in
                        SizeOptionButton(
                            size: size,
                            isSelected: size == currentSize,
                            onTap: {
                                onSelectSize(size)
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Cancel button
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct SizeOptionButton: View {
    let size: CellSize
    let isSelected: Bool
    let onTap: () -> Void
    
    private var icon: String {
        switch size {
        case .small: return "rectangle.portrait"
        case .medium: return "square"
        case .large: return "rectangle"
        }
    }
    
    private var description: String {
        switch size {
        case .small: return "33% of screen"
        case .medium: return "50% of screen"
        case .large: return "Full width"
        }
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "FFD700") : Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(isSelected ? .black : .white)
                }
                
                // Text info
                VStack(alignment: .leading, spacing: 4) {
                    Text(size.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(hex: "FFD700"))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex: "FFD700") : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

