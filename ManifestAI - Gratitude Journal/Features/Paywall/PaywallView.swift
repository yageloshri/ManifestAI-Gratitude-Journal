// PaywallView.swift
// Native, fully-localized, RTL-aware RevenueCat paywall. Replaces the old
// Superwall-hosted paywall. Built with adaptive layout (VStack/HStack,
// leading/trailing) — NOT fixed Figma coordinates — so he/ar mirror correctly.
//
// Content mirrors the previous Superwall trial paywall:
//   headline → 3-step timeline (Today / In 2 Days / In 3 Days+charge date) →
//   plan cards (annual default, weekly) with localized StoreKit prices →
//   "No payment due now" → golden CTA → Privacy / Restore / Terms.
//
// All user-facing copy is a Text("…") literal so the String Catalog localizes it.

import SwiftUI
import RevenueCat

struct PaywallView: View {
    /// Called when the user taps the close (X) button. The hard-paywall
    /// re-present decision lives in PaywallManager.handleDismiss (onDismiss).
    var onClose: () -> Void

    @StateObject private var model = PaywallViewModel()

    private let privacyURL = URL(string: "https://dream-manifest-shine.lovable.app/privacy")!
    private let termsURL = URL(string: "https://dream-manifest-shine.lovable.app/terms")!

    /// The app root forces LTR for the fixed-coordinate parity screens; this
    /// native paywall restores the NATURAL direction so he/ar get true RTL.
    private var naturalDirection: LayoutDirection {
        let lang = Locale.preferredLanguages.first ?? "en"
        let direction = Locale.Language(identifier: lang).characterDirection
        return direction == .rightToLeft ? .rightToLeft : .leftToRight
    }

