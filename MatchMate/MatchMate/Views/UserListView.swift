//
//  UserListView.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import Foundation
import SwiftUI
import Combine
import CoreData

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.users) { user in
                UserCardView(user: user)
            }
            .navigationTitle("MatchMate")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.clearCache()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
            }
            .task {
                viewModel.initializeData()
            }
        }
    }
}

struct UserCardView: View {
    let user: UserProfile
    @State private var currentStatus: String = "none"
    
    private let context = CoreDataManager.shared.context
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile Image
            AsyncImage(url: URL(string: user.picture.large)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                    )
            }
            .frame(height: 300)
            .clipped()
            
            // User Details
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("\(user.location.city), \(user.location.country)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Age placeholder
                    Text("25")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Additional details
                HStack(spacing: 16) {
                    DetailItem(icon: "location.fill", text: user.location.city)
                    DetailItem(icon: "envelope.fill", text: user.email)
                }
                
                // Action Buttons or Status Badge
                if currentStatus == "none" {
                    // Show action buttons when no status is set
                    HStack(spacing: 12) {
                        // Decline Button
                        Button(action: handleDecline) {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Accept Button
                        Button(action: handleAccept) {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 8)
                } else {
                    // Show status badge at the bottom
                    StatusBadge(status: currentStatus)
                        .padding(.top, 8)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .onAppear {
            loadCurrentStatus()
        }
    }
    
    // MARK: - Core Data Operations
    
    private func loadCurrentStatus() {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                currentStatus = userEntity.status ?? "none"
            }
        } catch {
            print("Failed to load user status: \(error)")
        }
    }
    
    private func handleAccept() {
        updateUserStatus("accepted")
    }
    
    private func handleDecline() {
        updateUserStatus("declined")
    }
    
    private func updateUserStatus(_ status: String) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                userEntity.status = status
            } else {
                // Create new entity if not found
                let newEntity = UserEntity(context: context)
                newEntity.update(from: user, status: status)
            }
            
            // Save to Core Data
            CoreDataManager.shared.saveContext()
            
            // Update UI
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStatus = status
            }
            
        } catch {
            print("Failed to update user status: \(error)")
        }
    }
}

// MARK: - Status Badge View

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(status == "accepted" ? "Accepted" : "Declined")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.blue)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// Helper view for detail items
struct DetailItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}
