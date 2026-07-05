// NumerologyStepView.swift
// Figma: "DOB" frame (268:1060) in Registration Screens section
// All geometry from fidelity/dob spec — do not eyeball values.

import SwiftUI

struct NumerologyStepView: View {
    @Binding var birthDate: Date
    let onContinue: () -> Void
    let onBack: () -> Void
    /// Parity gallery: deterministic render, no picker sheet.
    var parityMode: Bool = false

    @State private var showPicker = false

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 393
            let sy = geo.size.height / 852

            ZStack(alignment: .topLeading) {
                DesignTokens.Colors.background

                // Figma 268:1061: ellipse x 0, #4F31EC@0.21, blur 514
                EllipseGlowBackground(sx: sx, sy: sy, figmaOpacity: 0.21)

                // Figma 268:1071: step 5/6
                OnboardingStepper(currentStep: 5)
                    .frame(width: 353 * sx)
                    .parityPosition(x: 20 * sx, y: 76 * sy)

                // Figma 268:1068: Bitter SemiBold 26/1.2 #EBEBEB
                Text("Let’s align with your stars.")
                    .font(DesignTokens.Typography.h1)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 122 * sy)

                // Figma 268:2316: Poppins Regular 16/24 #B9B9B9
                Text("Enter your date of birth below")
                    .font(DesignTokens.Typography.bodyRegular)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 353 * sx, alignment: .topLeading)
                    .parityPosition(x: 20 * sx, y: 177 * sy)

                // Figma 268:2318: info box (20,209) 353×62, #251540, r18
                infoBox(sx: sx, sy: sy)
                    .frame(width: 353 * sx, height: 62 * sy)
                    .parityPosition(x: 20 * sx, y: 209 * sy)

                // Figma 282:807: pickers row (20,311) — Date / Month / Year
                pickerRow(sx: sx, sy: sy)
                    .parityPosition(x: 20 * sx, y: 311 * sy)

                // Figma 282:2352: bottom bar (19,704)
                HStack(spacing: 16 * sx) {
                    GlassBackButton(action: onBack)
                        .accessibilityIdentifier("dob.backButton")

                    PrimaryButton(title: String(localized: "Calculate"), icon: nil) {
                        onContinue()
                    }
                    .accessibilityIdentifier("dob.continueButton")
                }
                .frame(width: 355 * sx)
                .parityPosition(x: 19 * sx, y: 704 * sy)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("dob.root")
        .sheet(isPresented: $showPicker) {
            DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .presentationDetents([.height(280)])
                .preferredColorScheme(.dark)
        }
    }

    // MARK: - Info box (Figma 268:2318)

    private func infoBox(sx: CGFloat, sy: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "251540"))

            // Figma 268:2320: info icon 24×24, stroke #B9B9B9 1.5
            Image(systemName: "info.circle")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .frame(width: 24, height: 24)
                .parityPosition(x: 10 * sx, y: 10 * sy)

            // Figma 268:2321: Poppins Regular 14/21 #9F9E9E
            Text("We use this to calculate your personal daily number.")
                .font(DesignTokens.Typography.smallText)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .lineSpacing(smallLineSpacing)
                .frame(width: 275 * sx, alignment: .topLeading)
                .parityPosition(x: 42 * sx, y: 10 * sy)
        }
    }

    // MARK: - Picker row (Figma 282:807)

    private func pickerRow(sx: CGFloat, sy: CGFloat) -> some View {
        let cal = Calendar.current
        let day = cal.component(.day, from: birthDate)
        let month = cal.monthSymbols[cal.component(.month, from: birthDate) - 1]
        let year = cal.component(.year, from: birthDate)

        return ZStack(alignment: .topLeading) {
            // Date — label (0,0), box (0,29) 80×56
            Text("Date")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)

            pickerBox(width: 80 * sx, sy: sy) {
                Text("\(day)")
                    .font(DesignTokens.Typography.smallMedium)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
            }
            .parityPosition(x: 0, y: 29 * sy)

            // Month — label (88,0), box (88,29) 150×56
            Text("Month")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .parityPosition(x: 88 * sx, y: 0)

            pickerBox(width: 150 * sx, sy: sy) {
                HStack(spacing: 0) {
                    Text(month)
                        .font(DesignTokens.Typography.smallMedium)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                    ChevronDownShape()
                        .stroke(DesignTokens.Colors.primary,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .frame(width: 11.67, height: 5.83)
                        .padding(.leading, 8)
                }
            }
            .parityPosition(x: 88 * sx, y: 29 * sy)

            // Year — label (246,0), box (246,29) 105×56
            Text("Year")
                .font(DesignTokens.Typography.smallMedium)
                .foregroundStyle(DesignTokens.Colors.lightGrey)
                .parityPosition(x: 246 * sx, y: 0)

            pickerBox(width: 105 * sx, sy: sy) {
                HStack(spacing: 0) {
                    Text(String(year))
                        .font(DesignTokens.Typography.smallMedium)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                    ChevronDownShape()
                        .stroke(DesignTokens.Colors.primary,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .frame(width: 11.67, height: 5.83)
                        .padding(.leading, 8)
                }
            }
            .parityPosition(x: 246 * sx, y: 29 * sy)
        }
        .frame(width: 351 * sx, height: 85 * sy, alignment: .topLeading)
    }

    private func pickerBox<Content: View>(width: CGFloat, sy: CGFloat,
                                          @ViewBuilder content: () -> Content) -> some View {
        Button {
            if !parityMode { showPicker = true }
        } label: {
            ZStack {
                Color.clear
                    .figmaGlassSurface(cornerRadius: 28)
                content()
            }
            .frame(width: width, height: 56 * sy)
        }
        .buttonStyle(.plain)
    }

    private var smallLineSpacing: CGFloat {
        let font = UIFont(name: "Poppins-Regular", size: 14) ?? .systemFont(ofSize: 14)
        return max(0, 21 - font.lineHeight)
    }
}

/// ⌄ chevron, matches Figma Chevron_Down vector (11.67×5.83).
struct ChevronDownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

#Preview {
    NumerologyStepView(
        birthDate: .constant(Calendar.current.date(from: DateComponents(year: 2000, month: 9, day: 23))!),
        onContinue: {},
        onBack: {},
        parityMode: true
    )
}
