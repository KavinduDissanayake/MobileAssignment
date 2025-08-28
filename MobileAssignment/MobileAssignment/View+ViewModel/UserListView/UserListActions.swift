//
//  RandomUserApp.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//


import SwiftUI

// MARK: - Action Definitions
enum UserListActions: ActionIdType {
    case fetchUsers
    case loadMoreUsers
    case refreshUsers
    case fetchImage(String)
}

enum UserListUIActions: UIActionType {
    case tappedRefresh
    case tappedLoadMore
    case tappedRetry
    case tappedSearch
    case tappedUser(User)
}


