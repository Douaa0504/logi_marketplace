# LogiMarketplace

A robust, production-ready Multi-Vendor E-Commerce mobile application built with Flutter. The project bridges artistic digital design with core software engineering principles, featuring a scalable architecture tailored for both buyers and sellers.

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter & Dart
- **Architecture:** Clean Architecture (Feature-First Layering inside Presentation for optimal scalability)
- **Design Pattern:** Repository Pattern strictly adhering to SOLID Principles
- **State Management:** BLoC / Cubit (Decoupled business logic with predictable state flow)
- **Backend Service:** Supabase (Remote Database, PostgREST APIs, and Authentication)
- **Local Caching:** Hive (Offline-First Architecture & thread-safe local session caching)
- **Security:** Dotenv environment virtualization with Row-Level Security (RLS) enforced at the database layer

---

## 📂 Project Structure Overview

The codebase is organized following strict **Clean Architecture** guidelines to ensure maintainability, clear separation of concerns, and testability:

```text
lib/
│
├── core/                  # Shared components (Theme, Utilities, AppStorage Service)
│   ├── theme/
│   ├── constants/
│   └── errors/
│
├── data/                  # Data Layer (Models, Remote/Local Data Sources, Repositories Impl)
│   ├── datasources/       # (AuthRemoteDataSource, Hive Boxes)
│   ├── models/
│   └── repositories/      # (AuthRepositoryImpl - handles error wrapping)
│
├── domain/                # Domain Layer - Pure Dart Enterprise Rules (Entities, Use Cases, Contracts)
│   ├── entities/
│   ├── repositories/      # (AuthRepository Interface)
│   └── usecases/
│
└── presentation/          # Presentation Layer (UI Widgets, Pages, and Cubit State Management)
    ├── auth/
    │   ├── cubit/         # (AuthCubit & AuthState driving dynamic UI roles)
    │   └── pages/         # (SplashPage, AuthPage)
    ├── buyer/             # Buyer-centric features (Home, Cart, Product Details)
    ├── seller/            # Seller-centric features (Dashboard, Product Management)
    └── shared/            # Reusable UI components (Custom Buttons, Input Fields)