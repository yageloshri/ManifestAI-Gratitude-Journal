import SwiftUI

// Shared Figma glass-surface effects, validated pixel-by-pixel on the Welcome
// screen parity pass. Every bordered "glass" element in the Registration
// Screens section (panels, pills, text fields, back buttons) carries the same
// inset-shadow stack from Figma:
//   0/48.97/70.3/-45.2 rgba(21,15,108,.5); 0/8.79/13.8/-5 #271839;
//   0/123/125.6/-60.3 #271839; 0/5/22.6/0 #271839; 0/1.26/50.2/0 #1A0B2C
// plus a 2px #63507A border and backdrop-blur with rgba(251,251,251,0.01) fill.

/// Inset-shadow stack approximation for a rounded-rect glass surface.
/// `compact` tones the big top/bottom bands down for small controls
/// (text fields, buttons) where Figma's huge blur radii mostly vanish.
struct FigmaInnerShadows: View {
    var cornerRadius: CGFloat
    var compact: Bool = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        shape
            .fill(Color.clear)
            // all-edge vignette: 0 5.023 22.602 0 #271839
            .overlay(
                shape.stroke(DesignTokens.Colors.innerShadow1, lineWidth: compact ? 14 : 23)
                    .blur(radius: compact ? 7 : 11)
            )
            // all-edge deep vignette: 0 1.256 50.226 0 #1A0B2C
            .overlay(
                shape.stroke(DesignTokens.Colors.innerShadow3, lineWidth: compact ? 28 : 50)
                    .blur(radius: compact ? 14 : 25)
            )
            // top band: 0 123.053 125.565 -60.271 #271839
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.innerShadow1, location: 0),
                        .init(color: DesignTokens.Colors.innerShadow1.opacity(0), location: compact ? 0.6 : 0.28)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .opacity(compact ? 0.55 : 1)
            )
            // top tint: 0 48.97 70.316 -45.203 rgba(21,15,108,0.5)
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.innerShadow2.opacity(0.5), location: 0),
                        .init(color: DesignTokens.Colors.innerShadow2.opacity(0), location: compact ? 0.35 : 0.14)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            // bottom band: 0 -102.963 85.384 -80.361 rgba(39,24,57,0.3)
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: DesignTokens.Colors.innerShadow1.opacity(0), location: compact ? 0.55 : 0.86),
                        .init(color: DesignTokens.Colors.innerShadow1.opacity(0.3), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(shape)
    }
}

/// Full Figma glass surface: faint fill + inset shadows + 2px #63507A border.
struct FigmaGlassSurface: ViewModifier {
    var cornerRadius: CGFloat
    var compact: Bool = true
    /// Figma strokes are inside-aligned; opt in per screen (parity-calibrated
    /// screens keep the original centered stroke).
    var insetStroke: Bool = false

    private var strokeGradient: LinearGradient {
        // Figma stroke: linear gradient #63507A → #332643@0 with handles
        // (0.5,-0.38)→(0.5,1.014): effective alpha 0.73 at the top edge,
        // ~0 at the bottom (the border fades out toward the bottom).
        LinearGradient(
            stops: [
                .init(color: DesignTokens.Colors.glassBorder.opacity(0.73), location: 0),
                .init(color: Color(hex: "332643").opacity(0), location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.01))
            )
            .overlay(FigmaInnerShadows(cornerRadius: cornerRadius, compact: compact))
            .overlay(
                Group {
                    if insetStroke {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(strokeGradient, lineWidth: 2)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(strokeGradient, lineWidth: 2)
                    }
                }
            )
    }
}

extension View {
    func figmaGlassSurface(cornerRadius: CGFloat, compact: Bool = true,
                           insetStroke: Bool = false) -> some View {
        modifier(FigmaGlassSurface(cornerRadius: cornerRadius, compact: compact,
                                   insetStroke: insetStroke))
    }

    /// Top-leading placement that moves the view's LAYOUT frame (padding),
    /// so hit-testing follows the rendered position. `.offset` is only a
    /// render-time geometry effect — gestures stay at the un-offset slot,
    /// which made every screen appear unresponsive. Negative components
    /// (decorative texture crops) fall back to offset, which is visually
    /// identical and irrelevant for hit-testing.
    func parityPosition(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self
            .padding(.leading, max(x, 0))
            .padding(.top, max(y, 0))
            .offset(x: min(x, 0), y: min(y, 0))
    }
}

/// Purple ellipse glow behind every registration screen.
/// Figma: ellipse (0,12) 578.67×677.5, #4F31EC at 51%, layer blur 257.
struct EllipseGlowBackground: View {
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    /// Figma x offset of the ellipse (Category/Problems/Did-you-know use -30).
    var xOffset: CGFloat = 0
    /// Figma fill opacity of the ellipse — varies per screen
    /// (0.29 on most input screens, 0.21 on DOB, 0.51 on Welcome/Analysis/Subscription).
    var figmaOpacity: CGFloat = 0.29

    var body: some View {
        // Calibration vs reference exports: SwiftUI blur(257) ≈ Figma layer
        // blur 514, and the Figma fill opacity carries over directly.
        Ellipse()
            .fill(Color(hex: "4F31EC").opacity(figmaOpacity))
            .frame(width: 578.67 * sx, height: 677.5 * sy)
            .offset(x: xOffset * sx, y: 12 * sy)
            .blur(radius: 257 * sx)
    }
}
