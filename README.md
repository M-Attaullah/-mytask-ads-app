# 📋 My Notes App – Flutter-Based Personal Note Keeper

## 🚀 Project Overview

**My Notes App** is a sleek and intuitive note-taking app developed using **Flutter** and **Dart**. It allows users to create, view, update, and delete notes in real-time. Featuring modern UI design, secure authentication via Firebase, and efficient state management with Provider, it offers a responsive and user-friendly experience across devices.

---

## 🌟 Features

- ✨ **Create Notes** - Add new notes with title, content, date, and color
- 📋 **View Notes** - Display all notes in an organized list with search
- ✏️ **Edit Notes** - Update existing notes with new information
- 🗑️ **Delete Notes** - Remove notes with confirmation dialog
- 🎨 **Color Coding** - Organize notes by color
- 🔍 **Search** - Find notes quickly with search functionality
- 💾 **Local Storage** - Data persists locally using SQLite database
- 🎨 **Clean UI** - Modern Material Design interface with smooth animations
- 🔥 **AdMob Integration** - Firebase AdMob for banner, interstitial, and app open ads

---

## 📱 Screenshots

| Home Screen | Add Note Screen | Note Details |
|-------------|-----------------|--------------|
| ![Home](screenshots/home.png) | ![Add Note](screenshots/add_note.png) | ![Details](screenshots/details.png) |

---

## 📂 Project Structure

```
lib/
│
├── main.dart                      # App entry point
├── models/
│   └── task_model.dart           # Note data model
├── databases/
│   └── task_database.dart        # SQLite database operations
├── view_models/
│   └── task_view_model.dart      # Business logic & state management
├── screens/
│   ├── home_screen.dart          # Main notes list screen
│   └── add_edit_note_screen.dart # Add/edit note form
├── widgets/
│   └── note_card.dart            # Custom note card widget
└── services/
    └── ad_manager.dart           # AdMob ad management
```

---

## 🧠 Skills Demonstrated

- 🏗️ **MVVM Architecture** - Clean separation of concerns with Model-View-ViewModel pattern
- 📊 **State Management** - Efficient state handling using Provider pattern
- 🗄️ **Database Integration** - SQLite database for persistent local storage
- 🎨 **UI/UX Design** - Material Design principles with custom widgets
- 🔄 **CRUD Operations** - Complete Create, Read, Update, Delete functionality
- 📱 **Responsive Design** - Adaptive layouts for different screen sizes
- ⚡ **Performance** - Optimized list rendering with ListView.builder
- 🧪 **Code Organization** - Clean, maintainable, and scalable code structure
- 📺 **AdMob Integration** - Firebase AdMob for managing ads

---

## 🛠 Technologies Used

- **Flutter** (Dart) - Cross-platform mobile development framework
- **SQLite** (`sqflite` package) - Local database storage
- **Provider** - State management solution
- **Material Design** - UI components and design system
- **Path** - File path utilities for database operations
- **Firebase** - Authentication and Realtime Database for AdMob

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.8.1 or higher)
- Dart SDK (included with Flutter)
- VS Code or Android Studio with Flutter plugin
- Firebase project (with Authentication and Realtime Database enabled)
- AdMob account (for ad unit IDs)

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-todo-list.git
   cd flutter-todo-list
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective platform folders.
   - Update `android/app/src/main/AndroidManifest.xml` with your package name.
   - Enable Email/Password authentication in Firebase Console.
   - In Firebase Realtime Database, add an `admob` node with keys: `banner`, `interstitial`, `app_open` and set your AdMob unit IDs as values.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2        # State management
  sqflite: ^2.4.1         # SQLite database
  path: ^1.9.1            # File path utilities
  firebase_core: ^2.10.0  # Firebase core
  firebase_auth: ^5.10.0  # Firebase Authentication
  cloud_firestore: ^4.10.0 # Cloud Firestore
  google_mobile_ads: ^3.14.0 # Google Mobile Ads
```

---


## 🗄️ Database Schema

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  date INTEGER NOT NULL,
  color TEXT NOT NULL
);
```

---

## 🎯 Future Enhancements

- [ ] 🏷️ Task categories/tags
- [ ] 🔔 Task reminders/notifications
- [ ] ☁️ Data backup and sync
- [ ] 🌙 Dark mode support
- [ ] 📤 Task sharing functionality
- [ ] 📊 Statistics and analytics
- [ ] 📁 Import/export tasks
- [ ] 🎨 Custom themes and colors

---

## 🙌 Author

**Muhammad Attaullah**  
Feel free to connect or contribute to this project.

[![GitHub](https://img.shields.io/badge/GitHub-000?logo=github&logoColor=white)](https://github.com/M-Attaullah) [*M-Attaullah*](https://github.com/M-Attaullah)  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/muhammad-attaullah-705764333/) [*Muhammad Attaullah*](https://www.linkedin.com/in/muhammad-attaullah-705764333/)

---

> 📌 *This app was developed as part of a Flutter development project showcasing MVVM architecture, state management, and local database integration.*

