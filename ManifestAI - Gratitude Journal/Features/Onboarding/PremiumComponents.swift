// PremiumComponents.swift
// Premium UI components for onboarding screens
// Shared components with exact design from Figma

import SwiftUI

// MARK: - Premium Button
struct PremiumButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "D4AF37"))
                .frame(maxWidth: .infinity)
                .responsiveHeight(56)
                .background(
                    RoundedRectangle(cornerRadius: 28.responsive)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28.responsive)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "D4AF37").opacity(0.8),
                                            Color(hex: "FFD700").opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 28.responsive)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                )
        }
    }
}

// MARK: - Premium Text Field
struct PremiumTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(Theme.Fonts.system(size: 17, weight: .regular))
            .foregroundColor(.white)
            .accentColor(Color(hex: "FFD700"))
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.vertical, Theme.Spacing.lg + Theme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 14.responsive)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14.responsive)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "D4AF37").opacity(0.6),
                                        Color(hex: "FFD700").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 14.responsive)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            )
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - Premium Glass Card
struct PremiumGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Theme.Spacing.xxl)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Spacing.xxl)
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

