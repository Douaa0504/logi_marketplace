# LogiMarketplace

A robust, production-ready Multi-Vendor E-Commerce mobile application built with Flutter. The project bridges artistic digital design with core software engineering principles, featuring a scalable architecture tailored for both buyers and sellers.

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter & Dart
- **Architecture:** Clean Architecture (Feature-first inside Presentation)
- **Design Pattern:** Repository Pattern (SOLID Principles)
- **State Management:** BLoC / Cubit (Predictable State Flow)
- **Backend Service:** Supabase (Remote Database & Authentication)
- **Local Caching:** Hive (Offline-First Architecture Capabilities)

---

## 📂 Project Structure Overview

The codebase is organized following strict **Clean Architecture** guidelines to ensure maintainability and testability:

```text
lib/
├── core/          # Shared utilities, themes, and network configurations
├── data/          # Models, API contracts (Data Sources), and Repository Implementations
├── domain/        # Enterprise business rules (Entities, Use Cases, Repository Interfaces)
└── presentation/  # UI Layer (Screens, Widgets, and State Management via Cubit)