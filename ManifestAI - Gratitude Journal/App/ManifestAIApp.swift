import SwiftUI
import SwiftData
import SuperwallKit

@main
struct ManifestAIApp: App {
    @StateObject private var appState = AppState.shared
    
    init() {
        if Secrets.superwallApiKey.isEmpty {
            print("⚠️ Superwall API key missing — paywall features will be unavailable")
        } else {
            Superwall.configure(apiKey: Secrets.superwallApiKey)
            Superwall.shared.delegate = SuperwallDelegateHandler.shared
        }

        print("🚀 App initialized")
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
                            print("📱 ManifestAIApp: MainTabView is now visible")
                        }
                } else {
                    OnboardingContainerView()
                        .transition(.opacity)
                        .onAppear {
                            print("📱 ManifestAIApp: OnboardingView is visible")
                        }
                }
            }
            .animation(.easeInOut, value: appState.hasCompletedOnboarding)
            .preferredColorScheme(.dark)
            .onChange(of: appState.hasCompletedOnboarding) { oldValue, newValue in
                print("🔄 ManifestAIApp: hasCompletedOnboarding changed: \(oldValue) -> \(newValue)")
            }
    }
}
