/// PurchasesManager.swift
/// RevenueCat integration — replaces the old Superwall monetization stack.
///
/// Responsibilities:
///  • Configure `Purchases` once at launch.
///  • Act as `PurchasesDelegate`, mirroring the "pro" entitlement into
///    `SubscriptionManager.shared` (same contract as the old
///    `SuperwallDelegateHandler.syncSubscriptionStatus`, incl. the DEBUG
///    `-forceProState` escape hatch).
///  • Expose async APIs the native paywall drives:
///    `fetchOffering()`, `purchase(package:)`, `restore()`.

import Foundation
import RevenueCat

final class PurchasesManager: NSObject, PurchasesDelegate {
    static let shared = PurchasesManager()

    /// RevenueCat public SDK key (safe to ship in the client).
    static let apiKey = "appl_FKkxmPpnOEzVHAynWEfPESkpATx"

    /// The entitlement attached to both subscription products in the
    /// RevenueCat dashboard.
    static let proEntitlementID = "pro"

    private var isConfigured = false

    private override init() { super.init() }

    // MARK: - Launch configuration

    /// Configure RevenueCat and start mirroring entitlement state. Call once
    /// from `ManifestAIApp.init`.
    func configure() {
        guard !isConfigured else { return }
        isConfigured = true

        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: Self.apiKey)
        Purchases.shared.delegate = self
        dlog("🚀 RevenueCat configured")

        // Sync the local Pro flag with RevenueCat's cached CustomerInfo at
        // launch (the delegate callback then keeps it live).
        Purchases.shared.getCustomerInfo { [weak self] info, _ in
            if let info { self?.syncEntitlement(from: info) }
        }
    }

    // MARK: - Entitlement sync

    /// Mirrors the "pro" entitlement into `SubscriptionManager.isPro`.
    /// Mirrors the old `SuperwallDelegateHandler.syncSubscriptionStatus`
    /// pattern, including the DEBUG `-forceProState` escape hatch.
    private func syncEntitlement(from customerInfo: CustomerInfo) {
        #if DEBUG
        // Escape hatch for manual testing via:
        // `defaults write <bundle> user_is_pro -bool true` + "-forceProState".
        if ProcessInfo.processInfo.arguments.contains("-forceProState") {
            dlog("🧪 -forceProState set — skipping RevenueCat entitlement sync")
            return
        }
        #endif

        let isActive = customerInfo.entitlements[Self.proEntitlementID]?.isActive == true
        dlog("🔄 RevenueCat entitlement '\(Self.proEntitlementID)' active: \(isActive)")
        DispatchQueue.main.async {
            SubscriptionManager.shared.setProStatus(isActive)
        }
    }

    // MARK: - PurchasesDelegate

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        syncEntitlement(from: customerInfo)
    }

    // MARK: - Paywall APIs

    /// Fetch the current offering's packages (annual first, then weekly).
    /// Throws if StoreKit/RevenueCat can't return products (e.g. a bare
    /// simulator with no StoreKit config) so the paywall can show its error
    /// + retry state.
    func fetchOffering() async throws -> [Package] {
        let offerings = try await Purchases.shared.offerings()
        guard let current = offerings.current else {
            dlog("⚠️ RevenueCat: no current offering")
            throw PurchasesError.noOffering
        }
        let packages = current.availablePackages
        guard !packages.isEmpty else {
            dlog("⚠️ RevenueCat: current offering has no packages")
            throw PurchasesError.noOffering
        }
        // Annual first (the default/highlighted plan), then weekly, then any others.
        let ordered = packages.sorted { lhs, rhs in
            rank(lhs) < rank(rhs)
        }
        dlog("✅ RevenueCat fetched \(ordered.count) package(s)")
        return ordered
    }

    private func rank(_ package: Package) -> Int {
        switch package.packageType {
        case .annual: return 0
        case .weekly: return 1
        default: return 2
        }
    }

    /// Purchase a package. Returns `true` if the user is now Pro (completed),
    /// `false` if the user cancelled. Throws on real purchase errors.
    @discardableResult
    func purchase(package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        if result.userCancelled {
            dlog("🛑 Purchase cancelled by user")
            return false
        }
        let isActive = result.customerInfo.entitlements[Self.proEntitlementID]?.isActive == true
        dlog("✅ Purchase complete — pro active: \(isActive)")
        if isActive {
            AnalyticsManager.log("purchase_success", ["product": package.storeProduct.productIdentifier])
        }
        syncEntitlement(from: result.customerInfo)
        return isActive
    }

    /// Restore previous purchases. Returns `true` if Pro is now active.
    @discardableResult
    func restore() async throws -> Bool {
        let customerInfo = try await Purchases.shared.restorePurchases()
        let isActive = customerInfo.entitlements[Self.proEntitlementID]?.isActive == true
        dlog("✅ Restore complete — pro active: \(isActive)")
        if isActive {
            AnalyticsManager.log("purchase_restore")
        }
        syncEntitlement(from: customerInfo)
        return isActive
    }

    enum PurchasesError: LocalizedError {
        case noOffering

        var errorDescription: String? {
            switch self {
            case .noOffering:
                return "No subscription offering is currently available."
            }
        }
    }
}
