import Foundation

enum Constants {
    static let baseUrlAPI = "https://randomuser.me/api/"
    
    // MARK: - Logging Configuration
    static let isDebugMode = true
    
    #if DEBUG
    static let logLevel: String = "DEBUG"
    static let logToFile = true
    static let logToConsole = true
    #else
    static let logLevel: String = "ERROR"
    static let logToFile = false
    static let logToConsole = false
    #endif
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
