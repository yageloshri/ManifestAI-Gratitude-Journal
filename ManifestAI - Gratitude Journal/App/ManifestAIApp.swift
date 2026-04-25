import SwiftUI
import SwiftData
import SuperwallKit

@main
struct ManifestAIApp: App {
    @StateObject private var appState = AppState.shared
    
    init() {
        Superwall.configure(apiKey: "pk_9nLkGzwmrqk-gso1NsP5Z")
        
        // Set up Superwall delegate to track subscription status
        Superwall.shared.delegate = SuperwallDelegateHandler.shared
        
        print("🚀 App initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    DashboardView()
                        .transition(.opacity)
                        .onAppear {
                            print("📱 ManifestAIApp: DashboardView is now visible")
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
        .modelContainer(for: [JournalEntry.self, VisionBoardEntity.self])
    }
}
