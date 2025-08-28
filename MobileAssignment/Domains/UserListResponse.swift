//
//  UserListResponse.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import Foundation
// MARK: - Data Models
struct UserListResponse: Codable {
    let results: [User]?
    let info: Info?
}

struct Info: Codable {
    let seed: String?
    let results: Int?
    let page: Int?
    let version: String?
}

struct User: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let gender: String?
    let name: Name?
    let location: Location?
    let email: String?
    let login: Login?
    let dob: DateOfBirth?
    let registered: Registered?
    let phone: String?
    let cell: String?
    let picture: Picture?
    let nat: String?

    var fullName: String {
        guard let name = name else { return "Unknown Name" }
        let title = name.title ?? ""
        let first = name.first ?? ""
        let last = name.last ?? ""
        let joined = "\(title) \(first) \(last)"
        return joined
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var address: String {
        guard let location = location else { return "Unknown Address" }
        let number = location.street?.number.map(String.init) ?? ""
        let streetName = location.street?.name ?? ""
        let city = location.city ?? ""
        let state = location.state ?? ""
        let postcode = location.postcode ?? ""
        let country = location.country ?? ""
        let composed = "\(number) \(streetName), \(city), \(state) \(postcode), \(country)"
        return composed
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private enum CodingKeys: String, CodingKey {
        case gender, name, location, email, login, dob, registered, phone, cell, picture, nat
    }

    static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Convenience UI helpers
    var thumbnailURL: URL? {
        URL(string: picture?.thumbnail ?? "")
    }

    var largeURl: URL? {
        URL(string: picture?.large ?? "")
    }

    var ageText: String { dob?.age.map(String.init) ?? "—" }
    var genderText: String { (gender ?? "").capitalized }
}

struct Name: Codable {
    let title: String?
    let first: String?
    let last: String?
}

struct Location: Codable {
    let street: Street?
    let city: String?
    let state: String?
    let country: String?
    let postcode: String?
    let coordinates: Coordinates?
    let timezone: Timezone?

    private enum CodingKeys: String, CodingKey {
        case street, city, state, country, postcode, coordinates, timezone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        street = try container.decode(Street.self, forKey: .street)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        country = try container.decode(String.self, forKey: .country)
        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        timezone = try container.decode(Timezone.self, forKey: .timezone)

        if let postcodeString = try? container.decode(String.self, forKey: .postcode) {
            postcode = postcodeString
        } else if let postcodeInt = try? container.decode(Int.self, forKey: .postcode) {
            postcode = String(postcodeInt)
        } else {
            postcode = ""
        }
    }
}

struct Street: Codable {
    let number: Int?
    let name: String?
}

struct Coordinates: Codable {
    let latitude: String?
    let longitude: String?
}

struct Timezone: Codable {
    let offset: String?
    let description: String?
}

struct Login: Codable {
    let uuid: String?
    let username: String?
    let password: String?
    let salt: String?
    let md5: String?
    let sha1: String?
    let sha256: String?
}

struct DateOfBirth: Codable {
    let date: String?
    let age: Int?
}

struct Registered: Codable {
    let date: String?
    let age: Int?
}

struct Picture: Codable {
    let large: String?
    let medium: String?
    let thumbnail: String?
}
