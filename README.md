# 📱 MatchMate

**MatchMate** is a matrimonial-style iOS app that displays user match cards, similar to platforms like Shaadi.com.  
Built using **SwiftUI**, it features:

- ✅ Offline persistence with **Core Data**
- 🔁 Reactive updates via **Combine**
- 📐 Clean **MVVM** architecture

---

## 🚀 Features

- 🔄 Fetch 10 random users from [randomuser.me](https://randomuser.me)
- 🎴 Display SwiftUI-based cards with:
  - Profile image
  - Name
  - Email
  - Gender
  - Location
- ✅ Accept / ❌ Decline actions (status is persisted)
- 📡 Offline support via **Core Data**
- 🔄 Refresh functionality (clear cache + fetch new)
- 📶 Network monitoring (with offline banner)

---

## 🧠 Architecture

> **MVVM + Combine + Core Data**

Model:
└── UserProfile.swift
└── UserEntity+Extensions.swift

ViewModel:
└── UserListViewModel.swift

View:
└── UserListView.swift
└── UserCardView.swift

Services:
└── APIService.swift

Persistence:
└── CoreDataManager.swift


---

## 🧱 Tech Stack

| Layer        | Technology       |
|--------------|------------------|
| UI           | SwiftUI          |
| State Mgmt   | Combine           |
| Persistence  | Core Data        |
| Networking   | URLSession       |
| Monitoring   | NWPathMonitor    |

---

## 📡 API Reference

- **Endpoint:** `https://randomuser.me/api/?results=10`
- **Returns:**  
  - Name (title, first, last)  
  - Picture (URL)  
  - Email  
  - Gender  
  - Location (city, country)  
  - UUID (login)

---

## 🗃 Core Data Schema

- Stores basic user info:
  - `name`
  - `email`
  - `gender`
  - `location`
  - `imageUrl`
  - `id`
  - `status`: `none` / `accepted` / `declined`
- Uses `UserEntity` for local persistence
- Data is loaded from Core Data on app launch or offline mode

---

## 📁 Project Structure


MatchMate/
├── Views/
│ ├── UserListView.swift
│ └── UserCardView.swift
├── ViewModels/
│ └── UserListViewModel.swift
├── Models/
│ ├── UserProfile.swift
│ └── UserEntity+Extensions.swift
├── Services/
│ └── APIService.swift
├── Persistence/
│ └── CoreDataManager.swift
├── Resources/
│ └── MatchMateModel.xcdatamodeld

SS/Video-

<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-07-29 at 23 01 13" src="https://github.com/user-attachments/assets/e0178bd2-c707-4b50-824e-9ce0a3d74e27" />

<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-07-29 at 22 30 04" src="https://github.com/user-attachments/assets/c417d32b-08ee-4df3-850a-4c7bc1045704" />


https://github.com/user-attachments/assets/1295328c-1bca-4c28-a6d9-c3d08e43b3e1


---

## 🧪 Getting Started

```
# Clone the repository
git clone https://github.com/your-username/MatchMate.git

# Open the project
open MatchMate.xcodeproj
```

✅ Code Quality Highlights
🔁 Uses @Published & AnyPublisher for reactive state updates

🧵 Main-thread UI updates + background Core Data operations

🔀 MVVM structure with proper separation of concerns

🧼 Zero third-party dependencies

👩‍💻 Developer
Sonali
iOS Developer

Feedback and collaboration welcome! 😊

📄 License
This project is licensed under the MIT License.



