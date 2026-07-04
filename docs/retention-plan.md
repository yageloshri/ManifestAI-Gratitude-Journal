# ManifestAI Retention Plan — Notifications, Streaks & Return Visits

**Goal:** maximize daily (and multi-times-daily) return visits using notifications, streak mechanics, widgets, and Apple-native engagement surfaces, without tripping App Store review or driving opt-outs.

**Scope:** research-backed audit + roadmap. No app code was modified to produce this document.

---

## 1. Current-State Audit

| Mechanic | Exists? | Where | Quality assessment |
|---|---|---|---|
| Local push — morning/afternoon/evening 369 reminders | Yes | `Core/Utilities/NotificationManager369.swift` | 3 fixed daily notifications at 8:00 / 14:00 / 20:00 (user-editable). Same copy every single day, forever — no variety, no personalization, no name, no day-number, no streak state. Generic emoji-title + body. |
| Personalized notification copy (name, day-number) | No | — | `UserManager.shared.userName` (defaults to `"Dreamer"`) and `DailyInsightManager` already generate personalized, numerology-aware daily copy for **in-app** content (via Gemini) — this pipeline is never used to feed notification bodies. |
| Notification permission request | Yes, but mistimed | `App/ManifestAIApp.swift` `requestNotificationPermissionAtLaunch()` | Fires the *hard* system prompt ~800ms after first launch, before the user has seen any value (no soft-ask / priming screen in onboarding, no `.provisional` fallback). One-shot — if declined, there's no later re-prompt path except the Settings toggle. |
| Daily Reminders on/off toggle | Yes | `Features/Dashboard/MainTabView.swift` (`daily_reminders_on` via `@AppStorage`), `Features/Settings/ParityDailyRemindersView.swift` | Single master switch for all 3 notifications — no per-window control, no smart/quiet-hours logic. |
| Notification categories/actions (actionable buttons) | No (stubbed only) | `NotificationManager369.swift` sets `categoryIdentifier = "MANIFESTATION_369"` | The category identifier is set on content but **never registered** via `UNNotificationCategory`/`setNotificationCategories` — it's a dead field. No "Write now" / "Snooze" action buttons exist. |
| Badge count | Yes, inaccurate | `NotificationManager369.swift` | Every scheduled notification hardcodes `content.badge = 1`; cleared only in `Manifest369ViewModel.swift` on ritual completion. Doesn't reflect a real unread/actionable count — a HIG violation risk (see §2.7 and §2.8 in Part 2 research). |
| Streak (journal) | Yes, computed live | `MainTabView.swift` `streak` (consecutive days with a `JournalEntry`) | Pure computed property, no persistence beyond entries themselves. **No protection/freeze mechanic.** No "streak at risk" push. Breaking it is silent until the user reopens the app. |
| Streak (369 ritual, 33-day cycle) | Yes | `Core/Services/Ritual369Manager.swift` | Missing a day **hard-resets to 0**, no grace/freeze. Only surfaces the loss in-app (`streakResetNotice`) — never as a proactive push before the loss happens. |
| Streak-protection / "streak freeze" | No | — | Biggest single gap vs. best practice (see Part 2, item 1). |
| Lapsed-user re-engagement sequence | No | — | No Day-3/7/14 win-back logic anywhere; local notifications can't detect "hasn't opened in N days" without app foreground time anyway. |
| Home Screen widget | Yes | `ManifestWidgets/ManifestWidgets.swift` | Small + Medium families only, shows numerology number + daily affirmation, refreshes hourly via `TimelineProvider`, plus reload-on-change via `WidgetCenter.shared.reloadAllTimelines()` (called from `DashboardViewModel`). Solid foundation. |
| Lock Screen / StandBy widget | No | — | `.supportedFamilies` only declares `.systemSmall, .systemMedium` — no `.accessoryCircular/.accessoryRectangular/.accessoryInline` for Lock Screen or StandBy. |
| Interactive widget (button/toggle) | No | — | No App Intents wired into the widget; tapping only deep-links (or does nothing) — can't "log gratitude" from the widget without opening the app. |
| Live Activity | Stubbed, empty | `ManifestWidgets/ManifestWidgetsLiveActivity.swift` | File exists but contains only whitespace — effectively a dead placeholder from the widget-extension template. Not implemented. |
| App Intents / Siri Shortcuts / Spotlight | No | — | No `AppIntent`/`AppShortcut` conformance anywhere in the codebase. |
| Remote push (APNs / Firebase) | No | — | No Firebase SDK dependency (no Podfile/SPM package), no `Firebase`/`Messaging` import anywhere, **no push-notification entitlement** (`aps-environment`) in `ManifestAI - Gratitude Journal.entitlements`, no `UIBackgroundModes` remote-notification key in `Info.plist`. A `GoogleService-Info.plist` exists only in `~/Downloads` — it is **not** part of the Xcode project and Firebase is not integrated in any way today. |
| App Group (widget data sharing) | Yes | `group.com.manifestai.journal` in both entitlements files, `SharedDataManager.swift` | Good foundation already in place for sharing data with widgets/future extensions. |

