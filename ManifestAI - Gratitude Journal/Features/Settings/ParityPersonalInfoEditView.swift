// ParityPersonalInfoEditView.swift
// Figma: "Personal Info edit" frame (330:1645), 393×852.
// All geometry from fidelity/specs/personalinfo_edit.txt — do not eyeball values.

import SwiftUI

struct ParityPersonalInfoEditView: View {
    // mock-friendly inputs, defaults match the Figma frame exactly
    var name: String = "Ali Ahmad"
    var day: String = "23"
    var month: String = "September"
    var year: String = "2000"
    var avatarInitial: String = "A"
    var onBack: () -> Void = {}
    var onSave: () -> Void = {}
    /// Parity gallery: fixed mock data matching the Figma frame.
    var parityMode: Bool = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 330:1646: ellipse #4F31EC@0.29, blur 514
                EllipseGlowBackground(sx: sx, sy: sy)

                // Figma 330:1649: back button 40×40 glass r12 (20,68)
                ZStack {
                    Color.clear
                        .figmaGlassSurface(cornerRadius: DesignTokens.Radii.smallCard, compact: true)
                    // Figma 330:1651: vuesax/linear/arrow-left, #685EF5 1.5pt
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DesignTokens.Colors.primary)
                }
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
                .onTapGesture { onBack() }
                .parityPosition(x: 20 * sx, y: 68 * sy)
                .accessibilityIdentifier("personalinfoedit.backButton")

                // Figma 330:1652: title Bitter Bold 18 #EBEBEB (84,74.5)
                Text("Personal Information")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 84 * sx, y: 74.5 * sy)

                avatarWithEditBadge(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 148 * sy)

                nameField(sx: sx, sy: sy)

                dobFields(sx: sx, sy: sy)

                // Figma 330:1766: Save button (20,714) 353×56 r13 primary gradient
                saveButton(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 714 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("personalinfoedit.root")
    }

    // MARK: - Avatar + edit badge (Figma 330:1654)

    private func avatarWithEditBadge(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 330:1655: avatar 72×72 r50 #2C1E49, stroke #45326D 2pt
            Circle()
                .fill(DesignTokens.Colors.avatarBg)
                .overlay(Circle().stroke(DesignTokens.Colors.avatarBorder, lineWidth: 2))
                .overlay(
                    // Figma 330:1656: 'A' Bitter SemiBold 30 #FFFFFF@0.68
                    Text(avatarInitial)
                        .font(Font.custom("Bitter-SemiBold", size: 30))
                        .foregroundStyle(Color.white.opacity(0.68))
                )
                .frame(width: 72, height: 72)

            // Figma 330:1756: edit badge 24×24 glass circle (avatar-rel 48,50)
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.01))
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: DesignTokens.Colors.glassBorder.opacity(0.73), location: 0),
                                    .init(color: Color(hex: "332643").opacity(0), location: 1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    )
                    .background(.ultraThinMaterial, in: Circle())
                // Figma 330:1758: vuesax/linear/edit-2 12×12, #69AF52 0.75pt
                // PARITY-TODO: bake icon crop 330:1758
                Image(systemName: "pencil")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color(hex: "69AF52"))
            }
            .frame(width: 24, height: 24)
            .parityPosition(x: 48 * sx, y: 50 * sy)
            .accessibilityIdentifier("personalinfoedit.avatarEditBadge")
        }
        .frame(width: 72, height: 74 * sy, alignment: .topLeading)
        .accessibilityIdentifier("personalinfoedit.avatar")
    }

    // MARK: - Name field (Figma 330:1658)

    private func nameField(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma I330:1658;268:1515: label 'Name' Poppins Medium 14 #9F9E9E (20,262)
            Text("Name")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .parityPosition(x: 20 * sx, y: 262 * sy)

            // Figma I330:1658;268:1517: capsule field (20,292) 353×56, r150.7
            ZStack(alignment: .topLeading) {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 28, compact: true)

                // Figma I330:1658;268:1519: 'Ali Ahmad' Poppins Regular 14 #EBEBEB (field-rel 16,16)
                Text(name)
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // Figma I330:1658;268:1518: Arrow_Left_MD 14×12 #685EF5 2pt (field-rel 310,22)
                ArrowRightShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 14, height: 12)
                    .scaleEffect(x: -1) // left-pointing arrow
                    .parityPosition(x: 310 * sx, y: 22 * sy)
            }
            .frame(width: 353 * sx, height: 56 * sy, alignment: .topLeading)
            .parityPosition(x: 20 * sx, y: 292 * sy)
            .accessibilityIdentifier("personalinfoedit.nameField")
        }
    }

    // MARK: - Date / Month / Year (Figma 330:1659, Frame 221)

    private func dobFields(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Figma 330:1661: 'Date' label (20,380)
            Text("Date")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .parityPosition(x: 20 * sx, y: 380 * sy)
            // Figma 330:1663: pill (20,409) 80×56; 330:1664: '23' at (51,427)
            ZStack(alignment: .topLeading) {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 28, compact: true)
                Text(day)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 31 * sx, y: 18 * sy)
            }
            .frame(width: 80 * sx, height: 56 * sy, alignment: .topLeading)
            .parityPosition(x: 20 * sx, y: 409 * sy)
            .accessibilityIdentifier("personalinfoedit.dayField")

            // Figma 330:1666: 'Month' label (108,380)
            Text("Month")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .parityPosition(x: 108 * sx, y: 380 * sy)
            // Figma 330:1668: pill (108,409) 150×56; 330:1670 'September' (124,427);
            // 330:1671 chevron-down at (226.2,435) 11.67×5.83 #685EF5 2pt
            ZStack(alignment: .topLeading) {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 28, compact: true)
                Text(month)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 16 * sx, y: 18 * sy)
                ChevronDownShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 11.67, height: 5.83)
                    .parityPosition(x: 118.2 * sx, y: 26 * sy)
            }
            .frame(width: 150 * sx, height: 56 * sy, alignment: .topLeading)
            .parityPosition(x: 108 * sx, y: 409 * sy)
            .accessibilityIdentifier("personalinfoedit.monthField")

            // Figma 330:1674: 'Year' label (266,380)
            Text("Year")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .parityPosition(x: 266 * sx, y: 380 * sy)
            // Figma 330:1676: pill (266,409) 105×56; 330:1678 '2000' (283,427);
            // 330:1679 chevron-down at (342.2,435)
            ZStack(alignment: .topLeading) {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 28, compact: true)
                Text(year)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .parityPosition(x: 17 * sx, y: 18 * sy)
                ChevronDownShape()
                    .stroke(DesignTokens.Colors.primary,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 11.67, height: 5.83)
                    .parityPosition(x: 76.2 * sx, y: 26 * sy)
            }
            .frame(width: 105 * sx, height: 56 * sy, alignment: .topLeading)
            .parityPosition(x: 266 * sx, y: 409 * sy)
            .accessibilityIdentifier("personalinfoedit.yearField")
        }
    }

    // MARK: - Save button (Figma 330:1766)

    private func saveButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onSave) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)

                // Figma I330:1766;12:4957: 'Save Changes' Poppins Medium 16 white,
                // centered (btn-rel 16,16,321)
                Text("Save Changes")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(width: 321 * sx, alignment: .center)
                    .parityPosition(x: 16 * sx, y: 16 * sy)

                // Figma I330:1766;14:13869: vuesax arrow 7.1×15.84 white 1.5pt (btn-rel 306.9,20.1)
                VuesaxChevronShape()
                    .stroke(Color.white,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 7.098, height: 15.84)
                    .parityPosition(x: 306.9 * sx, y: 20.1 * sy)
            }
            .frame(width: 353 * sx, height: 56 * sy)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("personalinfoedit.saveButton")
    }
}

#Preview {
    ParityPersonalInfoEditView(parityMode: true)
}
