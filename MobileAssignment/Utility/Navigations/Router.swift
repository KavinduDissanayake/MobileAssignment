//
//  Router.swift
//  MobileAssignment
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//

import SwiftUI
import Foundation

final class Router: ObservableObject {
    static let shared = Router()
    private init() {}

    @Published var navigationPath = NavigationPath()
    private var dataStorage: [String: Any] = [:] // Store data by ID

    func navigate(to destination: Destination, _ data: Any? = nil) {
        let item = NavigationItem(destination)

        // Store data if provided
        if let data = data {
            dataStorage[item.id] = data
        }

        navigationPath.append(item)
    }

    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
        dataStorage.removeAll() // Clean up data storage
    }

    func navigationPathRest() {
        DispatchQueue.main.async {
            self.navigationPath = NavigationPath()
            self.dataStorage.removeAll()
        }
    }

    // Generic getData method
    func getData<T>(for item: NavigationItem, as type: T.Type) -> T? {
        if let boxed = dataStorage[item.id] as? ObservableBox<T> { return boxed.value }
        return dataStorage[item.id] as? T
    }

    func getCurrentData<T>(as type: T.Type) -> T? {
        // Get data from the last navigation item
        return dataStorage.values.compactMap { $0 as? T }.last
    }
}

final class ObservableBox<T>: ObservableObject {
    @Published var value: T
    init(value: T) { self.value = value }
}
