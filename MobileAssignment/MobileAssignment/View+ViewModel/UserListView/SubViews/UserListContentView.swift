//
//  UserListContentView.swift
//  MobileAssignment
//
//  Created by Kavindu Dissanayake on 2025-08-28.
//

import SwiftUI

struct UserListContentView: View {
    let users: [User]
    let searchText: String
    let isLoadingMore: Bool
    let canLoadMore: Bool
    let userCount: Int
    let onTapUser: (User) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        List {
            ForEach(users) { user in
                NavigationLink(destination: UserDetailView(user: user)) {
                    UserRowView(user: user)
                        .onTapGesture {
                            onTapUser(user)
                        }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .onAppear {
                    if user.id == users.last?.id && searchText.isEmpty {
                        Task { @MainActor in
                            onLoadMore()
                        }
                    }
                }
            }
            
            // Pagination footer
            if !searchText.isEmpty {
                searchResultsFooter
            } else if isLoadingMore {
                loadingMoreView
            } else if !canLoadMore && userCount >= 200 {
                endOfResultsView
            } else if canLoadMore {
                loadMoreButton
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var searchResultsFooter: some View {
        HStack {
            Spacer()
            Text("footer.resultsCount.format".localized(with:users.count))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
    }
    
    private var loadingMoreView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
            Text("loading.more.message".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            Spacer()
        }
        .padding()
    }
    
    private var endOfResultsView: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("status.allLoaded.message".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            Spacer()
        }
    }
    
    private var loadMoreButton: some View {
        Button(action: {
            onLoadMore()
        }) {
            HStack {
                Spacer()
                if isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.trailing, 8)
                }
                Text("action.loadMore.title".localized)
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoadingMore)
    }
}

#Preview {
    NavigationView {
        UserListContentView(
            users: [],
            searchText: "",
            isLoadingMore: false,
            canLoadMore: true,
            userCount: 0,
            onTapUser: { _ in },
            onLoadMore: {}
        )
    }
}


