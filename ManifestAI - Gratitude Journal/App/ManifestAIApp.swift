import SwiftUI
import SwiftData
import SuperwallKit

@main
struct ManifestAIApp: App {
    @StateObject private var appState = AppState.shared
    
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

        dlog("🚀 App initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            rootView
        }
        .modelContainer(for: [JournalEntry.self, VisionBoardEntity.self])
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
    }
}
