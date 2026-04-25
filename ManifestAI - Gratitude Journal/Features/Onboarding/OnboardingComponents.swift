// OnboardingComponents.swift
// Reusable UI components for the mystical onboarding experience
// Created for ManifestAI - Premium Gratitude Journal

import SwiftUI

// MARK: - Mystical Background
struct MysticalBackground: View {
    var body: some View {
        ZStack {
            // Deep gradient background - matching Figma design
            LinearGradient(
                colors: [
                    Color(hex: "1A1F3A"), // Top - dark blue
                    Color(hex: "1F2544"), // Mid-top
                    Color(hex: "2D1F4E"), // Mid
                    Color(hex: "3D2B5F"), // Mid-bottom
                    Color(hex: "4A2F6B")  // Bottom - purple
                ],
                startPoint: .top,
                endPoint: .bottom
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
