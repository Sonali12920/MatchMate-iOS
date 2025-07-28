//
//  UserListView.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import SwiftUI
import Combine

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.users) { user in
                HStack {
                    AsyncImage(url: URL(string: user.picture.large)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(user.name.fullName)
                            .font(.headline)
                        Text(user.location.city + ", " + user.location.country)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("MatchMate")
            .onAppear {
                viewModel.loadCachedUsers()
                viewModel.fetchUsersFromAPI()
            }
        }
    }
}
