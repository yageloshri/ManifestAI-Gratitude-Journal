// ParityVisionBoardsView.swift
// Vision tab home when saved boards exist. There is no Figma frame for this
// state — the layout reuses the app's verified design language (background,
// glow, tokens, glass surfaces, FigmaTabBar) and the empty-state geometry.

import SwiftUI

struct ParityVisionBoardsView: View {
    var boards: [VisionBoardEntity] = []
    var onCreateBoard: () -> Void = {}
    var onDeleteBoard: (VisionBoardEntity) -> Void = { _ in }
    var onEditBoard: (VisionBoardEntity) -> Void = { _ in }
    var onSelectTab: (FigmaTab) -> Void = { _ in }

    @State private var viewing: VisionBoardEntity?
    @State private var savedToast: String?          // "Saved!" / failure text
    @State private var albumSaver = BoardAlbumSaver()

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.29)

                // Title — same slot as the other vision screens (74.5pt)
                Text("Vision Board")
                    .font(DesignTokens.Typography.h4)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .center)
                    .parityPosition(x: 20 * sx, y: 74.5 * sy)

                Text("\(boards.count) saved \(boards.count == 1 ? "board" : "boards")")
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 353 * sx, alignment: .center)
                    .parityPosition(x: 20 * sx, y: 104 * sy)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 13 * sx),
                                  GridItem(.flexible(), spacing: 0)],
                        spacing: 13 * sy
                    ) {
                        ForEach(boards, id: \.id) { board in
                            boardCard(board, sx: sx, sy: sy)
                        }
                    }
                    .padding(.bottom, 16 * sy)
                }
                .frame(width: 353 * sx, height: 555 * sy, alignment: .top)
                .parityPosition(x: 20 * sx, y: 134 * sy)

                createButton(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 702 * sy)

                FigmaTabBar(active: .vision, onSelect: onSelectTab, sx: sx, sy: sy)
                    .parityPosition(x: 0, y: 774 * sy)

                if let board = viewing {
                    // explicit frame: the oversized glow ellipse inflates the
                    // ZStack union, which would shift a center-aligned child
                    boardViewer(board, sx: sx, sy: sy)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("visionBoards.root")
    }

    // MARK: - Board card (phone-screen aspect preview on a glass surface)

    private func boardCard(_ board: VisionBoardEntity, sx: CGFloat, sy: CGFloat) -> some View {
        ZStack {
            Color.clear
                .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: true)

            if let data = board.previewImageData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 28))
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
            }
        }
        .frame(width: 170 * sx, height: 270 * sy)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
        .overlay(alignment: .bottomLeading) {
            if let tag = board.tags.first {
                Text(tag)
                    .font(DesignTokens.Typography.label)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.45), in: Capsule())
                    .padding(8)
            }
        }
        .overlay(alignment: .topTrailing) {
            // Small edit affordance directly on the card, in addition to the
            // context menu and the fullscreen viewer's Edit action (Task 1).
            Button {
                onEditBoard(board)
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(7)
                    .background(Color.black.opacity(0.45), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
            .accessibilityIdentifier("visionBoards.card.edit")
        }
        .contentShape(Rectangle())
        .onTapGesture { viewing = board }
        .contextMenu {
            Button {
                onEditBoard(board)
            } label: {
                Label("Edit Board", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDeleteBoard(board)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityIdentifier("visionBoards.card")
    }

    // MARK: - Create CTA (353×56 r13 primary gradient, app-standard)

    private func createButton(sx: CGFloat, sy: CGFloat) -> some View {
        Button(action: onCreateBoard) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.primary)
                Text("Create New Board")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 353 * sx, height: 56 * sy)
        .accessibilityIdentifier("visionBoards.create")
    }

    // MARK: - Full-screen viewer (save to Photos / delete / close)

    private func boardViewer(_ board: VisionBoardEntity, sx: CGFloat, sy: CGFloat) -> some View {
        ZStack {
            Color.black.opacity(0.85)
                .contentShape(Rectangle())
                .onTapGesture { viewing = nil }

            VStack(spacing: 16 * sy) {
                if let data = board.previewImageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300 * sx, maxHeight: 600 * sy)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radii.card))
                }

                HStack(spacing: 8 * sx) {
                    viewerAction("Edit", system: "pencil") {
                        viewing = nil
                        onEditBoard(board)
                    }
                    viewerAction(savedToast ?? "Save to Photos",
                                 system: "square.and.arrow.down") {
                        if let data = board.previewImageData, let img = UIImage(data: data) {
                            // completion target — don't claim success blindly
                            albumSaver.onDone = { error in
                                savedToast = error == nil ? "Saved!" : "Check permission"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    savedToast = nil
                                }
                            }
                            UIImageWriteToSavedPhotosAlbum(
                                img, albumSaver,
                                #selector(BoardAlbumSaver.image(_:didFinishSavingWithError:contextInfo:)),
                                nil)
                        }
                    }
                    viewerAction("Delete", system: "trash", tint: DesignTokens.Colors.error) {
                        viewing = nil
                        onDeleteBoard(board)
                    }
                    viewerAction("Close", system: "xmark") { viewing = nil }
                }
            }
        }
        .accessibilityIdentifier("visionBoards.viewer")
    }

    /// Completion target for UIImageWriteToSavedPhotosAlbum (held in @State
    /// so it outlives the call).
    final class BoardAlbumSaver: NSObject {
        var onDone: ((Error?) -> Void)?
        @objc func image(_ image: UIImage,
                         didFinishSavingWithError error: Error?,
                         contextInfo: UnsafeRawPointer) {
            DispatchQueue.main.async { self.onDone?(error) }
        }
    }

    private func viewerAction(_ title: String, system: String,
                              tint: Color = DesignTokens.Colors.textPrimary,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: system).font(.system(size: 18))
                Text(title).font(DesignTokens.Typography.label)
            }
            .foregroundStyle(tint)
            .frame(width: 78, height: 56)
            .background(Color.white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: DesignTokens.Radii.smallCard))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ParityVisionBoardsView()
}
