import Foundation

class UserDomain: UserDomainProtocol {
    private let network: NetworkRequesting

    #if canImport(XCTest)
    // In test builds, require explicit injection to avoid linking app singletons
    init(network: NetworkRequesting) {
        self.network = network
    }
    #else
    init(network: NetworkRequesting = NetworkService.shared) {
        self.network = network
    }
    #endif

    func fetchUsers(page: Int, results: Int) async throws -> [User] {
        #if !canImport(XCTest)
        Logger.shared.info("Fetching users - Page: \(page), Results: \(results)", title: "User Domain")
        #endif

        let baseUrl: String
        #if canImport(XCTest)
        baseUrl = "https://example.com"
        #else
        baseUrl = Constants.baseUrlAPI
        #endif

        let response: UserListResponse = try await network.request(
            to: baseUrl,
            parameters: [
                "page": page,
                "results": results
            ],
            method: .get,
            encoding: .urlEncoded
        )

        let users = response.results ?? []
        #if !canImport(XCTest)
        Logger.shared.success("Successfully fetched \(users.count) users", title: "User Domain")
        #endif
        return users
    }
}

enum UserEndPoint {
    case users

    var path: String {
        return "results"
    }
}
