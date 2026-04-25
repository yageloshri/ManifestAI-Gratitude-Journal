// NameStepView.swift
// Name input screen with beautiful golden border

import SwiftUI
import UIKit

struct NameStepView: View {
    @Binding var userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    @FocusState private var isFocused: Bool
    
    @State private var titleLine1 = ""
    @State private var titleLine2 = ""
    @State private var showSubtitle = false
    @State private var showInput = false
    
    private let fullLine1 = "Let's align with"
    private let fullLine2 = "your frequency"
    
    var body: some View {
        ZStack {
            // Beautiful gradient
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
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 40) {
                    VStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Text(titleLine1)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(height: 40, alignment: .bottom)
                            
                            Text(titleLine2)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(height: 40, alignment: .top)
                        }
                        
                        Text("What is your name?")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.6))
                            .opacity(showSubtitle ? 1 : 0)
                    }
                    
                    if showInput {
                        VStack(spacing: 12) {
                            TextField("", text: $userName)
                                .focused($isFocused)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Color(hex: "FFD700"))
                                .multilineTextAlignment(.center)
                                .tint(Color(hex: "FFD700"))
                                .overlay(
                                    Text(userName.isEmpty ? "Your Name" : "")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .allowsHitTesting(false)
                                )
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color(hex: "FFD700").opacity(userName.isEmpty ? 0.3 : 1.0),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 2)
                                .shadow(color: Color(hex: "FFD700").opacity(userName.isEmpty ? 0 : 0.5), radius: 8)
                        }
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                
                Spacer()
                
                if userName.count >= 2 {
                    Button {
                        isFocused = false
                        UserDefaults.standard.set(userName, forKey: "user_name")
                        onContinue()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Begin Journey")
                                .font(.system(size: 18, weight: .bold))
                                .tracking(1)
                            
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
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
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
        
        // Type line 1
        for (index, char) in fullLine1.enumerated() {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                titleLine1.append(char)
                haptic.impactOccurred(intensity: 0.5)
            }
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
        
        // Show subtitle after typing
        let subtitleDelay = line2StartDelay + Double(fullLine2.count) * 0.05 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + subtitleDelay) {
            withAnimation(.easeIn(duration: 0.5)) {
                showSubtitle = true
            }
        }
        
        // Show input field after subtitle
        let inputDelay = subtitleDelay + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + inputDelay) {
            withAnimation(.easeIn(duration: 0.5)) {
                showInput = true
            }
            
            // Focus on input field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

#Preview {
    NameStepView(
        userName: .constant(""),
        onContinue: {},
        onBack: {}
    )
}


