// Parity369IntentionsView.swift
// "My Intentions" management sheet — opened from the ritual screen's
// affirmation chip. Lists every saved 369 intention (IntentionStore), marks
// the active one with a gold indicator, and lets the user switch active
// (tap), delete (swipe), edit, or add a new one. Styling follows the app's
// dark mystical glass language (DesignTokens + the shared glow/texture).

import SwiftUI

struct Parity369IntentionsView: View {
    @ObservedObject private var store = IntentionStore.shared

    /// Tap a row → make it the active intention.
    var onSetActive: (UUID) -> Void = { _ in }
    /// Edit → open the Set Intention editor pre-filled with this intention.
    var onEdit: (Intention369) -> Void = { _ in }
    /// + New Intention → open the Set Intention editor empty.
    var onNew: () -> Void = {}
    /// Done / dismiss.
    var onClose: () -> Void = {}

    var body: some View {
        NavigationStack {
            ZStack {
                mysticalBackground

                if store.intentions.isEmpty {
                    emptyState
                } else {
                    intentionList
                }

                newIntentionButton
            }
            .navigationTitle(Text("My Intentions"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onClose() } label: {
                        Text("Done")
                            .font(DesignTokens.Typography.bodyMedium)
                            .foregroundStyle(DesignTokens.Colors.primary)
                    }
                }
            }
            .toolbarBackground(DesignTokens.Colors.background, for: .navigationBar)
        }
        .presentationBackground(DesignTokens.Colors.background)
    }

    // MARK: - Background (shared mystical glow + cosmic texture)

    private var mysticalBackground: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852
            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background
                EllipseGlowBackground(sx: sx, sy: sy)
                Image("CosmicTexture")
                    .resizable()
                    .frame(width: 392 * sx, height: 382 * sy)
                    .opacity(0.2)
                    .parityPosition(x: 0, y: 145 * sy)
                    .accessibilityHidden(true)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - List

    private var intentionList: some View {
        List {
            ForEach(store.intentions) { intention in
                intentionRow(intention)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            store.delete(intention.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            onEdit(intention)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(DesignTokens.Colors.primary)
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            // Keep the last row clear of the floating New button.
            Color.clear.frame(height: 84)
        }
    }

    private func intentionRow(_ intention: Intention369) -> some View {
        let isActive = intention.id == store.activeId
        return Button {
            onSetActive(intention.id)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Gold indicator marks the active intention.
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isActive
                                     ? AnyShapeStyle(DesignTokens.Gradients.golden)
                                     : AnyShapeStyle(DesignTokens.Colors.textSecondary.opacity(0.5)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(intention.text)
                        .font(DesignTokens.Typography.smallMedium)
                        .foregroundStyle(isActive
                                         ? DesignTokens.Colors.secondary
                                         : DesignTokens.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .minimumScaleFactor(0.8)
                    if isActive {
                        Text("Active")
                            .font(DesignTokens.Typography.label)
                            .foregroundStyle(DesignTokens.Colors.secondary.opacity(0.8))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.clear.figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .stroke(DesignTokens.Colors.secondary.opacity(isActive ? 0.6 : 0),
                            lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(DesignTokens.Colors.secondary)
            Text("No intentions yet")
                .font(DesignTokens.Typography.h4)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
            Text("Add what you want to manifest to begin.")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - New Intention CTA

    private var newIntentionButton: some View {
        VStack {
            Spacer()
            Button {
                onNew()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("New Intention")
                        .font(DesignTokens.Typography.bodyMedium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                        .fill(DesignTokens.Gradients.primary)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    Parity369IntentionsView()
}
