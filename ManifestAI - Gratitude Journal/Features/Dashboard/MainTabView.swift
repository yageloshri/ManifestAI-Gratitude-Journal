// MainTabView.swift
// Live app root after onboarding: hosts the pixel-verified parity screens
// with real data (SwiftData, UserManager, NumerologyService) and navigation.

import SwiftUI
import SwiftData
import PhotosUI
import UserNotifications

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query private var boards: [VisionBoardEntity]
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var paywall = PaywallManager.shared

    @State private var tab: FigmaTab = {
        #if DEBUG
        // Smoke-test hook: launch with `-liveTab journal|vision|369|profile`
        if let i = ProcessInfo.processInfo.arguments.firstIndex(of: "-liveTab"),
           ProcessInfo.processInfo.arguments.indices.contains(i + 1) {
            switch ProcessInfo.processInfo.arguments[i + 1] {
            case "journal": return .journal
            case "vision": return .vision
            case "369": return .method369
            case "profile": return .profile
            default: break
            }
        }
        #endif
        return .today
    }()

    @Environment(\.scenePhase) private var scenePhase

    // Today
    @State private var showDailyInsight = false
    @State private var dailyInsight: PersonalizedInsight?

    // Journal
    private enum JournalRoute { case list, write, entry(JournalEntry) }
    @State private var journalRoute: JournalRoute = .list
    @State private var draftText: String = ""
    @State private var draftColorIndex: Int = 0
    @State private var editingEntry: JournalEntry?       // non-nil = editing, not creating
    @State private var elevatingIDs: Set<UUID> = []      // Gemini calls in flight
    @State private var failedElevation: JournalEntry?    // last entry whose elevation failed
    @State private var showElevateError = false

    // Vision
    private enum VisionRoute { case home, category, photos(String), upload(String) }
    @State private var visionRoute: VisionRoute = .home
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var pickedImage: UIImage?     // first pick, upload-screen preview
    @State private var showPhotoPicker = false
    private struct EditorCategory: Identifiable { let id = UUID(); let name: String }
    @State private var editorCategory: EditorCategory?   // non-nil presents the editor
    @State private var editingBoard: VisionBoardEntity?  // non-nil re-opens that board for editing (Task 1)

    // 369 — time-window gated (Ritual369Manager): 3× morning / 6× afternoon /
    // 9× night, persisted per day, 33-day cycle.
    private enum Flow369 { case method, how, intention, ritual }
    // Landing screen is decided on entry (see initialFlow369): the intro shows
    // only once ever; afterwards we land on the ritual (if an intention exists)
    // or on Set Intention.
    @State private var flow369: Flow369 = MainTabView.initialFlow369()
    // Legacy single-intention key — now a ONE-WAY mirror of the active
    // intention (written by IntentionStore) kept only for external readers.
    @AppStorage("intention369") private var intention369: String = ""
    @AppStorage("has_seen_369_intro") private var hasSeen369Intro = false
    @ObservedObject private var intentionStore = IntentionStore.shared
    /// Editor draft for Set Intention (kept separate so typing doesn't mutate
    /// the active intention until "Start Manifesting").
    @State private var intentionDraft: String = ""
    /// Non-nil = the Set Intention editor is refining this saved intention;
    /// nil = it will create a new one.
    @State private var editingIntentionId: UUID?
    @State private var showIntentionsManager = false
    @State private var ritualDraft: String = ""
    @ObservedObject private var ritualManager = Ritual369Manager.shared
    /// Re-evaluated by a timer so locked windows open (and midnight rolls
    /// over) without the user leaving and re-entering the screen.
    @State private var ritualClock: Date = MainTabView.ritualNow()
    private let ritualTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    // Profile
    private enum ProfileRoute { case main, personalInfo, personalInfoEdit, upgradePro }
    @State private var profileRoute: ProfileRoute = .main
    @AppStorage("daily_reminders_on") private var remindersOn = false
    @State private var showLanguagePicker = false

    var body: some View {
        ZStack {
            Group {
                switch tab {
                case .today: todayTab
                case .journal: journalTab
                case .vision: visionTab
                case .method369: tab369
                case .profile: profileTab
                }
            }
            .transition(.opacity)
        }
        // One animation driver for every tab/route change — tab switches
        // crossfade, inner screens slide in (see each tab's .transition).
        .animation(.easeInOut(duration: 0.28), value: navAnimationKey)
        #if DEBUG
        .onAppear {
            // Smoke-test hook: `-ritual369Reset` clears the 369 daily progress
            if ProcessInfo.processInfo.arguments.contains("-ritual369Reset") {
                Ritual369Manager.shared.debugReset()
            }
            // Smoke-test hook: `-seedJournal` inserts sample entries once
            if ProcessInfo.processInfo.arguments.contains("-seedJournal"), entries.isEmpty {
                modelContext.insert(JournalEntry(rawText: "I am grateful for my family and the fresh start today."))
                modelContext.insert(JournalEntry(
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    rawText: "Grateful for progress on my app.",
                    elevatedText: "Today I honour the steady progress on my app — each step compounds into the life I am building."))
                try? modelContext.save()
            }
        }
        #endif
        .photosPicker(isPresented: $showPhotoPicker, selection: $pickedItems,
                      maxSelectionCount: 6, matching: .images)
        .onChange(of: pickedItems) { _, items in
            guard let first = items.first else { pickedImage = nil; return }
            Task {
                if let data = try? await first.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    pickedImage = img
                }
            }
        }
        .fullScreenCover(item: $editorCategory) { category in
            VisionEditorSheet(category: category.name, items: pickedItems) {
                // saved or closed → back to the vision home (boards gallery)
                pickedItems = []
                pickedImage = nil
                visionRoute = .home
            }
        }
        .fullScreenCover(item: $editingBoard) { board in
            VisionEditBoardSheet(board: board)
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView(onClose: { showLanguagePicker = false })
        }
        .onAppear {
            presentPostOnboardingPaywallIfNeeded()
            SharedDataManager.shared.saveStreak(streak)
        }
        // Native RevenueCat paywall. onDismiss re-presents under the hard
        // paywall (closing without a purchase brings it back); a successful
        // purchase/restore sets isPro and stays closed.
        .fullScreenCover(isPresented: $paywall.isPresented, onDismiss: {
            paywall.handleDismiss()
        }) {
            PaywallView(onClose: { paywall.isPresented = false })
        }
        .onReceive(ritualTimer) { _ in ritualClock = Self.ritualNow() }
        // Notification "Write Now" action / notification tap → 369 tab.
        .onReceive(NotificationCenter.default.publisher(for: .openRitualRequested)) { _ in
            switchTab(.method369)
        }
        // Widget button / Siri App Intents leave a pending deep link.
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            // Hard paywall: re-evaluate every time the app comes to the fore.
            paywall.enforceHardPaywallIfNeeded()
            guard let link = SharedDataManager.shared.consumePendingDeepLink() else { return }
            if link == "ritual" { switchTab(.method369); flow369 = .ritual }
            if link == "journal_write" { switchTab(.journal); journalRoute = .write }
        }
        // Keep the Lock Screen / Home Screen widgets' streak in sync.
        .onChange(of: streak) { _, newValue in
            SharedDataManager.shared.saveStreak(newValue)
        }
        .alert("Couldn't elevate your entry", isPresented: $showElevateError) {
            Button("Try Again") {
                if let entry = failedElevation { elevate(entry) }
            }
            Button("Not Now", role: .cancel) { failedElevation = nil }
        } message: {
            Text("The AI rewrite didn't go through — check your connection and try again. Your original entry is saved.")
        }
    }

    /// HARD paywall: the app requires an active subscription (3-day trial
    /// included) — a non-subscribed user is always brought back to the
    /// paywall, on first launch after onboarding and on every later launch.
    /// Re-presentation after a dismissed paywall is handled by
    /// PaywallManager.handleDismiss (the fullScreenCover onDismiss).
    private func presentPostOnboardingPaywallIfNeeded() {
        UserDefaults.standard.set(false, forKey: "should_show_paywall_after_onboarding")
        guard PaywallManager.hardPaywallEnforced else { return }
        guard !SubscriptionManager.shared.isPro else { return }
        // Let the onboarding → main transition settle before presenting.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PaywallManager.shared.enforceHardPaywallIfNeeded()
        }
    }

    // MARK: - Data

    private var dailyNumber: Int {
        NumerologyService.shared.calculatePersonalDayNumber(birthDate: userManager.birthDate)
    }

    /// Journal streak with streak-freeze protection (retention-plan §3.6):
    /// an available grace day bridges a single missed day instead of
    /// resetting the count to zero.
    private var streak: Int {
        StreakFreezeManager.shared.effectiveJournalStreak(
            entryDays: Set(entries.map { $0.date })
        )
    }

    /// Free-tier usage is a persistent per-week counter, not a live row count —
    /// otherwise deleting entries would refund quota indefinitely. Existing
    /// rows still count as a floor so pre-counter installs can't over-write.
    private static func weekKey(_ date: Date = Date()) -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "journal_week_used_\(comps.yearForWeekOfYear ?? 0)_\(comps.weekOfYear ?? 0)"
    }

    private var usedThisWeek: Int {
        let cal = Calendar.current
        let weekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let liveCount = entries.filter { $0.date >= weekStart }.count
        return max(UserDefaults.standard.integer(forKey: Self.weekKey()), liveCount)
    }

    private func countEntryAgainstQuota() {
        let key = Self.weekKey()
        UserDefaults.standard.set(usedThisWeek + 1, forKey: key)
        // §3.4: a saved journal entry counts as the first meaningful action
        // that primes the contextual notification-permission ask.
        FirstMeaningfulAction.markCompletedIfNeeded()
    }

    /// Hard paywall: every user is subscribed — the old "N free entries left"
    /// quota banner is replaced by a premium-status line (owner decision).
    private var freeEntriesText: String {
        String(localized: "You're a Premium member")
    }

    private func switchTab(_ newTab: FigmaTab) {
        tab = newTab
        journalRoute = .list
        visionRoute = .home
        profileRoute = .main
        // Re-decide the 369 landing screen every time the tab is entered.
        if newTab == .method369 {
            flow369 = Self.initialFlow369()
            if flow369 == .intention {
                editingIntentionId = nil
                intentionDraft = ""
            }
        }
    }

    // MARK: - Navigation animation key
    // A single Equatable fingerprint of "which screen is showing" — drives
    // the .animation on the root so every tab/route change is animated.
    private var navAnimationKey: String {
        "\(tab.rawValue)-\(journalRouteKey)-\(visionRouteKey)-\(flow369Key)-\(profileRouteKey)"
    }

    private var journalRouteKey: Int {
        switch journalRoute { case .list: return 0; case .write: return 1; case .entry: return 2 }
    }

    private var visionRouteKey: Int {
        switch visionRoute { case .home: return 0; case .category: return 1; case .photos: return 2; case .upload: return 3 }
    }

    private var flow369Key: Int {
        switch flow369 { case .method: return 0; case .how: return 1; case .intention: return 2; case .ritual: return 3 }
    }

    private var profileRouteKey: Int {
        switch profileRoute { case .main: return 0; case .personalInfo: return 1; case .personalInfoEdit: return 2; case .upgradePro: return 3 }
    }

    // MARK: - Today

    private var todayTab: some View {
        ZStack {
            HomeView(
                userName: userManager.userName,
                dailyNumber: dailyNumber,
                streak: streak,
                totalEntries: entries.count,
                boardCount: boards.count,
                onSelectTab: switchTab,
                onOpenNumerology: { openDailyInsight() },
                onOpenJournal: { switchTab(.journal) },
                onOpenVision: { switchTab(.vision) },
                onOpen369: { switchTab(.method369) }
            )

            // Kept mounted (slid off-screen) instead of if-inserted: building
            // this screen's glass/blur stack on first tap caused a visible
            // hitch before the sheet appeared. Pre-mounted, opening is instant.
            GeometryReader { geo in
                ParityDailyNumerologyView(
                    userName: userManager.userName,
                    dailyNumber: dailyNumber,
                    insight: dailyInsight,
                    onClose: { showDailyInsight = false },
                    liveOverlay: true
                )
                .offset(y: showDailyInsight ? 0 : geo.size.height * 1.2)
                .opacity(showDailyInsight ? 1 : 0)
                .allowsHitTesting(showDailyInsight)
            }
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.3), value: showDailyInsight)
        // The day's Gemini insight is prefetched (cached once per day), so by
        // the time the user taps "Read Full Insight" the final content is
        // already there — no mid-read text swap.
        .task {
            if dailyInsight == nil {
                dailyInsight = DailyInsightManager.shared.getFallbackInsight(for: dailyNumber)
            }
            if let insight = try? await DailyInsightManager.shared.fetchDailyInsight() {
                withAnimation(.easeInOut(duration: 0.25)) { dailyInsight = insight }
            }
        }
    }

    /// Real daily content: the reading is prefetched when Home appears; the
    /// tap only slides the (already-built) screen in.
    private func openDailyInsight() {
        if dailyInsight == nil {
            dailyInsight = DailyInsightManager.shared.getFallbackInsight(for: dailyNumber)
        }
        showDailyInsight = true
        Task {
            if let insight = try? await DailyInsightManager.shared.fetchDailyInsight() {
                withAnimation(.easeInOut(duration: 0.25)) { dailyInsight = insight }
            }
        }
    }

    // MARK: - Journal

    private var journalTab: some View {
        ZStack {
        Group {
            switch journalRoute {
            case .list:
                if entries.isEmpty {
                    ParityJournalEmptyView(
                        journeyCount: 0,
                        freeEntriesText: freeEntriesText,
                        onSelectTab: switchTab,
                        onWriteEntry: { startWriting() }
                    )
                } else {
                    ParityJournalListView(
                        journeyCount: entries.count,
                        freeEntriesText: freeEntriesText,
                        entries: entries.map { listRow(for: $0) },
                        onSelectTab: switchTab,
                        onWriteEntry: { startWriting() },
                        onSelectEntry: { row in
                            if let entry = entries.first(where: { $0.id.uuidString == row.id.uuidString }) {
                                journalRoute = .entry(entry)
                            }
                        }
                    )
                }
            case .write:
                ParityJournalWriteView(
                    dateTitle: Self.dayTitle(editingEntry?.date ?? Date()),
                    selectedColorIndex: draftColorIndex,
                    liveText: $draftText,
                    onBack: { saveDraftIfNeeded(); journalRoute = .list },
                    onElevate: { elevateDraft() },
                    onElevateApproved: { original, approved in
                        saveApprovedElevation(original: original, approved: approved)
                    },
                    onSelectColor: { draftColorIndex = $0 }
                )
            case .entry(let entry):
                ParityJournalEntryView(
                    variant: entry.isElevated ? .elevated
                           : (entry.tintIndex == 0 ? .plain : .color),
                    dateTitle: Self.dayTitle(entry.date),
                    entryText: entry.elevatedText ?? entry.rawText,
                    onBack: { journalRoute = .list },
                    onElevate: {
                        // Fallback path (parity/mock contexts only): elevate
                        // in the background; the list row flips when Gemini
                        // responds. The live cinematic uses onElevateApproved.
                        elevate(entry)
                        journalRoute = .list
                    },
                    onEdit: {
                        draftText = entry.isElevated ? (entry.elevatedText ?? entry.rawText)
                                                     : entry.rawText
                        draftColorIndex = entry.tintIndex
                        editingEntry = entry
                        journalRoute = .write
                    },
                    onDelete: {
                        modelContext.delete(entry)
                        try? modelContext.save()
                        journalRoute = .list
                    },
                    onSelectColor: { i in
                        entry.colorIndex = i
                        try? modelContext.save()
                    },
                    onElevateApproved: { approved in
                        // The user already saw and approved this wording in
                        // the Elevate cinematic — persist it verbatim.
                        entry.elevatedText = approved
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        try? modelContext.save()
                        journalRoute = .list
                    },
                    tintHex: Self.swatchHex(entry.tintIndex),
                    selectedColorIndex: entry.tintIndex
                )
            }
        }
        // write/entry screens (no tab bar) slide in from the right
        .id(journalRouteKey)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
        }
        .transition(.opacity) // tab-level switches crossfade
    }

    /// Journal swatch palette (same hexes as ParityColorPicker's spec row).
    private static let swatchHexes = ["32166E", "560E50", "28450C", "45260C",
                                      "450C33", "0E4356", "403B4A", "365111", "13217A"]

    private static func swatchHex(_ index: Int) -> String {
        swatchHexes.indices.contains(index) ? swatchHexes[index] : swatchHexes[0]
    }

    private func listRow(for entry: JournalEntry) -> ParityJournalListEntry {
        ParityJournalListEntry(
            id: entry.id,
            date: Self.listDate(entry.date),
            title: elevatingIDs.contains(entry.id) ? "Elevating…"
                 : (entry.isElevated ? "Elevated Entry" : "Journal Entry"),
            body: entry.elevatedText ?? entry.rawText,
            cardHeight: 127,
            tinted: entry.isElevated
        )
    }

    /// Enforce the advertised free tier: 3 entries/week, unlimited for Pro.
    private func startWriting() {
        if SubscriptionManager.shared.canWriteJournalEntry(entriesThisWeek: usedThisWeek) {
            draftText = ""
            draftColorIndex = 0
            editingEntry = nil
            journalRoute = .write
        } else {
            PaywallManager.shared.present()
        }
    }

    private func saveDraftIfNeeded() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        defer { draftText = ""; editingEntry = nil }
        guard !text.isEmpty else { return }
        if let entry = editingEntry {
            // Editing in place: update whichever text the user was shown.
            if entry.isElevated { entry.elevatedText = text } else { entry.rawText = text }
            entry.colorIndex = draftColorIndex
        } else {
            modelContext.insert(JournalEntry(rawText: text, colorIndex: draftColorIndex))
            countEntryAgainstQuota()
        }
        try? modelContext.save()
    }

    /// "Elevate with AI": save the entry, then rewrite it with Gemini in the
    /// background — the list row flips to "Elevated Entry" when it lands.
    private func elevateDraft() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let entry: JournalEntry
        if let editing = editingEntry {
            if editing.isElevated { editing.elevatedText = text } else { editing.rawText = text }
            editing.colorIndex = draftColorIndex
            entry = editing
        } else {
            entry = JournalEntry(rawText: text, colorIndex: draftColorIndex)
            modelContext.insert(entry)
            countEntryAgainstQuota()
        }
        try? modelContext.save()
        draftText = ""
        editingEntry = nil
        journalRoute = .list
        elevate(entry)
    }

    /// Persist an elevation the user already approved in the Elevate
    /// cinematic (write flow): save the original as rawText and the approved
    /// wording verbatim as elevatedText — no second Gemini call.
    private func saveApprovedElevation(original: String, approved: String) {
        let approvedText = approved.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !approvedText.isEmpty else { return }

        if let editing = editingEntry {
            if !editing.isElevated { editing.rawText = original }
            editing.elevatedText = approvedText
            editing.colorIndex = draftColorIndex
        } else {
            let entry = JournalEntry(rawText: original,
                                     elevatedText: approvedText,
                                     colorIndex: draftColorIndex)
            modelContext.insert(entry)
            countEntryAgainstQuota()
        }
        try? modelContext.save()
        draftText = ""
        editingEntry = nil
        journalRoute = .list
    }

    /// Run the Gemini rewrite for a saved entry, with an in-flight marker,
    /// deleted-entry guard, and an error alert with retry.
    private func elevate(_ entry: JournalEntry) {
        let source = entry.isElevated ? (entry.elevatedText ?? entry.rawText) : entry.rawText
        elevatingIDs.insert(entry.id)
        failedElevation = nil
        Task {
            do {
                let elevated = try await GeminiService.shared.generateElevation(from: source)
                // The user may have deleted the entry while Gemini was working.
                if !entry.isDeleted, entry.modelContext != nil {
                    entry.elevatedText = elevated.trimmingCharacters(in: .whitespacesAndNewlines)
                    try? modelContext.save()
                }
            } catch {
                if !entry.isDeleted, entry.modelContext != nil {
                    failedElevation = entry
                    showElevateError = true
                }
            }
            elevatingIDs.remove(entry.id)
        }
    }

    private static func dayTitle(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d MMMM"; f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    private static func listDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM d, yyyy 'at' hh:mm a"; f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    // MARK: - Vision

    private var visionTab: some View {
        ZStack {
        Group {
            switch visionRoute {
            case .home:
                if boards.isEmpty {
                    ParityVisionEmptyView(
                        onCreateBoard: { visionRoute = .category },
                        onSelectTab: switchTab
                    )
                } else {
                    ParityVisionBoardsView(
                        boards: boards.sorted { $0.date > $1.date },
                        onCreateBoard: { visionRoute = .category },
                        onDeleteBoard: { board in
                            modelContext.delete(board)
                            try? modelContext.save()
                        },
                        onEditBoard: { board in editingBoard = board },
                        onSelectTab: switchTab
                    )
                }
            case .category:
                ParityVisionCategoryView(
                    onBack: { visionRoute = .home },
                    onSelectCategory: { visionRoute = .photos($0) }
                )
            case .photos(let category):
                ParityVisionPhotosView(
                    promptTitle: Self.photosPrompt(for: category),
                    onBack: { visionRoute = .category },
                    onContinue: { visionRoute = .upload(category) }
                )
            case .upload(let category):
                ParityVisionUploadView(
                    liveImage: pickedImage,
                    onBack: { visionRoute = .photos(category) },
                    onChangePhoto: { showPhotoPicker = true },
                    onDeletePhoto: { pickedImage = nil; pickedItems = [] },
                    onUpload: { uploadTapped(category: category) }
                )
            }
        }
        // category/photos/upload screens slide in from the right
        .id(visionRouteKey)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
        }
        .transition(.opacity) // tab-level switches crossfade
    }

    /// Per-category "find your photos" prompt; Love is the Figma original,
    /// the rest follow its voice (the Figma frame only mocked Love).
    private static func photosPrompt(for category: String) -> String {
        switch category {
        case "Wealth":
            return String(localized: "Find a photo that represents the abundance you're calling in. Is it financial freedom? A dream home? A thriving business?")
        case "Health":
            return String(localized: "Find a photo that represents the vitality you crave. Is it strength? Calm energy? Waking up rested and alive?")
        case "Travel":
            return String(localized: "Find a photo that represents the journey you dream of. Is it a far-away city? An ocean sunrise? A mountain trail?")
        case "Career":
            return String(localized: "Find a photo that represents the success you're building. Is it a dream role? Your own venture? A moment of recognition?")
        case "Peace":
            return String(localized: "Find a photo that represents the calm you seek. Is it a quiet morning? Deep stillness? A place that feels like home?")
        case "Family":
            return String(localized: "Find a photo that represents the family life you cherish. Is it laughter at dinner? A warm embrace? Time together at home?")
        default: // "Love" — Figma 326:13106 verbatim
            return String(localized: "Find a photo that represents the partnership you crave. Is it a wedding? A quiet moment at home? Holding hands?")
        }
    }

    /// "Upload Image": no photos yet → open the gallery; photos picked →
    /// open the iPhone wallpaper editor seeded with them.
    private func uploadTapped(category: String) {
        if pickedItems.isEmpty {
            showPhotoPicker = true
        } else {
            editorCategory = EditorCategory(name: category)
        }
    }

    // MARK: - 369

    private var tab369: some View {
        Group {
            switch flow369 {
            case .method:
                Parity369MethodView(
                    onNext: { flow369 = .how },
                    onSkip: { passIntro() },
                    onSelectTab: switchTab
                )
            case .how:
                Parity369HowItWorksView(
                    onNext: { passIntro() },
                    onSkip: { passIntro() },
                    onSelectTab: switchTab
                )
            case .intention:
                Parity369SetIntentionView(
                    liveText: $intentionDraft,
                    onStart: { commitIntention() },
                    onSkip: { flow369 = .ritual },
                    onSelectTab: switchTab
                )
            case .ritual:
                ritualScreen
            }
        }
        // 369 flow screens carry their own tab bar — crossfade only, so the
        // bar never appears to slide sideways.
        .id(flow369Key)
        .transition(.opacity)
        // "My Intentions" manager — opened from the ritual affirmation chip.
        .sheet(isPresented: $showIntentionsManager) {
            Parity369IntentionsView(
                onSetActive: { id in intentionStore.setActive(id) },
                onEdit: { intention in
                    showIntentionsManager = false
                    editingIntentionId = intention.id
                    intentionDraft = intention.text
                    flow369 = .intention
                },
                onNew: {
                    showIntentionsManager = false
                    editingIntentionId = nil
                    intentionDraft = ""
                    flow369 = .intention
                },
                onClose: { showIntentionsManager = false }
            )
        }
    }

    /// Landing screen for the 369 tab: the intro is shown only once ever;
    /// afterwards land on the ritual when an intention exists, else on Set
    /// Intention. Read directly from persistence so it can seed @State.
    private static func initialFlow369() -> Flow369 {
        guard UserDefaults.standard.bool(forKey: "has_seen_369_intro") else { return .method }
        let active = IntentionStore.shared.activeText.trimmingCharacters(in: .whitespacesAndNewlines)
        return active.isEmpty ? .intention : .ritual
    }

    /// User passed the intro (Next-Next or SKIP): remember it forever and move
    /// on to the ritual (if an intention already exists) or to Set Intention.
    private func passIntro() {
        hasSeen369Intro = true
        if intentionStore.activeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            editingIntentionId = nil
            intentionDraft = ""
            flow369 = .intention
        } else {
            flow369 = .ritual
        }
    }

    /// "Start Manifesting": save the draft (new or edited), make it active,
    /// and go to the ritual. Empty drafts are ignored.
    private func commitIntention() {
        let text = intentionDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        if let id = editingIntentionId {
            intentionStore.update(id: id, text: text)
            intentionStore.setActive(id)
        } else {
            intentionStore.add(text: text)   // add makes it active
        }
        editingIntentionId = nil
        intentionDraft = ""
        flow369 = .ritual
    }

    /// Ritual back arrow → refine the active intention in the Set Intention
    /// editor (or start a new one when none exists).
    private func editActiveIntention() {
        if let active = intentionStore.activeIntention {
            editingIntentionId = active.id
            intentionDraft = active.text
        } else {
            editingIntentionId = nil
            intentionDraft = ""
        }
        flow369 = .intention
    }

    private var ritualAffirmation: String {
        let active = intentionStore.activeText.trimmingCharacters(in: .whitespacesAndNewlines)
        return active.isEmpty
            ? "I am so happy and grateful now that I am earning $10,000 a month."
            : active
    }

    private var ritualDayText: String {
        // Acknowledge a streak reset instead of silently showing Day 1.
        if let lost = ritualManager.streakResetNotice, lost > 0 {
            return "Day 1 of 33 · streak reset (was day \(lost))"
        }
        return "Day \(ritualManager.dayNumber) of 33"
    }

    /// Real clock, overridable in DEBUG with `-ritual369Hour <h>` for testing
    /// the time windows on the simulator.
    private static func ritualNow() -> Date {
        #if DEBUG
        if let i = ProcessInfo.processInfo.arguments.firstIndex(of: "-ritual369Hour"),
           ProcessInfo.processInfo.arguments.indices.contains(i + 1),
           let h = Int(ProcessInfo.processInfo.arguments[i + 1]) {
            return Calendar.current.date(bySettingHour: h, minute: 30, second: 0, of: Date()) ?? Date()
        }
        #endif
        return Date()
    }

    @ViewBuilder
    private var ritualScreen: some View {
        switch ritualManager.screenState(now: ritualClock) {
        case .writing(let phase, let done, let target):
            Parity369RitualView(
                phase: phase,
                affirmation: ritualAffirmation,
                liveText: $ritualDraft,
                completedCount: done,
                targetCount: target,
                dayText: ritualDayText,
                onBack: { editActiveIntention() },
                onManageIntentions: { showIntentionsManager = true },
                onSave: { saveRitualWriting(phase: phase) },
                onSelectTab: switchTab
            )
        case .phaseDone(let current, let next, let opensAt):
            Parity369RitualView(
                phase: current,
                affirmation: ritualAffirmation,
                completedCount: ritualManager.target(for: current),
                targetCount: ritualManager.target(for: current),
                dayText: ritualDayText,
                lockedInfo: (
                    "\(current.title) complete",
                    next.map { "\($0.title) opens at \(opensAt ?? "")" }
                        ?? "All done for today — see you tomorrow morning"
                ),
                onBack: { editActiveIntention() },
                onManageIntentions: { showIntentionsManager = true },
                onSelectTab: switchTab
            )
        case .beforeMorning(let opensAt):
            Parity369RitualView(
                phase: .morning,
                affirmation: ritualAffirmation,
                completedCount: 0,
                targetCount: ritualManager.target(for: .morning),
                dayText: ritualDayText,
                lockedInfo: ("A new day is coming", "Morning Ritual opens at \(opensAt)"),
                onBack: { editActiveIntention() },
                onManageIntentions: { showIntentionsManager = true },
                onSelectTab: switchTab
            )
        case .dayComplete:
            Parity369RitualView(
                phase: .night,
                affirmation: ritualAffirmation,
                completedCount: ritualManager.target(for: .night),
                targetCount: ritualManager.target(for: .night),
                dayText: ritualDayText,
                lockedInfo: ("\(ritualDayText) complete!",
                             "All 18 affirmations written. Come back tomorrow morning."),
                onBack: { editActiveIntention() },
                onManageIntentions: { showIntentionsManager = true },
                onSelectTab: switchTab
            )
        case .cycleComplete:
            Parity369RitualView(
                phase: .night,
                affirmation: ritualAffirmation,
                completedCount: ritualManager.target(for: .night),
                targetCount: ritualManager.target(for: .night),
                dayText: "33 of 33 days complete",
                lockedInfo: ("Challenge complete!",
                             "33 consecutive days of manifestation — extraordinary. Set a new intention and begin again whenever you're ready."),
                lockedActionTitle: "Start a New 33-Day Challenge",
                onBack: { editActiveIntention() },
                onManageIntentions: { showIntentionsManager = true },
                onSave: {
                    // New challenge: keep saved intentions, open a fresh
                    // Set Intention editor for this next cycle.
                    ritualManager.startNewCycle(now: ritualClock)
                    editingIntentionId = nil
                    intentionDraft = ""
                    flow369 = .intention
                },
                onSelectTab: switchTab
            )
        }
    }

    /// One save = one written affirmation. The text must actually be written
    /// (that's the method); it is cleared for the next repetition.
    private func saveRitualWriting(phase: Parity369RitualView.RitualPhase) {
        guard !ritualDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        ritualManager.record(phase, now: Self.ritualNow())
        ritualDraft = ""
    }

    // MARK: - Profile

    private var profileTab: some View {
        Group {
            switch profileRoute {
            case .main:
                ParityProfileView(
                    userName: userManager.userName,
                    avatarInitial: String(userManager.userName.prefix(1)),
                    personalDayNumber: dailyNumber,
                    remindersOn: remindersOn,
                    onSelectTab: switchTab,
                    onSelectRow: handleProfileRow
                )
            case .personalInfo:
                ParityPersonalInfoView(
                    name: userManager.userName,
                    dob: Self.dobString(userManager.birthDate),
                    avatarInitial: String(userManager.userName.prefix(1)),
                    onBack: { profileRoute = .main },
                    onEdit: { profileRoute = .personalInfoEdit }
                )
            case .personalInfoEdit:
                ParityPersonalInfoEditView(
                    name: userManager.userName,
                    day: Self.comp(userManager.birthDate, "d"),
                    month: Self.comp(userManager.birthDate, "MMMM"),
                    year: Self.comp(userManager.birthDate, "yyyy"),
                    avatarInitial: String(userManager.userName.prefix(1)),
                    onBack: { profileRoute = .personalInfo },
                    onSave: { name, birthDate in
                        UserManager.shared.saveUser(name: name, birthDate: birthDate)
                        profileRoute = .personalInfo
                    }
                )
            case .upgradePro:
                ParityUpgradeProView(
                    onStartTrial: { PaywallManager.shared.present() },
                    onRestore: { Task { try? await PurchasesManager.shared.restore() } },
                    onPrivacy: {
                        if let url = URL(string: "https://dream-manifest-shine.lovable.app/privacy") {
                            UIApplication.shared.open(url)
                        }
                    },
                    onTerms: {
                        if let url = URL(string: "https://dream-manifest-shine.lovable.app/terms") {
                            UIApplication.shared.open(url)
                        }
                    },
                    onBack: { profileRoute = .main }
                )
            }
        }
        // profile detail screens crossfade (some carry their own tab bar)
        .id(profileRouteKey)
        .transition(.opacity)
    }

    private func handleProfileRow(_ rowId: String) {
        switch rowId {
        case "personalInfo": profileRoute = .personalInfo
        case "upgradePro": profileRoute = .upgradePro
        case "dailyReminders": toggleReminders()
        case "support":
            if let url = URL(string: "https://dream-manifest-shine.lovable.app/support") {
                UIApplication.shared.open(url)
            }
        case "privacyPolicy":
            if let url = URL(string: "https://dream-manifest-shine.lovable.app/privacy") {
                UIApplication.shared.open(url)
            }
        case "language":
            showLanguagePicker = true
        case "logout":
            logout()
        default: break
        }
    }

    /// Log out = a fresh start: the next onboarding run must not inherit this
    /// user's journal, boards, intention, or ritual progress. (Purchases are
    /// NOT touched — isPro re-syncs from RevenueCat.)
    private func logout() {
        for entry in entries { modelContext.delete(entry) }
        for board in boards { modelContext.delete(board) }
        try? modelContext.save()

        let defaults = UserDefaults.standard
        // Clears intentions369 list + active id + the intention369 mirror +
        // the has_seen_369_intro flag (next user starts from the intro).
        IntentionStore.shared.clearAll()
        defaults.removeObject(forKey: "intention369")
        defaults.removeObject(forKey: "ritual369State")
        defaults.removeObject(forKey: "cachedPersonalizedInsight")
        defaults.removeObject(forKey: "lastInsightDate")
        defaults.removeObject(forKey: "should_show_paywall_after_onboarding")

        remindersOn = false
        NotificationManager369.shared.setNotificationsEnabled(false)
        NotificationManager369.shared.cancelAllNotifications()

        AppState.shared.hasCompletedOnboarding = false
    }

    /// Reminders switch = real local notifications for the three 369 windows
    /// (NotificationManager369: 8:00 / 14:00 / 20:00 by default).
    private func toggleReminders() {
        let nm = NotificationManager369.shared
        if remindersOn {
            remindersOn = false
            nm.setNotificationsEnabled(false)
            nm.cancelAllNotifications()
        } else {
            // If permission was denied earlier, a new request is a silent
            // no-op — send the user to Settings instead of failing quietly.
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .denied {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        return
                    }
                    nm.requestPermission { granted in
                        DispatchQueue.main.async {
                            remindersOn = granted
                            if granted {
                                nm.setNotificationsEnabled(true)
                                nm.scheduleAllNotifications()
                            }
                        }
                    }
                }
            }
        }
    }

    private static func dobString(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d MMMM yyyy"; f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

    private static func comp(_ date: Date, _ fmt: String) -> String {
        let f = DateFormatter(); f.dateFormat = fmt; f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }
}

