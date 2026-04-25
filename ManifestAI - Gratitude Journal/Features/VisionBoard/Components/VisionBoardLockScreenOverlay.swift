import SwiftUI

struct VisionBoardLockScreenOverlay: View {
    let date: Date = Date()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Top Safe Area (Time & Date like iOS 16+)
                VStack(spacing: 4) {
                    // Date
                    Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 2)
                    
                    // Time - Big iOS 16 Style
                    Text(date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 76, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
                        .padding(.top, -8)
                }
                .padding(.top, 70) // Account for dynamic island + extra spacing
                
                Spacer()
                
                // MARK: - Bottom Safe Area (Flashlight & Camera)
                HStack(spacing: 0) {
                    // Flashlight
                    LockScreenButton(icon: "flashlight.off.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Camera
                    LockScreenButton(icon: "camera.fill")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 30) // Extra spacing from bottom
            }
        }
        .allowsHitTesting(false) // CRITICAL: Pass all touches through to grid below
        .edgesIgnoringSafeArea(.all)
    }
}

struct LockScreenButton: View {
    let icon: String
    
    var body: some View {
        ZStack {
            // Frosted glass background
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 52, height: 52)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4)
        }
    }
}
