//
//  NavigationItem.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import Foundation

struct NavigationItem: Hashable {
    let destination: Destination
    let id: String // Unique ID for hashing

    init(_ destination: Destination) {
        self.destination = destination
        self.id = UUID().uuidString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(destination)
        hasher.combine(id)
    }

    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        return lhs.destination == rhs.destination && lhs.id == rhs.id
    }
}
