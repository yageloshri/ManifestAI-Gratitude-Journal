// Ritual369Manager.swift
// Time-window + persistence engine for the 369 manifestation method.
//
// The method (researched 2026-06-11, see e.g. calm.com/blog/369-manifestation-method):
//   write the affirmation 3× in the morning, 6× in the afternoon, 9× at night
//   (before bed), every day for 33 consecutive days. Each phase belongs to its
//   own part of the day — writing everything in one sitting defeats the method.
//
// Windows enforced here:
//   morning    05:00–11:59
//   afternoon  12:00–16:59
//   night      17:00–23:59
//   00:00–04:59 → everything locked, next window is morning 05:00.
//
// A day is "complete" when all 3+6+9 entries were written. Completing days
// consecutively advances the 33-day cycle; missing a day restarts it.

import Foundation
import Combine

final class Ritual369Manager: ObservableObject {
    static let shared = Ritual369Manager()

    typealias Phase = Parity369RitualView.RitualPhase

    // MARK: - Persisted state

    private struct State: Codable {
        var dateKey: String          // yyyy-MM-dd of `counts`
        var counts: [Int]            // [morning, afternoon, night]
        var challengeStartKey: String?
        var completedDays: Int       // consecutive fully-completed days before today
        var lastCompleteKey: String? // dateKey of the last fully-completed day
        // Days of progress lost when a missed day restarted the cycle —
        // surfaced once so the reset isn't silent. Optional: decodes as nil
        // from states persisted before this field existed.
        var lostStreakDays: Int?
    }

