// CommitmentStepView.swift
// Commitment screen with hold-to-commit interaction - Step 5 of 5

import SwiftUI

struct CommitmentStepView: View {
    let onComplete: () -> Void
    let onBack: () -> Void
    
    @State private var isHolding = false
    @State private var progress: CGFloat = 0.0
    @State private var holdTimer: DispatchWorkItem?
    @State private var hasCompleted = false
    let holdDuration: TimeInterval = 2.0
    
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
            
            // Ambient glow
            Circle()
                .fill(Color(hex: "FFD700").opacity(0.05))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200)
            
            VStack {
                // Header
                ZStack(alignment: .center) {
                    // Buttons layer
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(hex: "FFD700"))
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 24)
                    
                    // Centered text layer
                    Text("STEP 5 OF 5")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(height: 44)
                .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("A Promise to Yourself")
                            .font(.system(size: 28, weight: .light))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.9))
                        
                        Capsule()
                            .fill(Color(hex: "FFD700").opacity(0.5))
                            .frame(width: 48, height: 4)
                    }
                    
                    Text("Change requires consistency.\nCan you commit to investing **3 minutes a day** in yourself?")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Fingerprint with hold interaction
                ZStack {
                    // Breathing rings (subtle)
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color(hex: "FFD700").opacity(0.2), lineWidth: 1)
                            .frame(width: 120 + CGFloat(i * 30), height: 120 + CGFloat(i * 30))
                            .scaleEffect(isHolding ? 1.05 : 1.0)
                            .opacity(isHolding ? 0.6 : 0.2)
                    }
                    
                    // Scanner base
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2a2640"), Color(hex: "151322")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "FFD700").opacity(isHolding ? 0.4 : 0.0), radius: 20)
                    
                    // Fingerprint icon
                    Image(systemName: "touchid")
                        .font(.system(size: 56, weight: .thin))
                        .foregroundStyle(Color(hex: "FFD700").opacity(0.8))
                    
                    // Progress fill
                    if isHolding {
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color(hex: "FFD700").opacity(0.3))
                                .frame(height: geometry.size.height * progress)
                                .offset(y: geometry.size.height * (1.0 - progress))
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                .frame(width: 100, height: 100)
                .contentShape(Rectangle()) // Ensure entire area is tappable
                .scaleEffect(isHolding ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: holdDuration, maximumDistance: 50, pressing: { pressing in
                    withAnimation {
                        isHolding = pressing
                    }
                    if pressing {
                        print("👆 User started holding...")
                        hasCompleted = false
                        
                        // מתחיל את אנימציית המילוי
                        withAnimation(.linear(duration: holdDuration)) {
                            progress = 1.0
                        }
                        
                        // מגדיר טיימר שיקרא ל-onComplete אחרי שהאנימציה תסתיים
                        let workItem = DispatchWorkItem {
                            print("⏰ Timer completed! Calling onComplete...")
                            print("🔍 isHolding state: \(isHolding)")
                            hasCompleted = true
                            // אם הטיימר לא בוטל, זה אומר שהמשתמש החזיק עד הסוף
                            onComplete()
                        }
                        holdTimer = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration, execute: workItem)
                        
                    } else {
                        // המשתמש הרפה - רק נבטל אם התהליך עדיין לא הושלם
                        if !hasCompleted {
                            print("👋 User released early - canceling timer")
                            holdTimer?.cancel()
                            holdTimer = nil
                            
                            withAnimation(.easeOut(duration: 0.2)) {
                                progress = 0.0
                            }
                        } else {
                            print("✅ User released after completion - this is expected")
                        }
                    }
                }, perform: {
                    // Fallback: if long press completes, call onComplete
                    print("✅ Long press gesture completed")
                    if !hasCompleted {
                        hasCompleted = true
                        onComplete()
                    }
                })
                
                Text("Touch & Hold to Commit")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.4))
                
                // Fallback button for iPad - visible if gesture fails
                // This ensures the onboarding can always be completed
                Button(action: {
                    print("🔄 Fallback button tapped - completing onboarding")
                    hasCompleted = true
                    holdTimer?.cancel()
                    onComplete()
                }) {
                    Text("Complete Setup")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "FFD700"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onDisappear {
            // ניקוי הטיימר כאשר המסך נעלם
            holdTimer?.cancel()
            holdTimer = nil
        }
    }
}

#Preview {
    CommitmentStepView(
        onComplete: {},
        onBack: {}
    )
}

