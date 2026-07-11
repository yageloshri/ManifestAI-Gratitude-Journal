// ElevateCinematicView.swift
// The "Elevate" cinematic moment: the user's raw entry animates to center,
// the owl mascot thinks while Gemini rewrites it, then flies off to reveal
// the elevated text in an editable, gold-tinted state.
//
// Driven entirely by an `ElevatePhase` value owned by the host screen
// (ParityJournalWriteView / ParityJournalEntryView). All transforms below
// are pure functions of that phase, so a single `withAnimation` wrapping a
// phase change at the call site animates the whole sequence — no ad-hoc
// state machines or onChange plumbing needed in here.

import SwiftUI

// MARK: - Phase

enum ElevatePhase: Equatable {
    case idle        // normal write/entry screen
    case centering   // entry text scales up + moves to center; chrome fades
    case thinking    // owl appears and thinks while Gemini is in flight
    case revealing   // owl flies off; elevated text reveals, gold-tinted
    case editing     // elevated text is editable; Save / Revert
    case failed      // apologetic owl exit; original text/chrome return
}

// MARK: - Owl thinking animation

/// The owl mascot thinking while the AI call is in flight. When the bundled
/// transparent "ElevateOwl" video is present it plays a fully-animated loop of
/// the owl walking side to side and pondering (a real character animation, not
/// a canned transform) with a thought-sparkle halo; otherwise it falls back to
/// the bobbing "ElevateOwlThinking"/"AnalysisOwl" still image so the flow keeps
/// working on any build.
struct OwlThinkingView: View {
    /// Height of the animated owl band; the video keeps its own aspect ratio.
    var size: CGFloat = 168
    /// Pause the video when the owl is not actively thinking.
    var isThinking: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bob = false

    private var hasVideo: Bool {
        Bundle.main.url(forResource: "ElevateOwl", withExtension: "mov") != nil
    }

    private var imageName: String {
        UIImage(named: "ElevateOwlThinking") != nil ? "ElevateOwlThinking" : "AnalysisOwl"
    }

    var body: some View {
        ZStack {
            ThoughtSparkles(active: !reduceMotion)
                .frame(width: size * 1.9, height: size * 0.9)
                .offset(y: -size * 0.72)

            if hasVideo {
                // A small owl that walks and ponders (real character animation).
                // Placed to pace just over the top of the centred entry text.
                // The video frame is ~square with the owl filling ~88% of its
                // height, so frame height ≈ target owl height / 0.88.
                LoopingVideoView(resourceName: "ElevateOwl", isPlaying: isThinking && !reduceMotion)
                    .frame(width: size * 1.16, height: size * 1.14)
                    .accessibilityLabel("Your owl guide is thinking")
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(reduceMotion ? 0 : (bob ? 2.5 : -2.5)))
                    .offset(y: reduceMotion ? 0 : (bob ? -8 : 8))
                    .scaleEffect(reduceMotion ? 1 : (bob ? 1.02 : 0.98))
                    .shadow(color: DesignTokens.Colors.primary.opacity(0.35), radius: 28, y: 14)
                    .onAppear {
                        guard !reduceMotion else { return }
                        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                            bob = true
                        }
                    }
                    .accessibilityLabel("Your owl guide is thinking")
            }
        }
    }
}

/// Ambient twinkling sparkles above the owl's head while it "thinks."
private struct ThoughtSparkles: View {
    var active: Bool

    private static let specs: [(dx: CGFloat, dy: CGFloat, delay: Double, scale: CGFloat)] = [
        (-38, 10, 0.00, 0.9),
        (12, -14, 0.35, 0.6),
        (44, 16, 0.60, 0.75),
        (-12, -32, 0.90, 0.55),
        (24, -40, 0.20, 0.8)
    ]

    @State private var twinkle = false

