import SwiftUI

// MARK: - Design Tokens extracted from Figma
// Source: Figma file "Mindfullnes" (qZfqlrTu23SNGAnT8bfMWX)
// Section: "Core App" (300:1013)
// Extracted: 2026-04-26

enum DesignTokens {

    // MARK: - Colors (from Figma Variables)

    enum Colors {
        // Figma variable: "Background Color"
        static let background = Color(hex: "16062A")

        // Figma variable: "Primary Color"
        static let primary = Color(hex: "685EF5")

        // Figma variable: "Secondary Color"
        static let secondary = Color(hex: "FCD471")

        // Figma variable: "Text Color"
        static let textPrimary = Color(hex: "EBEBEB")

        // Figma variable: "Labels"
        static let textSecondary = Color(hex: "B9B9B9")

        // Figma variable: "Light grey"
        static let lightGrey = Color(hex: "9F9E9E")

        // Figma variable: "Card"
        static let card = Color(hex: "FFFFFF")

        // Figma variable: "White"
        static let white = Color(hex: "FFFFFF")

        // Figma variable: "Outlines"
        static let outlines = Color(hex: "D4D3D3")

        // Figma variable: "BG"
        static let bgLight = Color(hex: "FAFAFB")

        // Figma variable: "Neutral Colors/Grey Shade 1"
        static let greyShade1 = Color(hex: "33363B")

        // Figma variable: "Error"
        static let error = Color(hex: "CC2123")

        // Glass card border (used across all glass panels)
        static let glassBorder = Color(hex: "63507A")

        // Tab bar inactive text
        static let tabInactive = Color(hex: "8D7CD3")

        // Dark surface / card background
        static let surfaceDark = Color(hex: "291846")

        // Streak card background
        static let streakCardBg = Color(hex: "2C1855")

        // Streak card border
        static let streakCardBorder = Color(hex: "38108D")

        // Profile card background
        static let profileCardBg = Color(hex: "221542")

        // Avatar background
        static let avatarBg = Color(hex: "2C1E49")

        // Avatar border
        static let avatarBorder = Color(hex: "45326D")

        // Page indicator inactive
        static let indicatorInactive = Color(hex: "392564")

        // Selected plan border (gold)
        static let selectedBorderGold = Color(hex: "E9C378")

        // Unselected plan border
        static let unselectedBorder = Color(hex: "BA9DDE")

        // Inner shadow colors (for glass panels)
        static let innerShadow1 = Color(hex: "271839")
        static let innerShadow2 = Color(hex: "150F6C")
        static let innerShadow3 = Color(hex: "1A0B2C")
    }

    // MARK: - Gradients

