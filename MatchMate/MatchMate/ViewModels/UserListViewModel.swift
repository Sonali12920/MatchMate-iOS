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
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let context = CoreDataManager.shared.context
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    private var page = 1
    private var isFetchingMore = false
    private var isInitialLoadComplete = false
    
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
    
    /// Fetch users from API with pagination
    func fetchUsersFromAPI(reset: Bool = false) {
        guard !isFetchingMore else { return }
        
        isFetchingMore = true
        isLoading = true
        
        if reset {
            page = 1
            users = []
            clearCacheOnly()
        }
        
        APIService.shared.fetchUsers(page: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isFetchingMore = false
                self.isLoading = false
                
                switch completion {
                case .failure(let error):
                    print("API Error: \(error)")
                    self.errorMessage = ErrorMessage(message: "Failed to fetch users from server. Please check your connection.")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] profiles in
                guard let self = self else { return }
                
                if self.page == 1 {
                    self.saveUsersToCoreData(profiles)
                }
                
                self.users.append(contentsOf: profiles)
                self.page += 1
                self.errorMessage = nil
                self.isInitialLoadComplete = true
            }
            .store(in: &cancellables)
    }
    
    /// Save API users to Core Data
    func saveUsersToCoreData(_ users: [UserProfile]) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to clear old users: \(error)")
        }
        
        for user in users {
            let entity = UserEntity(context: context)
            entity.update(from: user)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    /// Initialize data (called once from view lifecycle)
    func initializeData() {
        loadCachedUsers()
        
        if users.isEmpty {
            fetchUsersFromAPI()
        }
    }
    
    /// Clear cached users from Core Data only (no API call)
    private func clearCacheOnly() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
    
    /// Clear all cached data and fetch fresh users
    func clearCache() {
        users = []
        page = 1
        cancellables.removeAll()
        fetchUsersFromAPI(reset: true)
    }
    
    /// Trigger fetch for next page when user scrolls to last
    func fetchMoreIfNeeded(currentUser: UserProfile) {
        guard !isOffline, currentUser.id == users.last?.id else { return }
        fetchUsersFromAPI()
    }
    
    /// Call this when network is restored to sync local changes to server (if backend exists)
    func syncLocalChangesIfNeeded() {
        // Placeholder
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
