//
//  UserRowView.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI

// MARK: - User Row View
struct UserRowView: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            let thumbURL = URL(string: user.picture?.thumbnail ?? "")
            CachedAsyncImage(url: thumbURL)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .background(
                    Circle().fill(Color.gray.opacity(0.3))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.15), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(user.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        UserRowView(user: .preview)
    }
}
