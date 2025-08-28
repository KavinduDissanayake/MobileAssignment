import Foundation

// MARK: - User Domain Protocol
protocol UserDomainProtocol {
    func fetchUsers(page: Int, results: Int) async throws -> [User]
}

// MARK: - User Domain Implementation
class UserDomain: UserDomainProtocol {
    
    func fetchUsers(page: Int, results: Int) async throws -> [User] {
        Logger.shared.info("Fetching users - Page: \(page), Results: \(results)", title: "User Domain")
        
        let response: UserListResponse = try await NetworkService.shared.request(
            to: Constants.baseUrlAPI,
            parameters: [
                "page": page,
                "results": results
            ],
            method: .get,
            encoding: .urlEncoded
        )
        
        let users = response.results ?? []
        Logger.shared.success("Successfully fetched \(users.count) users", title: "User Domain")
        return users
    }
}

enum UserEndPoint {
    case users
    
    var path: String {
        return "results"
    }
}
