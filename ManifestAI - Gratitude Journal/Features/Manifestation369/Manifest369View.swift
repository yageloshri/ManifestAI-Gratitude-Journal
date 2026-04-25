/// Manifest369View.swift
/// Main interface for the 369 Manifestation Method.
/// Displays daily ritual progress with a circular progress indicator and three phase cards
/// (Morning, Afternoon, Evening) that unlock sequentially.

import SwiftUI
import SuperwallKit

struct Manifest369View: View {
    @StateObject private var viewModel = Manifest369ViewModel()
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPhase: RitualPhase?
    @State private var showAffirmationEditor = false
    @State private var showNotificationSettings = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "0F0520")
                .ignoresSafeArea()
            
            if subscriptionManager.can369Method {
                // Pro users: Show full feature
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with title
                        headerView
                        
                        // Circular progress indicator
                        circularProgressView
                        
                        // Timeline of phases
                        phaseTimelineView
                        
                        // Notification toggle
                        notificationToggleView
                    }
                    .padding()
                }
            } else {
                // Free users: Show locked overlay
                VStack(spacing: 40.responsive) {
                    Spacer()
                    
                    Image(systemName: "lock.fill")
                        .font(Theme.Fonts.system(size: 80))
                        .foregroundColor(Color(hex: "FFD700"))
                    
                    VStack(spacing: Theme.Spacing.md) {
                        Text("369 Method")
                            .font(Theme.Fonts.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Premium Feature")
                            .font(.headline)
                            .foregroundColor(Color(hex: "FFD700"))
                        
                        Text("Unlock the powerful 369 Manifestation Method to write your affirmations daily and manifest your dreams")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40.responsive)
                    }
                    
                    Button(action: { 
                        Task {
                            await Superwall.shared.register(placement: "campaign_trigger")
                        }
                    }) {
                        HStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Pro")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "0F0520"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(Theme.Spacing.lg)
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 20)
                    }
                    .padding(.horizontal, 40.responsive)
                    
                    Spacer()
                }
            }
        }
        .sheet(item: $selectedPhase) { phase in
            WritingRitualView(
                viewModel: viewModel,
                phase: phase,
                onComplete: { completedPhase in
                    handlePhaseCompletion(completedPhase)
                }
            )
        }
        .sheet(isPresented: $showAffirmationEditor) {
            AffirmationEditorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView(viewModel: viewModel)
        }
        .onAppear {
            // Check if user should see paywall immediately
            if !subscriptionManager.can369Method {
                Task {
                    await Superwall.shared.register(placement: "campaign_trigger")
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("✨")
                .font(.system(size: 50))
            
            Text("Daily Ritual")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("369 Manifestation Method")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 20)
    }
    
    // MARK: - Circular Progress
    
    private var circularProgressView: some View {
        VStack(spacing: 15) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: viewModel.cycle.totalProgress)
                
                // Center text
                VStack(spacing: 5) {
                    Text("\(viewModel.cycle.totalProgress)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("of 18")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("repetitions")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Today's affirmation preview (tappable)
            Text(viewModel.cycle.affirmation)
                .font(.subheadline)
                .foregroundColor(Color(hex: "FFD700"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal)
                .onTapGesture {
                    showAffirmationEditor = true
                }
        }
        .padding(.vertical, 20)
    }
    
    private var progressPercentage: Double {
        Double(viewModel.cycle.totalProgress) / Double(viewModel.cycle.totalTarget)
    }
    
    // MARK: - Phase Timeline
    
    private var phaseTimelineView: some View {
        VStack(spacing: 20) {
            // Morning Phase
            PhaseCard(
                title: "Morning",
                subtitle: "Write 3 times",
                icon: "sun.max.fill",
                count: viewModel.cycle.morningCount,
                target: 3,
                isComplete: viewModel.cycle.isMorningDone,
                isLocked: false,
                onTap: {
                    selectedPhase = .morning
                }
            )
            
            // Connection line
            connectionLine(isActive: viewModel.cycle.isMorningDone)
            
            // Afternoon Phase
            PhaseCard(
                title: "Afternoon",
                subtitle: "Write 6 times",
                icon: "sun.min.fill",
                count: viewModel.cycle.afternoonCount,
                target: 6,
                isComplete: viewModel.cycle.isAfternoonDone,
                isLocked: !viewModel.cycle.isMorningDone,
                onTap: {
                    if viewModel.cycle.isMorningDone {
                        selectedPhase = .afternoon
                    }
                }
            )
            
            // Connection line
            connectionLine(isActive: viewModel.cycle.isAfternoonDone)
            
            // Evening Phase
            PhaseCard(
                title: "Evening",
                subtitle: "Write 9 times",
                icon: "moon.stars.fill",
                count: viewModel.cycle.eveningCount,
                target: 9,
                isComplete: viewModel.cycle.isEveningDone,
                isLocked: !viewModel.cycle.isAfternoonDone,
                onTap: {
                    if viewModel.cycle.isAfternoonDone {
                        selectedPhase = .evening
                    }
                }
            )
        }
        .padding(.vertical, 10)
    }
    
    private func connectionLine(isActive: Bool) -> some View {
        VStack(spacing: 5) {
            ForEach(0..<3) { _ in
                Capsule()
                    .fill(isActive ? Color(hex: "FFD700") : Color.white.opacity(0.2))
                    .frame(width: 3, height: 8)
            }
        }
        .animation(.easeInOut, value: isActive)
    }
    
    // MARK: - Notification Toggle
    
    private var notificationToggleView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(Color(hex: "FFD700"))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminders")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Get notified for each phase")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { newValue in
                        if newValue && !viewModel.hasNotificationPermission {
                            viewModel.requestNotificationPermission()
                        } else {
                            viewModel.toggleNotifications(newValue)
                        }
                    }
                ))
                .tint(Color(hex: "FFD700"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            if viewModel.notificationsEnabled {
                Button(action: {
                    showNotificationSettings = true
                }) {
                    HStack {
                        Image(systemName: "clock")
                        Text("Customize Times")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "FFD700"))
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func handlePhaseCompletion(_ phase: RitualPhase) {
        // Trigger haptic on phase completion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Close the writing view
        selectedPhase = nil
    }
}

// MARK: - Phase Card Component

struct PhaseCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let count: Int
    let target: Int
    let isComplete: Bool
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if !isLocked {
                onTap()
            }
        }) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isComplete ? Color(hex: "FFD700").opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: isLocked ? "lock.fill" : icon)
                        .font(.title2)
                        .foregroundColor(isComplete ? Color(hex: "FFD700") : .white.opacity(isLocked ? 0.3 : 0.7))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(isLocked ? 0.3 : 1))
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(isLocked ? 0.3 : 0.6))
                }
                
                Spacer()
                
                // Progress indicator
                VStack(spacing: 5) {
                    Text("\(count)/\(target)")
                        .font(.headline)
                        .foregroundColor(isComplete ? Color(hex: "FFD700") : .white.opacity(isLocked ? 0.3 : 0.7))
                    
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "FFD700"))
                            .font(.title3)
                    } else if !isLocked {
                        ProgressView(value: Double(count), total: Double(target))
                            .tint(Color(hex: "FFD700"))
                            .frame(width: 50)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isLocked ? 0.05 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isComplete ? Color(hex: "FFD700") : Color.white.opacity(0.2),
                                lineWidth: isComplete ? 2 : 1
                            )
                    )
            )
        }
        .disabled(isLocked)
        .opacity(isLocked ? 0.5 : 1.0)
        .animation(.easeInOut, value: isComplete)
        .animation(.easeInOut, value: isLocked)
    }
}

