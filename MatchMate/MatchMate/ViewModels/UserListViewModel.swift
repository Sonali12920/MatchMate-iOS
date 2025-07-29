//
//  UserListViewModel.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import Combine
import CoreData
import Network

class UserListViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var errorMessage: ErrorMessage? = nil
    @Published var isOffline: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let context = CoreDataManager.shared.context
    private var isDataLoaded = false
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = (path.status != .satisfied)
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    /// Loads cached data from Core Data
    func loadCachedUsers() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let cachedUsers = try context.fetch(request)
            self.users = cachedUsers.map { $0.toUserProfile }
            self.errorMessage = nil
        } catch {
            print("Failed to load users from Core Data: \(error)")
            self.errorMessage = ErrorMessage(message: "Failed to load saved users. Please try again.")
        }
    }
    
    /// Fetches users from API and stores to Core Data
    func fetchUsersFromAPI() {
        guard !isDataLoaded else {
            print("Data already loaded, skipping API call")
            return
        }
        
        isDataLoaded = true
        
        APIService.shared.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("API Error: \(error)")
                    self?.errorMessage = ErrorMessage(message: "Failed to fetch users from server. Please check your connection.")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] profiles in
                guard let self = self else { return }
                
                self.users = profiles
                self.saveUsersToCoreData(profiles)
                self.errorMessage = nil
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
    
    /// Initialize data (called once from view lifecycle)
    func initializeData() {
        // First try to load from Core Data
        loadCachedUsers()
        
        // If no cached data, fetch from API
        if users.isEmpty {
            fetchUsersFromAPI()
        }
    }
    
    /// Clear all cached data and reset
    func clearCache() {
        // Clear Core Data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            CoreDataManager.shared.saveContext()
            print("Cache cleared successfully")
        } catch {
            print("Failed to clear cache: \(error)")
        }
        
        // Reset state
        users = []
        isDataLoaded = false
        cancellables.removeAll()
        
        // Fetch fresh data
        fetchUsersFromAPI()
    }
    
    /// Call this when network is restored to sync local changes to server (if backend exists)
    func syncLocalChangesIfNeeded() {
        // Placeholder: No-op for randomuser.me, but here is where you'd sync with a real backend
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
