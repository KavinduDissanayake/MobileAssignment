//
//  LocalizationConfiguration.swift
//  MobileAssignment
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//

import Foundation

/// Central configuration for localization behavior
final class LocalizationConfiguration {
    static let shared = LocalizationConfiguration()

    /// The .strings or .xcstrings table name to use. Default: "Localizable"
    var localizedFileName: String = "Localizable"

    /// Bundle that contains the localization tables. Default: `.main`. Set this if your strings live in another bundle/framework.
    var bundle: Bundle = .main

    /// Enable console logging for missing localization keys
    var enableMissingStringLog: Bool = true

    private init() {}
}


