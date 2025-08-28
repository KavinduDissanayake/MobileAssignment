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

        // Captured inputs
        var lastURL: String?
        var lastParameters: [String: Any]?
        var lastMethod: HTTPMethod?
        var lastEncoding: APIParameterEncoding?

        func request<T>(to url: String, parameters: [String: Any]?, method: HTTPMethod, encoding: APIParameterEncoding) async throws -> T where T: Decodable, T: Encodable {
            lastURL = url
            lastParameters = parameters
            lastMethod = method
            lastEncoding = encoding

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
            XCTAssertEqual((error as NSError).code, 123)
        }
    }

    func test_fetchUsers_withEmptyResults_returnsEmptyArray() async throws {
        let mock = NetworkClientMock()
        mock.nextResponse = UserListResponse(results: [], info: nil)
        let domain = UserDomain(network: mock)

        let users = try await domain.fetchUsers(page: 1, results: 20)
        XCTAssertTrue(users.isEmpty)
    }

    func test_fetchUsers_withNilResults_returnsEmptyArray() async throws {
        let mock = NetworkClientMock()
        mock.nextResponse = UserListResponse(results: nil, info: nil)
        let domain = UserDomain(network: mock)

        let users = try await domain.fetchUsers(page: 2, results: 50)
        XCTAssertTrue(users.isEmpty)
    }

    func test_fetchUsers_propagatesParametersAndHTTPConfig() async throws {
        let mock = NetworkClientMock()
        mock.nextResponse = UserListResponse(results: [User.preview], info: nil)
        let domain = UserDomain(network: mock)

        let page = 3
        let results = 25
        _ = try await domain.fetchUsers(page: page, results: results)

        // Assert method, encoding, and parameters propagated
        XCTAssertEqual(mock.lastMethod, .get)
        XCTAssertEqual(mock.lastEncoding, .urlEncoded)
        XCTAssertEqual(mock.lastParameters?["page"] as? Int, page)
        XCTAssertEqual(mock.lastParameters?["results"] as? Int, results)
        XCTAssertNotNil(mock.lastURL)
    }
}
