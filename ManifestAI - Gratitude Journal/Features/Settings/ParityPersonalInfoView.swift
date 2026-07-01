// ParityPersonalInfoView.swift
// Figma: "Personal Info" frame (330:1458), 393×852.
// All geometry from fidelity/specs/personalinfo.txt — do not eyeball values.

import SwiftUI

struct ParityPersonalInfoView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var name: String = "Ali Ahmad"
    var dob: String = "2nd June 2001"
    var avatarInitial: String = "A"
    var onBack: () -> Void = {}
    var onEdit: () -> Void = {}
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 330:1459: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 330:1462: back button 40×40 glass r12 (20,68)
                navSquare {
                    // Figma 330:1464: vuesax/linear/arrow-left, #685EF5 1.5pt
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DesignTokens.Colors.primary)
                }
                .contentShape(Rectangle())
                .onTapGesture { onBack() }
                .parityPosition(x: 20 * sx, y: 68 * sy)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Back")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("personalinfo.backButton")

                // Figma 330:1465: title Bitter Bold 18 #EBEBEB (84,74.5)
                Text("Personal Information")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 84 * sx, y: 74.5 * sy)

                // Figma 330:1742: edit button 40×40 glass r12 (327,68)
                navSquare {
                    // Figma 330:1744: vuesax/linear/edit-2, #685EF5 1.5pt
                    // PARITY-TODO: bake icon crop 330:1744
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DesignTokens.Colors.primary)
                }
                .contentShape(Rectangle())
                .onTapGesture { onEdit() }
                .parityPosition(x: 327 * sx, y: 68 * sy)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Edit")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("personalinfo.editButton")

                // Figma 330:1614: avatar 72×72 r50 #2C1E49, stroke #45326D 2pt (20,148)
                Circle()
                    .fill(DesignTokens.Colors.avatarBg)
                    .overlay(Circle().stroke(DesignTokens.Colors.avatarBorder, lineWidth: 2))
                    .overlay(
                        // Figma 330:1615: 'A' Bitter SemiBold 30 #FFFFFF@0.68
                        Text(avatarInitial)
                            .font(Font.custom("Bitter-SemiBold", size: 30))
                            .foregroundStyle(Color.white.opacity(0.68))
                    )
                    .frame(width: 72, height: 72)
                    .parityPosition(x: 20 * sx, y: 148 * sy)
                    .accessibilityIdentifier("personalinfo.avatar")

                // Figma 330:1727: Name field (read-only)
                // 330:1728: label 'Name' Poppins Medium 14 #9F9E9E (20,260)
                Text("Name")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.lightGrey)
                    .parityPosition(x: 20 * sx, y: 260 * sy)
                // 330:1735: value Poppins SemiBold 16 #EBEBEB (20,289)
                Text(name)
                    .font(DesignTokens.Typography.bodySemibold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 20 * sx, y: 289 * sy)

                // Figma 330:1738: DOB field (read-only)
                // 330:1739: label 'DOB' (20,343)
                Text("DOB")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.lightGrey)
                    .parityPosition(x: 20 * sx, y: 343 * sy)
                // 330:1740: value '2nd June 2001' (20,372)
                Text(dob)
                    .font(DesignTokens.Typography.bodySemibold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 20 * sx, y: 372 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("personalinfo.root")
    }

    /// 40×40 glass square (Figma Rectangle 39318, r12, 1pt fading #63507A border).
    private func navSquare<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.smallCard, compact: true)
            content()
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
    }
}

#Preview {
    ParityPersonalInfoView(parityMode: true)
}
