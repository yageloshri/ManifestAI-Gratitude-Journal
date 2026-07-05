// PaywallView.swift
// Native, fully-localized, RTL-aware RevenueCat paywall.
//
// Design: faithful to the original (proven) trial paywall — near-black
// backdrop, warm gold accents, connected 3-step trial timeline, gold-rimmed
// annual card with a floating "3-DAY FREE TRIAL" badge, solid gold CTA.
// Everything fits ONE screen (no scrolling): fixed compact rows + flexible
// breathing space that collapses first on short devices.
//
// All user-facing copy is a Text("…") literal so the String Catalog
// localizes it (20 languages). Layout is adaptive leading/trailing (not
// fixed coordinates), and the root restores the natural layout direction so
// he/ar render true RTL.

import SwiftUI
import RevenueCat

struct PaywallView: View {
    /// Called when the user taps the close (X) button. The hard-paywall
    /// re-present decision lives in PaywallManager.handleDismiss (onDismiss).
    var onClose: () -> Void

    @StateObject private var model = PaywallViewModel()

    private let privacyURL = URL(string: "https://dream-manifest-shine.lovable.app/privacy")!
    private let termsURL = URL(string: "https://dream-manifest-shine.lovable.app/terms")!

    // MARK: Palette (matches the original paywall, not the in-app purple)

    private let bg = Color(hex: "0D0915")
    private let gold = Color(hex: "FFD44D")
    private let goldDeep = Color(hex: "F2B90D")
    private let inkOnGold = Color(hex: "1C1503")
    private let stepCircle = Color(hex: "262230")
    private let stepIcon = Color(hex: "CBC7D8")
    private let connectorDim = Color(hex: "353041")
    private let cardStroke = Color(hex: "3B3550")

    private var goldGradient: LinearGradient {
        LinearGradient(colors: [gold, goldDeep], startPoint: .top, endPoint: .bottom)
    }

