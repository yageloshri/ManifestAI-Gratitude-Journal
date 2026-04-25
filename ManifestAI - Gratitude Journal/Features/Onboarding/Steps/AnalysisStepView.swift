// AnalysisStepView.swift
// Onboarding step 6 — "Analysis Complete"
// Figma node: 270:437 — pixel-perfect from Figma inspect

import SwiftUI

struct AnalysisStepView: View {
    let birthDate: Date
    let userName: String
    let onContinue: () -> Void

    // MARK: - Numerology calculation

    /// Reduces birth-date components (day + month + year digits) to a single digit 1-9.
    private var personalDayNumber: Int {
        calculatePersonalDayNumber()
    }

    private func calculatePersonalDayNumber() -> Int {
        let cal = Calendar.current
        let day = cal.component(.day, from: birthDate)
        let month = cal.component(.month, from: birthDate)
        let year = cal.component(.year, from: birthDate)

        // Sum all individual digits of day, month, year
        let allDigits = digits(of: day) + digits(of: month) + digits(of: year)
        var total = allDigits.reduce(0, +)

        // Reduce to a single digit (1-9)
        while total > 9 {
            total = digits(of: total).reduce(0, +)
        }
        return max(total, 1)
    }

    private func digits(of number: Int) -> [Int] {
        String(number).compactMap { $0.wholeNumberValue }
    }

    // MARK: - Gold gradient for number text

    private let goldGradient = LinearGradient(
        colors: [
            Color(red: 0xFC/255.0, green: 0xD4/255.0, blue: 0x71/255.0),
            Color(red: 0xBF/255.0, green: 0x88/255.0, blue: 0x00/255.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / 393.0

            ZStack {
                // -- 1. Background: #16062A + purple glow --
                Theme.Colors.background

                // Purple glow ellipse
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

                // -- 2. Full-screen glass panel --
                // Figma: (1, 0), 392x853, r=16, border #63507A 2px
                ZStack(alignment: .top) {
                    // Stars background inside panel (opacity 0.7)
                    Image("StarsBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 392 * s, height: 853 * s)
                        .clipped()
                        .opacity(0.7)
                }
                .frame(width: 392 * s, height: 853 * s)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.01))
                        .background(.ultraThinMaterial.opacity(0.01))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                )
                .position(
                    x: (1 + 392.0 / 2) * s,
                    y: (0 + 853.0 / 2) * s
                )

                // -- 3. Badge: "Analysis Complete, [userName]" --
                // Figma: centered horizontally, y=111, glass 229x53 r=14
                Text("Analysis Complete, \(userName)")
                    .font(.system(size: 18 * s, weight: .bold, design: .serif))
                    .foregroundStyle(Theme.Colors.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 229 * s, height: 53 * s)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.welcomeBadge)
                            .fill(Color.white.opacity(0.01))
                            .background(.ultraThinMaterial.opacity(0.01))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.welcomeBadge))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.welcomeBadge))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.welcomeBadge)
                            .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                    )
                    .shadow(
                        color: Theme.Colors.glassShadowBlue.opacity(0.3),
                        radius: 15 * s, y: 10 * s
                    )
                    .position(
                        x: 393.0 / 2 * s,
                        y: (111 + 53.0 / 2) * s
                    )

                // -- 4. Owl image --
                // Figma: centered, below badge, ~281x208
                Image("OwlIllustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 281 * s, height: 208 * s)
                    .position(
                        x: 393.0 / 2 * s,
                        y: (180 + 208.0 / 2) * s
                    )

                // -- 5. "According to Numberology" --
                // Figma: centered, y~431, sans semibold 18px, #EBEBEB
                Text("According to Numberology")
                    .font(.system(size: 18 * s, weight: .semibold))
                    .foregroundStyle(Theme.Colors.text)
                    .position(
                        x: 393.0 / 2 * s,
                        y: (431 + 11) * s
                    )

                // -- 6. Numerology number --
                // Figma: centered, y~480, icon container 88x88, glassmorphic bg
                // Number: serif bold 58px, gold gradient
                ZStack {
                    // Glassmorphic background container
                    RoundedRectangle(cornerRadius: Theme.Radius.iconContainerLg)
                        .fill(Color.white.opacity(0.01))
                        .background(.ultraThinMaterial.opacity(0.01))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.iconContainerLg))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.iconContainerLg)
                                .stroke(Theme.Colors.glassBorder, lineWidth: 2)
                        )
                        .shadow(
                            color: Theme.Colors.glassShadowBlue.opacity(0.5),
                            radius: 35 * s, x: 0, y: 24 * s
                        )

                    // Number text with gold gradient
                    Text("\(personalDayNumber)")
                        .font(.system(size: 58 * s, weight: .bold, design: .serif))
                        .foregroundStyle(goldGradient)
                }
                .frame(
                    width: Theme.Sizes.iconContainerLg * s,
                    height: Theme.Sizes.iconContainerLg * s
                )
                .position(
                    x: 393.0 / 2 * s,
                    y: (480 + 88.0 / 2) * s
                )

                // -- 7. "is your year of transformation" --
                // Figma: centered, y~590, sans medium 16px, #EBEBEB
                Text("is your year of transformation")
                    .font(.system(size: 16 * s, weight: .medium))
                    .foregroundStyle(Theme.Colors.text)
                    .position(
                        x: 393.0 / 2 * s,
                        y: (590 + 10) * s
                    )

                // -- 8. Bottom bar --
                // Figma: (20, 713), back + "Continue"

                // Continue button (no back button — analysis is a results screen)
                Button {
                    onContinue()
                } label: {
                    Text("Continue")
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
                .frame(width: 353 * s)
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (713 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    AnalysisStepView(
        birthDate: Date(),
        userName: "Sarah",
        onContinue: {}
    )
}
