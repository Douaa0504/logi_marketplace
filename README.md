# Logi Marketplace

A Flutter-based multi-vendor marketplace for Buyers and Sellers, built around a clean domain/data/presentation architecture and backed by Supabase for authentication, product data, storage, and role-aware access control.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11.1-02569B?logo=flutter" alt="Flutter version" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart language" />
  <img src="https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase" alt="Supabase backend" />
  <img src="https://img.shields.io/badge/State-BLoC%20%2F%20Cubit-6C63FF" alt="BLoC state management" />
  <img src="https://img.shields.io/badge/Storage-Hive-8A2BE2" alt="Hive local storage" />
</p>

---

## Project Overview

Logi Marketplace is a mobile commerce application that separates the buyer journey from the seller operations flow while keeping both tied to the same shared product catalog and profile data model.

The app is organized around a role-aware experience:

- Buyers can browse products, search and filter the catalog, save favorites, review items, and manage a cart.
- Sellers can manage their storefront profile, publish or update products, monitor orders, review sales data, and handle notifications.
- Shared infrastructure is handled through Supabase and local storage, while the UI is connected through BLoC/Cubit state management.

The project uses Flutter and Dart for the mobile client, Supabase for remote persistence and role-based access, and Hive for local application state such as theme selection and cached user role information.

---

## Screenshots

The following screenshots are included directly from the project's existing app gallery in their original numbered order.

<p align="center">
  <img src="lib/AppScreens/Screenshot1.jpg" width="200" alt="Authentication welcome screen" />
  <img src="lib/AppScreens/Screenshot2.jpg" width="200" alt="Buyer login screen" />
  <img src="lib/AppScreens/Screenshot3.jpg" width="200" alt="Seller registration screen" />
  <img src="lib/AppScreens/Screenshot4.jpg" width="200" alt="Buyer home catalog" />
  <img src="lib/AppScreens/Screenshot5.jpg" width="200" alt="Category and search controls on the buyer catalog" />
</p>

<p align="center">
  <img src="lib/AppScreens/Screenshot6.jpg" width="200" alt="Buyer product grid with cards and prices" />
  <img src="lib/AppScreens/Screenshot7.jpg" width="200" alt="Product details view" />
  <img src="lib/AppScreens/Screenshot8.jpg" width="200" alt="Product reviews and rating summary" />
  <img src="lib/AppScreens/Screenshot9.jpg" width="200" alt="Favorites list screen" />
  <img src="lib/AppScreens/Screenshot10.jpg" width="200" alt="Cart with order summary" />
</p>

<p align="center">
  <img src="lib/AppScreens/Screenshot11.jpg" width="200" alt="Checkout flow and order placement" />
  <img src="lib/AppScreens/Screenshot12.jpg" width="200" alt="Order confirmation screen" />
  <img src="lib/AppScreens/Screenshot13.jpg" width="200" alt="Seller dashboard overview" />
  <img src="lib/AppScreens/Screenshot14.jpg" width="200" alt="Seller orders list" />
  <img src="lib/AppScreens/Screenshot15.jpg" width="200" alt="Order management details" />
</p>

<p align="center">
  <img src="lib/AppScreens/Screenshot16.jpg" width="200" alt="Seller products management screen" />
  <img src="lib/AppScreens/Screenshot17.jpg" width="200" alt="Product editing form" />
  <img src="lib/AppScreens/Screenshot18.jpg" width="200" alt="Seller shop profile editor" />
  <img src="lib/AppScreens/Screenshot19.jpg" width="200" alt="Public shop storefront" />
  <img src="lib/AppScreens/Screenshot20.jpg" width="200" alt="Seller analytics dashboard" />
</p>

<p align="center">
  <img src="lib/AppScreens/Screenshot21.jpg" width="200" alt="Seller notifications panel" />
  <img src="lib/AppScreens/Screenshot22.jpg" width="200" alt="User profile and account settings" />
  <img src="lib/AppScreens/Screenshot23.jpg" width="200" alt="Theme and preferences settings" />
  <img src="lib/AppScreens/Screenshot24.jpg" width="200" alt="Image upload and media selection flow" />
  <img src="lib/AppScreens/Screenshot25.jpg" width="200" alt="Inventory configuration screen" />