// MARK: - Affirmation Editor

struct AffirmationEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: Manifest369ViewModel
    @State private var editedAffirmation: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0F0520")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Your Affirmation")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("This is what you'll write 18 times today")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextEditor(text: $editedAffirmation)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .frame(height: 150)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Button(action: saveAffirmation) {
                        Text("Save Affirmation")
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "0F0520"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "FFD700"))
                            )
                    }
                    .disabled(editedAffirmation.isEmpty)
                    .opacity(editedAffirmation.isEmpty ? 0.5 : 1.0)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .onAppear {
            editedAffirmation = viewModel.cycle.affirmation
        }
    }
    
    private func saveAffirmation() {
        viewModel.updateAffirmation(editedAffirmation)
        dismiss()
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: Manifest369ViewModel
    
    @State private var morningHour: Int = 8
    @State private var morningMinute: Int = 0
    @State private var afternoonHour: Int = 14
    @State private var afternoonMinute: Int = 0
    @State private var eveningHour: Int = 20
    @State private var eveningMinute: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0F0520")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "FFD700"))
                            
                            Text("Notification Times")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Choose when you want to be reminded")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Morning
                        TimePickerCard(
                            title: "☀️ Morning Ritual",
                            subtitle: "Write 3 times",
                            hour: $morningHour,
                            minute: $morningMinute
                        )
                        
                        // Afternoon
                        TimePickerCard(
                            title: "🌤 Afternoon Ritual",
                            subtitle: "Write 6 times",
                            hour: $afternoonHour,
                            minute: $afternoonMinute
                        )
                        
                        // Evening
                        TimePickerCard(
                            title: "🌙 Evening Ritual",
                            subtitle: "Write 9 times",
                            hour: $eveningHour,
                            minute: $eveningMinute
                        )
                        
                        // Save button
                        Button(action: saveSettings) {
                            Text("Save Times")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "0F0520"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "FFD700"))
                                )
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .onAppear {
            loadCurrentTimes()
        }
    }
    
    private func loadCurrentTimes() {
        let morningTime = viewModel.getNotificationTime(phase: .morning)
        morningHour = morningTime.hour ?? 8
        morningMinute = morningTime.minute ?? 0
        
        let afternoonTime = viewModel.getNotificationTime(phase: .afternoon)
        afternoonHour = afternoonTime.hour ?? 14
        afternoonMinute = afternoonTime.minute ?? 0
        
        let eveningTime = viewModel.getNotificationTime(phase: .evening)
        eveningHour = eveningTime.hour ?? 20
        eveningMinute = eveningTime.minute ?? 0
    }
    
    private func saveSettings() {
        viewModel.setNotificationTime(phase: .morning, hour: morningHour, minute: morningMinute)
        viewModel.setNotificationTime(phase: .afternoon, hour: afternoonHour, minute: afternoonMinute)
        viewModel.setNotificationTime(phase: .evening, hour: eveningHour, minute: eveningMinute)
        dismiss()
    }
}

// MARK: - Time Picker Card

struct TimePickerCard: View {
    let title: String
    let subtitle: String
    @Binding var hour: Int
    @Binding var minute: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 16) {
                // Hour picker
                VStack(spacing: 4) {
                    Text("Hour")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Picker("Hour", selection: $hour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d", hour))
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .compositingGroup()
                    .clipped()
                }
                
                Text(":")
                    .font(.title)
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.top, 20)
                
                // Minute picker
                VStack(spacing: 4) {
                    Text("Minute")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Picker("Minute", selection: $minute) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .compositingGroup()
                    .clipped()
                }
            }
            .frame(maxWidth: .infinity)
            
            // Preview time
            Text("Reminder at \(String(format: "%02d:%02d", hour, minute))")
                .font(.caption)
                .foregroundColor(Color(hex: "FFD700"))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

struct Manifest369View_Previews: PreviewProvider {
    static var previews: some View {
        Manifest369View()
    }
}

