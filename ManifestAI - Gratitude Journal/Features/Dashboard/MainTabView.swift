// MainTabView.swift
// Live app root after onboarding: hosts the pixel-verified parity screens
// with real data (SwiftData, UserManager, NumerologyService) and navigation.

import SwiftUI
import SwiftData
import PhotosUI
import SuperwallKit

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

    // Journal
    private enum JournalRoute { case list, write, entry(JournalEntry) }
    @State private var journalRoute: JournalRoute = .list
    @State private var draftText: String = ""

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

    private var freeEntriesText: String {
        let cal = Calendar.current
        let weekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let used = entries.filter { $0.date >= weekStart }.count
        let left = max(0, 3 - used)
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
                onOpenNumerology: { showDailyInsight = true },
                onOpenJournal: { switchTab(.journal) },
                onOpenVision: { switchTab(.vision) },
                onOpen369: { switchTab(.method369) }
            )

            if showDailyInsight {
                ParityDailyNumerologyView(
                    userName: userManager.userName,
                    dailyNumber: dailyNumber,
                    onClose: { showDailyInsight = false }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showDailyInsight)
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
                    dateTitle: Self.dayTitle(Date()),
                    liveText: $draftText,
                    onBack: { saveDraftIfNeeded(); journalRoute = .list },
                    onElevate: { elevateDraft() }
                )
            case .entry(let entry):
                ParityJournalEntryView(
                    variant: entry.isElevated ? .elevated : .plain,
                    dateTitle: Self.dayTitle(entry.date),
                    entryText: entry.elevatedText ?? entry.rawText,
                    onBack: { journalRoute = .list },
                    onDelete: {
                        modelContext.delete(entry)
                        try? modelContext.save()
                        journalRoute = .list
                    }
                )
            }
        }
    }

    private func listRow(for entry: JournalEntry) -> ParityJournalListEntry {
        ParityJournalListEntry(
            id: entry.id,
            date: Self.listDate(entry.date),
            title: entry.isElevated ? "Elevated Entry" : "Journal Entry",
            body: entry.elevatedText ?? entry.rawText,
            cardHeight: 127,
            tinted: entry.isElevated
        )
    }

    /// Enforce the advertised free tier: 3 entries/week, unlimited for Pro.
    private func startWriting() {
        let cal = Calendar.current
        let weekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let used = entries.filter { $0.date >= weekStart }.count
        if SubscriptionManager.shared.canWriteJournalEntry(entriesThisWeek: used) {
            draftText = ""
            journalRoute = .write
        } else {
            Superwall.shared.register(placement: "campaign_trigger")
        }
    }

    private func saveDraftIfNeeded() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        modelContext.insert(JournalEntry(rawText: text))
        try? modelContext.save()
        draftText = ""
    }

    /// "Elevate with AI": save the entry, then rewrite it with Gemini in the
    /// background — the list row flips to "Elevated Entry" when it lands.
    private func elevateDraft() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let entry = JournalEntry(rawText: text)
        modelContext.insert(entry)
        try? modelContext.save()
        draftText = ""
        journalRoute = .list
        Task {
            if let elevated = try? await GeminiService.shared.generateElevation(from: text) {
                entry.elevatedText = elevated.trimmingCharacters(in: .whitespacesAndNewlines)
                try? modelContext.save()
            }
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

    private var ritualDayText: String { "Day \(ritualManager.dayNumber) of 33" }

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
        switch ritualManager.screenState(now: Self.ritualNow()) {
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
                    onSave: { profileRoute = .personalInfo }
                )
            case .upgradePro:
                ParityUpgradeProView(
                    onStartTrial: { Superwall.shared.register(placement: "campaign_trigger") },
                    onRestore: { Superwall.shared.restorePurchases { _ in } }
                )
                .overlay(alignment: .topLeading) {
                    // temporary back affordance over the panel's top-left corner
                    Color.clear
                        .frame(width: 60, height: 60)
                        .contentShape(Rectangle())
                        .onTapGesture { profileRoute = .main }
                }
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
            AppState.shared.hasCompletedOnboarding = false
        default: break
        }
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
