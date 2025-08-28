//
//  User+Preview.swift
//  MobileAssignment
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//

import Foundation

extension User {
    static var preview: User {
        User(
            gender: "female",
            name: Name(title: "Ms", first: "Alice", last: "Mackay"),
            location: nil,
            email: "alice.mackay@example.com",
            login: Login(uuid: UUID().uuidString, username: "alicem", password: "password", salt: "salt", md5: "md5", sha1: "sha1", sha256: "sha256"),
            dob: DateOfBirth(date: "1990-01-01T00:00:00.000Z", age: 34),
            registered: Registered(date: "2020-01-01T00:00:00.000Z", age: 4),
            phone: "+1 555-1234",
            cell: "+1 555-5678",
            picture: Picture(
                large: "https://randomuser.me/api/portraits/women/1.jpg",
                medium: "https://randomuser.me/api/portraits/med/women/1.jpg",
                thumbnail: "https://randomuser.me/api/portraits/thumb/women/1.jpg"
            ),
            nat: "CA"
        )
    }
}
