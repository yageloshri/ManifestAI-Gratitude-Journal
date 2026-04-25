/// SuperwallDelegateHandler.swift
/// Handles Superwall events and updates subscription status.

import Foundation
import SuperwallKit

class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()
    
    private init() {}
    
    // Called when a subscription is purchased
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            // User completed a purchase
            print("✅ Subscription purchased - Unlocking Pro")
            SubscriptionManager.shared.unlockPro()
            
        case .transactionRestore:
            // User restored purchases
            print("✅ Purchases restored - Unlocking Pro")
            SubscriptionManager.shared.unlockPro()
            
        case .subscriptionStart:
            // Subscription started
            print("✅ Subscription started - Unlocking Pro")
            SubscriptionManager.shared.unlockPro()
            
        default:
            break
        }
    }
    
    // Optional: Track when paywall is presented
    func handlePaywallPresented(withInfo paywallInfo: PaywallInfo) {
        print("📱 Paywall presented: \(paywallInfo.name ?? "unknown")")
    }
    
    // Optional: Track when paywall is dismissed
    func handlePaywallDismissed(withInfo paywallInfo: PaywallInfo) {
        print("📱 Paywall dismissed: \(paywallInfo.name ?? "unknown")")
    }
}


