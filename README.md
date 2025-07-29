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



