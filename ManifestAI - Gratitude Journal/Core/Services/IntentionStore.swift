// IntentionStore.swift
// Persisted list of 369 manifestation intentions with one active selection.
//
// The 369 method lets the user refine the wording of what they're
// manifesting, and keep more than one intention around. This store owns
// that list (UserDefaults-encoded JSON) plus which one is active.
//
// The active intention's text is mirrored ONE-WAY into the legacy
// `intention369` UserDefaults key, so anything still reading that key
// (e.g. the ritual affirmation) keeps working unchanged. Switching the
// active intention never touches the 33-day cycle (Ritual369Manager) —
// they are independent.

import Foundation
import Combine

/// One saved 369 intention. Persisted as part of `IntentionStore`'s JSON.
struct Intention369: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

final class IntentionStore: ObservableObject {
    static let shared = IntentionStore()

    /// Saved intentions, oldest first (creation order).
    @Published private(set) var intentions: [Intention369] = []
    /// The currently-active intention's id (nil when the list is empty).
    @Published private(set) var activeId: UUID?

    private let defaults: UserDefaults
    private static let listKey = "intentions369_list"
    private static let activeKey = "intentions369_active_id"
    private static let legacyKey = "intention369"
    private static let introSeenKey = "has_seen_369_intro"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
        migrateLegacyIfNeeded()
        writeLegacyMirror()
    }

    // MARK: - Derived

    var activeIntention: Intention369? {
        guard let activeId else { return nil }
        return intentions.first { $0.id == activeId }
    }

    /// Text of the active intention, or "" when none is set.
    var activeText: String { activeIntention?.text ?? "" }

    // MARK: - Mutations

    /// Add a new intention and make it active. Returns the created model.
    @discardableResult
    func add(text: String) -> Intention369 {
        let intention = Intention369(text: text.trimmingCharacters(in: .whitespacesAndNewlines))
        intentions.append(intention)
        activeId = intention.id
        persist()
        return intention
    }

    /// Rewrite an existing intention's text (refining wording).
    func update(id: UUID, text: String) {
        guard let idx = intentions.firstIndex(where: { $0.id == id }) else { return }
        intentions[idx].text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        persist()
    }

    /// Make an existing intention the active one. Cycle progress is untouched.
    func setActive(_ id: UUID) {
        guard intentions.contains(where: { $0.id == id }) else { return }
        activeId = id
        persist()
    }

    /// Remove an intention; if it was active, fall back to the first remaining.
    func delete(_ id: UUID) {
        intentions.removeAll { $0.id == id }
        if activeId == id { activeId = intentions.first?.id }
        persist()
    }

    /// Wipe everything (used on logout — a fresh start for the next user).
    func clearAll() {
        intentions = []
        activeId = nil
        defaults.removeObject(forKey: Self.listKey)
        defaults.removeObject(forKey: Self.activeKey)
        defaults.removeObject(forKey: Self.legacyKey)
        defaults.removeObject(forKey: Self.introSeenKey)
    }

    // MARK: - Persistence

    private func load() {
        if let data = defaults.data(forKey: Self.listKey),
           let decoded = try? JSONDecoder().decode([Intention369].self, from: data) {
            intentions = decoded
        }
        if let idString = defaults.string(forKey: Self.activeKey),
           let id = UUID(uuidString: idString),
           intentions.contains(where: { $0.id == id }) {
            activeId = id
        } else {
            activeId = intentions.first?.id
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(intentions) {
            defaults.set(data, forKey: Self.listKey)
        }
        if let activeId {
            defaults.set(activeId.uuidString, forKey: Self.activeKey)
        } else {
            defaults.removeObject(forKey: Self.activeKey)
        }
        writeLegacyMirror()
    }

    /// One-way mirror of the active intention text into the legacy key.
    private func writeLegacyMirror() {
        defaults.set(activeText, forKey: Self.legacyKey)
    }

    /// First run after the multi-intention upgrade: fold any single legacy
    /// `intention369` value into the store as the active intention. A user
    /// who had a legacy intention clearly progressed past the intro, so mark
    /// the intro as seen too.
    private func migrateLegacyIfNeeded() {
        guard intentions.isEmpty else { return }
        let legacy = (defaults.string(forKey: Self.legacyKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !legacy.isEmpty else { return }
        let intention = Intention369(text: legacy)
        intentions = [intention]
        activeId = intention.id
        defaults.set(true, forKey: Self.introSeenKey)
        persist()
    }
}