    private static let storeKey = "ritual369State"
    @Published private var state: State

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storeKey),
           let decoded = try? JSONDecoder().decode(State.self, from: data) {
            state = decoded
        } else {
            state = State(dateKey: Self.key(Date()), counts: [0, 0, 0],
                          challengeStartKey: nil, completedDays: 0, lastCompleteKey: nil)
        }
        rolloverIfNeeded()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.storeKey)
        }
    }

    private static func key(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    /// Reset counts when the calendar day changes; settle yesterday's outcome
    /// for the 33-day cycle.
    func rolloverIfNeeded(now: Date = Date()) {
        let today = Self.key(now)
        guard state.dateKey != today else { return }

        let finishedDay = state.dateKey
        let wasComplete = Phase.allCases.allSatisfy { state.counts[index(of: $0)] >= target(for: $0) }

        if wasComplete {
            if state.challengeStartKey == nil { state.challengeStartKey = finishedDay }
            state.completedDays = min(33, state.completedDays + 1)
            state.lastCompleteKey = finishedDay
        }

        // A gap (any non-complete day in between) restarts the cycle.
        if let last = state.lastCompleteKey {
            let cal = Calendar.current
            if let lastDate = dateFrom(key: last),
               let days = cal.dateComponents([.day], from: cal.startOfDay(for: lastDate),
                                             to: cal.startOfDay(for: now)).day,
               days > 1 {
                if state.completedDays > 0 { state.lostStreakDays = state.completedDays }
                state.completedDays = 0
                state.challengeStartKey = nil
                state.lastCompleteKey = nil
            }
        } else if !wasComplete {
            state.completedDays = 0
            state.challengeStartKey = nil
        }

        state.dateKey = today
        state.counts = [0, 0, 0]
        persist()
    }

    private func dateFrom(key: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: key)
    }

    // MARK: - Phase math

    private func index(of phase: Phase) -> Int {
        switch phase {
        case .morning: return 0
        case .afternoon: return 1
        case .night: return 2
        }
    }

    func target(for phase: Phase) -> Int {
        switch phase {
        case .morning: return 3
        case .afternoon: return 6
        case .night: return 9
        }
    }

    func count(for phase: Phase) -> Int {
        rolloverIfNeeded()
        return state.counts[index(of: phase)]
    }

    func isComplete(_ phase: Phase) -> Bool {
        count(for: phase) >= target(for: phase)
    }

    /// Day currently being worked on, 1-based, capped at 33.
    var dayNumber: Int {
        rolloverIfNeeded()
        return min(33, state.completedDays + 1)
    }

    /// Days of progress lost the last time a missed day restarted the cycle;
    /// nil once acknowledged (cleared on the next written affirmation).
    var streakResetNotice: Int? { state.lostStreakDays }

    /// All 33 consecutive days are done — the challenge is finished.
    var cycleComplete: Bool {
        rolloverIfNeeded()
        return state.completedDays >= 33
    }

    /// Begin a fresh 33-day challenge after finishing one.
    func startNewCycle(now: Date = Date()) {
        state = State(dateKey: Self.key(now), counts: [0, 0, 0],
                      challengeStartKey: nil, completedDays: 0,
                      lastCompleteKey: nil, lostStreakDays: nil)
        persist()
    }

    // MARK: - Time windows

    /// The phase whose window contains `now`, or nil between 00:00–04:59.
    func activeWindow(now: Date = Date()) -> Phase? {
        let h = Calendar.current.component(.hour, from: now)
        switch h {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<24: return .night
        default: return nil
        }
    }

    func windowStartHour(of phase: Phase) -> Int {
        switch phase {
        case .morning: return 5
        case .afternoon: return 12
        case .night: return 17
        }
    }

    /// "5:00 AM" / "12:00 PM" / "5:00 PM" for the phase's opening time.
    func windowStartLabel(of phase: Phase) -> String {
        var comps = DateComponents()
        comps.hour = windowStartHour(of: phase)
        let date = Calendar.current.date(from: comps) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    /// Record one written affirmation for the phase. Returns false when the
    /// phase is locked (outside its window or already complete).
    @discardableResult
    func record(_ phase: Phase, now: Date = Date()) -> Bool {
        rolloverIfNeeded(now: now)
        guard activeWindow(now: now) == phase, !isComplete(phase) else { return false }
        state.counts[index(of: phase)] += 1
        state.lostStreakDays = nil   // writing again = reset acknowledged
        persist()
        return true
    }

    // MARK: - What should the ritual screen show right now?

    enum ScreenState: Equatable {
        /// Phase is open for writing.
        case writing(phase: Phase, done: Int, target: Int)
        /// Current window's phase is finished — wait for the next window.
        case phaseDone(current: Phase, next: Phase?, opensAt: String?)
        /// 00:00–04:59 — nothing is open yet.
        case beforeMorning(opensAt: String)
        /// All 18 writings done today.
        case dayComplete
        /// All 33 days completed — the challenge is finished.
        case cycleComplete
    }

    func screenState(now: Date = Date()) -> ScreenState {
        rolloverIfNeeded(now: now)

        if state.completedDays >= 33 { return .cycleComplete }
        if Phase.allCases.allSatisfy({ isComplete($0) }) { return .dayComplete }

        guard let phase = activeWindow(now: now) else {
            return .beforeMorning(opensAt: windowStartLabel(of: .morning))
        }

        if !isComplete(phase) {
            return .writing(phase: phase, done: count(for: phase), target: target(for: phase))
        }

        // Active phase finished → point to the next phase later today (if any).
        switch phase {
        case .morning:
            return .phaseDone(current: .morning, next: .afternoon,
                              opensAt: windowStartLabel(of: .afternoon))
        case .afternoon:
            return .phaseDone(current: .afternoon, next: .night,
                              opensAt: windowStartLabel(of: .night))
        case .night:
            return .phaseDone(current: .night, next: nil, opensAt: nil)
        }
    }

    #if DEBUG
    /// Test hooks: `-ritual369Reset` clears state; `-ritual369Hour <h>` is read
    /// by MainTabView to simulate a clock hour.
    func debugReset() {
        state = State(dateKey: Self.key(Date()), counts: [0, 0, 0],
                      challengeStartKey: nil, completedDays: 0,
                      lastCompleteKey: nil, lostStreakDays: nil)
        persist()
    }
    #endif
}
