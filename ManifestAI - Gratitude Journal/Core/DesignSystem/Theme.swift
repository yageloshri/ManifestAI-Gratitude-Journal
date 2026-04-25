import SwiftUI

struct Theme {
    struct Colors {
        static let backgroundDark = Color(hex: "0F0C29") // Deep Midnight Purple
        static let backgroundLight = Color(hex: "f8f8f5")
        static let primary = Color(hex: "4F46E5") // Blue
        static let secondary = Color(hex: "BABAEF") // Light Purple/Lavender
        static let accent = Color(hex: "9d4edd") // Mystical Purple
        
        static let surface = Color.white.opacity(0.05)
        static let glassBorder = Color.white.opacity(0.1)
        
        // Gradients
        static let mysticalGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "1a1638"),
                Color(hex: "0c0a20")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let goldGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FFD900"),
                Color(hex: "FFF5B3"), // Light yellow/gold (yellow-200 approx)
                Color(hex: "FFD900")
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    struct Fonts {
        /// Responsive display font that scales for iPad
        static func display(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let responsiveSize = size.responsive
            return .system(size: responsiveSize, weight: weight, design: .rounded)
        }
        
        /// Responsive body font that scales for iPad
        static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            let responsiveSize = size.responsive
            return .system(size: responsiveSize, weight: weight, design: .default)
        }
        
        /// Responsive system font that scales for iPad
        static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
            let responsiveSize = size.responsive
            return .system(size: responsiveSize, weight: weight, design: design)
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

// Common View Modifiers
struct GlassPanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Material.ultraThin)
            .background(Color.white.opacity(0.03))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.Colors.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassPanel() -> some View {
        self.modifier(GlassPanel())
    }
}

