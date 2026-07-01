import SwiftUI

/// Reusable glowing icon container from Figma "Elemento" component.
/// Used across feature cards (Gratitude Journal, Vision Board, 369 Methods, etc.)
///
/// Figma specs (node 312:1488):
/// - Size: 42×42 (standard), 54×54 (large/numerology)
/// - Corner radius: 12px
/// - Padding: 8px
/// - Border: 0.8px rgba(216,216,216,0.05)
/// - Background: backdrop-blur 10px + gradient overlay
/// - Outer shadow: 8 4 16 0 rgba(0,0,0,0.08)
/// - Inner glow: inset 0 0 8 0 rgba(tint, 0.32)
struct ElementoIcon: View {
    let icon: Image
    var tint: Color = DesignTokens.Colors.primary
    var size: CGFloat = 42

    private var iconSize: CGFloat {
        // Icon fills the padded area: size - 2 * padding(8)
        size - 16
    }

    private var cornerRadius: CGFloat {
        DesignTokens.Radii.smallCard // 12
    }

    var body: some View {
        ZStack {
            // Background: glass blur + subtle gradient
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 248/255, green: 251/255, blue: 255/255).opacity(0.04),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Icon
            icon
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(tint)

            // Inner glow (inset shadow emulation)
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.clear, lineWidth: 0)
                .shadow(color: tint.opacity(0.32), radius: 4, x: 0, y: 0)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .frame(width: size, height: size)
        // Outer border
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(red: 216/255, green: 216/255, blue: 216/255).opacity(0.05), lineWidth: 0.8)
        )
        // Outer shadow
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 8, y: 4)
    }
}

// MARK: - Convenience initializer for SF Symbols

extension ElementoIcon {
    init(systemName: String, tint: Color = DesignTokens.Colors.primary, size: CGFloat = 42) {
        self.icon = Image(systemName: systemName)
        self.tint = tint
        self.size = size
    }
}

// MARK: - Preview

#Preview("ElementoIcon Variants") {
    ZStack {
        DesignTokens.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 32) {
            Text("ElementoIcon Component")
                .font(DesignTokens.Typography.h4)
                .foregroundStyle(DesignTokens.Colors.textPrimary)

            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    ElementoIcon(
                        systemName: "book.fill",
                        tint: DesignTokens.Colors.primary
                    )
                    Text("Journal")
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }

                VStack(spacing: 8) {
                    ElementoIcon(
                        systemName: "eye.fill",
                        tint: Color(hex: "0089FF") // Vision blue
                    )
                    Text("Vision")
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }

                VStack(spacing: 8) {
                    ElementoIcon(
                        systemName: "flame.fill",
                        tint: Color(hex: "F39E09") // 369 orange
                    )
                    Text("369")
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }

                VStack(spacing: 8) {
                    ElementoIcon(
                        systemName: "star.fill",
                        tint: DesignTokens.Colors.secondary, // Gold
                        size: 54
                    )
                    Text("Numero")
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
            }
        }
    }
}
