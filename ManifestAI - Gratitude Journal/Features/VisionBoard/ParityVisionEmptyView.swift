// ParityVisionEmptyView.swift
// Figma: Vision Board empty state frame 325:12675 ("Name", Vision section)
// Spec: fidelity/specs/vision_empty.txt — all geometry from the dump, do not eyeball.

import SwiftUI

struct ParityVisionEmptyView: View {
    var onCreateBoard: () -> Void = {}
    var onSelectTab: (FigmaTab) -> Void = { _ in }
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 325:12675: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 325:12676: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 325:12687: 'image-from-rawpixel-id-12672331-png 1'
                // (0,157,392,382), IMAGE mode=STRETCH op=0.2
                // NEEDS ASSET dc6e302d33a1 at VisionEmptyTexture
                // imageTransform [[0.78978,0,0.199276],[0,1.151654,-0.055181]]
                // → rendered = box/(a,d) = (496.34, 331.70), offset = (-tx,-ty)*rendered
                backgroundTexture(sx: sx, sy: sy)
                    .frame(width: 392 * sx, height: 382 * sy)
                    .parityPosition(x: 0, y: 157 * sy)

                // Figma 325:12690: 'Ellipse 4' shadow (167,413,66,5) #000000@0.64, blur 5
                Ellipse()
                    .fill(Color.black.opacity(0.64))
                    .frame(width: 66 * sx, height: 5 * sy)
                    .parityPosition(x: 167 * sx, y: 413 * sy)
                    .blur(radius: 5)

                // Figma 325:12691: 'ChatGPT Image Jan 27, 2026, 04_38_15 PM 1'
                // (85,228,222,199), IMAGE mode=STRETCH op=1
                // NEEDS ASSET 12a2cab9696d at VisionEmptyIllustration
                // imageTransform [[1,0,0],[0,0.5976,0.204077]]
                // → rendered = (222, 333.00), offset = (0, -67.96)
                illustration(sx: sx, sy: sy)
                    .frame(width: 222 * sx, height: 199 * sy)
                    .parityPosition(x: 85 * sx, y: 228 * sy)

                // Figma 325:12679: 'My Vision' Bitter-SemiBold 26, #EBEBEB (20,68,353,31)
                Text("My Vision")
                    .font(DesignTokens.Typography.h1)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 68 * sy)

                // Figma 325:12693: 'Your Vision Gallery' Bitter-Bold 18, centered (18,444,356,27)
                Text("Your Vision Gallery")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 356 * sx, alignment: .top)
                    .parityPosition(x: 18 * sx, y: 444 * sy)

                // Figma 325:12694: subtitle Poppins-Regular 14 lh21, #B9B9B9, centered (25,479,342,42)
                Text("Create your first Vision Board to start\nmanifesting your dreams.")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineSpacing(figmaLineSpacing(font: "Poppins-Regular", size: 14, lineHeight: 21))
                    .multilineTextAlignment(.center)
                    .frame(width: 342 * sx, alignment: .top)
                    .parityPosition(x: 25 * sx, y: (479 + 1.33) * sy)

                // Figma 325:12683: 'Button Default' (89,550,214,56), primary gradient r13
                createBoardButton(sx: sx, sy: sy)
                    .parityPosition(x: 89 * sx, y: 550 * sy)

                // Figma 325:12703: tab bar group at (0,774,393,78), Vision active
                FigmaTabBar(active: .vision, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("visionEmpty.root")
    }

    // MARK: - Images

    @ViewBuilder
    private func backgroundTexture(sx: CGFloat, sy: CGFloat) -> some View {
        if UIImage(named: "VisionEmptyTexture") != nil {
            // STRETCH window: rendered 496.34×331.70, offset (-98.91, +18.30)
            Image("VisionEmptyTexture")
                .resizable()
                .frame(width: 496.34 * sx, height: 331.70 * sy)
                .parityPosition(x: -98.91 * sx, y: 18.30 * sy)
                .frame(width: 392 * sx, height: 382 * sy, alignment: .topLeading)
                .clipped()
                .opacity(0.2)
        } else {
            Color.clear                      // NEEDS ASSET dc6e302d33a1
        }
    }

    @ViewBuilder
    private func illustration(sx: CGFloat, sy: CGFloat) -> some View {
        if UIImage(named: "VisionEmptyIllustration") != nil {
            // STRETCH window: rendered 222×333.00, offset (0, -67.96)
            Image("VisionEmptyIllustration")
                .resizable()
                .frame(width: 222 * sx, height: 333.00 * sy)
                .parityPosition(x: 0, y: -67.96 * sy)
                .frame(width: 222 * sx, height: 199 * sy, alignment: .topLeading)
                .clipped()
        } else {
            Color.clear                      // NEEDS ASSET 12a2cab9696d
        }
    }

    // MARK: - Create New Board button (Figma 325:12683, 214×56 r13)

    private func createBoardButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onCreateBoard) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma 325:12684: vuesax/linear/add — plus strokes #FFFFFF 1.5
                // (button-rel: lines at (31.5,28)h12 and (37.5,22)v12)
                ParityVisionPlusShape()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .frame(width: 12, height: 12)
                    .parityPosition(x: 31.5 * sx, y: 22 * sy)

                // Figma 325:12685: 'Create New Board' Poppins-Medium 14, white (rel 59.5,17.5)
                Text("Create New Board")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(.white)
                    .frame(width: 129 * sx, alignment: .top)
                    .parityPosition(x: 59.5 * sx, y: 17.5 * sy)
            }
        }
        .frame(width: 214 * sx, height: 56 * sy, alignment: .topLeading)
        .accessibilityIdentifier("visionEmpty.createButton")
    }
}

/// + icon (12×12), Figma vuesax/linear/add strokes I325:12684;324:8054/8055.
private struct ParityVisionPlusShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

/// Figma line height − rendered UIFont line height, for .lineSpacing().
private func figmaLineSpacing(font name: String, size: CGFloat, lineHeight: CGFloat) -> CGFloat {
    guard let f = UIFont(name: name, size: size) else { return 0 }
    return max(0, lineHeight - f.lineHeight)
}

#Preview {
    ParityVisionEmptyView(parityMode: true)
}
