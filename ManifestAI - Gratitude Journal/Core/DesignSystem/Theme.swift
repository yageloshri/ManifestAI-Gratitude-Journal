import SwiftUI

struct Theme {

    // MARK: - Colors (from Figma "Light Version")
    struct Colors {
        // Core palette
        static let background = Color(hex: "16062A")
        static let primary = Color(hex: "685EF5")
        static let secondary = Color(hex: "FCD471")       // Gold/yellow accent
        static let text = Color(hex: "EBEBEB")
        static let labels = Color(hex: "B9B9B9")
        static let lightGrey = Color(hex: "9F9E9E")
        static let card = Color.white

        // Glass panel borders & surfaces
        static let glassBorder = Color(hex: "63507A")
        static let selectedBorder = Color(hex: "685EF5")   // Same as primary
        static let goldBorder = Color(hex: "EABD4E")
        static let subtleBorder = Color(hex: "BA9DDE")

        // Surface / card backgrounds
        static let surface = Color(hex: "251540")
        static let surfaceAlt = Color(hex: "291846")
        static let surfaceDark = Color(hex: "2C1855")
        static let streakBorder = Color(hex: "38108D")

        // Glass inner shadow tints (used in GlassPanel modifier)
        static let glassShadowDeep = Color(hex: "1A0B2C")
        static let glassShadowMid = Color(hex: "271839")
        static let glassShadowBlue = Color(hex: "150F6C")

        // Tab bar
        static let tabInactive = Color(hex: "8D7CD3")
        static let tabActive = Color(hex: "FCD471")        // Same as secondary

        // Button gradient stops
        static let buttonGradientStart = Color(hex: "3B2DF7")
        static let buttonGradientEnd = Color(hex: "7C38FF")

        // Gold gradient stops
        static let goldGradientStart = Color(hex: "FCD471")
        static let goldGradientEnd = Color(hex: "BF8800")

        // Category card icon glow colors
        static let glowLove = Color(hex: "FC0D1B")         // Red glow
        static let glowFinance = Color(hex: "F39E09")      // Orange glow
        static let glowPeace = Color(hex: "579341")        // Green glow
        static let glowCareer = Color(hex: "0089FF")       // Blue glow
        static let glowJournal = Color(hex: "3F36C3")      // Purple glow

        // Legacy aliases (keep for backward compatibility during migration)
        static let backgroundDark = background
        static let accent = primary
    }

    // MARK: - Gradients (from Figma)
    struct Gradients {
        /// Primary button gradient: #3B2DF7 → #7C38FF (left to right)
        static let button = LinearGradient(
            colors: [Colors.buttonGradientStart, Colors.buttonGradientEnd],
            startPoint: .leading,
            endPoint: .trailing
        )

