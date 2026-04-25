// SubscriptionStepView.swift
// Onboarding subscription / paywall screen
// Figma node: 294:691 — frame 393×852

import SwiftUI

struct SubscriptionStepView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var selectedPlan: String = "yearly"

    // MARK: - Local constants
    private let purpleGlow = Color(red: 0x4F/255.0, green: 0x31/255.0, blue: 0xEC/255.0)
    private let goldRadio = Color(red: 0xE9/255.0, green: 0xC3/255.0, blue: 0x78/255.0)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let s = w / 393.0

            ZStack {
                // ── 1. Background ──
                Theme.Colors.background.ignoresSafeArea()

                // Purple glow ellipse
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [purpleGlow.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300 * s
                        )
                    )
                    .frame(width: 580 * s, height: 680 * s)
                    .position(x: w * 0.5, y: h * 0.25)

                // Stars background at 0.2 opacity
                StarDustView()
                    .opacity(0.2)
                    .ignoresSafeArea()

                // ── Full-screen glass panel ──
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .fill(.ultraThinMaterial.opacity(0.01))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.card)
                            .stroke(Theme.Colors.glassBorder, lineWidth: 1)
                    )
                    .frame(width: 392 * s, height: 853 * s)
                    .position(x: w / 2, y: h / 2)

                // ── Content ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // ── Skip button (top-right) ──
                        HStack {
                            Spacer()
                            Button(action: onSkip) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Theme.Colors.text.opacity(0.7))
                                    .frame(width: 32, height: 32)
                            }
                        }
                        .padding(.trailing, 20 * s)
                        .padding(.top, 16 * s)

                        // ── 2. Title ──
                        titleSection(s: s)
                            .padding(.top, 20 * s)

                        // ── 3. Glass container ──
                        VStack(spacing: 0) {
                            // ── 4. Timeline rows ──
                            timelineSection(s: s)
                                .padding(.top, 20 * s)
                                .padding(.horizontal, 16 * s)

                            // ── 5. Plan options ──
                            planOptionsSection(s: s)
                                .padding(.top, 24 * s)

                            // ── 6. No payment due now ──
                            Text("No payment due now")
                                .font(Theme.Fonts.sansFallback(size: 12, weight: .regular))
                                .foregroundStyle(.white)
                                .padding(.top, 12 * s)

                            // ── 7. CTA button ──
                            Button(action: onContinue) {
                                Text("Start my 3-Day Free Trial")
                                    .font(Theme.Fonts.sansFallback(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                    .frame(width: 320 * s, height: 56 * s)
                                    .background(Theme.Gradients.button)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                            }
                            .padding(.top, 16 * s)

                            // ── 8. Price text ──
                            Text("3 days free, then Rs 6,900 per year (Rs 575/mo)")
                                .font(Theme.Fonts.sansFallback(size: 12, weight: .regular))
                                .foregroundStyle(Theme.Colors.labels)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10 * s)
                                .padding(.horizontal, 20 * s)

                            // ── 9. Footer links ──
                            HStack(spacing: 20 * s) {
                                Button("Privacy") {}
                                    .font(Theme.Fonts.sansFallback(size: 12, weight: .regular))
                                    .foregroundStyle(Theme.Colors.labels.opacity(0.7))
                                Button("Restore") {}
                                    .font(Theme.Fonts.sansFallback(size: 12, weight: .regular))
                                    .foregroundStyle(Theme.Colors.labels.opacity(0.7))
                                Button("Terms") {}
                                    .font(Theme.Fonts.sansFallback(size: 12, weight: .regular))
                                    .foregroundStyle(Theme.Colors.labels.opacity(0.7))
                            }
                            .padding(.top, 16 * s)
                            .padding(.bottom, 24 * s)
                        }
                        .glassPanel(cornerRadius: Theme.Radius.card, borderColor: Theme.Colors.glassBorder)
                        .frame(width: 352 * s)
                        .padding(.top, 16 * s)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Title Section
    @ViewBuilder
    private func titleSection(s: CGFloat) -> some View {
        let titleWidth: CGFloat = 307 * s
        VStack(spacing: 0) {
            (
                Text("Start your ")
                    .font(Theme.Fonts.serifFallback(size: 26 * s, weight: .semibold))
                    .foregroundColor(Theme.Colors.text)
                +
                Text("3-days Free ")
                    .font(Theme.Fonts.serifFallback(size: 26 * s, weight: .bold))
                    .italic()
                    .foregroundColor(Theme.Colors.secondary)
                +
                Text("Trial to continue")
                    .font(Theme.Fonts.serifFallback(size: 26 * s, weight: .semibold))
                    .foregroundColor(Theme.Colors.text)
            )
            .multilineTextAlignment(.center)
            .frame(width: titleWidth)
        }
    }

    // MARK: - Timeline Section
    @ViewBuilder
    private func timelineSection(s: CGFloat) -> some View {
        let rows: [(icon: String, title: String, desc: String)] = [
            ("lock.fill", "Today", "Unlock AI Insights, Unlimited Journalism & Daily Affirmations."),
            ("bell.fill", "In 2 Days", "We'll send you a reminder that your trial is ending soon."),
            ("crown.fill", "In 3 Days", "You'll be charged on 27 Jan 2026 unless you cancel anytime before.")
        ]

        HStack(alignment: .top, spacing: 12 * s) {
            // Left column: icons + dotted line
            VStack(spacing: 0) {
                ForEach(0..<rows.count, id: \.self) { index in
                    // Icon container
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.Radius.iconContainer)
                            .fill(.ultraThinMaterial.opacity(0.01))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.iconContainer)
                                    .stroke(Theme.Colors.glassBorder, lineWidth: 1)
                            )
                        Image(systemName: rows[index].icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Theme.Colors.secondary)
                    }
                    .frame(width: 42 * s, height: 42 * s)

                    // Dotted connector (except after last)
                    if index < rows.count - 1 {
                        DottedLine()
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            .foregroundColor(Theme.Colors.glassBorder)
                            .frame(width: 1.5, height: 30 * s)
                    }
                }
            }

            // Right column: text
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<rows.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 2 * s) {
                        Text(rows[index].title)
                            .font(Theme.Fonts.sansFallback(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Colors.text)
                        Text(rows[index].desc)
                            .font(Theme.Fonts.sansFallback(size: 14, weight: .regular))
                            .foregroundStyle(Theme.Colors.labels)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(height: (42 + (index < rows.count - 1 ? 30 : 0)) * s, alignment: .top)
                }
            }
        }
    }

    // MARK: - Plan Options
    @ViewBuilder
    private func planOptionsSection(s: CGFloat) -> some View {
        let planWidth: CGFloat = 320 * s

        VStack(spacing: 10 * s) {
            // Yearly (selected state)
            Button { selectedPlan = "yearly" } label: {
                HStack(spacing: 12 * s) {
                    // Radio circle
                    ZStack {
                        Circle()
                            .stroke(
                                selectedPlan == "yearly" ? goldRadio : Theme.Colors.subtleBorder,
                                lineWidth: 2
                            )
                            .frame(width: 24 * s, height: 24 * s)
                        if selectedPlan == "yearly" {
                            Circle()
                                .fill(goldRadio)
                                .frame(width: 16 * s, height: 16 * s)
                            Image(systemName: "checkmark")
                                .font(.system(size: 10 * s, weight: .bold))
                                .foregroundStyle(Theme.Colors.background)
                        }
                    }

                    // Labels
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yearly")
                            .font(Theme.Fonts.sansFallback(size: 14, weight: .medium))
                            .foregroundStyle(Theme.Colors.text)
                        Text("Billed Rs, 6900")
                            .font(Theme.Fonts.sansFallback(size: 14, weight: .regular))
                            .foregroundStyle(Theme.Colors.labels)
                    }

                    Spacer()

                    Text("Rs 133/week")
                        .font(Theme.Fonts.sansFallback(size: 14, weight: .regular))
                        .foregroundStyle(Theme.Colors.labels)
                }
                .padding(.horizontal, 16 * s)
                .frame(width: planWidth, height: 79 * s)
                .glassPanel(
                    cornerRadius: Theme.Radius.card,
                    borderColor: selectedPlan == "yearly"
                        ? Theme.Colors.secondary
                        : Theme.Colors.glassBorder,
                    borderWidth: selectedPlan == "yearly" ? 3 : 2
                )
            }
            .buttonStyle(.plain)

            // Weekly
            Button { selectedPlan = "weekly" } label: {
                HStack(spacing: 12 * s) {
                    // Radio circle
                    ZStack {
                        Circle()
                            .stroke(
                                selectedPlan == "weekly" ? goldRadio : Theme.Colors.subtleBorder,
                                lineWidth: 2
                            )
                            .frame(width: 24 * s, height: 24 * s)
                        if selectedPlan == "weekly" {
                            Circle()
                                .fill(goldRadio)
                                .frame(width: 16 * s, height: 16 * s)
                            Image(systemName: "checkmark")
                                .font(.system(size: 10 * s, weight: .bold))
                                .foregroundStyle(Theme.Colors.background)
                        }
                    }

                    Text("Weekly")
                        .font(Theme.Fonts.sansFallback(size: 14, weight: .medium))
                        .foregroundStyle(Theme.Colors.text)

                    Spacer()

                    Text("Rs 11,00/week")
                        .font(Theme.Fonts.sansFallback(size: 14, weight: .regular))
                        .foregroundStyle(Theme.Colors.labels)
                }
                .padding(.horizontal, 16 * s)
                .frame(width: planWidth, height: 56 * s)
                .glassPanel(
                    cornerRadius: Theme.Radius.card,
                    borderColor: selectedPlan == "weekly"
                        ? Theme.Colors.secondary
                        : Theme.Colors.glassBorder,
                    borderWidth: selectedPlan == "weekly" ? 3 : 2
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Dotted Line Shape
private struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
