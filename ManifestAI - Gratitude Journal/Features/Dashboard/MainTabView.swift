// MainTabView.swift
// Live app root after onboarding: hosts the pixel-verified parity screens
// with real data (SwiftData, UserManager, NumerologyService) and navigation.

import SwiftUI
import SwiftData
import PhotosUI
import SuperwallKit
import UserNotifications

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query private var boards: [VisionBoardEntity]
    @ObservedObject private var userManager = UserManager.shared

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

    // 369 — time-window gated (Ritual369Manager): 3× morning / 6× afternoon /
    // 9× night, persisted per day, 33-day cycle.
    private enum Flow369 { case method, how, intention, ritual }
    @State private var flow369: Flow369 = .method
    @AppStorage("intention369") private var intention369: String = ""
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

    var body: some View {
        ZStack {
            switch tab {
            case .today: todayTab
            case .journal: journalTab
            case .vision: visionTab
            case .method369: tab369
            case .profile: profileTab
            }
        }
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
        .onAppear { presentPostOnboardingPaywallIfNeeded() }
        .onReceive(ritualTimer) { _ in ritualClock = Self.ritualNow() }
        .alert("Couldn't elevate your entry", isPresented: $showElevateError) {
            Button("Try Again") {
                if let entry = failedElevation { elevate(entry) }
            }
            Button("Not Now", role: .cancel) { failedElevation = nil }
        } message: {
            Text("The AI rewrite didn't go through — check your connection and try again. Your original entry is saved.")
        }
    }

    /// Onboarding sets this flag for its post-completion paywall; it used to
    /// be consumed only by the legacy DashboardView, which never ships.
    private func presentPostOnboardingPaywallIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "should_show_paywall_after_onboarding") else { return }
        UserDefaults.standard.set(false, forKey: "should_show_paywall_after_onboarding")
        guard !SubscriptionManager.shared.isPro else { return }
        // Let the onboarding → main transition settle before presenting.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Superwall.shared.register(placement: "campaign_trigger")
        }
    }

    // MARK: - Data

    private var dailyNumber: Int {
        NumerologyService.shared.calculatePersonalDayNumber(birthDate: userManager.birthDate)
    }

    private var streak: Int {
        let cal = Calendar.current
        let days = Set(entries.map { cal.startOfDay(for: $0.date) })
        var count = 0
        var day = cal.startOfDay(for: Date())
        if !days.contains(day) {
            guard let prev = cal.date(byAdding: .day, value: -1, to: day), days.contains(prev) else { return 0 }
            day = prev
        }
        while days.contains(day) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return count
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
    }

    private var freeEntriesText: String {
        let left = max(0, 3 - usedThisWeek)
        return "\(left) Free entries left this week"
    }

    private func switchTab(_ newTab: FigmaTab) {
        tab = newTab
        journalRoute = .list
        visionRoute = .home
        profileRoute = .main
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

            if showDailyInsight {
                ParityDailyNumerologyView(
                    userName: userManager.userName,
                    dailyNumber: dailyNumber,
                    insight: dailyInsight,
                    onClose: { showDailyInsight = false }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showDailyInsight)
    }

    /// Real daily content: show the per-number reading immediately, then let
    /// the personalized Gemini insight (cached once per day) replace it.
    private func openDailyInsight() {
        if dailyInsight == nil {
            dailyInsight = DailyInsightManager.shared.getFallbackInsight(for: dailyNumber)
        }
        showDailyInsight = true
        Task {
            if let insight = try? await DailyInsightManager.shared.fetchDailyInsight() {
                dailyInsight = insight
            }
        }
    }

    // MARK: - Journal

    private var journalTab: some View {
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
                        // Elevate an already-saved entry; the list row flips
                        // to "Elevated Entry" when Gemini responds.
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
                    tintHex: Self.swatchHex(entry.tintIndex),
                    selectedColorIndex: entry.tintIndex
                )
            }
        }
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
            Superwall.shared.register(placement: "campaign_trigger")
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
    }

    /// Per-category "find your photos" prompt; Love is the Figma original,
    /// the rest follow its voice (the Figma frame only mocked Love).
    private static func photosPrompt(for category: String) -> String {
        switch category {
        case "Wealth":
            return "Find a photo that represents the abundance you're calling in. Is it financial freedom? A dream home? A thriving business?"
        case "Health":
            return "Find a photo that represents the vitality you crave. Is it strength? Calm energy? Waking up rested and alive?"
        case "Travel":
            return "Find a photo that represents the journey you dream of. Is it a far-away city? An ocean sunrise? A mountain trail?"
        case "Career":
            return "Find a photo that represents the success you're building. Is it a dream role? Your own venture? A moment of recognition?"
        case "Peace":
            return "Find a photo that represents the calm you seek. Is it a quiet morning? Deep stillness? A place that feels like home?"
        case "Family":
            return "Find a photo that represents the family life you cherish. Is it laughter at dinner? A warm embrace? Time together at home?"
        default: // "Love" — Figma 326:13106 verbatim
            return "Find a photo that represents the partnership you crave. Is it a wedding? A quiet moment at home? Holding hands?"
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
                    onSkip: { flow369 = intention369.isEmpty ? .intention : .ritual },
                    onSelectTab: switchTab
                )
            case .how:
                Parity369HowItWorksView(
                    onNext: { flow369 = .intention },
                    onSkip: { flow369 = .intention },
                    onSelectTab: switchTab
                )
            case .intention:
                Parity369SetIntentionView(
                    liveText: $intention369,
                    onStart: {
                        if !intention369.trimmingCharacters(in: .whitespaces).isEmpty {
                            flow369 = .ritual
                        }
                    },
                    onSkip: { flow369 = .method },
                    onSelectTab: switchTab
                )
            case .ritual:
                ritualScreen
            }
        }
    }

    private var ritualAffirmation: String {
        intention369.isEmpty
            ? "I am so happy and grateful now that I am earning $10,000 a month."
            : intention369
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
                onBack: { flow369 = .intention },
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
                onBack: { flow369 = .intention },
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
                onBack: { flow369 = .intention },
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
                onBack: { flow369 = .intention },
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
                onBack: { flow369 = .intention },
                onSave: {
                    ritualManager.startNewCycle(now: ritualClock)
                    intention369 = ""
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
                    onStartTrial: { Superwall.shared.register(placement: "campaign_trigger") },
                    onRestore: { Superwall.shared.restorePurchases { _ in } },
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
        case "logout":
            logout()
        default: break
        }
    }

    /// Log out = a fresh start: the next onboarding run must not inherit this
    /// user's journal, boards, intention, or ritual progress. (Purchases are
    /// NOT touched — isPro re-syncs from Superwall.)
    private func logout() {
        for entry in entries { modelContext.delete(entry) }
        for board in boards { modelContext.delete(board) }
        try? modelContext.save()

        let defaults = UserDefaults.standard
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

#Preview {
    MainTabView()
        .modelContainer(for: [JournalEntry.self, VisionBoardEntity.self], inMemory: true)
}
