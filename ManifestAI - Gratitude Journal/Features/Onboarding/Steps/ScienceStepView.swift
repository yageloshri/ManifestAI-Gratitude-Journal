// ScienceStepView.swift
// Science fact screen with typewriter animation - Step 3 of 5

import SwiftUI
import UIKit

struct ScienceStepView: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @State private var titleText = ""
    @State private var showContent = false
    @State private var titleInCenter = true
    @State private var bodyText1 = ""
    @State private var bodyText2 = ""
    @State private var showButton = false
    
    private let fullTitle = "DID YOU KNOW?"
    private let fullBody1 = "Neuroscience shows that practicing gratitude for 21 days physically rewires your brain."
    private let fullBody2 = "It boosts happiness levels by 25% and improves long-term mental clarity."
    
    var body: some View {
        ZStack {
            // Beautiful gradient with radial glow
            LinearGradient(
                colors: [
                    Color(hex: "0a0e17"),
                    Color(hex: "0f0c29")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color(hex: "FFD700").opacity(0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            .opacity(0.8)
            
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .center) {
                    // Back button layer
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 24))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Centered text layer
                    Text("STEP 3 OF 5")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(height: 44)
                .padding(.top, 10)
                .opacity(showContent ? 1 : 0)
                
                // Centered title during typewriter
                if titleInCenter {
                    Spacer()
                    
                    Text(titleText)
                        .font(.system(size: 32, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(Color(hex: "FFD700"))
                        .padding(.horizontal, 32)
                    
                    Spacer()
                } else {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Title at top after slide up
                        Text(titleText)
                            .font(.system(size: 14, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "FFD700"))
                            .opacity(0.9)
                            .padding(.bottom, 32)
                            .frame(height: 20)
                        
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FFD700").opacity(0.2))
                                    .frame(width: 250, height: 250)
                                    .blur(radius: 60)
                                
                                LottieView(
                                    name: "Brain Creative Ideas Animation",
                                    loopMode: .loop,
                                    animationSpeed: 1.0,
                                    tintColor: .white
                                )
                                .frame(width: 280, height: 280)
                                .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 30)
                            }
                            .frame(height: 320)
                            .padding(.bottom, 20)
                            .opacity(showContent ? 1 : 0)
                            
                            VStack(spacing: 24) {
                                Text(bodyText1)
                                    .font(.system(size: 22, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .minimumScaleFactor(0.8)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                
                                Text(bodyText2)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                            }
                            .padding(.horizontal, 32)
                            
                            Spacer()
                            
                            if showButton {
                                Button(action: onContinue) {
                                    HStack {
                                        Text("Wow, tell me more")
                                            .font(.system(size: 18, weight: .bold))
                                            .tracking(0.5)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(hex: "FFD700"))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20)
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    }
                }
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
            let delay = Double(index) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleText.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
        }
        
        // After typing completes, wait a bit then slide up
        let slideUpDelay = Double(fullTitle.count) * 0.08 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + slideUpDelay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                titleInCenter = false
            }
            
            // Show icon after slide up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showContent = true
                }
                
                // Start typing body text 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    typeBodyText1()
                }
            }
        }
    }
    
    private func typeBodyText1() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        
        for (index, char) in fullBody1.enumerated() {
            let delay = Double(index) * 0.03
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                bodyText1.append(char)
                if index % 3 == 0 {
                    haptic.impactOccurred(intensity: 0.3)
                }
            }
        }
        
        // Start typing body text 2
        let body2Delay = Double(fullBody1.count) * 0.03 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + body2Delay) {
            typeBodyText2()
        }
    }
    
    private func typeBodyText2() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        
        for (index, char) in fullBody2.enumerated() {
            let delay = Double(index) * 0.03
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                bodyText2.append(char)
                if index % 3 == 0 {
                    haptic.impactOccurred(intensity: 0.3)
                }
            }
        }
        
        // Show button after all text is typed
        let buttonDelay = Double(fullBody2.count) * 0.03 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + buttonDelay) {
            withAnimation(.easeIn(duration: 0.5)) {
                showButton = true
            }
        }
    }
}

#Preview {
    ScienceStepView(
        onContinue: {},
        onBack: {}
    )
}


