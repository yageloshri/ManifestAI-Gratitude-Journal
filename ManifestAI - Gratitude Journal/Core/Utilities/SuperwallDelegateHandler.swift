/// SuperwallDelegateHandler.swift
/// Handles Superwall events and updates subscription status.

import Foundation
import SuperwallKit

class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()
    
    private init() {}

    // MARK: - Subscription Status Sync

    /// Mirrors Superwall's real subscription status into `SubscriptionManager.isPro`.
    /// Call on every status change and once at launch (after `Superwall.configure`).
    func syncSubscriptionStatus(_ status: SubscriptionStatus) {
        #if DEBUG
        // Escape hatch for manual testing via:
        // `defaults write <bundle> user_is_pro -bool true` + "-forceProState" launch argument.
        if ProcessInfo.processInfo.arguments.contains("-forceProState") {
            dlog("🧪 -forceProState set — skipping Superwall subscription sync")
            return
        }
        #endif

        switch status {
        case .unknown:
            // Superwall reports .unknown before its first fetch — never
            // downgrade Pro here or paying users would flash-lock out.
            break
        case .active, .inactive:
            SubscriptionManager.shared.setProStatus(status.isActive)
        }
    }

    // Called whenever Superwall's subscription status changes
    func subscriptionStatusDidChange(
        from oldValue: SubscriptionStatus,
        to newValue: SubscriptionStatus
    ) {
        dlog("🔄 Superwall subscription status changed: \(oldValue) -> \(newValue)")
        syncSubscriptionStatus(newValue)
    }

    // Called when a subscription is purchased
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            // User completed a purchase
            dlog("✅ Subscription purchased - Unlocking Pro")
            SubscriptionManager.shared.unlockPro()
            
        case .transactionRestore:
            // User restored purchases
            dlog("✅ Purchases restored - Unlocking Pro")
            SubscriptionManager.shared.unlockPro()
            
        case .subscriptionStart:
            // Subscription started
            dlog("✅ Subscription started - Unlocking Pro")
            SubscriptionManager.shared.unlockPro()
            
        default:
            break
        }
    }
    
    // Optional: Track when paywall is presented
    func handlePaywallPresented(withInfo paywallInfo: PaywallInfo) {
        dlog("📱 Paywall presented: \(paywallInfo.name ?? "unknown")")
    }
    
    // Optional: Track when paywall is dismissed
    func handlePaywallDismissed(withInfo paywallInfo: PaywallInfo) {
        dlog("📱 Paywall dismissed: \(paywallInfo.name ?? "unknown")")
    }
}


