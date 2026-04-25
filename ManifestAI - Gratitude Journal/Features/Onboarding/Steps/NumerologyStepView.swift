// NumerologyStepView.swift
// Birth date input screen - Step 4 of 5

import SwiftUI

struct NumerologyStepView: View {
    @Binding var birthDate: Date
    let onContinue: () -> Void
    let onBack: () -> Void
    
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
                // Header
                ZStack(alignment: .center) {
                    // Back button layer
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    // Centered text layer
                    Text("STEP 4 OF 5")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(height: 44)
                .padding(.top, 12)
                .padding(.bottom, 20)
                
                Spacer()
                
                VStack(spacing: 40) {
                    VStack(spacing: 12) {
                        Text("Let's align with\nyour stars.")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("Enter your date of birth below.")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 36)
                            .padding(.horizontal, 16)
                        
                        DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .frame(maxHeight: 200)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color(hex: "FFD700"))
                            .font(.caption)
                        
                        Text("We use this to calculate your personal daily number.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "FFD700").opacity(0.8))
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Calculate")
                            .font(.system(size: 18, weight: .bold))
                            .tracking(1)
                            .textCase(.uppercase)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "FFD700"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    NumerologyStepView(
        birthDate: .constant(Date()),
        onContinue: {},
        onBack: {}
    )
}


