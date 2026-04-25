/// WritingRitualView.swift
/// A focused writing interface where users repeatedly write their affirmation.
/// Each successful match triggers haptic feedback and visual celebration.

import SwiftUI

enum RitualPhase: Identifiable {
    case morning
    case afternoon
    case evening
    
    var id: String {
        switch self {
        case .morning: return "morning"
        case .afternoon: return "afternoon"
        case .evening: return "evening"
        }
    }
    
    var targetCount: Int {
        switch self {
        case .morning: return 3
        case .afternoon: return 6
        case .evening: return 9
        }
    }
    
    var title: String {
        switch self {
        case .morning: return "Morning Ritual"
        case .afternoon: return "Afternoon Ritual"
        case .evening: return "Evening Ritual"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sun.max.fill"
        case .afternoon: return "sun.min.fill"
        case .evening: return "moon.stars.fill"
        }
    }
}

struct WritingRitualView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: Manifest369ViewModel
    
    let phase: RitualPhase
    let onComplete: (RitualPhase) -> Void
    
    @State private var currentInput: String = ""
    @State private var currentRepetition: Int = 1
    @State private var isValidated: Bool = false
    @State private var showCelebration: Bool = false
    @State private var completedReps: [String] = []
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "0F0520")
                .ignoresSafeArea()
            
            if showCelebration {
                celebrationView
            } else {
                mainContentView
            }
        }
        .onAppear {
            setupInitialState()
            isTextFieldFocused = true
        }
    }
    
    // MARK: - Main Content
    
    private var mainContentView: some View {
        VStack(spacing: 30) {
            // Header
            headerView
            
            // Progress indicator
            progressView
            
            // Target affirmation display
            affirmationDisplayView
            
            Spacer()
            
            // Completed repetitions list
            completedRepsView
            
            // Current input field
            inputFieldView
            
            Spacer()
            
            // Action button
            validateButton
        }
        .padding()
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.title3)
            }
            
            Spacer()
            
            VStack {
                Image(systemName: phase.icon)
                    .foregroundColor(Color(hex: "FFD700"))
                    .font(.title)
                
                Text(phase.title)
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Balance the layout
            Color.clear
                .frame(width: 44)
        }
    }
    
    private var progressView: some View {
        HStack(spacing: 15) {
            ForEach(1...phase.targetCount, id: \.self) { index in
                Circle()
                    .fill(index <= completedReps.count ? Color(hex: "FFD700") : Color.white.opacity(0.2))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "FFD700"), lineWidth: index == currentRepetition ? 2 : 0)
                    )
                    .scaleEffect(index == currentRepetition ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3), value: currentRepetition)
            }
        }
    }
    
    private var affirmationDisplayView: some View {
        VStack(spacing: 10) {
            Text("Write this affirmation:")
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)
            
            Text(viewModel.cycle.affirmation)
                .foregroundColor(Color(hex: "FFD700"))
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    private var completedRepsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !completedReps.isEmpty {
                Text("Completed:")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(completedReps.enumerated()), id: \.offset) { index, rep in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "FFD700"))
                                
                                Text("\(index + 1). \(rep)")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                }
                .frame(maxHeight: 100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var inputFieldView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repetition \(currentRepetition) of \(phase.targetCount)")
                .foregroundColor(.white.opacity(0.7))
                .font(.subheadline)
            
            TextField("Type your affirmation here...", text: $currentInput)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isValidated ? Color(hex: "FFD700") : Color.white.opacity(0.2), lineWidth: 2)
                        )
                )
                .focused($isTextFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    validateInput()
                }
        }
    }
    
    private var validateButton: some View {
        Button(action: validateInput) {
            Text(currentRepetition == phase.targetCount ? "Complete Ritual" : "Next")
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "0F0520"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFD700"))
                )
        }
        .disabled(currentInput.isEmpty)
        .opacity(currentInput.isEmpty ? 0.5 : 1.0)
    }
    
    // MARK: - Celebration View
    
    private var celebrationView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                // Animated circles
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 2)
                        .frame(width: 150, height: 150)
                        .scaleEffect(showCelebration ? 1.5 : 0.5)
                        .opacity(showCelebration ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                                .delay(Double(index) * 0.2)
                                .repeatForever(autoreverses: false),
                            value: showCelebration
                        )
                }
                
                VStack(spacing: 20) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "FFD700"))
                    
                    Text("Frequency Aligned")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(phase.title) Complete")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .onAppear {
            // Auto-dismiss after celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        switch phase {
        case .morning:
            currentRepetition = viewModel.cycle.morningCount + 1
            completedReps = Array(repeating: viewModel.cycle.affirmation, count: viewModel.cycle.morningCount)
        case .afternoon:
            currentRepetition = viewModel.cycle.afternoonCount + 1
            completedReps = Array(repeating: viewModel.cycle.affirmation, count: viewModel.cycle.afternoonCount)
        case .evening:
            currentRepetition = viewModel.cycle.eveningCount + 1
            completedReps = Array(repeating: viewModel.cycle.affirmation, count: viewModel.cycle.eveningCount)
        }
    }
    
    private func validateInput() {
        let normalized = currentInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let target = viewModel.cycle.affirmation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if normalized == target {
            // Success!
            triggerSuccess()
        } else {
            // Shake animation for incorrect input
            triggerError()
        }
    }
    
    private func triggerSuccess() {
        // Heavy haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Play success sound (optional - can be added)
        // AudioServicesPlaySystemSound(1519) // Peek feedback
        
        // Visual feedback
        isValidated = true
        
        // Animate text to gold
        withAnimation(.spring(response: 0.3)) {
            completedReps.append(currentInput)
        }
        
        // Update the model
        incrementPhaseCount()
        
        // Move to next repetition or complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if currentRepetition < phase.targetCount {
                // Move to next rep
                currentRepetition += 1
                currentInput = ""
                isValidated = false
            } else {
                // Phase complete!
                onComplete(phase)
                withAnimation {
                    showCelebration = true
                }
            }
        }
    }
    
    private func triggerError() {
        // Notification haptic for error
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // Shake animation
        withAnimation(.default) {
            // Can add shake animation to input field
        }
    }
    
    private func incrementPhaseCount() {
        switch phase {
        case .morning:
            viewModel.incrementMorning()
        case .afternoon:
            viewModel.incrementAfternoon()
        case .evening:
            viewModel.incrementEvening()
        }
    }
}

