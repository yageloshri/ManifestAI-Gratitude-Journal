import Foundation
import FirebaseAnalytics

/// Thin wrapper around Firebase Analytics so call sites stay one-liners
/// and logging is centralized (and debug-visible via `dlog`).
enum AnalyticsManager {
    static func log(_ name: String, _ params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
        dlog("📊 \(name) \(params ?? [:])")
    }
}
