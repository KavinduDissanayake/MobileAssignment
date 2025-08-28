//
//  LoadingView.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.5)
            Text("loading.users.message".localized)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