    var body: some View {
        ZStack {
            DesignTokens.Colors.background.ignoresSafeArea()
            // Contain the 578pt-wide glow ellipse inside a flexible, clipped
            // layer so it can't inflate the ZStack past the screen width.
            Color.clear
                .overlay(alignment: .top) { EllipseGlowBackground(figmaOpacity: 0.51) }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
                .ignoresSafeArea()

            // Pin the content column to the safe-area width so long strings
            // wrap instead of overflowing the screen.
            GeometryReader { geo in
                content(width: geo.size.width)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
        .environment(\.layoutDirection, naturalDirection)
        .preferredColorScheme(.dark)
        .task { await model.loadIfNeeded() }
        .alert("Something went wrong. Please try again.", isPresented: $model.showPurchaseError) {
            Button("OK", role: .cancel) {}
        }
        .accessibilityIdentifier("paywall.root")
    }

    @ViewBuilder
    private func content(width: CGFloat) -> some View {
        switch model.state {
        case .loading:
            loadingState
        case .error:
            errorState
        case .loaded:
            loadedState(width: width)
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 20) {
            closeButtonRow
            Spacer()
            ProgressView()
                .tint(DesignTokens.Colors.secondary)
                .scaleEffect(1.4)
            Text("Loading your plan…")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.screenPadding)
    }

    // MARK: - Error

    private var errorState: some View {
        VStack(spacing: 24) {
            closeButtonRow
            Spacer()
            owl
            Text("We couldn't load subscription options right now.")
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.screenPadding)
            Button {
                Task { await model.reload() }
            } label: {
                Text("Try Again")
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignTokens.Sizes.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                            .fill(DesignTokens.Gradients.golden)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DesignTokens.Spacing.screenPadding)
            Spacer()
            footerLinks
        }
    }

    // MARK: - Loaded

    private func loadedState(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            closeButtonRow
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    owl
                    trialBadge
                    headline
                    timeline
                    planCards
                    Text("No payment due now")
                        .font(DesignTokens.Typography.label)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    ctaButton
                    footnote
                    footerLinks
                }
                .padding(.horizontal, DesignTokens.Spacing.screenPadding)
                .padding(.bottom, 24)
                // Pin the scrolling column to a concrete width so Text wraps
                // instead of taking its unbounded ideal width.
                .frame(width: width)
            }
        }
    }

    // MARK: - Pieces

    private var closeButtonRow: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                    .overlay(Circle().stroke(DesignTokens.Colors.glassBorder.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Close"))
            .accessibilityIdentifier("paywall.closeButton")
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.screenPadding)
        .padding(.top, 12)
    }

    private var owl: some View {
        Image("AnalysisOwl")
            .resizable()
            .scaledToFit()
            .frame(width: 92, height: 92)
            .accessibilityHidden(true)
    }

    private var trialBadge: some View {
        Text("3-DAY FREE TRIAL")
            .font(DesignTokens.Typography.smallTextSemibold)
            .foregroundStyle(DesignTokens.Colors.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(DesignTokens.Colors.secondary.opacity(0.12))
            )
            .overlay(
                Capsule().stroke(DesignTokens.Colors.secondary.opacity(0.5), lineWidth: 1)
            )
    }

    private var headline: some View {
        Text("Start your 3-day FREE trial to continue")
            .font(DesignTokens.Typography.h1)
            .foregroundStyle(DesignTokens.Colors.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Timeline

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            timelineRow(
                icon: "SubTimelineIcon1",
                title: Text("Today"),
                body: Text("Unlock AI-Insights, unlimited journaling and daily affirmations."),
                showConnector: true
            )
            timelineRow(
                icon: "SubTimelineIcon2",
                title: Text("In 2 Days"),
                body: Text("We'll send you a reminder before your trial ends."),
                showConnector: true
            )
            timelineRow(
                icon: "SubTimelineIcon3",
                title: Text("In 3 Days"),
                body: Text("You'll be charged on \(model.chargeDateString) unless you cancel before."),
                showConnector: false
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                .fill(Color.white.opacity(0.01))
        )
        .figmaGlassSurface(cornerRadius: DesignTokens.Radii.card, compact: false)
    }

    private func timelineRow(icon: String, title: Text, body: Text, showConnector: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(icon)
                    .resizable()
                    .frame(width: 44, height: 44)
                if showConnector {
                    Rectangle()
                        .fill(Color(hex: "8E5BEB"))
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 2)
                }
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 6) {
                title
                    .font(DesignTokens.Typography.smallTextSemibold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                body
                    .font(DesignTokens.Typography.smallText)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, showConnector ? 18 : 0)
            Spacer(minLength: 0)
        }
    }

    // MARK: Plan cards

    private var planCards: some View {
        VStack(spacing: 12) {
            if let annual = model.annualPackage {
                planCard(
                    package: annual,
                    title: Text("Yearly"),
                    subtitle: Text("Billed \(annual.storeProduct.localizedPriceString) / year"),
                    trailing: model.perWeekString(for: annual)
                )
            }
            if let weekly = model.weeklyPackage {
                planCard(
                    package: weekly,
                    title: Text("Weekly"),
                    subtitle: nil,
                    trailing: model.perWeekString(for: weekly)
                )
            }
        }
    }

    private func planCard(package: Package, title: Text, subtitle: Text?, trailing: String?) -> some View {
        let selected = model.selectedPackage?.identifier == package.identifier
        return Button {
            model.selectedPackage = package
        } label: {
            HStack(spacing: 14) {
                selectionIndicator(selected: selected)
                VStack(alignment: .leading, spacing: 4) {
                    title
                        .font(DesignTokens.Typography.smallMedium)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                    if let subtitle {
                        subtitle
                            .font(DesignTokens.Typography.smallText)
                            .foregroundStyle(DesignTokens.Colors.textSecondary)
                    }
                }
                Spacer(minLength: 8)
                if let trailing {
                    Text(trailing)
                        .font(DesignTokens.Typography.smallText)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .fill(Color.white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radii.card)
                    .strokeBorder(
                        selected
                        ? AnyShapeStyle(LinearGradient(
                            stops: [
                                .init(color: DesignTokens.Colors.secondary.opacity(0.85), location: 0),
                                .init(color: DesignTokens.Colors.secondary.opacity(0.4), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(DesignTokens.Colors.glassBorder.opacity(0.5)),
                        lineWidth: selected ? 3 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("paywall.plan.\(package.packageType == .annual ? "yearly" : "weekly")")
    }

    private func selectionIndicator(selected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(selected
                      ? AnyShapeStyle(RadialGradient(
                        stops: [
                            .init(color: Color(hex: "A8842F"), location: 0),
                            .init(color: Color(hex: "C7A14B"), location: 1)
                        ], center: .center, startRadius: 0, endRadius: 12))
                      : AnyShapeStyle(Color.white.opacity(0.01)))
                .overlay(
                    Circle().stroke(
                        selected ? DesignTokens.Colors.selectedBorderGold.opacity(0.85)
                                 : DesignTokens.Colors.unselectedBorder.opacity(0.6),
                        lineWidth: 1)
                )
                .frame(width: 24, height: 24)
            if selected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "FAFAFB"))
            }
        }
    }

    // MARK: CTA + footnote

    private var ctaButton: some View {
        Button {
            Task { await model.purchaseSelected() }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radii.button)
                    .fill(DesignTokens.Gradients.golden)
                if model.isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Text("Start my 3-day free trial")
                            .font(DesignTokens.Typography.bodyMedium)
                            .foregroundStyle(Color(hex: "3A2A05"))
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(hex: "3A2A05"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.Sizes.buttonHeight)
        }
        .buttonStyle(.plain)
        .disabled(model.isPurchasing || model.selectedPackage == nil)
        .accessibilityIdentifier("paywall.startTrialButton")
    }

    @ViewBuilder
    private var footnote: some View {
        if let annual = model.annualPackage {
            Text("3 days free, then \(annual.storeProduct.localizedPriceString) per year (\(model.perMonthString(for: annual))/mo)")
                .font(DesignTokens.Typography.label)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var footerLinks: some View {
        HStack {
            Button { UIApplication.shared.open(privacyURL) } label: {
                Text("Privacy")
            }
            .accessibilityIdentifier("paywall.privacy")
            Spacer()
            Button {
                Task { await model.restore() }
            } label: {
                Text("Restore")
            }
            .accessibilityIdentifier("paywall.restore")
            Spacer()
            Button { UIApplication.shared.open(termsURL) } label: {
                Text("Terms")
            }
            .accessibilityIdentifier("paywall.terms")
        }
        .buttonStyle(.plain)
        .font(DesignTokens.Typography.label)
        .foregroundStyle(DesignTokens.Colors.textSecondary)
        .opacity(0.8)
        .padding(.horizontal, DesignTokens.Spacing.screenPadding)
        .padding(.vertical, 10)
    }
}

// MARK: - View Model

@MainActor
final class PaywallViewModel: ObservableObject {
    enum State { case loading, loaded, error }

    @Published var state: State = .loading
    @Published var packages: [Package] = []
    @Published var selectedPackage: Package?
    @Published var isPurchasing = false
    @Published var showPurchaseError = false

    /// Trial length used by the on-screen copy.
    private static let trialDays = 3

    var annualPackage: Package? {
        packages.first { $0.packageType == .annual } ?? packages.first
    }
    var weeklyPackage: Package? {
        packages.first { $0.packageType == .weekly }
    }

    /// First charge date: today + trial length, formatted for the user's locale.
    var chargeDateString: String {
        let date = Calendar.current.date(byAdding: .day, value: Self.trialDays, to: Date()) ?? Date()
        return date.formatted(.dateTime.day().month().year())
    }

    func loadIfNeeded() async {
        guard packages.isEmpty else { return }
        await reload()
    }

    func reload() async {
        state = .loading
        do {
            let fetched = try await PurchasesManager.shared.fetchOffering()
            packages = fetched
            selectedPackage = annualPackage
            state = .loaded
        } catch {
            dlog("⚠️ Paywall: failed to load offering — \(error.localizedDescription)")
            state = .error
        }
    }

    func purchaseSelected() async {
        guard let package = selectedPackage, !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let unlocked = try await PurchasesManager.shared.purchase(package: package)
            if unlocked {
                PaywallManager.shared.dismissAfterSuccess()
            }
        } catch {
            dlog("⚠️ Paywall: purchase failed — \(error.localizedDescription)")
            showPurchaseError = true
        }
    }

    func restore() async {
        do {
            let unlocked = try await PurchasesManager.shared.restore()
            if unlocked {
                PaywallManager.shared.dismissAfterSuccess()
            } else {
                showPurchaseError = true
            }
        } catch {
            dlog("⚠️ Paywall: restore failed — \(error.localizedDescription)")
            showPurchaseError = true
        }
    }

    /// Per-week equivalent of a package's price, normalized by its billing
    /// period (annual → price/52, weekly → price as-is), formatted with the
    /// product's own currency formatter, e.g. "$0.48 / week".
    func perWeekString(for package: Package) -> String? {
        let weeksInPeriod = weeksIn(package.packageType)
        guard let formatted = formattedPrice(package.storeProduct.price / weeksInPeriod,
                                             formatter: package.storeProduct.priceFormatter)
        else { return nil }
        return String(localized: "\(formatted) / week")
    }

    private func weeksIn(_ type: PackageType) -> Decimal {
        switch type {
        case .annual: return 52
        case .sixMonth: return 26
        case .threeMonth: return 13
        case .twoMonth: return Decimal(string: "8.7")!
        case .monthly: return Decimal(string: "4.345")!
        case .weekly: return 1
        default: return 1
        }
    }

    /// Per-month equivalent of a package's price (price / 12).
    func perMonthString(for package: Package) -> String {
        formattedPrice(package.storeProduct.price / 12,
                       formatter: package.storeProduct.priceFormatter)
            ?? package.storeProduct.localizedPriceString
    }

    private func formattedPrice(_ value: Decimal, formatter: NumberFormatter?) -> String? {
        let f = formatter ?? {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            return nf
        }()
        return f.string(from: value as NSDecimalNumber)
    }
}
