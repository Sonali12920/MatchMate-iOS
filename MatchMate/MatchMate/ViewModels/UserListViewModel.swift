//
//  UserListViewModel.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import Combine
import CoreData

class UserListViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let context = CoreDataManager.shared.context
    
    init() {
        loadCachedUsers()        // Load offline data
        fetchUsersFromAPI()      // Fetch new users from API
    }
    
    /// Loads cached data from Core Data
    func loadCachedUsers() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let cachedUsers = try context.fetch(request)
            self.users = cachedUsers.map { $0.toUserProfile }
        } catch {
            print("Failed to load users from Core Data: \(error)")
        }
    }
    
    /// Fetches users from API and stores to Core Data
    func fetchUsersFromAPI() {
        APIService.shared.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("API Error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] profiles in
                guard let self = self else { return }
                
                self.users = profiles
                self.saveUsersToCoreData(profiles)
            }
            .store(in: &cancellables)
    }
    
    /// Save API users to Core Data
    func saveUsersToCoreData(_ users: [UserProfile]) {
        // Clear existing data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to clear old users: \(error)")
        }
        
        // Add new users
        for user in users {
            let entity = UserEntity(context: context)
            entity.update(from: user)
        }
        
        CoreDataManager.shared.saveContext()
    }
}
