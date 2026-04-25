import SwiftUI
import StoreKit
import SuperwallKit

struct ProfileView: View {
    @ObservedObject var userManager = UserManager.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var dailyRemindersEnabled = true
    @State private var showingEditProfile = false
    @State private var showingSubscription = false
    
    // Calculate Life Path Number (simplified for profile display)
    var lifePathNumber: Int {
        // This is simplified. Normally you sum digits of birth date.
        // Reusing the daily number logic for now or could implement full numerology
        return userManager.calculateDailyNumber() // Placeholder: In real app, calculate Life Path
    }
    
    // URLs
    private let privacyPolicyURL = URL(string: "https://dream-manifest-shine.lovable.app/privacy")!
    private let supportURL = URL(string: "https://dream-manifest-shine.lovable.app/support")!
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.mysticalGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.xxxl) {
                            // Profile Header
                            VStack(spacing: Theme.Spacing.lg) {
                                ZStack {
                                    // Avatar Ring
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Theme.Colors.primary, Theme.Colors.primary.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                        .frame(width: 128.responsive, height: 128.responsive)
                                        .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 10)
                                    
                                    // Avatar Image (Placeholder)
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 116.responsive, height: 116.responsive)
                                        .overlay(
                                            Text(String(userManager.userName.prefix(1)).uppercased())
                                                .font(Theme.Fonts.system(size: 48, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.8))
                                        )
                                        .clipShape(Circle())
                                    
                                    // Pro Badge (only if subscribed)
                                    if SubscriptionManager.shared.isPro {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Text("PRO")
                                                    .font(Theme.Fonts.system(size: 10, weight: .bold))
                                                    .foregroundStyle(Theme.Colors.backgroundDark)
                                                    .padding(.horizontal, Theme.Spacing.sm)
                                                    .padding(.vertical, Theme.Spacing.xs)
                                                    .background(Theme.Colors.primary)
                                                    .clipShape(Capsule())
                                                    .overlay(Capsule().stroke(Theme.Colors.backgroundDark, lineWidth: 2))
                                                    .offset(x: -10.responsive, y: -10.responsive)
                                            }
                                        }
                                        .frame(width: 128.responsive, height: 128.responsive)
                                    }
                                }
                                
                                VStack(spacing: Theme.Spacing.xs) {
                                    Text(userManager.userName)
                                        .font(Theme.Fonts.display(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                    
                                    Text("PERSONAL DAY NUMBER \(lifePathNumber)")
                                        .font(Theme.Fonts.display(size: 12, weight: .bold))
                                        .tracking(1)
                                        .foregroundStyle(Theme.Colors.primary.opacity(0.8))
                                }
                            }
                            .padding(.top, Theme.Spacing.xl)
                            
                            // Personal Details
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("PERSONAL DETAILS")
                                        .font(Theme.Fonts.display(size: 12, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .padding(.horizontal, 8)
                                    
                                    Spacer()
                                    
                                    Button(action: { showingEditProfile = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "pencil")
                                            Text("Edit")
                                        }
                                        .font(.caption)
                                        .foregroundStyle(Theme.Colors.primary)
                                    }
                                }
                                
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("Name")
                                            .foregroundStyle(.white.opacity(0.7))
                                        Spacer()
                                        Text(userManager.userName)
                                            .foregroundStyle(.white)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    
                                    Divider().background(Color.white.opacity(0.1))
                                    
                                    HStack {
                                        Text("Birth Date")
                                            .foregroundStyle(.white.opacity(0.7))
                                        Spacer()
                                        Text(userManager.birthDate.formatted(date: .long, time: .omitted))
                                            .foregroundStyle(.white)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                            .padding(.horizontal, 24)
                            
                            // Settings List
                            VStack(spacing: 12) {
                                SettingRow(
                                    icon: "crown.fill",
                                    title: SubscriptionManager.shared.isPro ? "My Subscription" : "Upgrade to Pro",
                                    subtitle: SubscriptionManager.shared.isPro ? "Active" : "Unlock all features",
                                    showBadge: SubscriptionManager.shared.isPro,
                                    action: { 
                                        if SubscriptionManager.shared.isPro {
                                            showingSubscription = true
                                        } else {
                                            Task {
                                                await Superwall.shared.register(placement: "campaign_trigger")
                                            }
                                        }
                                    }
                                )
                                
                                ToggleRow(
                                    icon: "bell.fill",
                                    title: "Daily Reminders",
                                    isOn: $dailyRemindersEnabled
                                )
                                
                                SettingRow(
                                    icon: "star.fill",
                                    title: "Rate App",
                                    action: { rateApp() }
                                )
                                
                                SettingRow(
                                    icon: "envelope.fill",
                                    title: "Support",
                                    action: { openURL(supportURL) }
                                )
                                
                                SettingRow(
                                    icon: "lock.fill",
                                    title: "Privacy Policy",
                                    action: { openURL(privacyPolicyURL) }
                                )
                            }
                            .padding(.horizontal, 24)
                            
                            // Version
                            VStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .foregroundStyle(.white.opacity(0.2))
                                Text("Version 2.1.0 (Build 450)")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .onAppear {
            loadSettings()
        }
    }
    
    // MARK: - Actions
    
    private func loadSettings() {
        // Load daily reminders preference
        dailyRemindersEnabled = NotificationManager369.shared.areNotificationsEnabled()
    }
    
    private func rateApp() {
        // Request app review
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var showBadge: Bool = false
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundStyle(Theme.Colors.primary)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Fonts.display(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                if showBadge {
                    Text("PRO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(16)
            .glassPanel()
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundStyle(Theme.Colors.primary)
                    .font(.system(size: 18))
            }
            
            Text(title)
                .font(Theme.Fonts.display(size: 16, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.primary))
                .labelsHidden()
                .onChange(of: isOn) { oldValue, newValue in
                    handleToggleChange(newValue)
                }
        }
        .padding(16)
        .glassPanel()
    }
    
    private func handleToggleChange(_ enabled: Bool) {
        if enabled {
            // Request notification permission
            NotificationManager369.shared.requestPermission { granted in
                if granted {
                    NotificationManager369.shared.setNotificationsEnabled(true)
                } else {
                    // If not granted, turn the toggle back off
                    DispatchQueue.main.async {
                        isOn = false
                    }
                }
            }
        } else {
            NotificationManager369.shared.setNotificationsEnabled(false)
        }
    }
}

// MARK: - Subscription View

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.mysticalGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.Colors.primary, Color.yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Theme.Colors.primary.opacity(0.5), radius: 20)
                            
                            Text("ManifestAI Pro")
                                .font(Theme.Fonts.display(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text(subscriptionManager.isPro ? "You're a Pro member!" : "Unlock your full potential")
                                .font(Theme.Fonts.body(size: 16))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.top, 40)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "sparkles", title: "Unlimited 369 Manifestations", description: "No daily limits")
                            FeatureRow(icon: "book.pages.fill", title: "Advanced Journal Analysis", description: "AI-powered insights")
                            FeatureRow(icon: "eye.fill", title: "Unlimited Vision Boards", description: "Create as many as you want")
                            FeatureRow(icon: "moon.stars.fill", title: "Daily Numerology", description: "Personalized readings")
                            FeatureRow(icon: "bell.badge.fill", title: "Smart Reminders", description: "Never miss your rituals")
                            FeatureRow(icon: "iphone", title: "Widget Support", description: "Quick access from home screen")
                        }
                        .padding(.horizontal, 24)
                        
                        if subscriptionManager.isPro {
                            // Current Status for Pro users
                            VStack(spacing: 12) {
                                Text("CURRENT SUBSCRIPTION")
                                    .font(Theme.Fonts.display(size: 12, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Pro Plan")
                                                .font(Theme.Fonts.display(size: 18, weight: .bold))
                                                .foregroundStyle(.white)
                                            
                                            Text("Active")
                                                .font(Theme.Fonts.body(size: 14))
                                                .foregroundStyle(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(Theme.Colors.primary)
                                    }
                                    .padding()
                                    .glassPanel()
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Manage Button
                            Button(action: {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Manage Subscription")
                                    .font(Theme.Fonts.display(size: 16, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.primary)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.Colors.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.display(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(Theme.Fonts.body(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userManager = UserManager.shared
    
    @State private var editedName: String = ""
    @State private var editedBirthDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.mysticalGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(Theme.Fonts.display(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        TextField("Your name", text: $editedName)
                            .font(Theme.Fonts.display(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Birth Date Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Date")
                            .font(Theme.Fonts.display(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        DatePicker(
                            "",
                            selection: $editedBirthDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .colorScheme(.dark)
                        .tint(Theme.Colors.primary)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveProfile) {
                        Text("Save Changes")
                            .font(Theme.Fonts.display(size: 16, weight: .bold))
                            .foregroundStyle(Theme.Colors.backgroundDark)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(editedName.isEmpty)
                    .opacity(editedName.isEmpty ? 0.5 : 1.0)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .onAppear {
            editedName = userManager.userName
            editedBirthDate = userManager.birthDate
        }
    }
    
    private func saveProfile() {
        userManager.userName = editedName
        userManager.birthDate = editedBirthDate
        dismiss()
    }
}

#Preview {
    ProfileView()
}
