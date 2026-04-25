// NumerologyStepView.swift
// Onboarding step 5 — "Let's align with your stars."
// Figma node: 268:1060 — pixel-perfect from Figma inspect

import SwiftUI

struct NumerologyStepView: View {
    @Binding var birthDate: Date
    let onContinue: () -> Void
    let onBack: () -> Void

    // Local state for the three date components
    @State private var selectedDay: Int = 1
    @State private var selectedMonth: Int = 1   // 1-based
    @State private var selectedYear: Int = 2000

    private static let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var daysInMonth: Int {
        let dc = DateComponents(year: selectedYear, month: selectedMonth)
        let calendar = Calendar.current
        if let date = calendar.date(from: dc),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31
    }

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
                // Figma: (20, 76), w=353, h=6, step 5 of 6 (first 5 active)
                HStack(spacing: 2 * s) {
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                            .fill(Theme.Colors.primary)
                            .frame(height: Theme.Sizes.stepperHeight * s)
                    }
                    RoundedRectangle(cornerRadius: Theme.Radius.stepper)
                        .fill(Theme.Colors.lightGrey.opacity(0.3))
                        .frame(height: Theme.Sizes.stepperHeight * s)
                }
                .frame(width: 353 * s)
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (76 + 3) * s
                )

                // -- 4. Title --
                // Figma: (20, 122), serif semibold 26px, #EBEBEB
                Text("Let\u{2019}s align with\nyour stars.")
                    .font(.system(size: 26 * s, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.Colors.text)
                    .lineSpacing(26 * 0.2 * s)
                    .frame(width: 353 * s, alignment: .leading)
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (122 + 20) * s
                    )

                // -- 5. Subtitle --
                // Figma: (20, ~170), sans regular 16px, #B9B9B9
                Text("Enter your date of birth below")
                    .font(.system(size: 16 * s, weight: .regular))
                    .foregroundStyle(Theme.Colors.labels)
                    .frame(width: 353 * s, alignment: .leading)
                    .position(
                        x: (20 + 353.0 / 2) * s,
                        y: (178 + 10) * s
                    )

                // -- 6. Info box --
                // Figma: (20, ~202), w=353, bg #251540, r=18, 10px padding
                HStack(alignment: .center, spacing: 8 * s) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18 * s, weight: .regular))
                        .foregroundStyle(Theme.Colors.lightGrey)
                        .frame(width: 24 * s, height: 24 * s)

                    Text("We use this to calculate your personal daily number.")
                        .font(.system(size: 14 * s, weight: .regular))
                        .foregroundStyle(Theme.Colors.lightGrey)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10 * s)
                .frame(width: 353 * s, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.infoBox)
                        .fill(Theme.Colors.surface)
                )
                .position(
                    x: (20 + 353.0 / 2) * s,
                    y: (210 + 24) * s
                )

                // -- 7. Date fields --
                // Figma: (20, 311), 3 fields with 8px gaps
                // Date w=80, Month w=150, Year w=105, all h=56

                // Date field
                dateFieldView(
                    label: "Date",
                    width: 80,
                    s: s,
                    content: AnyView(
                        Menu {
                            ForEach(1...daysInMonth, id: \.self) { day in
                                Button("\(day)") { selectedDay = day }
                            }
                        } label: {
                            Text("\(selectedDay)")
                                .font(.system(size: 14 * s, weight: .medium))
                                .foregroundStyle(Theme.Colors.text)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    )
                )
                .position(
                    x: (20 + 80.0 / 2) * s,
                    y: (311 + 28 + 10) * s    // offset for label above
                )

                // "Date" label
                Text("Date")
                    .font(.system(size: 14 * s, weight: .medium))
                    .foregroundStyle(Theme.Colors.lightGrey)
                    .frame(width: 80 * s, alignment: .leading)
                    .position(
                        x: (20 + 80.0 / 2) * s,
                        y: (295 + 7) * s
                    )

                // Month field
                dateFieldView(
                    label: "Month",
                    width: 150,
                    s: s,
                    content: AnyView(
                        Menu {
                            ForEach(1...12, id: \.self) { month in
                                Button(Self.monthNames[month - 1]) {
                                    selectedMonth = month
                                }
                            }
                        } label: {
                            HStack(spacing: 4 * s) {
                                Text(Self.monthNames[selectedMonth - 1])
                                    .font(.system(size: 14 * s, weight: .medium))
                                    .foregroundStyle(Theme.Colors.text)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12 * s, weight: .medium))
                                    .foregroundStyle(Theme.Colors.text)
                            }
                            .padding(.horizontal, 16 * s)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    )
                )
                .position(
                    x: (20 + 80 + 8 + 150.0 / 2) * s,
                    y: (311 + 28 + 10) * s
                )

                // "Month" label
                Text("Month")
                    .font(.system(size: 14 * s, weight: .medium))
                    .foregroundStyle(Theme.Colors.lightGrey)
                    .frame(width: 150 * s, alignment: .leading)
                    .position(
                        x: (20 + 80 + 8 + 150.0 / 2) * s,
                        y: (295 + 7) * s
                    )

                // Year field
                dateFieldView(
                    label: "Year",
                    width: 105,
                    s: s,
                    content: AnyView(
                        Menu {
                            ForEach((1920...currentYear).reversed(), id: \.self) { year in
                                Button("\(year)") { selectedYear = year }
                            }
                        } label: {
                            HStack(spacing: 4 * s) {
                                Text("\(selectedYear)")
                                    .font(.system(size: 14 * s, weight: .medium))
                                    .foregroundStyle(Theme.Colors.text)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12 * s, weight: .medium))
                                    .foregroundStyle(Theme.Colors.text)
                            }
                            .padding(.horizontal, 16 * s)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    )
                )
                .position(
                    x: (20 + 80 + 8 + 150 + 8 + 105.0 / 2) * s,
                    y: (311 + 28 + 10) * s
                )

                // "Year" label
                Text("Year")
                    .font(.system(size: 14 * s, weight: .medium))
                    .foregroundStyle(Theme.Colors.lightGrey)
                    .frame(width: 105 * s, alignment: .leading)
                    .position(
                        x: (20 + 80 + 8 + 150 + 8 + 105.0 / 2) * s,
                        y: (295 + 7) * s
                    )

                // -- 8. Bottom bar --
                // Figma: (19, 704)

                // Back button: 56x56
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
                    y: (704 + 28) * s
                )

                // Continue button: "Calculate"
                Button {
                    syncToBinding()
                    onContinue()
                } label: {
                    Text("Calculate")
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
                    y: (704 + 28) * s
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear { syncFromBinding() }
        .onChange(of: selectedDay) { _ in syncToBinding() }
        .onChange(of: selectedMonth) { _ in clampDay(); syncToBinding() }
        .onChange(of: selectedYear) { _ in clampDay(); syncToBinding() }
    }

    // MARK: - Glass capsule field

    private func dateFieldView(label: String, width: CGFloat, s: CGFloat, content: AnyView) -> some View {
        content
            .frame(width: width * s, height: 56 * s)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.01))
                    .background(.ultraThinMaterial.opacity(0.01))
                    .clipShape(Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(Theme.Colors.glassBorder, lineWidth: 2)
            )
            .shadow(
                color: Theme.Colors.glassShadowBlue.opacity(0.3),
                radius: 20 * s, y: 10 * s
            )
    }

    // MARK: - Date sync helpers

    private func syncFromBinding() {
        let cal = Calendar.current
        selectedDay = cal.component(.day, from: birthDate)
        selectedMonth = cal.component(.month, from: birthDate)
        selectedYear = cal.component(.year, from: birthDate)
    }

    private func syncToBinding() {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = selectedDay
        if let date = Calendar.current.date(from: comps) {
            birthDate = date
        }
    }

    private func clampDay() {
        if selectedDay > daysInMonth {
            selectedDay = daysInMonth
        }
    }
}

// MARK: - Preview

#Preview {
    NumerologyStepView(
        birthDate: .constant(Date()),
        onContinue: {},
        onBack: {}
    )
}
