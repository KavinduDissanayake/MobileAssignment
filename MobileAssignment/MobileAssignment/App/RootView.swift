//
//  RootView.swift
//  MobileAssignment
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            ViewFactory.shared.setRootView()
                .navigationDestination(for: NavigationItem.self) { navigationItem in
                    ViewFactory.shared.setViewForDestination(
                        navigationItem.destination,
                        navigationItem
                    )
                }
        }
    }
}

struct RouteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environmentObject(Router.shared)
    }
}

extension View {
    func applyViewRoutes() -> some View {
        modifier(RouteModifier())
    }
}

#Preview {
    RootView()
        .applyViewRoutes()
}


