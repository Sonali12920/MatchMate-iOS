//
//  UserEntity+Extensions.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import Foundation

extension UserEntity {
    var toUserProfile: UserProfile {
        return UserProfile(
            name: .init(title: "", first: name ?? "", last: ""),
            picture: .init(large: imageUrl ?? ""),
            email: email ?? "",
            gender: gender ?? "",
            location: .init(city: city ?? "", country: country ?? ""),
            login: .init(uuid: id ?? "")
        )
    }
    
    func update(from user: UserProfile, status: String = "none") {
        self.id = user.id
        self.name = user.name.fullName
        self.email = user.email
        self.gender = user.gender
        self.city = user.location.city
        self.country = user.location.country
        self.imageUrl = user.picture.large
        self.status = status
    }
}
