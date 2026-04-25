// CommitmentStepView.swift
// Onboarding step 6 — "A promise to yourself"
// Figma node: 282:570 — pixel-perfect from Figma inspect

import SwiftUI

struct CommitmentStepView: View {
    let onComplete: () -> Void
    let onBack: () -> Void

    // MARK: - Hold-to-commit state

    @State private var isHolding = false
    @State private var holdProgress: CGFloat = 0
    @State private var holdCompleted = false
    @State private var holdTimer: Timer?

    /// Total hold duration in seconds
    private let holdDuration: TimeInterval = 2.0
    /// Timer tick interval
    private let tickInterval: TimeInterval = 0.02

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / 393.0

            ZStack {
                // -- 1. Background: solid #16062A --
                Theme.Colors.background

                // -- 2. Purple glow ellipse --
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0x4F/255.0, green: 0x31/255.0, blue: 0xEC/255.0).opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 289 * s
                        )
                    )
                    .frame(width: 578.67 * s, height: 677.5 * s)
                    .position(x: (0 + 578.67 / 2) * s, y: (12 + 677.5 / 2) * s)

                // -- 3. Stepper --
                // Figma: (20, 76), w=353, h=6, step 6 of 6 (ALL active)
                HStack(spacing: 2 * s) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                            .fill(Theme.Colors.primary)
                            .frame(height: Theme.Sizes.stepperHeight * s)
                    }
                }
                .frame(width: 353 * s)
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (76 + 3) * s
                )

                // -- 4. Glass card --
                // Figma: (20, 135), 353x564, cornerRadius 16, border #63507A 2px
                ZStack(alignment: .top) {
                    // Stars background at top of card
                    Image("StarsBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 353 * s, height: 329 * s)
                        .clipped()
                        .opacity(0.6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    VStack(spacing: 0) {
                        // Owl illustration: 195x195, centered, top=18
                        Image("OwlIllustration")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 195 * s, height: 195 * s)
                            .padding(.top, 18 * s)

                        // "A promise to yourself" -- serif semibold 26px, #FCD471
                        // y~234 inside card -> after owl (18+195=213), gap ~ 21
                        Text("A promise to yourself")
                            .font(.system(size: 26 * s, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.Colors.secondary)
                            .padding(.top, 21 * s)

                        // Bullet points -- sans medium 16px, #EBEBEB
                        VStack(alignment: .leading, spacing: 10 * s) {
                            bulletRow("Change requires consistency.", s: s)
                            bulletRow("Can you commit to investing 3 minutes a day in yourself?", s: s)
                        }
                        .frame(width: 307 * s, alignment: .leading)
                        .padding(.top, 16 * s)

                        Spacer()

                        // Fingerprint icon container: 88x88, glassmorphic, r=25, centered
                        // y~413 inside card
                        ZStack {
                            // Glass background
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                                .opacity(0.01)
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.05))
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Theme.Colors.glassBorder, lineWidth: 2)

                            // Circular progress ring during hold
                            if isHolding || holdCompleted {
                                Circle()
                                    .trim(from: 0, to: holdProgress)
                                    .stroke(
                                        Theme.Colors.primary,
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .frame(width: 70 * s, height: 70 * s)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: tickInterval), value: holdProgress)
                            }

                            // Touch ID SF Symbol: 28x28, tinted #EBEBEB
                            Image(systemName: "touchid")
                                .font(.system(size: 28 * s))
                                .foregroundStyle(
                                    holdCompleted
                                        ? Theme.Colors.secondary
                                        : Theme.Colors.text
                                )
                        }
                        .frame(width: 88 * s, height: 88 * s)
                        .contentShape(Rectangle())
                        .gesture(holdGesture)
                        .scaleEffect(isHolding ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isHolding)

                        // "Touch and hold to commit" -- sans regular 14px, #B9B9B9
                        Text("Touch and hold to commit")
                            .font(.system(size: 14 * s, weight: .regular))
                            .foregroundStyle(Theme.Colors.labels)
                            .padding(.top, 10 * s)

                        Spacer()
                            .frame(height: 20 * s)
                    }
                }
                .frame(width: 353 * s, height: 564 * s)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .fill(.ultraThinMaterial)
                        .opacity(0.01)
                )
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .fill(Color.white.opacity(0.01))
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                )
                .shadow(color: Theme.Colors.glassShadowBlue.opacity(0.5), radius: 35, x: 0, y: 24)
                .shadow(color: Theme.Colors.glassShadowMid.opacity(0.3), radius: 11, x: 0, y: 5)
                .shadow(color: Theme.Colors.glassShadowDeep.opacity(0.8), radius: 25, x: 0, y: 1)
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (135 + 564.0 / 2) * s
                )

                // -- 5. Bottom bar --
                // Figma: (20, 737)
                // Back button: 56x56, cornerRadius 12, border #63507A 2px
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14 * s, weight: .medium))
                        .foregroundStyle(Theme.Colors.text)
                        .frame(
                            width: Theme.Sizes.backButtonSize * s,
                            height: Theme.Sizes.backButtonSize * s
                        )
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.backButton)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Radius.backButton)
                                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                                )
                        )
                        .shadow(
                            color: Theme.Colors.glassShadowBlue.opacity(0.3),
                            radius: 15 * s, y: 10 * s
                        )
                }
                .position(
                    x: (20 + 28) * s,
                    y: (737 + 28) * s
                )

                // Continue / Complete Setup button (accessibility fallback)
                Button {
                    triggerCompletion()
                } label: {
                    Text("Complete Setup")
                        .font(.system(size: 16 * s, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.Sizes.buttonHeight * s)
                        .background(
                            LinearGradient(
                                stops: [
                                    .init(color: Theme.Colors.buttonGradientStart, location: 0.31858),
                                    .init(color: Theme.Colors.buttonGradientEnd, location: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                }
                .frame(width: (355 - 56 - 16) * s)
                .position(
                    x: (20 + 56 + 16 + (355.0 - 56 - 16) / 2) * s,
                    y: (737 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }

    // MARK: - Bullet row helper

    private func bulletRow(_ text: String, s: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8 * s) {
            Circle()
                .fill(Theme.Colors.text)
                .frame(width: 5 * s, height: 5 * s)
                .padding(.top, 8 * s)

            Text(text)
                .font(.system(size: 16 * s, weight: .medium))
                .foregroundStyle(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Hold-to-commit gesture

    private var holdGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.01)
            .onChanged { _ in
                startHold()
            }
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { _ in
                cancelHold()
            }
    }

    private func startHold() {
        guard !holdCompleted else { return }
        isHolding = true
        holdProgress = 0

        holdTimer?.invalidate()
        holdTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
            holdProgress += CGFloat(tickInterval / holdDuration)

            if holdProgress >= 1.0 {
                holdProgress = 1.0
                timer.invalidate()
                holdTimer = nil
                holdCompleted = true
                isHolding = false
                triggerCompletion()
            }
        }
    }

    private func cancelHold() {
        guard !holdCompleted else { return }
        holdTimer?.invalidate()
        holdTimer = nil
        isHolding = false

        withAnimation(.easeOut(duration: 0.3)) {
            holdProgress = 0
        }
    }

    private func triggerCompletion() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        onComplete()
    }
}

// MARK: - Preview

#Preview {
    CommitmentStepView(
        onComplete: {},
        onBack: {}
    )
}
