// OnboardingComponents.swift
// Reusable UI components for the mystical onboarding experience
// Created for ManifestAI - Premium Gratitude Journal

import SwiftUI

// MARK: - Mystical Background
struct MysticalBackground: View {
    var body: some View {
        ZStack {
            // Deep radial gradient
            RadialGradient(
                colors: [
                    Color(hex: "1a1a40"),
                    Color(hex: "0d0d2b"),
                    Color(hex: "000000")
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // Star dust overlay
            StarDustView()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Star Dust Particles
struct StarDustView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<80, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
}

// MARK: - Glass Card Component
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                Color.white.opacity(0.05)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - Gold Button Component
struct GoldButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(
                    ZStack {
                        // Gradient background
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "FFA500")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Subtle glass overlay
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFE55C"),
                                    Color(hex: "FF8C00")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Glass Text Field
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(.white)
            .accentColor(Color(hex: "FFD700"))
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700").opacity(0.6),
                                        Color(hex: "FFA500").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - Goal Card for Selection
struct GoalCard: View {
    let goal: ManifestationGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 30, weight: .regular))
                        .foregroundColor(isSelected ? .black : Color(hex: "FFD700"))
                }
                
                // Label
                Text(goal.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ?
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2.5 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? Color(hex: "FFD700").opacity(0.4) : .black.opacity(0.2),
                        radius: isSelected ? 20 : 10,
                        x: 0,
                        y: 5
                    )
            )
            .environment(\.colorScheme, .dark)
        }
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}

// MARK: - Timeline View (Morning, Noon, Night)
struct TimelineView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Morning
            TimelineSegment(
                icon: "sun.max.fill",
                label: "Morning",
                position: .leading
            )
            
            // Connector Line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFD700").opacity(0.6), Color(hex: "FFA500").opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, -8)
            
            // Afternoon
            TimelineSegment(
                icon: "sun.max.fill",
                label: "Afternoon",
                position: .center
            )
            
            // Connector Line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFA500").opacity(0.4), Color(hex: "FFD700").opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, -8)
            
            // Night
            TimelineSegment(
                icon: "moon.fill",
                label: "Night",
                position: .trailing
            )
        }
        .padding(.horizontal, 20)
    }
}

struct TimelineSegment: View {
    let icon: String
    let label: String
    let position: Alignment
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFD700").opacity(0.3), Color(hex: "FFA500").opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // Label
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Constellation View
struct ConstellationView: View {
    var body: some View {
        ZStack {
            // Constellation lines
            Path { path in
                path.move(to: CGPoint(x: 20, y: 30))
                path.addLine(to: CGPoint(x: 50, y: 15))
                path.addLine(to: CGPoint(x: 80, y: 25))
                path.move(to: CGPoint(x: 50, y: 15))
                path.addLine(to: CGPoint(x: 60, y: 50))
                path.move(to: CGPoint(x: 80, y: 25))
                path.addLine(to: CGPoint(x: 100, y: 40))
                path.move(to: CGPoint(x: 60, y: 50))
                path.addLine(to: CGPoint(x: 90, y: 70))
            }
            .stroke(
                LinearGradient(
                    colors: [Color(hex: "FFD700").opacity(0.4), Color(hex: "FFA500").opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            
            // Stars
            ForEach([
                CGPoint(x: 20, y: 30),
                CGPoint(x: 50, y: 15),
                CGPoint(x: 80, y: 25),
                CGPoint(x: 60, y: 50),
                CGPoint(x: 100, y: 40),
                CGPoint(x: 90, y: 70)
            ], id: \.x) { point in
                Circle()
                    .fill(Color(hex: "FFD700"))
                    .frame(width: 4, height: 4)
                    .position(point)
            }
            
            // Larger featured stars
            ForEach([
                CGPoint(x: 50, y: 15),
                CGPoint(x: 90, y: 70)
            ], id: \.x) { point in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFD700").opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: 16, height: 16)
                    .position(point)
            }
            
            // Moon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "E6D5B8"), Color(hex: "9B8B7E")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .fill(Color(hex: "8B7D6B").opacity(0.3))
                        .frame(width: 8, height: 8)
                        .offset(x: -4, y: -4)
                )
                .position(x: 30, y: 90)
        }
        .frame(width: 120, height: 120)
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

