// AnalyzingStepView.swift
// 7-second "thinking" interlude shown right after the birth-date step,
// before the Analysis Complete screen. Sells the numerology computation
// with a progress ring, pulsing owl and cycling status messages.

import SwiftUI

struct AnalyzingStepView: View {
    let birthDate: Date
    let onFinished: () -> Void
    /// Parity gallery: frozen mid-state, no timers.
    var parityMode: Bool = false

    @State private var ringProgress: CGFloat = 0
    @State private var messageIndex = 0
    @State private var pulse = false
    @State private var hasFinished = false

    private static let totalDuration: Double = 7

    private let messages = [
        "Reading your birth date…",
        "Calculating your life path number…",
        "Mapping your personal year cycle…",
        "Aligning your transformation profile…"
    ]

    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: birthDate)
    }

    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()

            EllipseGlowBackground()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // ambient gold halo behind the ring
                    Circle()
                        .fill(DesignTokens.Colors.secondary.opacity(0.18))
                        .frame(width: 220, height: 220)
                        .blur(radius: 60)

                    Circle()
                        .stroke(Color.white.opacity(0.10), lineWidth: 5)
                        .frame(width: 188, height: 188)

                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            DesignTokens.Gradients.golden,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 188, height: 188)

                    Image("AnalysisOwl")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 132, height: 132)
                        .scaleEffect(pulse ? 1.06 : 0.96)
                        .animation(
                            .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: pulse
                        )
                }
                .padding(.bottom, 44)

                Text("Analyzing your numbers")
                    .font(DesignTokens.Typography.h1)
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 10)

                Text(formattedBirthDate)
                    .font(DesignTokens.Typography.bodySemibold18)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .padding(.bottom, 28)

                Text(messages[messageIndex])
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .id(messageIndex)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut(duration: 0.35), value: messageIndex)

                Spacer()
                Spacer()
            }
        }
        .accessibilityIdentifier("analyzing.root")
        .onAppear {
            guard !parityMode else {
                ringProgress = 0.6
                return
            }
            pulse = true
            withAnimation(.linear(duration: Self.totalDuration)) {
                ringProgress = 1
            }
        }
        .task {
            guard !parityMode else { return }
            let stepDuration = Self.totalDuration / Double(messages.count)
            for index in messages.indices.dropFirst() {
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                messageIndex = index
            }
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            guard !Task.isCancelled, !hasFinished else { return }
            hasFinished = true
            onFinished()
        }
    }
}

#Preview {
    AnalyzingStepView(birthDate: Date(), onFinished: {}, parityMode: true)
}
