// BreakthroughStepView.swift
// Breakthrough area selection screen - Step 1 of 5

import SwiftUI
import UIKit

struct BreakthroughStepView: View {
    @Binding var selected: String?
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @State private var titleText = ""
    @State private var showContent = false
    @State private var titleInCenter = true
    
    private let fullTitle = "Where do you need a breakthrough?"
    
    let areas = [
        ("❤️", "Love & Relationships", "Deepen connections & harmony"),
        ("💰", "Financial Abundance", "Attract wealth & prosperity"),
        ("🧘‍♀️", "Inner Peace", "Calmness & spiritual grounding"),
        ("🚀", "Career Growth", "Success & professional clarity")
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
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.05))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Text("STEP 1 OF 5")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(height: 44)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .opacity(showContent ? 1 : 0)
                
                // Centered title during typewriter
                if titleInCenter {
                    Spacer()
                    
                    Text(titleText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            if !titleInCenter {
                                Text(titleText)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .black.opacity(0.3), radius: 10)
                            }
                            
                            if showContent {
                                Text("Select the area you want to focus your energy on today.")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if showContent {
                            VStack(spacing: 16) {
                            ForEach(areas, id: \.1) { emoji, title, desc in
                                Button {
                                    selected = title
                                } label: {
                                    HStack(spacing: 20) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.05))
                                                .frame(width: 56, height: 56)
                                            
                                            Text(emoji)
                                                .font(.system(size: 28))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(title)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundStyle(selected == title ? Color(hex: "FFD700") : .white)
                                            
                                            Text(desc)
                                                .font(.system(size: 12))
                                                .foregroundStyle(.white.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        ZStack {
                                            Circle()
                                                .stroke(selected == title ? Color(hex: "FFD700") : Color.white.opacity(0.2), lineWidth: 1)
                                                .frame(width: 24, height: 24)
                                                .background(selected == title ? Color(hex: "FFD700") : Color.clear)
                                                .clipShape(Circle())
                                            
                                            if selected == title {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(Color.black)
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selected == title ? Color(hex: "FFD700").opacity(0.05) : Color.white.opacity(0.03))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selected == title ? Color(hex: "FFD700") : Color.white.opacity(0.08), lineWidth: 1)
                                    )
                                    .shadow(color: selected == title ? Color(hex: "FFD700").opacity(0.15) : .clear, radius: 15)
                                }
                                .buttonStyle(.plain)
                            }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // רווח שקוף כדי שיהיה אפשר לגלול את התוכן האחרון מעל הכפתורים
                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 24)
                }
                .opacity(titleInCenter ? 0 : 1)
            }
            
            // Layer 2: Floating Bottom Buttons
            VStack {
                Spacer() // דוחף את הכפתורים למטה
                
                VStack(spacing: 12) {
                    if selected == nil {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(hex: "FFD700"))
                            
                            Text("Select an area to focus on")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text(selected == nil ? "Skip for Now" : "Continue")
                                .font(.system(size: 18, weight: .bold))
                            
                            if selected != nil {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .foregroundStyle(selected == nil ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selected == nil ? Color.white.opacity(0.15) : Color(hex: "FFD700"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selected == nil ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .shadow(color: selected != nil ? Color(hex: "FFD700").opacity(0.3) : .clear, radius: 20)
                    }
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [
                            Color.clear, // מתחיל שקוף למעלה
                            Color(hex: "0a0e17").opacity(0.9),
                            Color(hex: "0a0e17") // נגמר אטום למטה
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
    BreakthroughStepView(
        selected: .constant(nil),
        onContinue: {},
        onBack: {}
    )
}
