//
//  UserDomainTests.swift
//  MobileAssignmentTests
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//


import XCTest
import MobileAssignment

final class UserDomainTests: XCTestCase {

    // MARK: - Doubles
    final class NetworkClientMock: NetworkRequesting {
        var nextResponse: Any?
        var nextError: Error?

        func request<T>(to url: String, parameters: [String: Any]?, method: HTTPMethod, encoding: APIParameterEncoding) async throws -> T where T: Decodable, T: Encodable {
            if let error = nextError { throw error }
            guard let response = nextResponse as? T else {
                throw NSError(domain: "Test", code: -1)
            }
            return response
        }
    }

    // MARK: - Tests
    func test_fetchUsers_returnsDecodedUsers() async throws {
        // Arrange
        let mock = NetworkClientMock()
        let expectedUsers = [User.preview]
        mock.nextResponse = UserListResponse(results: expectedUsers, info: nil)

        let domain = UserDomain(network: mock)

        // Act
        let users = try await domain.fetchUsers(page: 1, results: 1)

        // Assert
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.fullName, expectedUsers.first?.fullName)
    }

    func test_fetchUsers_propagatesError() async {
        // Arrange
        let mock = NetworkClientMock()
        mock.nextError = NSError(domain: "Test", code: 123)
        let domain = UserDomain(network: mock)

        // Act
        do {
            _ = try await domain.fetchUsers(page: 1, results: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            // Assert
            XCTAssertTrue((error as NSError).code == 123)
        }
    }
}