    enum Gradients {
        // Figma variable: "Golden Gradient"
        static let golden = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 252/255, green: 212/255, blue: 113/255), // #FCD471
                Color(red: 191/255, green: 136/255, blue: 0/255)    // #BF8800
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        // Figma variable: "Gradient" (tab bar / primary button)
        // Figma: linear 90°, #3B2DF7 at 31.858% → #7C38FF at 100%
        static let primary = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "3B2DF7"), location: 0.31858),
                .init(color: Color(hex: "7C38FF"), location: 1.0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )

        // Card image overlay gradient
        static let cardOverlay = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 34/255, green: 21/255, blue: 70/255),           // #221546
                Color(red: 34/255, green: 20/255, blue: 67/255).opacity(0.587),
                Color(red: 34/255, green: 18/255, blue: 62/255).opacity(0)
            ]),
            startPoint: .trailing,
            endPoint: .leading
        )
    }

    // MARK: - Typography (from Figma Variables)

    enum Typography {
        // Figma variable: "H1"
        // Bitter SemiBold, 26px, weight 600, lineHeight 1.2
        static let h1 = Font.custom("Bitter-SemiBold", size: 26)

        // Figma variable: "H2-Bold"
        // Bitter Bold, 23px, weight 700, lineHeight 1.2
        static let h2Bold = Font.custom("Bitter-Bold", size: 23)

        // Figma variable: "H4"
        // Bitter Bold, 18px, weight 700, lineHeight 1.5
        static let h4 = Font.custom("Bitter-Bold", size: 18)

        // Figma variable: "Body-Medium"
        // Poppins Medium, 16px, weight 500, lineHeight 1.5
        static let bodyMedium = Font.custom("Poppins-Medium", size: 16)

        // Figma variable: "Body-Semibold"
        // Poppins SemiBold, 16px, weight 600, lineHeight 1.5
        static let bodySemibold = Font.custom("Poppins-SemiBold", size: 16)

        // Poppins SemiBold 18, lineHeight 27 (Figma: Analysis headline 270:522)
        static let bodySemibold18 = Font.custom("Poppins-SemiBold", size: 18)

        // Figma variable: "Body-Regular"
        // Poppins Regular, 16px, weight 400, lineHeight 1.5
        static let bodyRegular = Font.custom("Poppins-Regular", size: 16)

        // Figma variable: "Small - Medium"
        // Poppins Medium, 14px, weight 500, lineHeight 1.5
        static let smallMedium = Font.custom("Poppins-Medium", size: 14)

        // Figma variable: "Small-Text"
        // Poppins Regular, 14px, weight 400, lineHeight 1.5
        static let smallText = Font.custom("Poppins-Regular", size: 14)

        // Figma variable: "Small Text - Semibold"
        // Poppins SemiBold, 14px, weight 600, lineHeight 1.5
        static let smallTextSemibold = Font.custom("Poppins-SemiBold", size: 14)

        // Figma variable: "Label Tect" (sic - Figma typo)
        // Poppins Regular, 12px, weight 400, lineHeight 1.5
        static let label = Font.custom("Poppins-Regular", size: 12)

        // Welcome screen title — Figma node 264:874, Bitter 37px
        static let welcomeTitle = Font.custom("Bitter-SemiBold", size: 37)
        static let welcomeTitleLight = Font.custom("Bitter-Light", size: 37)
        static let welcomeTitleLightItalic = Font.custom("Bitter-LightItalic", size: 37)

        // Line height multipliers (for use with .lineSpacing())
        enum LineHeight {
            static let tight: CGFloat = 1.2    // H1, H2
            static let normal: CGFloat = 1.5   // Body, Small, Label
        }
    }

    // MARK: - Spacing (from Figma layout measurements)

    enum Spacing {
        static let screenPadding: CGFloat = 20    // Horizontal padding from edges
        static let cardPadding: CGFloat = 16      // Internal card padding
        static let sectionGap: CGFloat = 24       // Gap between major sections
        static let cardGap: CGFloat = 8           // Gap between cards
        static let itemGap: CGFloat = 12          // Gap between items within a card
        static let textGap: CGFloat = 4           // Gap between title/subtitle pairs
        static let tabBarGap: CGFloat = 21        // Gap between tab bar items
    }

    // MARK: - Radii (from Figma corner radius values)

    enum Radii {
        static let card: CGFloat = 16             // Card corner radius
        static let cardInner: CGFloat = 15        // Inner card elements
        static let button: CGFloat = 13           // Primary button
        static let tabBar: CGFloat = 12           // Tab bar top corners
        static let smallCard: CGFloat = 12        // Small icon containers
        static let input: CGFloat = 8             // Input fields / suggestion bar
        static let tabIndicator: CGFloat = 12     // Tab active indicator
        static let avatar: CGFloat = 50           // Profile avatar (circular)
        static let headerBadge: CGFloat = 14        // Welcome header glass pill (Figma node 268:1015)
        static let pill: CGFloat = 30             // Page indicator pills
        static let circle: CGFloat = 200          // Toggle switch, radio buttons
    }

    // MARK: - Sizes (from Figma component measurements)

    enum Sizes {
        static let screenWidth: CGFloat = 393     // iPhone 14/15 width
        static let screenHeight: CGFloat = 852    // iPhone 14/15 height
        static let tabBarHeight: CGFloat = 78     // Tab bar total height
        static let statusBarHeight: CGFloat = 44  // Status bar height
        static let buttonHeight: CGFloat = 56     // Primary button height
        static let buttonWidth: CGFloat = 353     // Full-width button
        static let navButtonSize: CGFloat = 40    // Navigation back button
        static let iconSize: CGFloat = 24         // Standard icon size
        static let smallIconSize: CGFloat = 20    // Small icons (in buttons)
        static let cardIconSize: CGFloat = 42     // "Elemento" icon container
        static let avatarSize: CGFloat = 72       // Profile avatar
        static let tabBarItemWidth: CGFloat = 53  // Tab bar item width
        static let tabIndicatorWidth: CGFloat = 38  // Active tab indicator width
        static let tabIndicatorHeight: CGFloat = 4  // Active tab indicator height
        static let settingsRowHeight: CGFloat = 70  // Profile settings row height
        static let toggleWidth: CGFloat = 56      // Toggle switch width
        static let toggleHeight: CGFloat = 32     // Toggle switch height
        static let profileAvatarLetter: CGFloat = 48 // Profile avatar size on home
        static let ritualCircleSize: CGFloat = 28    // 369 ritual progress circle
    }
}
