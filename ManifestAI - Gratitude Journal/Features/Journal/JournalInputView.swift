import SwiftUI
import SwiftData
import UIKit
import SuperwallKit

// MARK: - Animation Phases
enum JournalAnimationPhase {
    case input          // Regular typing
    case centering      // Text moves to center
    case dissolve       // Text shatters/fades
    case reveal         // New text types out
    case complete       // Final state with action buttons
}

struct JournalInputView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = JournalViewModel()
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    // Animation State
    @State private var phase: JournalAnimationPhase = .input
    @State private var entryText: String = ""
    @State private var displayedElevatedText: String = ""
    @State private var finalEditableText: String = ""
    @State private var isEditingResult: Bool = false
    @Namespace private var animation
    
    // Paywall State
    @State private var entriesThisWeek = 0
    
    // Focus State
    @FocusState private var isFocused: Bool
    @FocusState private var isEditingFocused: Bool
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            // 🌌 Minimalist Dark Background
            Color(hex: "050510").ignoresSafeArea()
            
            // Background Elements (Subtle)
            if phase == .input {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.05))
                    .frame(width: 300.responsive, height: 300.responsive)
                    .blur(radius: 100)
                    .offset(x: -100.responsive, y: -200.responsive)
            }
            
            VStack {
                // Header (Fades out during animation)
                if phase == .input {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(Theme.Fonts.system(size: 20, weight: .light))
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(Theme.Spacing.sm + Theme.Spacing.xs)
                        }
                        
                        Spacer()
                        
                        Text(dateString.uppercased())
                            .font(Theme.Fonts.system(size: 14, weight: .semibold, design: .monospaced))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        Color.clear.frame(width: 40.responsive, height: 40.responsive)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.top, Theme.Spacing.xl)
                    .transition(.opacity)
                }
                
                Spacer()
                
                // MAIN CONTENT AREA
                ZStack {
                    // Phase A: Input
                    if phase == .input {
                        VStack(spacing: Theme.Spacing.xxxl - Theme.Spacing.xs) {
                            TextEditor(text: $entryText)
                                .font(Theme.Fonts.system(size: 24, weight: .light, design: .serif))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .scrollContentBackground(.hidden)
                                .focused($isFocused)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.horizontal, Theme.Spacing.xxl)
                                .matchedGeometryEffect(id: "text", in: animation)
                                .overlay(
                                    Group {
                                        if entryText.isEmpty {
                                            Text("What are you grateful for?")
                                                .font(Theme.Fonts.system(size: 24, weight: .light, design: .serif))
                                                .foregroundStyle(.white.opacity(0.2))
                                                .allowsHitTesting(false)
                                        }
                                    }
                                )
                            
                            // Elevate Button
                            if !entryText.isEmpty {
                                Button {
                                    startMagicSequence()
                                } label: {
                                    HStack(spacing: Theme.Spacing.md) {
                                        Image(systemName: "sparkles")
                                            .font(Theme.Fonts.system(size: 18))
                                        Text("ELEVATE")
                                            .font(Theme.Fonts.system(size: 16, weight: .bold, design: .rounded))
                                            .tracking(1)
                                    }
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .responsiveHeight(56)
                                    .background(Theme.Colors.primary)
                                    .clipShape(Capsule())
                                    .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 20)
                                }
                                .padding(.horizontal, 40.responsive)
                                .padding(.bottom, Theme.Spacing.xl)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                    
                    // Phase B & C: Centering & Dissolving
                    if phase == .centering || phase == .dissolve {
                        Text(entryText)
                            .font(Theme.Fonts.system(size: 24, weight: .light, design: .serif))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(Theme.Spacing.xxl)
                            .matchedGeometryEffect(id: "text", in: animation)
                            .blur(radius: phase == .dissolve ? 20 : 0)
                            .scaleEffect(phase == .dissolve ? 1.5 : 1.0)
                            .opacity(phase == .dissolve ? 0 : 1)
                    }
                    
                    // Phase D: Reveal (The Artifact)
                    if phase == .reveal || phase == .complete {
                        VStack(spacing: 40) {
                            // The Magic Text (Editable or Static)
                            if isEditingResult {
                                TextEditor(text: $finalEditableText)
                                    .font(.system(size: 28, weight: .medium, design: .serif))
                                    .foregroundStyle(Theme.Colors.primary)
                                    .multilineTextAlignment(.center)
                                    .scrollContentBackground(.hidden)
                                    .focused($isEditingFocused)
                                    .frame(maxHeight: 400)
                                    .padding(.horizontal, 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                Text(displayedElevatedText)
                                    .font(.system(size: 28, weight: .medium, design: .serif))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "FFD700"), Color(hex: "FFF5B3")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(8)
                                    .padding(.horizontal, 32)
                                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20)
                            }
                            
                            // Action Buttons (Appear at end)
                            if phase == .complete {
                                if isEditingResult {
                                    // Save after editing
                                    Button {
                                        saveAndDismiss(text: finalEditableText)
                                    } label: {
                                        Text("Done")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 12)
                                            .background(Theme.Colors.primary)
                                            .clipShape(Capsule())
                                    }
                                } else {
                                    // Keep or Edit
                                    HStack(spacing: 32) {
                                        // Edit Button
                                        Button {
                                            withAnimation {
                                                finalEditableText = displayedElevatedText
                                                isEditingResult = true
                                                isEditingFocused = true
                                            }
                                        } label: {
                                            VStack(spacing: 4) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 20))
                                                Text("Edit")
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundStyle(.white.opacity(0.6))
                                        }
                                        
                                        // Keep Button (Primary)
                                        Button {
                                            saveAndDismiss(text: displayedElevatedText)
                                        } label: {
                                            Text("Keep")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 40)
                                                .padding(.vertical, 14)
                                                .background(Theme.Colors.primary)
                                                .clipShape(Capsule())
                                                .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 15)
                                        }
                                    }
                                }
                            }
                        }
                        .transition(.opacity)
                    }
                    
                    // Loading State (Hidden but functional)
                    if viewModel.isAnalyzing {
                        // Optional: Subtle ambient pulse while waiting for API
                        Circle()
                            .fill(Theme.Colors.primary.opacity(0.05))
                            .frame(width: 100, height: 100)
                            .scaleEffect(phase == .centering ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: phase)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            isFocused = true
            checkJournalAccess()
        }
    }
    
    // MARK: - Logic & Animation Sequence
    
    private func startMagicSequence() {
        // Phase A: Focus
        isFocused = false
        withAnimation(.easeInOut(duration: 0.5)) {
            phase = .centering
        }
        
        // Start API Call
        Task {
            await viewModel.elevateEntry(text: entryText)
            
            // Once API is done (or failed), continue sequence
            if let result = viewModel.elevatedText {
                triggerDissolveAndReveal(result)
            } else {
                // Fallback if error
                triggerDissolveAndReveal(entryText) // Just reveal original if AI fails
            }
        }
    }
    
    private func triggerDissolveAndReveal(_ finalText: String) {
        // Phase C: The Dissolve
        withAnimation(.easeIn(duration: 1.0)) {
            phase = .dissolve
        }
        
        // Phase D: The Reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                phase = .reveal
            }
            typewriterEffect(text: finalText)
        }
    }
    
    private func typewriterEffect(text: String) {
        displayedElevatedText = ""
        let haptic = UIImpactFeedbackGenerator(style: .soft)
        haptic.prepare()
        
        for (index, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.04) {
                displayedElevatedText.append(char)
                haptic.impactOccurred(intensity: 0.7)
            }
        }
        
        // Phase Complete
        let totalTime = Double(text.count) * 0.04 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            withAnimation {
                phase = .complete
            }
        }
    }
    
    private func saveAndDismiss(text: String) {
        // Record journal entry for free user tracking
        subscriptionManager.recordJournalEntry()
        
        // Temporarily set the elevated text in VM to the final edited version if needed
        viewModel.elevatedText = text
        viewModel.saveEntry(context: modelContext, rawText: entryText)
        dismiss()
    }
    
    private func checkJournalAccess() {
        entriesThisWeek = subscriptionManager.getJournalEntriesThisWeek()
        
        // Show paywall if limit reached
        if !subscriptionManager.canWriteJournalEntry(entriesThisWeek: entriesThisWeek) {
            Task {
                await Superwall.shared.register(placement: "campaign_trigger")
            }
            dismiss()
        }
    }
}

#Preview {
    JournalInputView()
}