    var body: some View {
        ZStack {
            ForEach(Self.specs.indices, id: \.self) { i in
                let s = Self.specs[i]
                Image(systemName: "sparkle")
                    .font(.system(size: 14 * s.scale))
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .opacity(active ? (twinkle ? 0.9 : 0.15) : 0.3)
                    .scaleEffect(active && twinkle ? 1.15 : 0.85)
                    .offset(x: s.dx, y: s.dy)
                    .animation(
                        active
                            ? .easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(s.delay)
                            : .default,
                        value: twinkle
                    )
            }
        }
        .onAppear { if active { twinkle = true } }
        .accessibilityHidden(true)
    }
}

/// Quick trailing-sparkle burst that lingers where the owl launched from
/// when it flies off screen.
private struct FlyOffSparkleTrail: View {
    var active: Bool

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 8 + CGFloat(i) * 2))
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .opacity(active ? 0 : 0.9)
                    .scaleEffect(active ? 1.6 : 0.4)
                    .offset(x: CGFloat(i - 3) * 14, y: CGFloat(i % 3) * -10)
                    .animation(.easeOut(duration: 0.5).delay(Double(i) * 0.05), value: active)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Gold text reveal

/// Reveals `text` sentence-by-sentence (a practical stand-in for "per
/// line" on a single flowing paragraph), each fading + un-blurring with a
/// gold tint that settles into the normal text color.
struct GoldRevealText: View {
    let text: String
    var font: Font
    var revealed: Bool

    private var sentences: [String] {
        let parts = text
            .split(separator: ".")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard parts.count > 1 else { return [text] }
        return parts.enumerated().map { index, sentence in
            index == parts.count - 1 ? sentence : sentence + "."
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ForEach(Array(sentences.enumerated()), id: \.offset) { index, sentence in
                Text(sentence)
                    .font(font)
                    .foregroundStyle(revealed ? DesignTokens.Colors.textPrimary : DesignTokens.Colors.secondary)
                    .opacity(revealed ? 1 : 0)
                    .blur(radius: revealed ? 0 : 6)
                    .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.12), value: revealed)
            }
        }
    }
}

// MARK: - Cinematic overlay

/// Full-screen overlay that orchestrates the whole Elevate sequence. The
/// host screen owns `phase` and wraps every transition in `withAnimation`;
/// every transform here is a pure function of that phase so it animates
/// automatically as part of that transaction.
struct ElevateCinematicOverlay: View {
    var phase: ElevatePhase
    var originalText: String
    @Binding var elevatedText: String
    var errorMessage: String
    var sx: CGFloat
    var sy: CGFloat
    var screenSize: CGSize
    var onSave: (String) -> Void
    var onRevert: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(scrimOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(phase != .idle)

            // Step 1: the user's own words, enlarged and centered.
            Text(originalText)
                .font(DesignTokens.Typography.h4)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28 * sx)
                .frame(width: screenSize.width, alignment: .center)
                .scaleEffect(heroScale)
                .opacity(heroOpacity)
                .position(x: screenSize.width / 2, y: screenSize.height * heroYFactor)
                .allowsHitTesting(false)

            // Step 2/3: the owl thinks, then flies off.
            FlyOffSparkleTrail(active: owlFlyOff)
                .position(x: screenSize.width / 2, y: screenSize.height * owlYFactor)

            OwlThinkingView(size: 140, isThinking: phase == .thinking)
                .offset(x: owlOffsetX, y: owlOffsetY)
                .rotationEffect(.degrees(owlRotation))
                .scaleEffect(owlScale)
                .opacity(owlOpacity)
                .position(x: screenSize.width / 2, y: screenSize.height * owlYFactor)
                .allowsHitTesting(false)

