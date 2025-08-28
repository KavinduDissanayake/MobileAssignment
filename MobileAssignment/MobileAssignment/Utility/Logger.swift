import Foundation
import os.log

// MARK: - Log Types
enum LogType: String, CaseIterable {
    case error = "ERROR"
    case warning = "WARNING"
    case success = "SUCCESS"
    case info = "INFO"
    case action = "ACTION"
    case canceled = "CANCELED"
    case debug = "DEBUG"
    case network = "NETWORK"
    
    var emoji: String {
        switch self {
        case .error: return "❌"
        case .warning: return "⚠️"
        case .success: return "✅"
        case .info: return "ℹ️"
        case .action: return "🛠️"
        case .canceled: return "🚫"
        case .debug: return "🔍"
        case .network: return "🌐"
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .error: return .error
        case .warning: return .default
        case .success: return .info
        case .info: return .info
        case .action: return .debug
        case .canceled: return .default
        case .debug: return .debug
        case .network: return .info
        }
    }
}

// MARK: - Log Destination
enum LogDestination {
    case console
    case osLog
    case file
    case remote
}

// MARK: - Log Configuration
struct LogConfiguration {
    let isEnabled: Bool
    let minimumLevel: LogType
    let destinations: Set<LogDestination>
    let includeTimestamp: Bool
    let includeThreadInfo: Bool
    let maxFileSize: Int // in MB
    let maxFileCount: Int
    
    static let `default` = LogConfiguration(
        isEnabled: true,
        minimumLevel: .info,
        destinations: [.console, .osLog],
        includeTimestamp: true,
        includeThreadInfo: false,
        maxFileSize: 10,
        maxFileCount: 5
    )
    
    static let production = LogConfiguration(
        isEnabled: false,
        minimumLevel: .error,
        destinations: [.osLog],
        includeTimestamp: true,
        includeThreadInfo: false,
        maxFileSize: 5,
        maxFileCount: 3
    )
    
    static let debug = LogConfiguration(
        isEnabled: true,
        minimumLevel: .debug,
        destinations: [.console, .osLog, .file],
        includeTimestamp: true,
        includeThreadInfo: true,
        maxFileSize: 20,
        maxFileCount: 10
    )
}

// MARK: - Logger
final class Logger {
    
    // MARK: - Properties
    static let shared = Logger()
    private var configuration: LogConfiguration
    private let osLog: OSLog
    private let fileManager = FileManager.default
    private let logDirectory: URL
    
    // MARK: - Initialization
    private init() {
        #if DEBUG
        self.configuration = LogConfiguration.debug
        #else
        self.configuration = LogConfiguration.production
        #endif
        
        self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "MobileAssignment", category: "App")
        
        // Create log directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.logDirectory = documentsPath.appendingPathComponent("Logs")
        createLogDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    func configure(_ config: LogConfiguration) {
        configuration = config
    }
    
    func log(
        _ type: LogType,
        title: String? = nil,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard configuration.isEnabled else { return }
        guard shouldLog(type) else { return }
        
        let logEntry = createLogEntry(type: type, title: title, message: message, file: file, function: function, line: line)
        
        // Send to all configured destinations
        if configuration.destinations.contains(.console) {
            logToConsole(logEntry)
        }
        
        if configuration.destinations.contains(.osLog) {
            logToOSLog(logEntry, type: type)
        }
        
        if configuration.destinations.contains(.file) {
            logToFile(logEntry)
        }
        
        if configuration.destinations.contains(.remote) {
            logToRemote(logEntry)
        }
    }
    
    // MARK: - Convenience Methods
    func error(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, title: title, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, title: title, message: message, file: file, function: function, line: line)
    }
    
    func success(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.success, title: title, message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, title: title, message: message, file: file, function: function, line: line)
    }
    
    func action(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.action, title: title, message: message, file: file, function: function, line: line)
    }
    
    func canceled(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.canceled, title: title, message: message, file: file, function: function, line: line)
    }
    
    func debug(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, title: title, message: message, file: file, function: function, line: line)
    }
    
    func network(_ message: String, title: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        log(.network, title: title, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    private func shouldLog(_ type: LogType) -> Bool {
        let levels: [LogType] = [.debug, .info, .network, .action, .success, .warning, .canceled, .error]
        guard let currentIndex = levels.firstIndex(of: type),
              let minimumIndex = levels.firstIndex(of: configuration.minimumLevel) else {
            return false
        }
        return currentIndex >= minimumIndex
    }
    
    private func createLogEntry(
        type: LogType,
        title: String?,
        message: String,
        file: String,
        function: String,
        line: Int
    ) -> String {
        var components: [String] = []
        
        if configuration.includeTimestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            components.append("[\(formatter.string(from: Date()))]")
        }
        
        components.append("[\(type.rawValue)]")
        
        if configuration.includeThreadInfo {
            let threadName = Thread.isMainThread ? "Main" : "Background"
            components.append("[\(threadName)]")
        }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        components.append("[\(fileName):\(line)]")
        components.append("[\(function)]")
        
        let displayTitle = title ?? type.rawValue
        components.append("\(displayTitle)")
        
        return "\(components.joined(separator: " ")): \(message)"
    }
    
    private func logToConsole(_ entry: String) {
        print(entry)
    }
    
    private func logToOSLog(_ entry: String, type: LogType) {
        os_log("%{public}@", log: osLog, type: type.osLogType, entry)
    }
    
    private func logToFile(_ entry: String) {
        let logFile = getCurrentLogFile()
        let logEntry = entry + "\n"
        
        if let data = logEntry.data(using: .utf8) {
            if fileManager.fileExists(atPath: logFile.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: logFile)
            }
            
            // Check file size and rotate if needed
            checkAndRotateLogFiles()
        }
    }
    
    private func logToRemote(_ entry: String) {
        // Implement remote logging (e.g., to a server, Crashlytics, etc.)
        // This is a placeholder for future implementation
    }
    
    private func getCurrentLogFile() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        return logDirectory.appendingPathComponent("app-\(dateString).log")
    }
    
    private func createLogDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: logDirectory.path) {
            try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func checkAndRotateLogFiles() {
        let logFiles = try? fileManager.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: [URLResourceKey.fileSizeKey, URLResourceKey.creationDateKey])
        
        guard let files = logFiles else { return }
        
        // Sort by creation date
        let sortedFiles = files.sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [URLResourceKey.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? file2.resourceValues(forKeys: [URLResourceKey.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 < date2
        }
        
        // Check file sizes and remove old files if needed
        for file in sortedFiles {
            if let size = try? file.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize,
               size > configuration.maxFileSize * 1024 * 1024 {
                try? fileManager.removeItem(at: file)
            }
        }
        
        // Remove old files if we exceed max count
        if sortedFiles.count > configuration.maxFileCount {
            let filesToRemove = sortedFiles.prefix(sortedFiles.count - configuration.maxFileCount)
            for file in filesToRemove {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Utility Methods
    func getLogFiles() -> [URL] {
        return (try? fileManager.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)) ?? []
    }
    
    func clearLogs() {
        let files = getLogFiles()
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }
    
    func getLogContent(for file: URL) -> String? {
        return try? String(contentsOf: file, encoding: .utf8)
    }
}
