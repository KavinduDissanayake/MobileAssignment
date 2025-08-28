//
//  NetworkRequesting.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

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
