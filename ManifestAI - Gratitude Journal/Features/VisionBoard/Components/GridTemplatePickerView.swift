import SwiftUI

/// Horizontal grid-template picker shown above the editor canvas (Task 2).
/// Offers 6 fixed layouts — 2×2, 3×3, 2×3, "1 big + 2 small", "1 big top +
/// 3 bottom", and a mixed-size mosaic — each shown as a mini rounded-rect
/// schematic. Tapping one re-flows existing photos into the new cells via
/// `VisionBoardViewModel.selectTemplate(_:)`.
struct GridTemplatePickerView: View {
    @ObservedObject var viewModel: VisionBoardViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(GridLayoutTemplate.pickerTemplates, id: \.self) { template in
                    templateButton(template)
                }
            }
            .padding(.horizontal, 24)
        }
        .accessibilityIdentifier("visionEditor.templatePicker")
    }

    private func templateButton(_ template: GridLayoutTemplate) -> some View {
        let isSelected = viewModel.currentLayout == template
        return Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                viewModel.selectTemplate(template)
            }
        } label: {
            VStack(spacing: 5) {
                GridTemplateSchematic(template: template)
                    .padding(8)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(isSelected ? 0.16 : 0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? DesignTokens.Colors.secondary : Color.white.opacity(0.15),
                                    lineWidth: isSelected ? 2 : 1)
                    )

                Text(template.displayName)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("visionEditor.template.\(template.rawValue)")
    }
}

/// Mini schematic of a template's cells, drawn straight from the same
/// `normalizedCells` geometry the real canvas and the export renderer use —
/// so the icon is always an accurate preview of what selecting it produces.
struct GridTemplateSchematic: View {
    let template: GridLayoutTemplate

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(template.normalizedCells.enumerated()), id: \.offset) { _, rect in
                    SchematicCell(rect: rect, size: geo.size)
                }
            }
        }
    }
}

/// One mini cell of the schematic — split out so the compiler type-checks
/// the geometry math as a plain function instead of one giant expression.
private struct SchematicCell: View {
    let rect: CGRect
    let size: CGSize

    var body: some View {
        let cellWidth: CGFloat = max(2, rect.width * size.width - 2)
        let cellHeight: CGFloat = max(2, rect.height * size.height - 2)
        let centerX: CGFloat = rect.midX * size.width
        let centerY: CGFloat = rect.midY * size.height

        return RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Color.white.opacity(0.85))
            .frame(width: cellWidth, height: cellHeight)
            .position(x: centerX, y: centerY)
    }
}