/// Presents the iPhone-mockup wallpaper editor with a fresh view model per
/// session, seeded with the photos picked in the parity upload flow.
private struct VisionEditorSheet: View {
    let category: String
    let items: [PhotosPickerItem]
    var onFinished: () -> Void

    @StateObject private var vm = VisionBoardViewModel()

    var body: some View {
        VisionBoardEditorView(viewModel: vm)
            .onAppear {
                vm.selectedEnergies = [category]
                if vm.gridItems.isEmpty, !items.isEmpty {
                    vm.loadPhotos(from: items)
                }
            }
            .onDisappear { onFinished() }
    }
}

/// Reopens an existing saved board in the same grid editor (Task 1), with a
/// fresh view model per session that restores every photo (crop/zoom) and
/// the saved grid template via `loadBoard`. The editor's own Save button
/// updates this same `VisionBoardEntity` in place (matched by id in
/// `VisionBoardViewModel.saveBoard`), so editing never creates a duplicate.
private struct VisionEditBoardSheet: View {
    let board: VisionBoardEntity

    @StateObject private var vm = VisionBoardViewModel()

    var body: some View {
        VisionBoardEditorView(viewModel: vm)
            .onAppear {
                vm.loadBoard(board)
            }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [JournalEntry.self, VisionBoardEntity.self], inMemory: true)
}
