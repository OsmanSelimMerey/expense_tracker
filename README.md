# 💰 Expense Tracker

This project is a modern, offline-first Flutter application where users can track their daily expenses. The project was developed in accordance with **Clean Architecture** standards, keeping maintainability and scalability in mind.

## 🚀 Key Features

* **Secure Authentication:** User registration and login system via Firebase Authentication. Thanks to data isolation, each user can only view and manage their own expenses.
* **Offline-First Approach:** Data is cached locally using Hive integration. Even when the internet connection is lost, the application handles the exception gracefully, and the latest cached data continues to be displayed on the screen.
* **Dynamic State Management:** Using GetX and reactive programming (Rx), the UI updates dynamically across *Loading*, *Empty List*, *Error*, and *Success* states without needing manual rebuilds.
* **Modern User Experience:** 
  * "Swipe to delete" functionality for intuitive expense removal.
  * Informative SnackBar notifications for error handling and success states.
  * Robust form validation processes for data integrity.

## 🛠️ Technologies & Architecture

* **Framework:** Flutter / Dart
* **Architecture:** Clean Architecture (Domain, Data, and Presentation layers)
* **State Management:** GetX
* **Database & Backend:** Firebase Cloud Firestore
* **Local Cache:** Hive (NoSQL Local Database)

## 📂 Folder Structure

The project is structured modularly according to Clean Architecture principles:

- `lib/features/`: Contains the main features of the app (Auth, Expenses).
  - `domain/`: Business rules (Entities) and interfaces (Repositories).
  - `data/`: Communication with external data sources (Firebase, Hive) and models.
  - `presentation/`: User interface (UI) and Controller (GetX) layers.
- `lib/core/`: Shared utility classes, constants, and themes used across the application.

## 👨‍💻 Developer

**Osman Selim Merey**
