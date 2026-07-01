import SwiftUI

/// Figma: Back button component (node 282:2311)
/// 56×56 glass square with arrow-left icon.
///
/// Figma specs:
/// - Size: 56×56
/// - Corner radius: 12px
/// - Border: 2px #63507A
/// - Glass: ultraThinMaterial + rgba(251,251,251,0.01)
/// - Icon: Arrow_Left_MD, 28×28, centered, white
struct GlassBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Color.clear
                    .figmaGlassSurface(cornerRadius: DesignTokens.Radii.smallCard) // 12

                // Figma: Arrow_Left_MD vector 16.3×14, 2pt stroke, #685EF5
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.primary)
            }
            .frame(width: 56, height: 56) // Figma: 56×56
        }
    }
}

#Preview("GlassBackButton") {
    ZStack {
        DesignTokens.Colors.background.ignoresSafeArea()
        GlassBackButton {}
    }
}
