//
//  UserListView.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import SwiftUI
import Combine

class UserListViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadUsers() {
        APIService.shared.fetchUsers()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { users in
                self.users = users
            })
            .store(in: &cancellables)
    }
}

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
                viewModel.loadUsers()
            }
        }
    }
}