</p>

<p align="center">
  <img src="lib/AppScreens/Screenshot27.jpg" width="200" alt="Review submission form" />
  <img src="lib/AppScreens/Screenshot28.jpg" width="200" alt="Review list with comments" />
  <img src="lib/AppScreens/Screenshot29.jpg" width="200" alt="Seller review visibility screen" />
  <img src="lib/AppScreens/Screenshot30.jpg" width="200" alt="Marketplace listing with shop and product detail" />
  <img src="lib/AppScreens/Screenshot31.jpg" width="200" alt="Navigation and dashboard summary" />
</p>

---

## Features

### Authentication and Role Management

The app implements a role-based authentication flow using Supabase Auth and a dedicated `AuthCubit` for register, login and sign-out actions. User role information is cached locally with Hive, and the app routes users to the appropriate experience after authentication.

Key components:

- `lib/presentation/auth/cubit/auth_cubit.dart`
- `lib/data/datasources/auth_remote_datasource.dart`
- `lib/data/repositories/auth_repository_impl.dart`
- `lib/core/storage/app_storage.dart`

### Buyer Experience

The buyer journey is centered on the catalog, product discovery, and product detail flow.

Supported capabilities include:

- product browsing by category and keyword
- search and filtering on the buyer home screen
- reusable product cards and detail pages
- favorites management
- cart management
- order placement through the cart and order flow
- review submission and display on product details pages

The main UI is implemented in the buyer presentation layer, with the related state loaded through `BuyerHomeCubit` and repository access to the product catalog.

### Product Discovery and Product Details

Product data is exposed through a repository abstraction and mapped to domain entities before being consumed by the UI. The app supports product metadata such as title, description, price, category, image URL, and inventory configuration.

The domain model includes:

- `ProductEntity`
- `ProductInventoryOptionEntity`
- related repository contracts in `lib/domain/repositories/product_repository.dart`

### Favorites

Favorites are stored against the authenticated user in a Supabase-backed repository. The buyer can add or remove products from their favorites list, and the list is read back from the current user’s favorite records.

### Reviews and Ratings

The review feature is modeled through `ReviewEntity` and `ReviewRepository`, with a Supabase implementation for list, insert, update, and delete operations. Each review contains a rating, review text, creation timestamp, and buyer metadata.

The application validates the rating range and review length on the client side and checks whether the current user is the owner before deletion. This is enforced in the repository layer and backed by the Supabase schema and RLS policies defined in the migration files.

### Seller Dashboard and Shop Management

Seller functionality is grouped under the seller dashboard with dedicated sections for:

- analytics
- orders
- products
- profile and storefront configuration

The app supports editing the shop profile, uploading a shop logo, previewing the public storefront, and managing product listings for the seller's own catalog.

### Product Management

Sellers can add and update products through a product repository and product use cases. Product creation includes image handling, making use of the mobile image picker package.

### Order Management

Order retrieval and order status updates are performed through the Supabase-backed order repository implementation. Seller order screens display order snapshots, product information, and status transitions.

### Notifications

The seller notification repository loads unread-only and all notifications for the connected seller, with read/unread states and marking-as-read methods exposed through the repository contract.

### Profiles and Storefronts

The public and private shop profile flows are separated. The seller profile repository returns both the current user’s private profile and a public version for a given seller ID, which is then used by the public shop page. This keeps store identity data available where needed without exposing unrelated data in the app.

### Themes and Local Storage

Local preferences are handled via `AppStorage`, backed by Hive. The app stores theme mode and role information locally so that the selected display mode and recent auth role are available after app restarts.

---

## Architecture

The project follows a clean layered structure that mirrors the actual code organization in the repository.

