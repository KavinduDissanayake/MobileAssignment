//
//  UserDetailView.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI


// MARK: - User Detail View
struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileImageSection
                userInfoSection
                contactInfoSection
                locationInfoSection
            }
            .padding()
        }
        .navigationTitle("navigation.profile.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 12) {
            CachedAsyncImage(url: user.largeURl)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .background(
                    Circle().fill(Color.gray.opacity(0.3))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.15), lineWidth: 0.5)
                )
            
            Text(user.fullName)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(user.ageGenderLocalized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var userInfoSection: some View {
        InfoSectionView(title: "section.personal".localized) {
            InfoRowView(icon: "envelope.fill", label: "label.email".localized, value: user.email ?? "")
            InfoRowView(icon: "flag.fill", label: "label.nationality".localized, value: user.nat ?? "")
            InfoRowView(icon: "calendar", label: "label.dob".localized, value: user.dob?.date?.formatDate() ?? "Unknown")
        }
    }
    
    private var contactInfoSection: some View {
        InfoSectionView(title: "section.contact".localized) {
            InfoRowView(icon: "phone.fill", label: "label.phone".localized, value: user.phone ?? "")
            InfoRowView(icon: "iphone", label: "label.cell".localized, value: user.cell ?? "")
        }
    }
    
    private var locationInfoSection: some View {
        InfoSectionView(title: "section.location".localized) {
            InfoRowView(icon: "location.fill", label: "label.address".localized, value: user.address, isMultiline: true)
            let tzDesc = user.location?.timezone?.description ?? ""
            let tzOffset = user.location?.timezone?.offset ?? ""
            InfoRowView(icon: "clock.fill", label: "label.timezone".localized, value: "\(tzDesc) (UTC\(tzOffset))")
        }
    }
    

}

// MARK: - Info Section View
struct InfoSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Info Row View
struct InfoRowView: View {
    let icon: String
    let label: String
    let value: String
    let isMultiline: Bool
    
    init(icon: String, label: String, value: String, isMultiline: Bool = false) {
        self.icon = icon
        self.label = label
        self.value = value
        self.isMultiline = isMultiline
    }
    
    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
     NavigationView {
        UserDetailView(user: .preview)
             .environment(\.locale, .init(identifier: "en"))
    }
}
