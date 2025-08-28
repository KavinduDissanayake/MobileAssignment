import Foundation

// MARK: - String Extensions
extension String {
    
    /// Formats a date string from ISO format to a readable format
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let date = formatter.date(from: self) {
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return "Unknown"
    }
}

