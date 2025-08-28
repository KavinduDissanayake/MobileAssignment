//
//  RandomUserApp.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI
import Foundation

// MARK: - Main App Entry Point
@main
struct RandomUserApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .applyViewRoutes()
        }
    }
}
