// AnalysisStepView.swift
// Analysis result screen with Lottie animation

import SwiftUI

struct AnalysisStepView: View {
    let birthDate: Date
    let userName: String
    let onContinue: () -> Void
    
    @State private var showResult = false
    
    var personalYear: Int {
        ((Calendar.current.component(.year, from: Date()) % 9) + 1)
    }
    
    var body: some View {
        ZStack {
            // Beautiful gradient
            LinearGradient(
                colors: [
                    Color(hex: "0a0e17"),
                    Color(hex: "0f0c29")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showResult {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FFD700").opacity(0.1))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 32))
                                .foregroundStyle(Color(hex: "FFD700"))
                        }
                        .padding(.top, 8)
                        
                        VStack(spacing: 8) {
                            Text("Analysis Complete, \(userName)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FFF5B3")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .multilineTextAlignment(.center)
                            
                            Text("According to Numerology,")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("\(personalYear)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color(hex: "FFD700"))
                                .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 10)
                                .padding(.vertical, 4)
                            
                            Text("is your year of transformation.")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        
                        Button(action: onContinue) {
                            HStack(spacing: 8) {
                                Text("CONTINUE")
                                    .font(.system(size: 14, weight: .bold))
                                    .tracking(1)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "FFD700"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color(hex: "FFD700").opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 16)
                        
                        Text("Personalized Report Ready")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(hex: "151326"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .shadow(color: Color(hex: "FFD700").opacity(0.1), radius: 40)
                    
                    Spacer()
                }
            } else {
                VStack(spacing: 40) {
                    LottieView(name: "CosmicLoader", loopMode: .loop)
                        .frame(width: 180, height: 180)
                        .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 30)
                    
                    Text("Mapping your star chart...")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showResult = true
                }
            }
        }
    }
}

#Preview {
    AnalysisStepView(
        birthDate: Date(),
        userName: "Yagel",
        onContinue: {}
    )
}