```text
+------------------------------------------------------+
|                  Presentation Layer                   |
|  Pages, Widgets, Cubits, BLoCs, UI state            |
|  - auth, buyer, seller, shared components            |
+---------------------------+--------------------------+
                            |
                            v
+------------------------------------------------------+
|                    Domain Layer                       |
|  Entities, use cases, repository contracts           |
|  - ProductEntity, ReviewEntity, ShopProfileEntity    |
|  - ProductRepository, ReviewRepository, AuthRepository|
+---------------------------+--------------------------+
                            |
                            v
+------------------------------------------------------+
|                     Data Layer                        |
|  Repositories implementations + datasources         |
|  - Supabase clients, product repository, profile      |
|  - favorites, notifications, reviews                 |
+---------------------------+--------------------------+
                            |
                            v
+------------------------------------------------------+
|                 Supabase / PostgreSQL                  |
|  Auth, products, profiles, reviews, favorites,      |
|  notifications, orders, storage, RLS policies       |
+------------------------------------------------------+
                            ^
                            |
+------------------------------------------------------+
|                     Hive / Local Storage             |
|  AppStorage: theme preference and cached auth role   |
+------------------------------------------------------+
```

This architecture is reflected directly in the repository layout and the dependency wiring in `lib/main.dart`, where repository providers and blocs are assembled at the app root.

---

## Tech Stack

| Technology | Purpose in this project |
| --- | --- |
| Flutter | Cross-platform mobile application framework for the Buyer and Seller experience |
| Dart | Application logic, state management, domain models, and business rules |
| Supabase Flutter | Auth, PostgreSQL-backed data access, and remote repository integration |
| Flutter BLoC | State management for authentication, product catalog, favorites, and UI flows |
| Hive | Local persistence for theme preference and cached role data |
| image_picker | Seller product and shop image uploads |
| flutter_dotenv | Loading environment configuration from `.env` |
| http | HTTP client support for remote operations |
| equatable | Value-based state comparisons in the app state layer |

---

## Project Structure

```text
.
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── lib/
│   ├── core/
│   │   ├── navigation/
│   │   ├── storage/
│   │   └── theme/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── auth/
│   │   ├── buyer/
│   │   ├── seller/
│   │   └── shared/
│   ├── main.dart
│   └── AppScreens/
├── supabase/
│   └── migrations/
├── test/
├── .env
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── logi_marketplace.iml
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.11.x or compatible Dart SDK
- A Supabase project with authentication enabled
- A configured `.env` file in the project root

### 1. Clone the repository

```bash
git clone <repository-url>
cd logi_marketplace
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

The app loads environment variables from a `.env` file at the project root. Create a `.env` file with the Supabase settings used by the app:

```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```

The values are read in `lib/main.dart` when the application initializes Supabase.

### 4. Run the app

```bash
flutter run
```

### 5. Run tests

```bash
flutter test
```

---

## Security and Data Access Notes

The codebase is built around Supabase and includes migration files under `supabase/migrations/` to scope access to buyer, seller, and review-related workflows. The app uses authenticated sessions to restrict actions such as:

- seller-only product management
- owner-only review deletion
- seller notifications scoped to the connected seller
- public shop and review visibility tied to the correct product and profile context

These rules are not enforced only at the UI layer; the repository code and the Supabase schema work together to keep data access consistent.

---

## Notes

- This repository contains the Flutter client and its Supabase integration for a multi-vendor marketplace flow.
- The app architecture is intentionally layered and easy to extend for additional catalog, order, or seller features.
- This project is best run with a valid Supabase project and matching `.env` values.

---

## License

Copyright © 2026 Douaa ERRAMI.

All rights reserved, subject to the applicable ownership rights and permissions governing this project.

Do not redistribute proprietary source code, company data, or confidential materials without the necessary authorization.

---

**Developed by Douaa ERRAMI**

*Flutter Mobile Developer · Dart · Cross-Platform Development*

[GitHub Profile](https://github.com/Douaa0504)

