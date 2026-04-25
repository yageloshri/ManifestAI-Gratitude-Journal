import SwiftUI

/// A realistic iPhone frame mockup that wraps the canvas
struct iPhoneFrameView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        // iPhone 14 Pro Approximate Dimensions - EVEN SMALLER (60% of screen)
        let phoneWidth: CGFloat = 240
        let phoneHeight: CGFloat = phoneWidth * 2.16 // 19.5:9 aspect ratio
        let cornerRadius: CGFloat = 40
        let borderWidth: CGFloat = 8
        
        ZStack {
            // Phone Bezel (Border)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "2c2c2e"),
                            Color(hex: "1c1c1e")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: phoneWidth, height: phoneHeight)
                .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            // Screen Content Area
            ZStack {
                content
            }
            .frame(
                width: phoneWidth - (borderWidth * 2),
                height: phoneHeight - (borderWidth * 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 6))
            
            // Dynamic Island
            VStack {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 110, height: 32)
                    .padding(.top, borderWidth + 8)
                Spacer()
            }
            .frame(width: phoneWidth, height: phoneHeight)
            .allowsHitTesting(false)
        }
        .frame(width: phoneWidth, height: phoneHeight)
    }
}
