//
//  UserListView.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI

// MARK: - Enhanced User List View
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()

    var body: some View {
        VStack {
            if viewModel.isInitialLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.users.isEmpty {
                ErrorView(message: errorMessage) {
                    viewModel.triggerUIAction(actionId: .tappedRetry)
                }
            } else {
                UserListContentView(
                    users: viewModel.filteredUsers,
                    searchText: viewModel.searchText,
                    isLoadingMore: viewModel.isLoadingMore,
                    canLoadMore: viewModel.canLoadMore,
                    userCount: viewModel.userCount,
                    onTapUser: { user in
                        viewModel.triggerUIAction(actionId: .tappedUser(user))
                    },
                    onLoadMore: {
                        viewModel.loadMoreUsers()
                    }
                )
            }
        }
        .navigationTitle("Random Users (\(viewModel.userCount))")
        .searchable(text: $viewModel.searchText, prompt: "Search by name")
        .onSubmit(of: .search) {
            viewModel.triggerUIAction(actionId: .tappedSearch)
        }
        .refreshable {
            await MainActor.run {
                viewModel.triggerUIAction(actionId: .tappedRefresh)
            }
        }
        .task {
            if viewModel.users.isEmpty {
                await MainActor.run {
                    viewModel.loadUsers()
                }
            }
        }
    }

    // moved list content into UserListContentView
}

#Preview {
    UserListView()
}