    /// The app root forces LTR for the fixed-coordinate parity screens; this
    /// native paywall restores the NATURAL direction so he/ar get true RTL.
    private var naturalDirection: LayoutDirection {
        let lang = Locale.preferredLanguages.first ?? "en"
        return Locale.Language(identifier: lang).characterDirection == .rightToLeft
            ? .rightToLeft : .leftToRight
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            // Whisper of the brand purple rising from the bottom.
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "16062A").opacity(0), location: 0.55),
                    .init(color: Color(hex: "2A1650").opacity(0.35), location: 1)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            switch model.state {
            case .loading: loadingState
            case .error: errorState
            case .loaded: loadedState
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

    // MARK: - One-screen loaded layout

    private var loadedState: some View {
        VStack(spacing: 0) {
            closeButtonRow

            Spacer(minLength: 4)

            headline
                .padding(.horizontal, 28)

            Spacer(minLength: 14).frame(maxHeight: 26)

            timeline
                .padding(.horizontal, 26)

            Spacer(minLength: 14).frame(maxHeight: 30)

            VStack(spacing: 12) {
                if let annual = model.annualPackage {
                    annualCard(annual)
                }
                if let weekly = model.weeklyPackage {
                    weeklyCard(weekly)
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 10).frame(maxHeight: 18)

            noPaymentRow

            Spacer(minLength: 10).frame(maxHeight: 16)

            ctaButton
                .padding(.horizontal, 20)

            footnote
                .padding(.top, 10)
                .padding(.horizontal, 24)

            Spacer(minLength: 6).frame(maxHeight: 14)

            footerLinks
        }
        .padding(.bottom, 4)
    }

    // MARK: - Header

    private var closeButtonRow: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: "9B96A8"))
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Close"))
            .accessibilityIdentifier("paywall.closeButton")
        }
        .padding(.horizontal, 12)
        .padding(.top, 2)
    }

    /// Big two-line headline with the localized "FREE" word lit in gold.
    private var headline: some View {
        highlightedHeadline
            .font(.system(size: 29, weight: .bold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    /// Colors the localized emphatic word (key "FREE") inside the localized
    /// headline. Falls back to the plain headline if not found.
    private var highlightedHeadline: Text {
        let headline = String(localized: "Start your 3-day FREE trial to continue")
        let free = String(localized: "FREE")
        var attributed = AttributedString(headline)
        if !free.isEmpty, let range = attributed.range(of: free) {
            attributed[range].foregroundColor = gold
        }
        return Text(attributed)
    }

    // MARK: - Timeline (connected steps, crown lit gold)

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            timelineRow(
                systemIcon: "lock.open.fill", lit: false,
                title: Text("Today"),
                caption: Text("Unlock AI-Insights, unlimited journaling and daily affirmations."),
                connector: .dim
            )
            timelineRow(
                systemIcon: "bell.fill", lit: false,
                title: Text("In 2 Days"),
                caption: Text("We'll send you a reminder before your trial ends."),
                connector: .toGold
            )
            timelineRow(
                systemIcon: "crown.fill", lit: true,
                title: Text("In 3 Days"),
                caption: Text("You'll be charged on \(model.chargeDateString) unless you cancel before."),
                connector: .none
            )
        }
    }

    private enum Connector { case none, dim, toGold }

    private func timelineRow(systemIcon: String, lit: Bool,
                             title: Text, caption: Text,
                             connector: Connector) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(lit ? AnyShapeStyle(goldGradient) : AnyShapeStyle(stepCircle))
                        .frame(width: 42, height: 42)
                    Image(systemName: systemIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(lit ? inkOnGold : stepIcon)
                }
                if connector != .none {
                    Rectangle()
                        .fill(connector == .toGold
                              ? AnyShapeStyle(LinearGradient(colors: [connectorDim, goldDeep],
                                                             startPoint: .top, endPoint: .bottom))
                              : AnyShapeStyle(connectorDim))
                        .frame(width: 4)
                        .frame(minHeight: 22, maxHeight: .infinity)
                }
            }
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 3) {
                title
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                caption
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "A49FB3"))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, connector == .none ? 0 : 16)
            .padding(.top, 1)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Plan cards

    private func annualCard(_ package: Package) -> some View {
        Button { model.selectedPackage = package } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Yearly")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Billed \(package.storeProduct.localizedPriceString) / year")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "A49FB3"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 8)
                if let perWeek = model.perWeekString(for: package) {
                    Text(perWeek)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected(package) ? 0.05 : 0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected(package) ? AnyShapeStyle(goldGradient)
                                                      : AnyShapeStyle(cardStroke),
                                  lineWidth: isSelected(package) ? 2 : 1)
            )
            // Floating badge riding the card's top edge — original design.
            .overlay(alignment: .top) {
                Text("3-DAY FREE TRIAL")
                    .font(.system(size: 11, weight: .heavy))
                    .kerning(0.5)
                    .foregroundStyle(inkOnGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(goldGradient))
                    .offset(y: -11)
            }
            .padding(.top, 11) // room for the badge overhang
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected(package) ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("paywall.plan.yearly")
    }

    private func weeklyCard(_ package: Package) -> some View {
        Button { model.selectedPackage = package } label: {
            HStack {
                Text("Weekly")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                Spacer(minLength: 8)
                if let perWeek = model.perWeekString(for: package) {
                    Text(perWeek)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected(package) ? 0.05 : 0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected(package) ? AnyShapeStyle(goldGradient)
                                                      : AnyShapeStyle(cardStroke),
                                  lineWidth: isSelected(package) ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected(package) ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("paywall.plan.weekly")
    }

    private func isSelected(_ package: Package) -> Bool {
        model.selectedPackage?.identifier == package.identifier
    }

    // MARK: - Bottom stack

    private var noPaymentRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            Text("No payment due now")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var ctaButton: some View {
        Button {
            Task { await model.purchaseSelected() }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15).fill(goldGradient)
                if model.isPurchasing {
                    ProgressView().tint(inkOnGold)
                } else {
                    Text("Start my 3-day free trial")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(inkOnGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .shadow(color: goldDeep.opacity(0.35), radius: 14, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(model.isPurchasing || model.selectedPackage == nil)
        .accessibilityIdentifier("paywall.startTrialButton")
    }

    @ViewBuilder
    private var footnote: some View {
        if let annual = model.annualPackage {
            Text("3 days free, then \(annual.storeProduct.localizedPriceString) per year (\(model.perMonthString(for: annual))/mo)")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "8B8698"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    private var footerLinks: some View {
        HStack(spacing: 34) {
            Button { UIApplication.shared.open(privacyURL) } label: { Text("Privacy") }
                .accessibilityIdentifier("paywall.privacy")
            Button { Task { await model.restore() } } label: { Text("Restore") }
                .accessibilityIdentifier("paywall.restore")
            Button { UIApplication.shared.open(termsURL) } label: { Text("Terms") }
                .accessibilityIdentifier("paywall.terms")
        }
        .buttonStyle(.plain)
        .font(.system(size: 13))
        .foregroundStyle(Color(hex: "716C80"))
        .padding(.vertical, 8)
    }

    // MARK: - Loading / Error

    private var loadingState: some View {
        VStack(spacing: 20) {
            closeButtonRow
            Spacer()
            ProgressView()
                .tint(gold)
                .scaleEffect(1.4)
            Text("Loading your plan…")
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: "A49FB3"))
            Spacer()
        }
    }

    private var errorState: some View {
        VStack(spacing: 22) {
            closeButtonRow
            Spacer()
            Image("AnalysisOwl")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
            Text("We couldn't load subscription options right now.")
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                Task { await model.reload() }
            } label: {
                Text("Try Again")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(inkOnGold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 15).fill(goldGradient))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            Spacer()
            footerLinks
        }
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
