//
//  MatchCardView.swift
//  MatchMate
//
//  Created by Sonali on 28/07/25.
//

import SwiftUI
import CoreData

struct MatchCardView: View {
    let user: UserProfile
    @State private var currentStatus: String = "none"
    @State private var showStatusBadge: Bool = false
    
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
            .frame(height: 400)
            .clipped()
            .overlay(
                // Status Badge
                VStack {
                    if showStatusBadge {
                        StatusBadge(status: currentStatus)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.leading, 16)
                , alignment: .topLeading
            )
            
            // User Details
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(user.location.city), \(user.location.country)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Age placeholder (you can add age calculation logic)
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
                
                // Action Buttons
                HStack(spacing: 20) {
                    // Decline Button
                    Button(action: handleDecline) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(currentStatus == "declined" ? Color.orange : Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .disabled(currentStatus != "none")
                    
                    Spacer()
                    
                    // Accept Button
                    Button(action: handleAccept) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(currentStatus == "accepted" ? Color.orange : Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .disabled(currentStatus != "none")
                }
                .padding(.top, 8)
            }
            .padding(20)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding(.horizontal, 20)
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
                showStatusBadge = true
            }
            
            // Hide badge after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showStatusBadge = false
                }
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
        HStack(spacing: 6) {
            Image(systemName: status == "accepted" ? "heart.fill" : "xmark")
                .font(.caption)
                .foregroundColor(.white)
            
            Text(status == "accepted" ? "Accepted!" : "Declined!")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(status == "accepted" ? Color.green : Color.red)
        .cornerRadius(12)
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

#Preview {
    MatchCardView(
        user: UserProfile(
            name: .init(title: "Mr", first: "John", last: "Doe"),
            picture: .init(large: "https://randomuser.me/api/portraits/men/1.jpg"),
            email: "john.doe@example.com",
            gender: "male",
            location: .init(city: "New York", country: "USA"),
            login: .init(uuid: "123")
        )
    )
} 