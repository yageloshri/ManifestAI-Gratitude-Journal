// WelcomeStepView.swift
// First onboarding screen with typewriter animation

import SwiftUI
import UIKit

struct WelcomeStepView: View {
    let onContinue: () -> Void
    @State private var showContent = false
    @State private var titleLine1 = ""
    @State private var titleLine2 = ""
    
    private let fullLine1 = "Turn your dreams"
    private let fullLine2 = "into reality"
    
    var body: some View {
        ZStack {
            // Beautiful background
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
            
            VStack(spacing: 0) {
                // Centered logo
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color(hex: "FFD700"))
                        .font(.system(size: 24))
                    
                    Text("Gratitude Journal: Manifest")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Lottie Animation
                LottieView(name: "Technology Network", loopMode: .loop, tintColor: .white)
                    .frame(width: 220, height: 220)
                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 30)
                
                Spacer()
                
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Capsule()
                            .fill(Color(hex: "FFD700").opacity(0.5))
                            .frame(width: 48, height: 4)
                        
                        VStack(spacing: 8) {
                            // Typewriter effect
                            Text(titleLine1)
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.white)
                                .frame(height: 50, alignment: .bottom)
                            
                            Text(titleLine2)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FFF5B3")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 50, alignment: .top)
                        }
                        
                        Text("in 5 minutes a day")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.7))
                            .opacity(showContent ? 1 : 0)
                    }
                    .multilineTextAlignment(.center)
                    
                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text("Start My Journey")
                                .font(.system(size: 16, weight: .bold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "FFD700"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20)
                    }
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            runTypewriterAnimation()
        }
    }
    
    private func runTypewriterAnimation() {
        guard titleLine1.isEmpty else { return }
        
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        
        var currentIndex = 0
        let totalChars = fullLine1.count + fullLine2.count
        
        // Type line 1
        for (index, char) in fullLine1.enumerated() {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleLine1.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
            currentIndex = index + 1
        }
        
        // Small pause, then type line 2
        let line2StartDelay = Double(fullLine1.count) * 0.05 + 0.2
        for (index, char) in fullLine2.enumerated() {
            let delay = line2StartDelay + Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleLine2.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
        }
        
        // Show subtitle and button after typing
        let finalDelay = line2StartDelay + Double(fullLine2.count) * 0.05 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + finalDelay) {
            withAnimation(.easeIn(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

#Preview {
    WelcomeStepView(onContinue: {})
}


