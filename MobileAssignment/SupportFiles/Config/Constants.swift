import Foundation

enum Constants {
    // Read from Info.plist (populated by xcconfig)
    private static func plistString(_ key: String, default defaultValue: String = "") -> String {
        (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? defaultValue
    }

    private static func plistBoolFromYesNo(_ key: String, default defaultValue: Bool = false) -> Bool {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return defaultValue }
        return raw.uppercased() == "YES" || raw == "1" || raw.lowercased() == "true"
    }

    static var baseUrlAPI: String {
        // Value stored escaped in plist; unescape \/ → /
        let raw = plistString("BASE_URL", default: "https://randomuser.me/api/")
        return raw.replacingOccurrences(of: "\\/", with: "/")
    }

    static var logLevel: String {
        plistString("LOG_LEVEL", default: "DEBUG")
    }

    static var logToFile: Bool {
        plistBoolFromYesNo("LOG_TO_FILE", default: true)
    }

    static var logToConsole: Bool {
        plistBoolFromYesNo("LOG_TO_CONSOLE", default: true)
    }
}

// MARK: - Constants Extension
extension Constants {
    static func isLoggingEnabled() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