**Bottom line:** ManifestAI has a working *local-only*, *static-copy*, *no-protection* 3x/day reminder system and a decent but under-powered widget. Every mechanic proven to move the retention needle further — personalization, streak protection, actionable notifications, lapsed-user win-back, remote push, Live Activities, App Intents — is either absent or stubbed.

---

## 2. Gap Analysis vs. Best Practice

1. **No streak-protection ("streak freeze").** Duolingo users with 7+ day streaks retain at **2.4x** the rate of those who never build one, and the streak-wager/freeze mechanic produced a **14% lift in Day-14 retention**; doubling available freezes measurably lifted DAU (+0.38% in one Duolingo test). ManifestAI's two streak systems (journal streak, 369 cycle) both hard-reset with zero grace and zero proactive warning. *(Source: [Duolingo Streak System Breakdown](https://medium.com/@salamprem49/duolingo-streak-system-detailed-breakdown-design-flow-886f591c953f); [Duolingo habit-forming reminders](https://www.digia.tech/post/duolingo-habit-forming-reminders-retention-architecture/); [Duolingo streak mechanics — Game Data Pros](https://duolingo.deconstructoroffun.com/mechanics/streaks))*

2. **Notification copy is 100% static and unpersonalized.** Personalized push gets up to **4x higher open rates** than generic broadcast copy; RevenueCat's dataset of 75,000+ apps confirms the same pattern for subscription apps specifically. ManifestAI already computes the user's name and numerology day-number for in-app content (`DailyInsightManager`) but never routes it into notification bodies. *(Source: [RevenueCat State of Subscription Apps](https://www.revenuecat.com/state-of-subscription-apps/); [Mobiloud — behavioral triggers](https://www.mobiloud.com/blog/what-are-behavioral-triggers))*

3. **No actionable notifications.** `UNNotificationCategory`/`UNNotificationAction` let a banner surface up to 4 buttons (e.g. "Write now") that act without opening the app — ManifestAI sets a category identifier but never registers it, so the capability is inert. *(Source: [Apple — Declaring your actionable notification types](https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types))*

4. **Permission is hard-asked at first launch with no priming and no provisional fallback.** `.provisional` authorization delivers quiet Notification-Center-only notifications with *no upfront prompt*, letting users see value before deciding to fully opt in — and A/B data shows no downside to addressable-audience size vs. the standard prompt. ManifestAI fires the full system dialog ~800ms after cold launch, during onboarding, before any ritual has been completed. *(Source: [Apple — Asking permission to use notifications](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications); [Phiture — Provisional Push](https://phiture.com/blog/provisional-push-what-is-it-and-how-will-it-impact-your-addressable-audience/))*

5. **No lapsed-user win-back sequence.** A staged Day-3 / Day-7 / Day-14 sequence recovers roughly 10–25% of lapsed users combined, with the highest-probability recovery window at days 3–14 (by day 30 the app is "mentally filed away"). ManifestAI has no inactivity-triggered messaging at all, and — critically — **cannot build one with local notifications alone**, since detecting "hasn't opened in N days" from outside the app requires a server. *(Source: [OneSignal — Re-engaging users before they churn](https://onesignal.com/blog/how-to-re-engage-mobile-users-before-they-churn/))*

6. **No remote push / server-side send capability.** Remote push (APNs, typically via Firebase Cloud Messaging or a provider like OneSignal) is the only way to do true behavioral/segment-based sends, lapsed-user win-back, or time-of-day-optimal delivery based on live server data — none of which local notifications can do. ManifestAI has zero infrastructure for this (no entitlement, no SDK, no backend). *(Source: [OneSignal — Local vs remote push on iOS](https://onesignal.com/blog/understanding-ios-remote-local-push-notifications/); [OneSignal push best practices 2026](https://onesignal.com/blog/onesignal-guide-push-notification-best-practices-2026/))*

7. **3x/day cadence is a double-edged sword — currently un-mitigated.** RevenueCat's 75k-app dataset shows sending 2–5 pushes/*week* causes **40%+ of users to disable push entirely**; a fixed 3x/day (21/week) schedule is far above every published comfort threshold *unless* the three pings are clearly distinct, low-friction, and each individually optional. Today all 3 are bundled behind a single on/off switch with no way to keep just one or two. Duolingo caps *routine* pushes at ~2/day and reserves any 3rd send for genuine streak-loss risk — never 3 generic identical-purpose sends. *(Source: [RevenueCat State of Subscription Apps](https://www.revenuecat.com/state-of-subscription-apps/); [Business of Apps — push notification statistics](https://www.businessofapps.com/marketplace/push-notifications/research/push-notifications-statistics/); [Duolingo notification mechanics](https://duolingo.deconstructoroffun.com/mechanics/notifications))*

8. **Widget is static and non-interactive.** iOS 17+ interactive widgets (App-Intent-backed `Button`/`Toggle`) let a user act *without opening the app* — Apple's own documented mechanism for engagement-without-launch. ManifestAI's widget is read-only (number + affirmation), has no Lock Screen/StandBy family, and has no tie to an App Intent. *(Source: [Apple — Adding interactivity to widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities))*

9. **Live Activity file exists but is an empty stub.** Live Activities are explicitly restricted by Apple to genuine ongoing, user-initiated activities (not marketing) but are well suited to something like an in-progress 369 ritual countdown on the Lock Screen/Dynamic Island — currently unimplemented. *(Source: [Live Activities guide — Newly](https://newly.app/guides/ios-live-activities))*

10. **No App Intents / Siri / Spotlight surface.** App Intents expose actions like "Log gratitude" or "Start 369 ritual" to Siri, Spotlight, Shortcuts, widgets, and the Action Button — a documented low-friction re-entry channel entirely absent from ManifestAI today. *(Source: [Singular — App Intents iOS 18](https://www.singular.net/blog/app-intents-ios18/); [GoodRequest — App Intents](https://www.goodrequest.com/blog/app-intents-how-to-make-your-app-more-accessible-through-siri-spotlight-and-widgets))*

11. **Badge count is fake.** `content.badge = 1` is hardcoded on every send regardless of actual actionable state — Apple's HIG requires badge numbers correspond to real, actionable content; mismatches erode trust and lead users to disable badges entirely (and are a soft App Store review risk under the "accurate" requirement). *(Source: [WillowTree — iOS badge best practices](https://www.willowtreeapps.com/craft/best-practices-for-driving-engagement-with-ios-app-notification-badges))*

12. **App Store compliance is currently low-risk but only because the feature set is thin.** Guideline 4.5.4 requires notifications not be required for core function and not carry sensitive data; Guideline 4.5.3 bars using push (or Live Activities) to spam/send unsolicited marketing. As remote push and win-back sequences are added (roadmap below), explicit in-app opt-in copy and a real unsubscribe path become mandatory, not optional. *(Source: [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/))*

13. **Tone precedent exists but isn't applied to notifications.** Calm's push style reads as "gentle... invitations rather than demands"; Headspace's mindfulness pushes intentionally omit hard CTAs, using a philosophical prompt instead of a command. ManifestAI's current copy ("Time to write your affirmation 3 times") already leans command-style rather than invitational — a tone mismatch with the mystical/warm brand voice used elsewhere in the app. *(Source: [Calm marketing strategy](https://ronntorossian.medium.com/how-calm-disrupted-the-wellness-industry-with-a-smart-app-marketing-strategy-2063bca3f203); [Headspace "Mindful Moment" pushes](https://taplytics.com/blog/headspace-sends-push-notifications-with-prompts-to-help-users-become-more-mindful/))*

---

## 3. Prioritized Roadmap

### 🟢 Quick Wins (this week, local-only, no new infra)

**3.1 — Personalize the 3 existing notifications (name + day-number + copy rotation)**
Wire `UserManager.shared.userName` and the day's numerology number (already computed by `NumerologyService`/`DailyInsightManager`) into the notification body at schedule time (each morning, when the app is foregrounded, re-schedule the day's 3 notifications with that day's specific copy — same local-only mechanism, richer content). Rotate through a copy bank (8–10 variants below) keyed by day-of-week or day-number so it never repeats twice in a row.

*Exact schedule (unchanged times, upgraded content):*
- **08:00** — Morning (3x affirmation)
- **14:00** — Afternoon (6x affirmation)
- **20:00** — Evening (9x affirmation)

*Ready-to-use copy (mystical-warm voice, name + day-number, ×3 per window so they can rotate):*

Morning (08:00):
1. "☀️ Good morning, {name}. Day {day_number} is calling — write your 3 lines and set the tone."
2. "🌅 {name}, the universe is listening at sunrise. Your 3 morning lines are waiting."
3. "✨ Rise and manifest, {name}. Three lines, one intention — Day {day_number} begins now."

Afternoon (14:00):
4. "🌤 {name}, your 6 lines are calling. Keep Day {day_number}'s momentum alive."
5. "🔆 Midday check-in, {name} — 6 affirmations stand between you and today's manifestation."
6. "💫 Don't let the day drift, {name}. Your 6 lines are ready when you are."

Evening (20:00):
7. "🌙 {name}, close Day {day_number} with your 9 lines. You're almost home."
8. "✨ The stars are out, {name} — finish strong with tonight's 9 affirmations."
9. "🌌 One ritual left today, {name}. Write your 9 lines and let Day {day_number} rest easy."
10. "🕯 {name}, your evening ritual is waiting. Nine lines, then peace."

**3.2 — Register real notification categories + actions.**
Register `UNNotificationCategory` for `MANIFESTATION_369` with a `"WRITE_NOW"` foreground action and a `"SNOOZE_1H"` background action at app launch (in `ManifestAIApp.init`), so long-pressing/swiping a banner offers "Write Now" / "Remind me in 1 hour" without opening the app. *(Apple: [Declaring actionable notification types](https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types))*

**3.3 — Fix the badge.**
Compute badge count from actual unfinished-window state for the day (0, 1, 2, or 3 depending on how many of morning/afternoon/evening are still un-written) instead of hardcoding `1`. Clear it in the same places it's currently cleared, plus whenever a ritual phase completes (not just full-day completion).

**3.4 — Move permission ask, add provisional fallback.**
Replace the blind 800ms-after-launch hard prompt with: (a) a one-screen soft-ask *after* the user completes their first 369 session (contextual — "want a nudge for tomorrow's ritual?"), and (b) if declined or postponed, fall back to `.provisional` authorization so notifications land quietly in Notification Center without a system dialog, preserving addressable audience. *(Apple: [Asking permission](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications); [Phiture — Provisional Push](https://phiture.com/blog/provisional-push-what-is-it-and-how-will-it-impact-your-addressable-audience/))*

**3.5 — Split the single reminders toggle into 3 independent toggles.**
Let users keep, say, only the evening ritual on if 3x/day feels like too much — directly mitigates the "40%+ disable push after 2–5/week" risk (§2.7) by giving users a lower-commitment on-ramp instead of all-or-nothing.

---

### 🟡 Medium (streak-protection, smart copy variants, widget upgrade)

**3.6 — Streak Freeze for both streak systems.**
Grant 1 free "Grace Day" per rolling 30 days (2 for Pro subscribers, mirroring Duolingo's "more freezes lifted DAU" finding) that auto-applies if a day is missed, preserving both the journal streak and the 33-day 369 cycle instead of hard-resetting to 0. Surface remaining freezes in Settings/Profile next to the existing streak display.

**3.7 — Streak-at-risk push (the single highest-leverage addition).**
A local notification scheduled for ~21:30–22:00 (after the evening window closes but before midnight) *only* if the user has an active streak (≥2 days) and hasn't completed today's ritual yet. This is schedulable locally each morning based on that day's known state — no server required. Copy examples:
- "🔥 {name}, your {streak_count}-day streak is still alive — one ritual left tonight to keep it."
- "⏳ Don't let Day {streak_count} slip away, {name}. A few lines now and your streak holds."

**3.8 — Widget upgrade: Lock Screen + StandBy families, and one interactive action.**
Add `.accessoryRectangular`/`.accessoryCircular` families (Lock Screen + StandBy) showing streak count + today's number, and add one `Button`-backed App Intent ("Mark ritual started") that deep-links or pre-fills the writing screen without a full cold launch. *(Apple: [Adding interactivity to widgets](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities))*

**3.9 — App Intents for Siri/Spotlight/Shortcuts/Action Button.**
Ship `AppIntent`s for "Start 369 Ritual," "Log Gratitude Entry," and "Show Today's Number" so they're invokable via Siri, Spotlight search, the Shortcuts app, and (on Pro devices) the Action Button — a zero-notification-permission-required re-entry channel. *(Source: [Singular — App Intents iOS 18](https://www.singular.net/blog/app-intents-ios18/))*

---

### 🔴 Larger (remote push, Live Activities, lapsed-user win-back)

**3.10 — Stand up remote push (Firebase Cloud Messaging → APNs, or OneSignal).**
Requires: enabling the Push Notifications capability + `aps-environment` entitlement, adding `UIBackgroundModes: remote-notification`, integrating the Firebase/FCM SDK (the stray `GoogleService-Info.plist` in Downloads suggests this was already being considered — it needs to actually be added to the Xcode project and paired with a Firebase project + `firebase_messaging`/APNs auth key), and a lightweight backend (Cloud Functions or a small server) to track last-open date per user. This is the only way to implement:
- **Lapsed-user win-back sequence** at Day 3 / Day 7 / Day 14 of inactivity:
  - Day 3 ("reminder," deep-linked to last state): *"{name}, Day {day_number} is waiting for you — pick up right where you left off."*
  - Day 7 ("value restatement"): *"✨ {name}, your numerology reading for today is ready. The universe doesn't wait — but it does miss you."*
  - Day 14 ("win-back," acknowledges the gap): *"🌙 It's been a while, {name}. Come back to your practice — your streak record and vision board are still here."*
  After Day 14 with no response, drop to a low-frequency monthly touchpoint rather than continuing standard lifecycle sends. *(Source: [OneSignal — Re-engaging users](https://onesignal.com/blog/how-to-re-engage-mobile-users-before-they-churn/))*
- Time-of-day-optimal sends based on each user's actual historical open time (not a fixed 8/14/20 schedule for everyone).
- Server-triggered "streak freeze about to expire" and "new numerology insight ready" pushes.

**3.11 — Live Activity for an in-progress 369 ritual.**
Implement `ManifestWidgetsLiveActivity.swift` (currently empty) to show a Lock Screen/Dynamic Island countdown while a ritual session is actively in progress (e.g., "6 of 9 lines written tonight") — genuinely tied to a user-initiated session, not marketing, per Apple's restriction. Respect the ~8-hour active / 4-hour stale budget and 4KB payload cap. *(Source: [Live Activities guide](https://newly.app/guides/ios-live-activities))*

**3.12 — Behavioral-trigger push engine (replace fixed-schedule with adaptive).**
Once remote push exists, move from "always 8/14/20" to sends gated by behavior: skip the afternoon nudge entirely if the user already wrote before noon; escalate emotional intensity only after 3+ consecutive missed days (mirroring Duolingo's escalation pattern); never send more than one *non-essential* push per day beyond the user's own chosen ritual windows. *(Source: [Duolingo notification mechanics](https://duolingo.deconstructoroffun.com/mechanics/notifications))*

---

### App Store Compliance Notes (apply across all tiers)

- Keep the 3 ritual reminders and any streak-risk push tied to a feature the user explicitly enabled — never gate core app functionality behind granting notification permission (Guideline 4.5.4).
- Any remote/marketing-style push (win-back sequences, "new feature" pushes) needs its own explicit in-app opt-in copy, separate from the ritual-reminder opt-in, plus a visible way to turn it off (Guideline 4.5.3/4.5.4) — recommend a "Ritual Reminders" vs. "Tips & Offers" split in Settings once remote push ships.
- Do not use the Live Activity for promotional content — only for the live ritual-in-progress state (Apple explicitly reviews for this).
- Keep badge counts strictly accurate to actionable state (§2.11) — an easy, free HIG-compliance win.
- Respect frequency ceilings even after remote push exists: cap **total** notifications (local + remote combined) at roughly 1/day outside of a user's own chosen ritual windows, since RevenueCat's data shows 2–5/week already triggers 40%+ opt-out on subscription apps generally.

---

## 4. Metrics to Track

| Metric | Why it matters | Target signal |
|---|---|---|
| Notification opt-in rate (at launch vs. after moving the ask, §3.4) | Confirms the priming/provisional change worked | Increase vs. current baseline; watch for provisional→full upgrade rate |
| Push → session-open rate (per notification variant/window) | Tells you which copy/time actually drives opens, not just sends | Track per-copy-variant (A/B the 8–10 lines) |
| Notification opt-out / permission-revoked rate over time | Direct signal of fatigue (RevenueCat's 40%+ threshold is the danger zone) | Should stay flat or drop after moving to independent per-window toggles (§3.5) |
| Streak length distribution (journal + 369 cycle) | Core proxy for habit formation; Duolingo's 7-day inflection is the benchmark | Track % of users crossing 3-day / 7-day / 33-day thresholds before/after streak-freeze ships |
| Streak-freeze usage rate & its effect on Day-14/Day-33 retention | Directly tests the highest-leverage roadmap item (§3.6/§2.1) | Compare retention of freeze-users vs. non-users |
| DAU and sessions-per-DAU (specifically multi-session days: users opening 2x or 3x same day) | The literal "multiple times per day" goal — separate from raw DAU | Rising share of DAU with 2+ or 3+ opens/day |
| D1/D3/D7/D14/D30 retention curves, cut by cohort (personalized copy vs. control, provisional vs. hard-ask, etc.) | Standard funnel to validate each roadmap item's actual lift | Compare cohorts pre/post each rollout |
| Lapsed-user win-back sequence recovery rate (Day 3 / 7 / 14 sends) | Validates §3.10's core promise | Benchmark against the cited 10–25% combined recovery range |
| Widget install rate + widget→app-open rate | Confirms the widget upgrade (§3.8) actually drives opens, not just installs | Track opens attributed to widget taps/deep links separately from cold opens |
| App Intent (Siri/Spotlight/Shortcuts) invocation count | Validates §3.9 as a real re-entry channel vs. unused surface | Any non-trivial adoption is a win given zero cost to notification budget |
| "Not enough usage" as a stated cancellation reason (via post-cancellation survey, if added) | RevenueCat's #1 churn driver (37.2%) — the plan's north-star business metric | Downward trend as retention mechanics ship |

---

*Compiled from a live code audit of `ManifestAI - Gratitude Journal/` (see file references throughout) plus 2024–2026 industry research on Duolingo, Calm, Headspace, Daylio, Finch, RevenueCat, OneSignal, Apple Developer documentation, and the App Store Review Guidelines. All external claims are cited inline with source URLs.*
