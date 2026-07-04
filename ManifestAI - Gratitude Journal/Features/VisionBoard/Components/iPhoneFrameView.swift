import SwiftUI

/// A realistic iPhone frame mockup that wraps the canvas.
///
/// `content` is laid out at a fixed reference canvas size (`canvasSize`,
/// e.g. the vision-board editor's 390x844 grid). Previously this view just
/// force-framed the "screen" area to the (smaller) bezel interior size
/// without scaling `content` down — since `content` reports its own fixed
/// 390x844 size regardless of what's proposed, the bezel's `.clipShape`
/// silently CROPPED the canvas instead of shrinking it, hiding roughly the
/// outer ~40% of the board from the user while editing. That's the real
/// root cause behind "my saved board looks different from what I edited" —
/// large parts of the canvas (and any photos placed there) were never
/// visible on screen at all. Fixed by explicitly computing a fit scale and
/// applying `.scaleEffect`, so the mockup always shows the *entire* canvas,
/// just smaller — the same coordinate space the exporter renders from.
struct iPhoneFrameView<Content: View>: View {
    let content: Content
    let canvasSize: CGSize

    init(canvasSize: CGSize = CGSize(width: 390, height: 844), @ViewBuilder content: () -> Content) {
        self.canvasSize = canvasSize
        self.content = content()
    }

    var body: some View {
        // Size the mockup to the space the parent actually offers (capped at
        // the original 240pt width) instead of a fixed 240×518 — on shorter
        // devices the fixed size overflowed the editor's VStack, pushing the
        // toolbar into the status bar and the bottom button off-screen.
        GeometryReader { geo in
            let maxWidth = min(geo.size.width, 240)
            let phoneHeight = min(geo.size.height, maxWidth * 2.16)
            let phoneWidth = phoneHeight / 2.16 // 19.5:9 aspect ratio
            let f = phoneWidth / 240 // proportional factor for chrome details
            let cornerRadius: CGFloat = 40 * f
            let borderWidth: CGFloat = 8 * f
            let screenAreaWidth = phoneWidth - (borderWidth * 2)
            let screenAreaHeight = phoneHeight - (borderWidth * 2)
            // Fit (not fill) so the whole canvas is always visible — never crop.
            let fitScale = min(screenAreaWidth / canvasSize.width, screenAreaHeight / canvasSize.height)

            phoneBody(phoneWidth: phoneWidth, phoneHeight: phoneHeight,
                      cornerRadius: cornerRadius, borderWidth: borderWidth,
                      screenAreaWidth: screenAreaWidth, screenAreaHeight: screenAreaHeight,
                      fitScale: fitScale, f: f)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func phoneBody(phoneWidth: CGFloat, phoneHeight: CGFloat,
                           cornerRadius: CGFloat, borderWidth: CGFloat,
                           screenAreaWidth: CGFloat, screenAreaHeight: CGFloat,
                           fitScale: CGFloat, f: CGFloat) -> some View {
        ZStack {
            // Phone Bezel (Border)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "2c2c2e"),
                            Color(hex: "1c1c1e")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: phoneWidth, height: phoneHeight)
                .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

            // Screen Content Area — the full canvas, scaled to fit inside the
            // bezel rather than cropped.
            ZStack {
                content
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .scaleEffect(fitScale)
            }
            .frame(width: screenAreaWidth, height: screenAreaHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 6))

            // Dynamic Island
            VStack {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 110 * f, height: 32 * f)
                    .padding(.top, borderWidth + 8 * f)
                Spacer()
            }
            .frame(width: phoneWidth, height: phoneHeight)
            .allowsHitTesting(false)
        }
        .frame(width: phoneWidth, height: phoneHeight)
    }
}