        /// Gold text/accent gradient: #FCD471 → #BF8800 (162° angle ≈ top-left to bottom-right)
        static let gold = LinearGradient(
            colors: [Colors.goldGradientStart, Colors.goldGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Tab bar background: same as button gradient
        static let tabBar = LinearGradient(
            colors: [Colors.buttonGradientStart, Colors.buttonGradientEnd],
            startPoint: .leading,
            endPoint: .trailing
        )

        /// Subtle background glow (radial, for decorative ellipse behind content)
        static let backgroundGlow = RadialGradient(
            colors: [
                Color(hex: "685EF5").opacity(0.3),
                Color(hex: "16062A").opacity(0)
            ],
            center: .topLeading,
            startRadius: 0,
            endRadius: 400
        )

        /// Streak bar decorative gradient
        static let streak = LinearGradient(
            colors: [
                Color(hex: "2C1855"),
                Color(hex: "2C1855")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Typography (from Figma: Bitter + Poppins)
    struct Fonts {

        // --- Bitter (serif headings) ---

        /// H1: Bitter SemiBold 26px, lineHeight 1.2
        static func h1() -> Font {
            .custom("Bitter-SemiBold", size: CGFloat(26).responsive)
        }

        /// H4: Bitter Bold 18px, lineHeight 1.5
        static func h4() -> Font {
            .custom("Bitter-Bold", size: CGFloat(18).responsive)
        }

        /// Hero title: Bitter Light Italic 37px (onboarding welcome)
        static func heroItalic() -> Font {
            .custom("Bitter-LightItalic", size: CGFloat(37).responsive)
        }

        /// Hero title: Bitter SemiBold 37px (onboarding welcome)
        static func heroSemiBold() -> Font {
            .custom("Bitter-SemiBold", size: CGFloat(37).responsive)
        }

        /// Bold Italic: Bitter Bold Italic 26px (subscription heading)
        static func boldItalic(size: CGFloat = 26) -> Font {
            .custom("Bitter-BoldItalic", size: size.responsive)
        }

        /// Numerology large number: Bitter Bold 58px
        static func numerologyLarge() -> Font {
            .custom("Bitter-Bold", size: CGFloat(58).responsive)
        }

        /// Numerology small (home card): Bitter Bold 36px
        static func numerologySmall() -> Font {
            .custom("Bitter-Bold", size: CGFloat(36).responsive)
        }

        // --- Poppins (sans-serif body) ---

        /// Body-Medium: Poppins Medium 16px, lineHeight 1.5
        static func bodyMedium() -> Font {
            .custom("Poppins-Medium", size: CGFloat(16).responsive)
        }

        /// Body-Regular: Poppins Regular 16px, lineHeight 1.5
        static func bodyRegular() -> Font {
            .custom("Poppins-Regular", size: CGFloat(16).responsive)
        }

        /// Body-SemiBold: Poppins SemiBold 16px, lineHeight 1.5
        static func bodySemiBold() -> Font {
            .custom("Poppins-SemiBold", size: CGFloat(16).responsive)
        }

        /// Small-Medium: Poppins Medium 14px, lineHeight 1.5
        static func smallMedium() -> Font {
            .custom("Poppins-Medium", size: CGFloat(14).responsive)
        }

        /// Small-Text: Poppins Regular 14px, lineHeight 1.5
        static func smallText() -> Font {
            .custom("Poppins-Regular", size: CGFloat(14).responsive)
        }

        /// Small-SemiBold: Poppins SemiBold 14px, lineHeight 1.5
        static func smallSemiBold() -> Font {
            .custom("Poppins-SemiBold", size: CGFloat(14).responsive)
        }

        /// Label: Poppins Regular 12px, lineHeight 1.5
        static func label() -> Font {
            .custom("Poppins-Regular", size: CGFloat(12).responsive)
        }

        // --- Fallback system fonts (used if custom fonts aren't bundled yet) ---

        /// System serif fallback for Bitter
        static func serifFallback(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .system(size: size.responsive, weight: weight, design: .serif)
        }

        /// System sans fallback for Poppins
        static func sansFallback(size: CGFloat, weight: Font.Weight = .medium) -> Font {
            .system(size: size.responsive, weight: weight, design: .default)
        }
    }

    // MARK: - Spacing (responsive, scales 1.4x on iPad)
    struct Spacing {
        static let xs: CGFloat = CGFloat(4).responsive
        static let sm: CGFloat = CGFloat(8).responsive
        static let md: CGFloat = CGFloat(12).responsive
        static let lg: CGFloat = CGFloat(16).responsive
        static let xl: CGFloat = CGFloat(20).responsive
        static let xxl: CGFloat = CGFloat(24).responsive
        static let xxxl: CGFloat = CGFloat(32).responsive

        static func custom(_ value: CGFloat) -> CGFloat {
            return value.responsive
        }
    }

    // MARK: - Corner Radii (from Figma)
    struct Radius {
        static let button: CGFloat = 13              // Button Default
        static let card: CGFloat = 16                // Glass cards, panels
        static let textField: CGFloat = 150          // Capsule-shaped text fields (very large = pill)
        static let backButton: CGFloat = 12          // Back arrow button
        static let stepper: CGFloat = 50             // Stepper segments (pill)
        static let checkboxPill: CGFloat = 200       // Pill checkboxes (problems screen)
        static let tabBar: CGFloat = 12              // Tab bar top corners
        static let iconContainer: CGFloat = 12       // Icon "Elemento" containers
        static let iconContainerLg: CGFloat = 25     // Large icon containers (numerology)
        static let infoBox: CGFloat = 18             // Info/hint boxes
        static let welcomeBadge: CGFloat = 14        // Welcome title badge
        static let tag: CGFloat = 8                  // Small tags/chips
    }

    // MARK: - Sizes (from Figma, in points)
    struct Sizes {
        // Buttons
        static let buttonHeight: CGFloat = 56
        static let backButtonSize: CGFloat = 56
        static let stepperHeight: CGFloat = 6

        // Text fields
        static let textFieldHeight: CGFloat = 56

        // Cards
        static let categoryCardHeight: CGFloat = 82
        static let checkboxPillHeight: CGFloat = 52
        static let homeNumerologyCardHeight: CGFloat = 125
        static let homeStreakBarHeight: CGFloat = 64
        static let homeFeatureCardHeight: CGFloat = 197
        static let homeSmallCardHeight: CGFloat = 135

        // Icons
        static let iconSmall: CGFloat = 24
        static let iconMedium: CGFloat = 28
        static let iconContainer: CGFloat = 42
        static let iconContainerLg: CGFloat = 88
        static let numerologyIconHome: CGFloat = 54
        static let checkboxCircle: CGFloat = 24

        // Tab bar
        static let tabBarHeight: CGFloat = 78
        static let tabIcon: CGFloat = 24

        // Avatar
        static let avatarSize: CGFloat = 48

        // Layout
        static let screenPadding: CGFloat = 20
        static let stepperTopOffset: CGFloat = 76
        static let contentTopOffset: CGFloat = 122
        static let bottomBarOffset: CGFloat = 734
    }
}

// MARK: - Glass Panel Modifier (matches Figma "Glass effect" style)
struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.card
    var borderColor: Color = Theme.Colors.glassBorder
    var borderWidth: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(0.01)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.01))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Theme.Colors.glassShadowBlue.opacity(0.5), radius: 35, x: 0, y: 24)
            .shadow(color: Theme.Colors.glassShadowMid.opacity(0.3), radius: 11, x: 0, y: 5)
            .shadow(color: Theme.Colors.glassShadowDeep.opacity(0.8), radius: 25, x: 0, y: 1)
    }
}

// MARK: - View Extensions
extension View {
    /// Apply the standard glass panel effect from Figma
    func glassPanel(
        cornerRadius: CGFloat = Theme.Radius.card,
        borderColor: Color = Theme.Colors.glassBorder,
        borderWidth: CGFloat = 2
    ) -> some View {
        self.modifier(GlassPanel(
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }

    /// Apply pill-shaped glass panel (for text fields, checkboxes)
    func glassPill(
        borderColor: Color = Theme.Colors.glassBorder,
        borderWidth: CGFloat = 2
    ) -> some View {
        self.modifier(GlassPanel(
            cornerRadius: Theme.Radius.textField,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }

    /// Apply the primary button gradient background
    func primaryButtonStyle() -> some View {
        self
            .frame(height: Theme.Sizes.buttonHeight)
            .background(Theme.Gradients.button)
            .cornerRadius(Theme.Radius.button)
    }
}
