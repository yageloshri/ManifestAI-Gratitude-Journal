import SwiftUI

// MARK: - Theme (Compatibility Shim)
// All tokens now point to DesignTokens (Figma source of truth).
// Views should migrate to DesignTokens directly over time.
// Once all views are migrated, this file can be deleted.

struct Theme {
    struct Colors {
        // Mapped to Figma tokens
        static var backgroundDark: Color { DesignTokens.Colors.background }
        static var primary: Color { DesignTokens.Colors.primary }
        static var secondary: Color { DesignTokens.Colors.secondary }

        static var surface: Color { Color.white.opacity(0.05) }
        static var glassBorder: Color { DesignTokens.Colors.glassBorder }

        // DEPRECATED: not in Figma, remove when no view uses it
        static let backgroundLight = Color(hex: "f8f8f5")
        // DEPRECATED: not in Figma, remove when no view uses it
        static let accent = Color(hex: "9d4edd")

        // Gradients — mapped to Figma tokens
        static var mysticalGradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [
                    DesignTokens.Colors.background,
                    DesignTokens.Colors.background.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }

        static var goldGradient: LinearGradient { DesignTokens.Gradients.golden }
    }

    struct Fonts {
        /// Responsive display font — now uses Bitter (heading font from Figma)
        static func display(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let responsiveSize = size.responsive
            switch weight {
            case .bold:
                return .custom("Bitter-Bold", size: responsiveSize)
            case .semibold:
                return .custom("Bitter-SemiBold", size: responsiveSize)
            default:
                return .custom("Bitter-Regular", size: responsiveSize)
            }
        }

        /// Responsive body font — now uses Poppins (body font from Figma)
        static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let responsiveSize = size.responsive
            switch weight {
            case .bold:
                return .custom("Poppins-Bold", size: responsiveSize)
            case .semibold:
                return .custom("Poppins-SemiBold", size: responsiveSize)
            case .medium:
                return .custom("Poppins-Medium", size: responsiveSize)
            default:
                return .custom("Poppins-Regular", size: responsiveSize)
            }
        }

        /// Responsive system font — maps to Poppins for most weights
        static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
            let responsiveSize = size.responsive
            // For serif/rounded designs, fall back to system fonts
            if design == .serif || design == .rounded || design == .monospaced {
                return .system(size: responsiveSize, weight: weight, design: design)
            }
            // Default design uses Poppins
            switch weight {
            case .bold:
                return .custom("Poppins-Bold", size: responsiveSize)
            case .semibold:
                return .custom("Poppins-SemiBold", size: responsiveSize)
            case .medium:
                return .custom("Poppins-Medium", size: responsiveSize)
            case .light:
                return .custom("Poppins-Regular", size: responsiveSize)
            default:
                return .custom("Poppins-Regular", size: responsiveSize)
            }
        }
    }

    struct Spacing {
        /// Responsive spacing values that scale for iPad
        static let xs: CGFloat = 4.responsive
        static let sm: CGFloat = 8.responsive
        static let md: CGFloat = 12.responsive
        static let lg: CGFloat = 16.responsive
        static let xl: CGFloat = 20.responsive
        static let xxl: CGFloat = 24.responsive
        static let xxxl: CGFloat = 32.responsive

        /// Custom responsive spacing
        static func custom(_ value: CGFloat) -> CGFloat {
            return value.responsive
        }
    }
}

// MARK: - Common View Modifiers

struct GlassPanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Material.ultraThin)
            .background(Color.white.opacity(0.03))
            .cornerRadius(DesignTokens.Radii.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .stroke(DesignTokens.Colors.glassBorder, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassPanel() -> some View {
        self.modifier(GlassPanel())
    }
}
