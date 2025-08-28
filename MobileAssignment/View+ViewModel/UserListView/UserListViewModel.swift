//
//  UserListViewModel.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import Foundation

// MARK: - Enhanced User List ViewModel with BaseViewModel
class UserListViewModel: BaseViewModel<UserListActions, UserListUIActions> {

    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var searchText: String = "" {
        didSet {
            filterUsers()
        }
    }

    // MARK: - Private Properties
    private let userDomain: UserDomainProtocol
    private var currentPage = 1
    private let maxPages = 10
    private var currentSeed: String = ""
    private var searchTask: Task<Void, Never>?

    // MARK: - Computed Properties
    var isInitialLoading: Bool {
        return isLoading(for: .fetchUsers) && users.isEmpty
    }

    var isLoadingMore: Bool {
        return isLoading(for: .loadMoreUsers)
    }

    var canLoadMore: Bool {
        return currentPage < maxPages && !isLoading(for: .loadMoreUsers)
    }

    var userCount: Int {
        return users.count
    }

    // MARK: - Initialization
    init(userDomain: UserDomainProtocol = UserDomain()) {
        self.userDomain = userDomain
        super.init()
        generateNewSeed()
    }

    // MARK: - Public Methods

    /// Load initial users (first page)
    func loadUsers() {
        generateNewSeed()
        currentPage = 1

        dispatch(actionId: .fetchUsers) {
            try await self.userDomain.fetchUsers(page: 1, results: 20)
        }
    }

    /// Load more users (next page)
    func loadMoreUsers() {
        guard canLoadMore else { return }

        currentPage += 1

        dispatch(actionId: .loadMoreUsers) {
            try await self.userDomain.fetchUsers(page: self.currentPage, results: 20)
        }
    }

    /// Refresh users
    func refreshUsers() {
        dispatch(actionId: .refreshUsers) {
            self.generateNewSeed()
            self.currentPage = 1
            return try await self.userDomain.fetchUsers(page: 1, results: 20)
        }
    }

    // MARK: - Private Methods

    private func generateNewSeed() {
        currentSeed = UUID().uuidString.prefix(8).lowercased().description
    }

    private func filterUsers() {
        searchTask?.cancel()

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay

            guard !Task.isCancelled else { return }

            await MainActor.run {
                if searchText.isEmpty {
                    filteredUsers = users
                } else {
                    filteredUsers = users.filter { user in
                        let fullName = user.fullName.lowercased()
                        let searchLower = searchText.lowercased()
                        return fullName.contains(searchLower)
                    }
                }
            }
        }
    }

    // MARK: - BaseViewModel Overrides

    override func onSuccess<T>(actionId: UserListActions, result: T) {
        super.onSuccess(actionId: actionId, result: result)
        Logger.shared.success("Action succeeded at \(actionId.analyticsEventInfo.timeStamp)", title: String(describing: actionId))

        switch actionId {
        case .fetchUsers, .refreshUsers:
            if let users = result as? [User] {
                self.users = users
                self.filteredUsers = searchText.isEmpty ? users : self.users.filter { user in
                    user.fullName.lowercased().contains(searchText.lowercased())
                }
            }

        case .loadMoreUsers:
            if let newUsers = result as? [User] {
                self.users.append(contentsOf: newUsers)
                self.filteredUsers = searchText.isEmpty ? users : self.users.filter { user in
                    user.fullName.lowercased().contains(searchText.lowercased())
                }
            }

        case .fetchImage:
            // Image caching is handled in the network layer
            break
        }
    }

    override func onStatusUpdate(actionId: UserListActions, isLoading: Bool) {
        let verb = isLoading ? "starts" : "ends"
        Logger.shared.info("Data fetching \(verb) at \(actionId.analyticsEventInfo.timeStamp)", title: String(describing: actionId))
    }

    override func onUIAction(_ action: UserListUIActions) {
        super.onUIAction(action)
        switch action {
        case .tappedRefresh:
            Logger.shared.action("User clicked refresh", title: "UI")
            refreshUsers()

        case .tappedLoadMore:
            Logger.shared.action("User clicked load more", title: "UI")
            loadMoreUsers()

        case .tappedRetry:
            Logger.shared.action("User clicked retry", title: "UI")
            loadUsers()

        case .tappedSearch:
            Logger.shared.action("User tapped search", title: "UI")

        case .tappedUser(let user):
            Logger.shared.action("User tapped on: \(user.fullName)", title: "UI")
            Router.shared.navigate(to: .userDetails, user)
        }
    }
}
