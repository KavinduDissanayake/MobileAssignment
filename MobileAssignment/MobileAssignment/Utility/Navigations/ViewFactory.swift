//
//  ViewFactory.swift
//  MobileAssignment
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//

import SwiftUI

// MARK: - View Factory
class ViewFactory {

    static let shared = ViewFactory()
    let router = Router.shared

    init() {}

    @ViewBuilder
    func setViewForDestination(_ destination: Destination, _ item: NavigationItem? = nil) -> some View {
        switch destination {
        case .userDetails:
            if let item, let userData = router.getData(for: item, as: User.self) {
                UserDetailView(user: userData)
            }
        case .userList:
            UserListView()
        }
    }

    @ViewBuilder
    func setRootView() -> some View {
        if isAuthenticated() {
            self.setViewForDestination(.userList)
        } else {
            self.setViewForDestination(.userList)
        }
    }
}

extension ViewFactory {
    func isAuthenticated() -> Bool {
        // TODO: Implement authentication check
        return true
    }
}


