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
    
    func fetchUsers(page: Int = 1) -> AnyPublisher<[UserProfile], Error> {
        let url = URL(string: "https://randomuser.me/api/?results=10&page=\(page)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}
