import Foundation

/// Debug-only console logging — compiled out of Release builds so user data
/// (names, journal text, subscription state) never reaches the console.
@inline(__always)
func dlog(_ items: Any...) {
    #if DEBUG
    print(items.map { "\($0)" }.joined(separator: " "))
    #endif
}
