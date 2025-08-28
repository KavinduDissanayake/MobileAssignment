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
        let config = LocalizationConfiguration.shared
        let table = config.localizedFileName
        let bundle = config.bundle

        let value = bundle.localizedString(forKey: self, value: nil, table: table)
        if value == self {
            logMissingString("⚠️ No localized string found for key '\(self)' in table '\(table)'; returning original string.")
        }
        return value
    }

    /// Localizes the string with arguments using the `localizedFileName` from `LocalizationConfiguration`.
    public func localized(with args: CVarArg...) -> String {
        // Use the already-localized pattern and format with the current locale
        let pattern = self.localized
        return String(format: pattern, locale: Locale.current, arguments: args)
    }

    /// Logs missing localization strings if `enableMissingStringLog` is enabled.
    private func logMissingString(_ message: String) {
        guard LocalizationConfiguration.shared.enableMissingStringLog else { return }
        // If your Logger is main-actor isolated, hop to the main actor safely
        Task { @MainActor in
            Logger.shared.info(message, title: "Localization")
        }
    }
}
