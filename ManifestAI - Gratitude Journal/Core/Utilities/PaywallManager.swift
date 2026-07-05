/// PaywallManager.swift
/// Drives presentation of the native RevenueCat paywall and enforces the
/// HARD-paywall rule. Replaces the role of the old SuperwallDelegateHandler.
///
/// The app ships with a HARD paywall (3-day trial): without an active
/// subscription the paywall keeps coming back. QA/simulator runs can disable
/// enforcement via `defaults write <bundle> debug_bypass_paywall -bool true`
/// (or the -forceProState launch argument path in PurchasesManager).

import Foundation
import SwiftUI
import Combine

@MainActor
final class PaywallManager: ObservableObject {
    static let shared = PaywallManager()

    /// Bound to MainTabView's `.fullScreenCover(isPresented:)`.
    @Published var isPresented = false

    private var cancellable: AnyCancellable?

    private init() {
        // The launch entitlement sync from RevenueCat lands ASYNC — a device
        // holding a stale cached `user_is_pro = true` (e.g. from the old
        // Superwall era) passes the first onAppear enforcement and would
        // never see the paywall. Re-enforce the moment isPro flips false.
        cancellable = SubscriptionManager.shared.$isPro
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPro in
                guard let self, !isPro else { return }
                self.enforceHardPaywallIfNeeded()
            }
    }

    /// True unless QA disabled enforcement with the `debug_bypass_paywall`
    /// default. Mirrors the old `SuperwallDelegateHandler.hardPaywallEnforced`.
    static var hardPaywallEnforced: Bool {
        !UserDefaults.standard.bool(forKey: "debug_bypass_paywall")
    }

    /// Present the paywall from a feature gate (369, vision save, journal
    /// quota, upgrade button). No-op if the user is already Pro.
    func present() {
        guard !SubscriptionManager.shared.isPro else { return }
        guard !isPresented else { return }
        dlog("📱 Presenting native paywall")
        isPresented = true
    }

    /// Re-evaluate the HARD paywall: present it if enforcement is on, the user
    /// finished onboarding, and they are not Pro. Called on MainTabView
    /// `onAppear` and whenever the scene becomes active.
    func enforceHardPaywallIfNeeded() {
        guard Self.hardPaywallEnforced else { return }
        guard AppState.shared.hasCompletedOnboarding else { return }
        guard !SubscriptionManager.shared.isPro else { return }
        guard !isPresented else { return }
        dlog("🔒 Hard paywall: presenting (no active subscription)")
        isPresented = true
    }

    /// Called from the paywall's `onDismiss`. Under a hard paywall, closing
    /// without a purchase just brings the paywall back — there is no free path
    /// into the app. In QA (bypass on) the dismissal stands.
    func handleDismiss() {
        guard Self.hardPaywallEnforced else { return }
        guard AppState.shared.hasCompletedOnboarding else { return }
        guard !SubscriptionManager.shared.isPro else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, !SubscriptionManager.shared.isPro else { return }
            dlog("🔒 Hard paywall: re-presenting after dismissal without purchase")
            self.isPresented = true
        }
    }

    /// Purchase / restore succeeded → close and stay closed.
    func dismissAfterSuccess() {
        dlog("✅ Paywall: unlocking Pro and dismissing")
        isPresented = false
    }
}
