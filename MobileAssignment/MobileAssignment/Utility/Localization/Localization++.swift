//
//  File.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI

extension String {

    /// Localizes the string using the `localizedFileName` from `LocalizationConfiguration`.
    public var localized: String {
        let tableName = LocalizationConfiguration.shared.localizedFileName
        let localizedString = NSLocalizedString(self, tableName: tableName, bundle: .main, comment: "")
        if localizedString != self {
            return localizedString
        }
        logMissingString("⚠️ No localized string found for key '\(self)' in table '\(tableName)', returning original string.")
        return self
    }

    /// Localizes the string with arguments using the `localizedFileName` from `LocalizationConfiguration`.
    public func localized(with args: CVarArg...) -> String {
        let tableName = LocalizationConfiguration.shared.localizedFileName
        let localizedString = NSLocalizedString(self, tableName: tableName, bundle: .main, comment: "")
        if localizedString != self {
            return String(format: localizedString, arguments: args)
        }
        
        logMissingString("⚠️ No localized string found for key '\(self)' in table '\(tableName)', returning original string with arguments.")
        return String(format: self, arguments: args)
    }
    
    /// Logs missing localization strings if `enableMissingStringLog` is enabled.
    private func logMissingString(_ message: String) {
        guard LocalizationConfiguration.shared.enableMissingStringLog else { return }
        Logger.shared.info(message, title: "Localization")
    }
}
