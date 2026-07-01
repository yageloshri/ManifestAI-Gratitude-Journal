// ParityGallery.swift
// Debug-only deterministic screen renderer for Figma parity verification.
// Launch the app with: -parityScreen <id>
// Every screen renders immediately with fixed mock data — no navigation, no animation.

#if DEBUG
import SwiftUI

/// Stable string ids for every screen under parity verification.
/// Keep this list in sync with fidelity/CHECKLIST.md.
enum ParityScreen: String, CaseIterable {
    case welcome        // Figma 258:1851 "Onboarding"
    case name           // Figma 255:1190 "Name"
    case category       // Figma 255:1247 "Category"
    case problems       // Figma 256:1133 "Problems"
    case didyouknow     // Figma 257:1658 "Did you know"
    case dob            // Figma 268:1060 "DOB"
    case analysis       // Figma 270:437 "Analysis"
    case commitment     // Figma 282:570 "A promise to you self"
    case subscription   // Figma 294:691 "Subscription"
    case home           // Figma 300:2058 "Home" (Core App)
    case dailynumerology // Figma 321:1862 "Daily Numberology" (Home + sheet)
    case method369      // Figma 332:3006 "The 369 Method"
    case howitworks     // Figma 340:3232 "How it works?"
    case setintention   // Figma 341:3336 "Set Your Intention"
    case ritualMorning   = "ritual_morning"    // Figma 364:2234
    case ritualAfternoon = "ritual_afternoon"  // Figma 364:3878
    case ritualNight     = "ritual_night"      // Figma 364:4226
    case journalEmpty    = "journal_empty"     // Figma 324:1938
    case journalList     = "journal_list"      // Figma 324:12139
    case journalWrite    = "journal_write"     // Figma 324:11854
    case journalEntry    = "journal_entry"     // Figma 324:11997 (color variant)
    case visionEmpty     = "vision_empty"      // Figma 325:12675
    case visionCategory  = "vision_category"   // Figma 325:12793
    case visionUpload    = "vision_upload"     // Figma 326:13117
    case visionPhotos    = "vision_photos"     // Figma 327:1492
    case profile         // Figma 326:13312
    case personalInfo    = "personalinfo"      // Figma 330:1458
    case personalInfoEdit = "personalinfo_edit" // Figma 330:1645
    case dailyReminders  = "dailyreminders"    // Figma 331:2779
    case upgradePro      = "upgradepro"        // Figma 330:1770

    static func fromLaunchArguments() -> ParityScreen? {
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: "-parityScreen"),
              args.indices.contains(flagIndex + 1) else { return nil }
        return ParityScreen(rawValue: args[flagIndex + 1])
    }
}

struct ParityGalleryView: View {
    let screen: ParityScreen

    var body: some View {
        Group {
            switch screen {
            case .welcome:
                WelcomeStepView(onContinue: {}, parityMode: true)
            case .name:
                NameStepView(userName: .constant(""), onContinue: {}, onBack: {}, parityMode: true)
            case .category:
                BreakthroughStepView(selected: .constant(nil), onContinue: {}, onBack: {}, parityMode: true)
            case .commitment:
                CommitmentStepView(onComplete: {}, onBack: {}, parityMode: true)
            case .subscription:
                SubscriptionScreenView(parityMode: true)
            case .home:
                HomeView(parityMode: true)
            case .dailynumerology:
                ParityDailyNumerologyView(parityMode: true)
            case .method369:
                Parity369MethodView(parityMode: true)
            case .howitworks:
                Parity369HowItWorksView(parityMode: true)
            case .setintention:
                Parity369SetIntentionView(parityMode: true)
            case .ritualMorning:
                Parity369RitualView(phase: .morning, parityMode: true)
            case .ritualAfternoon:
                Parity369RitualView(phase: .afternoon, parityMode: true)
            case .ritualNight:
                Parity369RitualView(phase: .night, parityMode: true)
            case .journalEmpty:
                ParityJournalEmptyView(parityMode: true)
            case .journalList:
                ParityJournalListView(parityMode: true)
            case .journalWrite:
                ParityJournalWriteView(parityMode: true)
            case .journalEntry:
                ParityJournalEntryView(parityMode: true)
            case .visionEmpty:
                ParityVisionEmptyView(parityMode: true)
            case .visionCategory:
                ParityVisionCategoryView(parityMode: true)
            case .visionUpload:
                ParityVisionUploadView(parityMode: true)
            case .visionPhotos:
                ParityVisionPhotosView(parityMode: true)
            case .profile:
                ParityProfileView(parityMode: true)
            case .personalInfo:
                ParityPersonalInfoView(parityMode: true)
            case .personalInfoEdit:
                ParityPersonalInfoEditView(parityMode: true)
            case .dailyReminders:
                ParityDailyRemindersView(parityMode: true)
            case .upgradePro:
                ParityUpgradeProView(parityMode: true)
            case .analysis:
                AnalysisStepView(birthDate: Date(timeIntervalSince1970: 970_000_000),
                                 userName: "Ali", onContinue: {}, parityMode: true)
            case .dob:
                NumerologyStepView(
                    birthDate: .constant(Calendar.current.date(from: DateComponents(year: 2000, month: 9, day: 23))!),
                    onContinue: {}, onBack: {}, parityMode: true)
            case .didyouknow:
                ScienceStepView(onContinue: {}, onBack: {}, parityMode: true)
            case .problems:
                PainPointsStepView(selected: .constant(["Self-Doubt"]), userName: "Ali",
                                   onContinue: {}, onBack: {}, parityMode: true)
            }
        }
        .accessibilityIdentifier("parity.\(screen.rawValue)")
    }
}
#endif
