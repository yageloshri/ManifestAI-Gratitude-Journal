import SwiftUI
import SwiftData
import SuperwallKit
import UserNotifications

@main
struct ManifestAIApp: App {
    // Remote push (§3.10): APNs registration callbacks require a UIKit
    // app delegate; it also runs FirebaseApp.configure() at launch.
    @UIApplicationDelegateAdaptor(PushAppDelegate.self) private var pushDelegate

    @StateObject private var appState = AppState.shared
    @Environment(\.scenePhase) private var scenePhase

    /// §3.4 contextual pre-prompt: shown once, the first time
    /// `.firstMeaningfulActionCompleted` fires (first 369 phase or first
    /// journal entry).
    @State private var showNotificationPrePrompt = false

    init() {
        if Secrets.superwallApiKey.isEmpty {
            dlog("⚠️ Superwall API key missing — paywall features will be unavailable")
        } else {
            Superwall.configure(apiKey: Secrets.superwallApiKey)
            Superwall.shared.delegate = SuperwallDelegateHandler.shared
            // Sync the local Pro flag with Superwall's real subscription status
            // at launch (no-op while status is still .unknown; the delegate's
            // subscriptionStatusDidChange picks up the definitive value).
            SuperwallDelegateHandler.shared.syncSubscriptionStatus(Superwall.shared.subscriptionStatus)
        }

        // §3.2: register the "Write Now" / "Snooze 1h" actionable-notification
        // category and hand delivery/response handling to NotificationDelegate.
        NotificationManager369.shared.registerNotificationCategories()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        dlog("🚀 App initialized")
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
        .modelContainer(for: [JournalEntry.self, VisionBoardEntity.self])
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // §3.1/§3.3/§3.7: fresh personalized copy, accurate badge,
                // and streak-at-risk re-evaluation every time the app is
                // brought to the foreground (covers the "each morning" case
                // without needing a background task).
                NotificationManager369.shared.rescheduleForToday()
                // §3.10: keep the APNs/FCM registration fresh.
                PushNotificationManager.shared.registerForRemoteNotifications()
            }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        if let parityScreen = ParityScreen.fromLaunchArguments() {
            ParityGalleryView(screen: parityScreen)
                .preferredColorScheme(.dark)
        } else {
            mainContent
        }
        #else
        mainContent
        #endif
    }

    private var mainContent: some View {
            Group {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                        .transition(.opacity)
                        .onAppear {
                            dlog("📱 ManifestAIApp: MainTabView is now visible")
                        }
                } else {
                    OnboardingContainerView()
                        .transition(.opacity)
                        .onAppear {
                            dlog("📱 ManifestAIApp: OnboardingView is visible")
                        }
                }
            }
            .animation(.easeInOut, value: appState.hasCompletedOnboarding)
            .preferredColorScheme(.dark)
            // Screens are positioned at fixed Figma coordinates; larger
            // accessibility text sizes would overflow/collide instead of
            // reflowing, so clamp Dynamic Type at .large (truncation is worse
            // than a frozen size here).
            .dynamicTypeSize(...DynamicTypeSize.large)
            .onChange(of: appState.hasCompletedOnboarding) { oldValue, newValue in
                dlog("🔄 ManifestAIApp: hasCompletedOnboarding changed: \(oldValue) -> \(newValue)")
            }
            // Widget/App-Intent deep links (manifestai://ritual etc.) — the
            // tab host consumes the pending link when it becomes active.
            .onOpenURL { url in
                if url.absoluteString.contains("ritual") {
                    SharedDataManager.shared.setPendingDeepLink("ritual")
                }
            }
            .task {
                await primeProvisionalNotificationsAtLaunch()
            }
            .onReceive(NotificationCenter.default.publisher(for: .firstMeaningfulActionCompleted)) { _ in
                presentNotificationPrePromptIfNeeded()
            }
            .alert("Want a gentle nudge for tomorrow's ritual?", isPresented: $showNotificationPrePrompt) {
                Button("Yes, remind me") {
                    Task { await requestFullNotificationPermission() }
                }
                Button("Not now", role: .cancel) {}
            } message: {
                Text("A soft whisper at the right moment — nothing more. You can turn it off anytime in Profile.")
            }
    }

    /// Owner decision (2026-07): notifications must be LOUD — full banners +
    /// sound, not provisional/quiet delivery. Request full authorization at
    /// launch; also upgrades devices that were previously provisional.
    private func primeProvisionalNotificationsAtLaunch() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined, .provisional:
            await requestFullNotificationPermission()
        case .authorized, .ephemeral:
            dlog("✅ ManifestAIApp: full notification authorization already active")
        case .denied:
            dlog("⚠️ ManifestAIApp: notifications denied — user can enable in Settings")
        @unknown default:
            break
        }
    }

    /// §3.4 contextual soft-ask: shown once, the first time the user
    /// completes their first 369 phase or saves their first journal entry.
    /// Skips the ask entirely if the user is already fully authorized.
    private func presentNotificationPrePromptIfNeeded() {
        let key = "has_shown_notification_pre_prompt"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            guard settings.authorizationStatus != .authorized else { return }
            await MainActor.run {
                UserDefaults.standard.set(true, forKey: key)
                showNotificationPrePrompt = true
            }
        }
    }

    /// Upgrades from provisional (or notDetermined) to full authorization
    /// after the user accepts the contextual pre-prompt.
    private func requestFullNotificationPermission() async {
        let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )) ?? false

        await MainActor.run {
            if granted {
                dlog("✅ ManifestAIApp: full notification permission granted after contextual prompt")
                let nm = NotificationManager369.shared
                nm.setNotificationsEnabled(true)
                UserDefaults.standard.set(true, forKey: "daily_reminders_on")
            } else {
                dlog("⚠️ ManifestAIApp: full notification permission declined after contextual prompt")
            }
        }
    }
}
