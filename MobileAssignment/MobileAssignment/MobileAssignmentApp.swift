//
//  MobileAssignmentApp.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI

@main
struct MobileAssignmentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
