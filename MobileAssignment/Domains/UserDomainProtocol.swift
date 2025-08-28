//
//  UserDomainProtocol.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

// MARK: - User Domain Protocol
protocol UserDomainProtocol {
    func fetchUsers(page: Int, results: Int) async throws -> [User]
}
