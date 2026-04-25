// NotificationSoftAskStepView.swift
// "Soft Ask" pre-permission screen for notifications
// Uses priming strategy to increase opt-in rate before showing system dialog

import SwiftUI
import UserNotifications

struct NotificationSoftAskStepView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var isRequestingPermission = false
    @State private var animateIcon = false
    
    var body: some View {
        ZStack {
            // Beautiful mystical gradient
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
                .fill(Color(hex: "FFD700").opacity(0.08))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(y: -100)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Central Icon/Illustration
                ZStack {
                    // Breathing glow rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color(hex: "FFD700").opacity(0.15), lineWidth: 1.5)
                            .frame(width: 140 + CGFloat(i * 40), height: 140 + CGFloat(i * 40))
                            .scaleEffect(animateIcon ? 1.1 : 1.0)
                            .opacity(animateIcon ? 0.3 : 0.6)
                            .animation(
                                Animation.easeInOut(duration: 2.0 + Double(i) * 0.3)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                value: animateIcon
                            )
                    }
                    
                    // Icon container
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700").opacity(0.15),
                                        Color(hex: "FFD700").opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                        
                        // Dove icon - symbol of peace and gentle notification
                        Image(systemName: "bell.badge")
                            .font(.system(size: 64, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FFF5B3")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 20)
                    }
                }
                .padding(.bottom, 48)
                
                // Content Section
                VStack(spacing: 24) {
                    // Decorative divider
                    Capsule()
                        .fill(Color(hex: "FFD700").opacity(0.5))
                        .frame(width: 48, height: 4)
                    
                    // Headline - Focus on feeling, not technology
                    Text("Start your day with intention.")
                        .font(.system(size: 32, weight: .light))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Subtext - Explain the 'Why'
                    Text("Get a daily reminder to focus on your manifestations and gratitude. A gentle nudge to keep you on your path.")
                        .font(.system(size: 17))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // CTA Buttons
                VStack(spacing: 16) {
                    // Primary Button - Positive affirmation phrasing
                    Button(action: handleYesButton) {
                        HStack(spacing: 10) {
                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Yes, I want inspiration")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "FFD700"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 20)
                    }
                    .disabled(isRequestingPermission)
                    
                    // Secondary Button - Low friction opt-out
                    Button(action: handleMaybeLater) {
                        Text("Maybe later")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(height: 44)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Start breathing animation
            withAnimation {
                animateIcon = true
            }
        }
    }
    
    // MARK: - Actions
    
    /// Handles the primary CTA - requests system permission ONLY when user clicks
    private func handleYesButton() {
        isRequestingPermission = true
        
        // Haptic feedback
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
        
        // Request system permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isRequestingPermission = false
                
                if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                }
                
                if granted {
                    print("✅ User granted notification permission")
                    // Success haptic
                    let successHaptic = UINotificationFeedbackGenerator()
                    successHaptic.notificationOccurred(.success)
                } else {
                    print("⚠️ User denied notification permission")
                }
                
                // Continue to next screen regardless of permission result
                onContinue()
            }
        }
    }
    
    /// Handles the secondary button - skip without asking for permission
    private func handleMaybeLater() {
        // Gentle haptic
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        
        print("ℹ️ User chose 'Maybe later' for notifications")
        
        // Navigate to next screen without requesting permission
        onSkip()
    }
}

#Preview {
    NotificationSoftAskStepView(
        onContinue: { print("Continue pressed") },
        onSkip: { print("Skip pressed") }
    )
}

