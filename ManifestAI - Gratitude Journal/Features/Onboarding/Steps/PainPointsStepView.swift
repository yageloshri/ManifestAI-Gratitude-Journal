// PainPointsStepView.swift
// Pain points selection screen - Step 2 of 5

import SwiftUI
import UIKit

struct PainPointsStepView: View {
    @Binding var selected: [String]
    let userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @State private var titleText = ""
    @State private var showContent = false
    @State private var titleInCenter = true
    
    private var fullTitle: String {
        "\(userName.isEmpty ? "" : "\(userName), ")what is holding you back right now?"
    }
    
    let points = [
        "Procrastination", "Self-Doubt", "Anxiety", "Fear of Failure",
        "Lack of Direction", "Don't know where to start",
        "Emotional Fatigue", "Imposter Syndrome",
        "Financial Stress", "Past Trauma"
    ]
    
    var body: some View {
        ZStack {
            // Layer 0: Background
            LinearGradient(
                colors: [
                    Color(hex: "0a0e17"),
                    Color(hex: "0f0c29"),
                    Color(hex: "2d1b4e").opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Layer 1: Content (Header + ScrollView)
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .center) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(Theme.Fonts.system(size: 20, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 44.responsive, height: 44.responsive)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    
                    Text("STEP 2 OF 5")
                        .font(Theme.Fonts.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(height: 44.responsive)
                .padding(.top, Theme.Spacing.sm + Theme.Spacing.xs)
                .padding(.bottom, Theme.Spacing.xl)
                .opacity(showContent ? 1 : 0)
                
                // Centered title during typewriter
                if titleInCenter {
                    Spacer()
                    
                    Text(titleText)
                        .font(Theme.Fonts.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xxxl)
                    
                    Spacer()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                        VStack(alignment: .center, spacing: Theme.Spacing.md) {
                            if !titleInCenter {
                                Text(titleText)
                                    .font(Theme.Fonts.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                            }
                            
                            if showContent {
                                Text("Select all that resonate with your spirit to begin clearing your path.")
                                    .font(Theme.Fonts.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Theme.Spacing.sm + Theme.Spacing.xs)
                        
                        if showContent {
                            VStack(spacing: Theme.Spacing.sm + Theme.Spacing.xs) {
                            ForEach(points, id: \.self) { point in
                                Button {
                                    if selected.contains(point) {
                                        selected.removeAll { $0 == point }
                                    } else {
                                        selected.append(point)
                                    }
                                } label: {
                                    HStack(spacing: Theme.Spacing.sm + Theme.Spacing.xs) {
                                        Text(point)
                                            .font(Theme.Fonts.system(size: 16, weight: selected.contains(point) ? .bold : .medium))
                                            .foregroundStyle(selected.contains(point) ? Color(hex: "FFD700") : .white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.9)
                                        
                                        Spacer(minLength: 0)
                                        
                                        if selected.contains(point) {
                                            Image(systemName: "checkmark")
                                                .font(Theme.Fonts.system(size: 14, weight: .bold))
                                                .foregroundStyle(Color(hex: "FFD700"))
                                        }
                                    }
                                    .padding(.horizontal, Theme.Spacing.lg)
                                    .padding(.vertical, 14.responsive)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(selected.contains(point) ? Color(hex: "FFD700").opacity(0.1) : Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 14.responsive))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14.responsive)
                                            .stroke(selected.contains(point) ? Color(hex: "FFD700") : Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // רווח שקוף לגלילה סופית
                        Color.clear.frame(height: 120.responsive)
                    }
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.bottom, Theme.Spacing.xxl)
                }
                .opacity(titleInCenter ? 0 : 1)
            }
            
            // Layer 2: Floating Bottom Buttons
            VStack {
                Spacer() // Push buttons down
                
                VStack(spacing: Theme.Spacing.sm + Theme.Spacing.xs) {
                    Text(selected.isEmpty ? "Select at least one (or skip)" : "\(selected.count) selected")
                        .font(Theme.Fonts.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Button(action: onContinue) {
                        Text(selected.isEmpty ? "Skip for Now" : "Reveal My Path")
                            .font(Theme.Fonts.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .responsiveHeight(56)
                            .background(Color(hex: "FFD700"))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Spacing.lg))
                            .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20)
                    }
                }
                .padding(.horizontal, Theme.Spacing.xxl)
                .padding(.top, Theme.Spacing.xxl)
                .safeBottomPadding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "0a0e17").opacity(0.9),
                            Color(hex: "0a0e17")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onAppear {
            runTypewriterAnimation()
        }
    }
    
    private func runTypewriterAnimation() {
        guard titleText.isEmpty else { return }
        
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        
        // Type title character by character
        for (index, char) in fullTitle.enumerated() {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleText.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
        }
        
        // After typing completes, wait a bit then slide up
        let slideUpDelay = Double(fullTitle.count) * 0.05 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + slideUpDelay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                titleInCenter = false
            }
            
            // Show content after slide up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    PainPointsStepView(
        selected: .constant([]),
        userName: "Yagel",
        onContinue: {},
        onBack: {}
    )
}
