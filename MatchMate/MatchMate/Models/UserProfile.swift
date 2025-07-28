//
//  UserProfile.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation

struct UserResponse: Codable {
    let results: [UserProfile]
}

struct UserProfile: Codable, Identifiable {
    var id: String { login.uuid }
    
    let name: Name
    let picture: Picture
    let email: String
    let gender: String
    let location: Location
    let login: Login
    
    struct Name: Codable {
        let title: String
        let first: String
        let last: String
        
        var fullName: String {
            return "\(title) \(first) \(last)"
        }
    }
    
    struct Picture: Codable {
        let large: String
    }
    
    struct Location: Codable {
        let city: String
        let country: String
    }
    
    struct Login: Codable {
        let uuid: String
    }
}

