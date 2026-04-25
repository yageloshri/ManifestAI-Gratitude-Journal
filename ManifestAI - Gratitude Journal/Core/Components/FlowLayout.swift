import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    var alignment: Alignment

    init(spacing: CGFloat = 8, alignment: Alignment = .leading) {
        self.spacing = spacing
        self.alignment = alignment
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        if rows.isEmpty { return .zero }
        
        let height = rows.last?.maxY ?? 0
        let width = rows.map { $0.width }.max() ?? 0
        
        // Ensure we return valid finite numbers
        return CGSize(
            width: width.isFinite ? width : 0,
            height: height.isFinite ? height : 0
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Guard against invalid bounds
        guard bounds.width.isFinite, bounds.height.isFinite, !bounds.width.isNaN, !bounds.height.isNaN else { return }
        
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        for row in rows {
            let rowXOffset: CGFloat
            if alignment == .center {
                rowXOffset = (bounds.width - row.width) / 2
            } else if alignment == .trailing {
                rowXOffset = bounds.width - row.width
            } else {
                rowXOffset = 0
            }
            
            for element in row.elements {
                element.subview.place(
                    at: CGPoint(x: bounds.minX + element.x + rowXOffset, y: bounds.minY + element.y),
                    proposal: ProposedViewSize(width: element.width, height: element.height)
                )
            }
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        let maxWidth = proposal.width ?? .infinity
        
        var currentRow = Row(y: 0, height: 0, elements: [], width: 0)
        
        for subview in subviews {
            // Critical: Use .unspecified to get the ideal size of the content (e.g. Text)
            // preventing it from trying to fill the proposed width and causing layout loops.
            let size = subview.sizeThatFits(.unspecified)
            
            // Guard against NaN or infinite sizes from subviews
            let elementWidth = (size.width.isFinite && !size.width.isNaN) ? size.width : 0
            let elementHeight = (size.height.isFinite && !size.height.isNaN) ? size.height : 0
            
            if currentRow.width + elementWidth + spacing > maxWidth && !currentRow.elements.isEmpty {
                // Finish current row
                currentRow.height = currentRow.elements.map { $0.height }.max() ?? 0
                rows.append(currentRow)
                
                // Start new row
                currentRow = Row(y: currentRow.maxY + spacing, height: 0, elements: [], width: 0)
            }
            
            // Add to current row
            let x = currentRow.width == 0 ? 0 : currentRow.width + spacing
            currentRow.elements.append(Row.Element(subview: subview, x: x, y: currentRow.y, width: elementWidth, height: elementHeight))
            currentRow.width += (currentRow.width == 0 ? elementWidth : spacing + elementWidth)
        }
        
        if !currentRow.elements.isEmpty {
            currentRow.height = currentRow.elements.map { $0.height }.max() ?? 0
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var y: CGFloat
        var height: CGFloat
        var elements: [Element]
        var width: CGFloat
        
        var maxY: CGFloat { y + height }
        
        struct Element {
            var subview: LayoutSubviews.Element
            var x: CGFloat
            var y: CGFloat
            var width: CGFloat
            var height: CGFloat
        }
    }
}
