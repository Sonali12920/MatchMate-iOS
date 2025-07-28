//
//  APIService.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private init() {}
    
    func fetchUsers() -> AnyPublisher<[UserProfile], Error> {
        let url = URL(string: "https://randomuser.me/api/?results=10")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: UserResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
