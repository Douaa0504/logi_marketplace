# LogiMarketplace 

A robust, production-ready Multi-Vendor E-Commerce mobile application built with Flutter. The project bridges artistic digital design with core software engineering principles, featuring a scalable architecture tailored for both buyers and sellers.

---

##  Tech Stack & Architecture

- **Framework:** Flutter & Dart
- **Architecture:** Clean Architecture (Feature-First Layering inside Presentation for optimal scalability)
- **Design Pattern:** Repository Pattern strictly adhering to SOLID Principles
- **State Management:** BLoC / Cubit (Decoupled business logic with predictable state flow)
- **Backend & Database:** Supabase (Remote Database, PostgREST APIs, PostgreSQL, and Authentication)
- **Database Security:** Row-Level Security (RLS) policies enforcing multi-role permissions (Buyers & Sellers)
- **Local Caching:** Hive (Offline-First Architecture & thread-safe local session caching)
- **Environment Management:** Dotenv environment virtualization for secure API keys

---

## ⚡ Key Features & Schema Implementation

- **Role-Based Authentication:** Dynamic registration and login flow for both Buyers and Sellers.
- **Automated Profile Triggers:** Seamless Postgres Trigger synchronization (`handle_new_user`) bridging Supabase Auth with custom user profiles.
- **Dynamic Product Catalog:** Real-time catalog feed displaying categorized marketplace items with full details and responsive image fetching.
- **Granular RLS Policies:** Secured data access ensuring users only modify or manage authorized resources.

---

##  Project Structure Overview

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
│   ├── datasources/       # (AuthRemoteDataSource, ProductRemoteDataSource, Hive Boxes)
│   ├── models/
│   └── repositories/      # (AuthRepositoryImpl, ProductRepositoryImpl)
│
├── domain/                # Domain Layer - Pure Dart Enterprise Rules (Entities, Use Cases, Contracts)
│   ├── entities/
│   ├── repositories/      # (AuthRepository & ProductRepository Interfaces)
│   └── usecases/
│
└── presentation/          # Presentation Layer (UI Widgets, Pages, and Cubit State Management)
    ├── auth/
    │   ├── cubit/         # (AuthCubit & AuthState driving dynamic UI roles)
    │   └── pages/         # (SplashPage, AuthPage)
    ├── buyer/             # Buyer-centric features (Home Catalog, Cart, Product Details)
    ├── seller/            # Seller-centric features (Dashboard, Product Management)
    └── shared/            # Reusable UI components (Custom Buttons, Input Fields)