            if phase == .failed {
                Text(errorMessage)
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40 * sx)
                    .position(x: screenSize.width / 2, y: screenSize.height * 0.68)
                    .transition(.opacity)
            }

            // Step 3/4: elevated text reveal → editable.
            GoldRevealText(
                text: elevatedText,
                font: DesignTokens.Typography.h4,
                revealed: phase == .revealing || phase == .editing
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28 * sx)
            .frame(width: screenSize.width, alignment: .center)
            .opacity(phase == .revealing || phase == .editing ? 1 : 0)
            .position(x: screenSize.width / 2, y: screenSize.height * (phase == .editing ? 0.28 : 0.38))
            .allowsHitTesting(false)

            if phase == .editing {
                editableCard
                    .position(x: screenSize.width / 2, y: screenSize.height * 0.62)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .accessibilityIdentifier("journalElevate.cinematic")
    }

    // MARK: - Derived transforms (pure functions of `phase`)

    private var scrimOpacity: Double { phase == .idle ? 0 : 0.62 }

    private var heroScale: CGFloat {
        if reduceMotion { return 1 }
        switch phase {
        case .idle, .failed: return 1
        case .centering: return 1.14
        case .thinking, .revealing, .editing: return 0.92
        }
    }

    private var heroYFactor: CGFloat {
        switch phase {
        case .idle, .failed: return 0.19
        // The user's entry settles to the screen centre while the owl ponders
        // just above where the text begins.
        case .centering, .thinking: return 0.44
        case .revealing, .editing: return 0.20
        }
    }

    private var heroOpacity: Double {
        switch phase {
        case .idle, .revealing, .editing: return 0
        case .centering, .thinking, .failed: return 1
        }
    }

    /// The owl paces just above where the centred entry text begins (the text
    /// sits at `heroYFactor` 0.44 while thinking), so it reads as hovering over
    /// the top of the text.
    private var owlYFactor: CGFloat { 0.29 }

    /// True once the owl has launched off screen (success path only).
    private var owlFlyOff: Bool { phase == .revealing || phase == .editing }

    private var owlOffsetX: CGFloat {
        guard owlFlyOff else { return 0 }
        return reduceMotion ? 0 : 230
    }

    private var owlOffsetY: CGFloat {
        if owlFlyOff { return reduceMotion ? 0 : -380 }
        return phase == .failed ? 24 : 0
    }

    private var owlRotation: Double {
        if owlFlyOff { return reduceMotion ? 0 : 46 }
        return phase == .failed ? -6 : 0
    }

    private var owlScale: CGFloat {
        guard owlFlyOff else { return 1 }
        return reduceMotion ? 1 : 0.2
    }

    private var owlOpacity: Double {
        switch phase {
        case .thinking, .failed: return 1
        case .idle, .centering, .revealing, .editing: return 0
        }
    }

    // MARK: - Editable step

    private var editableCard: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                .fill(DesignTokens.Colors.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                        .stroke(DesignTokens.Colors.secondary.opacity(0.5), lineWidth: 1)
                )
                .overlay(
                    TextEditor(text: $elevatedText)
                        .font(DesignTokens.Typography.h4)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .tint(DesignTokens.Colors.secondary)
                        .padding(12)
                        .accessibilityIdentifier("journalElevate.editor")
                )
                .frame(width: screenSize.width - 40, height: 200)

            HStack(spacing: 12) {
                Button(action: onRevert) {
                    Text("Revert to Original")
                        .font(DesignTokens.Typography.smallMedium)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                                .stroke(DesignTokens.Colors.glassBorder, lineWidth: 1)
                        )
                }
                .accessibilityIdentifier("journalElevate.revertButton")

                Button(action: { onSave(elevatedText) }) {
                    Text("Save")
                        .font(DesignTokens.Typography.bodyMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                                .fill(DesignTokens.Gradients.primary)
                        )
                }
                .accessibilityIdentifier("journalElevate.saveButton")
            }
            .frame(width: screenSize.width - 40)
        }
    }
}

// MARK: - Shared timing helper

/// Animation curve for a given phase transition, honoring Reduce Motion
/// with a simple crossfade instead of the springy/arcing motion.
enum ElevateMotion {
    static func spring(reduceMotion: Bool, response: Double = 0.5, damping: Double = 0.8) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: response, dampingFraction: damping)
    }

    static func flight(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.25) : .interpolatingSpring(stiffness: 90, damping: 14)
    }

    static func settle(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.35)
    }
}
