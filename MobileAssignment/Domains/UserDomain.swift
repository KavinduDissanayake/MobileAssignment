import Foundation

// MARK: - User Domain Protocol
protocol UserDomainProtocol {
    func fetchUsers(page: Int, results: Int) async throws -> [User]
}

// MARK: - User Domain Implementation
// Abstraction for network client to enable unit testing
protocol NetworkRequesting {
    func request<T: Codable>(
        to url: String,
        parameters: [String: Any]?,
        method: HTTPMethod,
        encoding: APIParameterEncoding
    ) async throws -> T
}

extension NetworkService: NetworkRequesting {}

class UserDomain: UserDomainProtocol {
    private let network: NetworkRequesting

    init(network: NetworkRequesting = NetworkService.shared) {
        self.network = network
    }

    func fetchUsers(page: Int, results: Int) async throws -> [User] {
        Logger.shared.info("Fetching users - Page: \(page), Results: \(results)", title: "User Domain")

        let response: UserListResponse = try await network.request(
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
