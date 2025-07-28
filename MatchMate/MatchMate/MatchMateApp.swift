//
//  MatchMateApp.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import SwiftUI

@main
struct MatchMateApp: App {
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            UserListView()
                .environment(\.managedObjectContext, coreDataManager.context)
        }
    }
}
