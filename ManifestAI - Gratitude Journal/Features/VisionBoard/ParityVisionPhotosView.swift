// ParityVisionPhotosView.swift
// Figma: Vision Board "find your photos" frame 327:1492 ("Name", Vision section)
// Spec: fidelity/specs/vision_photos.txt — all geometry from the dump, do not eyeball.

import SwiftUI

struct ParityVisionPhotosView: View {
    // Defaults match the Figma frame text exactly.
    var promptTitle: String = "Find a photo that represents the partnership you crave. Is it a wedding? A quiet moment at home? Holding hands?"
    var promptSubtitle: String = "Take a moment to find photo that match this energy"
    var onBack: () -> Void = {}
    var onContinue: () -> Void = {}
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    /// Diagonal collage (Figma 327:2363): parent frame is ROTATED -0.0896 rad
    /// (-5.1345°); the spec dump's 156.5×140.6 boxes are AABBs of the rotated
    /// tiles. True tile = 145.665×128.035 r9.398; x/y below are AABB top-left
    /// (tiles are placed by AABB center, then rotated).
    private struct CollageTile {
        let nodeId: String
        let ref: String      // Figma image fill ref hash
        let x: CGFloat
        let y: CGFloat
    }

    private let tiles: [CollageTile] = [
        // Row 327:2364
        .init(nodeId: "327:2366", ref: "3f5373a94435", x: -67,     y: 84.222),
        .init(nodeId: "327:2369", ref: "6dc0e193f46d", x: 89.781,  y: 70.134),
        .init(nodeId: "327:2372", ref: "dc12cee21254", x: 246.563, y: 56.047),
        // Row 327:2409
        .init(nodeId: "327:2410", ref: "8fdda723006f", x: -54.069, y: 228.133),
        .init(nodeId: "327:2411", ref: "0978cbdac398", x: 102.712, y: 214.045),
        .init(nodeId: "327:2412", ref: "427b0dcab6e2", x: 259.494, y: 199.958),
        // Row 327:2404
        .init(nodeId: "327:2405", ref: "3f5373a94435", x: -41.138, y: 372.044),
        .init(nodeId: "327:2406", ref: "1d28ca776737", x: 115.643, y: 357.956),
        .init(nodeId: "327:2407", ref: "6e384179a1d7", x: 272.425, y: 343.869),
        // Row 327:2399
        .init(nodeId: "327:2400", ref: "3f5373a94435", x: -28.207, y: 515.955),
        .init(nodeId: "327:2401", ref: "1d28ca776737", x: 128.574, y: 501.868),
        .init(nodeId: "327:2402", ref: "6e384179a1d7", x: 285.356, y: 487.780)
    ]

    /// AABB of each rotated tile (from the spec dump).
    private let tileAABB = CGSize(width: 156.540, height: 140.567)
    /// Un-rotated tile size (solved from AABB + rotation).
    private let tileSize = CGSize(width: 145.665, height: 128.035)
    /// Figma rotation -0.0896 rad → tilts up to the right (CCW on screen).
    private let tileRotation: Angle = .degrees(-5.1345)

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 327:1492: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 327:1493: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 327:2363: collage tiles (145.665×128.035 r9.398,
                // rotated -5.1345°, placed by AABB center)
                ForEach(tiles, id: \.nodeId) { tile in
                    collageTile(tile, sx: sx, sy: sy)
                        .rotationEffect(tileRotation)
                        .position(x: (tile.x + tileAABB.width / 2) * sx,
                                  y: (tile.y + tileAABB.height / 2) * sy)
                }

                // Figma 327:2413: 'Rectangle 39328' full-frame veil
                // GRADIENT_LINEAR #49179B@0 (top) → #190835 at 55.6%, solid below
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "49179B").opacity(0), location: 0),
                        .init(color: Color(hex: "190835"), location: 0.556),
                        .init(color: Color(hex: "190835"), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(width: 393 * sx, height: 852 * sy)

                // Figma 327:2424: glass back button 40×40 r12 at (20,68)
                ParityVisionBackButton40(action: onBack)
                    .parityPosition(x: 20 * sx, y: 68 * sy)
                    .accessibilityIdentifier("visionPhotos.back")

                // Figma 326:13114: 'Rectangle 39329' gold pill (20,478,41,9) r30
                RoundedRectangle(cornerRadius: DesignTokens.Radii.pill)
                    .fill(DesignTokens.Gradients.golden)
                    .frame(width: 41 * sx, height: 9 * sy)
                    .parityPosition(x: 20 * sx, y: 478 * sy)

                // Figma 326:13106: prompt Bitter-Bold 18 lh27, #EBEBEB (20,499,270,108)
                Text(promptTitle)
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .lineSpacing(figmaLineSpacing(font: "Bitter-Bold", size: 18, lineHeight: 27))
                    .frame(width: 270 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: (499 + 3.33) * sy)   // measured: app 6px high

                // Figma 326:13107: subtitle Poppins-Regular 14 lh21, #B9B9B9 (20,625,270,42)
                Text(promptSubtitle)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineSpacing(figmaLineSpacing(font: "Poppins-Regular", size: 14, lineHeight: 21))
                    .frame(width: 270 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: (625 + 0.33) * sy)   // measured: app 3px low

                // Figma 326:13109: 'Button Default' CTA (20,714,353,56), primary gradient r13
                continueButton(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 714 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("visionPhotos.root")
    }

    // MARK: - Collage tile (145.665×128.035, r9.398, mode=FILL)
    // NEEDS ASSET VisionPhotos_<ref> for every ref hash (see tiles list).

    @ViewBuilder
    private func collageTile(_ tile: CollageTile, sx: CGFloat, sy: CGFloat) -> some View {
        let assetName = "VisionPhotos_\(tile.ref)"
        Group {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: tileSize.width * sx, height: tileSize.height * sy)
                    .clipped()
            } else {
                Color.clear // NEEDS ASSET <tile.ref>
            }
        }
        .frame(width: tileSize.width * sx, height: tileSize.height * sy)
        .clipShape(RoundedRectangle(cornerRadius: 9.397782325744629))
    }

    // MARK: - CTA (Figma 326:13109, 353×56 r13, primary gradient)

    private func continueButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onContinue) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma I326:13109;12:4957: 'I Have My Photos Ready' Poppins-Medium 16,
                // white, centered in (rel 16,16,321,24)
                Text("I Have My Photos Ready")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 321 * sx, alignment: .top)
                    .parityPosition(x: 16 * sx, y: (16 + 1.33) * sy)    // measured: app 4px high

                // Figma I326:13109;14:13869: chevron › vector 7.1×15.84, white 1.5
                // (rel 306.9,20.1)
                ChevronRightSmallShape()
                    .stroke(Color.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.098, height: 15.84)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 353 * sx, height: 56 * sy, alignment: .topLeading)
        .accessibilityIdentifier("visionPhotos.continueButton")
    }
}

/// Figma line height − rendered UIFont line height, for .lineSpacing().
private func figmaLineSpacing(font name: String, size: CGFloat, lineHeight: CGFloat) -> CGFloat {
    guard let f = UIFont(name: name, size: size) else { return 0 }
    return max(0, lineHeight - f.lineHeight)
}

#Preview {
    ParityVisionPhotosView(parityMode: true)
}
