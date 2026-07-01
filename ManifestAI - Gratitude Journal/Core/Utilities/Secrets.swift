import Foundation

struct Secrets {
    // Keys are injected via Config.xcconfig -> Info.plist at build time.
    // See Config.xcconfig.example for setup instructions.

    static let unsplashAccessKey: String = {
        guard let key = Bundle.main.infoDictionary?["UNSPLASH_ACCESS_KEY"] as? String, !key.isEmpty else {
            #if DEBUG
            fatalError("UNSPLASH_ACCESS_KEY not set. Copy Config.xcconfig.example to Config.xcconfig and add your key.")
            #else
            dlog("⚠️ UNSPLASH_ACCESS_KEY missing in release build - feature will be unavailable")
            return ""
            #endif
        }
        return key
    }()

    static let geminiKey: String = {
        guard let key = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String, !key.isEmpty else {
            #if DEBUG
            fatalError("GEMINI_API_KEY not set. Copy Config.xcconfig.example to Config.xcconfig and add your key.")
            #else
            dlog("⚠️ GEMINI_API_KEY missing in release build - feature will be unavailable")
            return ""
            #endif
        }
        return key
    }()

    static let superwallApiKey: String = {
        guard let key = Bundle.main.infoDictionary?["SUPERWALL_API_KEY"] as? String, !key.isEmpty else {
            #if DEBUG
            fatalError("SUPERWALL_API_KEY not set. Copy Config.xcconfig.example to Config.xcconfig and add your key.")
            #else
            dlog("⚠️ SUPERWALL_API_KEY missing in release build - feature will be unavailable")
            return ""
            #endif
        }
        return key
    }()
}
