// ParityVisionUploadView.swift
// Figma: Vision Board "Upload Image" frame 326:13117 ("Name", Vision section)
// Spec: fidelity/specs/vision_upload.txt — all geometry from the dump, do not eyeball.

import SwiftUI

struct ParityVisionUploadView: View {
    /// Live mode: user-picked photo replaces the reference asset.
    var liveImage: UIImage? = nil
    var onBack: () -> Void = {}
    var onChangePhoto: () -> Void = {}
    var onDeletePhoto: () -> Void = {}
    var onUpload: () -> Void = {}
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                // Figma 326:13117: frame fill #16062A
                DesignTokens.Colors.background

                // Figma 326:13118: ellipse #4F31EC@0.29, layer blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Figma 326:13121: glass back button 40×40 r12 at (20,68)
                ParityVisionBackButton40(action: onBack)
                    .parityPosition(x: 20 * sx, y: 68 * sy)
                    .accessibilityIdentifier("visionUpload.back")

                // Figma 326:13124: 'Upload Image' Bitter-Bold 18, #EBEBEB (84,74.5,119,27)
                Text("Upload Image")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 84 * sx, y: 74.5 * sy)

                // Figma 326:13265: 'Rectangle 39330' (32,146,330,529)
                // fill #D9D9D9 + IMAGE(mode=FILL), stroke #685EF5@0.28 sw=11, r20
                photoRect(sx: sx, sy: sy)
                    .parityPosition(x: 32 * sx, y: 146 * sy)

                // Figma 326:13300: 'Frame 1000003716' buttons row at (40,621,314,46)
                changePhotoButton(sx: sx, sy: sy)
                    .parityPosition(x: 40 * sx, y: 621 * sy)
                deleteButton(sx: sx, sy: sy)
                    .parityPosition(x: 202 * sx, y: 621 * sy)

                // Figma 326:13224: 'Button Default' CTA (20,714,353,56), primary gradient r13
                uploadButton(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 714 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("visionUpload.root")
    }

    // MARK: - Photo (Figma 326:13265, 330×529 r20, 11px #685EF5@0.28 inner stroke)

    private func photoRect(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack {
            // base fill #D9D9D9 (visible until the image asset is baked)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "D9D9D9"))

            // NEEDS ASSET 1dc6caaf541b at VisionUploadPhoto (mode=FILL)
            if let liveImage {
                Image(uiImage: liveImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 330 * sx, height: 529 * sy)
                    .clipped()
            } else if UIImage(named: "VisionUploadPhoto") != nil {
                Image("VisionUploadPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 330 * sx, height: 529 * sy)
                    .clipped()
            } else {
                Color.clear
            }
        }
        .frame(width: 330 * sx, height: 529 * sy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            // Figma strokeAlign=OUTSIDE: 11px band outside the 330×529 box
            // (centerline path expanded 5.5, radius 20+5.5)
            RoundedRectangle(cornerRadius: 25.5)
                .stroke(DesignTokens.Colors.primary.opacity(0.28), lineWidth: 11)
                .padding(-5.5)
        )
        .accessibilityIdentifier("visionUpload.photo")
    }

    // MARK: - Change Photo (Figma 326:13270, 154×46 white r13)

    private func changePhotoButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onChangePhoto) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(Color.white)

                // Figma 326:13277: vuesax/linear/edit-2, 20×20 strokes #16062A (rel 12,13)
                // PARITY-TODO: bake icon crop 326:13277
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.background)
                    .frame(width: 20, height: 20)
                    .parityPosition(x: 12 * sx, y: 13 * sy)

                // Figma 326:13271: 'Change Photo' Poppins-Regular 14, #16062A (rel 42,12.5)
                Text("Change Photo")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.background)
                    .fixedSize()
                    .frame(width: 100 * sx, alignment: .top)
                    .parityPosition(x: 42 * sx, y: 12.5 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 154 * sx, height: 46 * sy, alignment: .topLeading)
        .accessibilityIdentifier("visionUpload.changePhoto")
    }

    // MARK: - Delete (Figma 326:13290, 152×46 white r13)
    // NOTE: Figma label literally reads 'Change Photo' on this button too (326:13292).

    private func deleteButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onDeletePhoto) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(Color.white)

                // Figma 326:13291: vuesax/linear/trash, 18×18 strokes #CC2123 (rel 12,14)
                // PARITY-TODO: bake icon crop 326:13291
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DesignTokens.Colors.error)
                    .frame(width: 18, height: 18)
                    .parityPosition(x: 12 * sx, y: 14 * sy)

                // Figma 326:13292: 'Change Photo' Poppins-Regular 14, #16062A (rel 40,12.5)
                Text("Change Photo")
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.background)
                    .fixedSize()
                    .frame(width: 100 * sx, alignment: .top)
                    .parityPosition(x: 40 * sx, y: 12.5 * sy)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 152 * sx, height: 46 * sy, alignment: .topLeading)
        .accessibilityIdentifier("visionUpload.delete")
    }

    // MARK: - Upload CTA (Figma 326:13224, 353×56 r13, primary gradient)

    private func uploadButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onUpload) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma I326:13224;12:4957: 'Upload Image' Poppins-Medium 16, white,
                // centered in (rel 16,16,321,24)
                Text("Upload Image")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 321 * sx, alignment: .top)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // Figma I326:13224;14:13869: chevron › vector 7.1×15.84, white 1.5
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
        .accessibilityIdentifier("visionUpload.uploadButton")
    }
}

#Preview {
    ParityVisionUploadView(parityMode: true)
}
