# App-WatchHub Agent Guide

## Section A - Identity

- App-WatchHub is a Flutter/Dart luxury watch commerce MVP.
- Stack: Flutter, Dart, Riverpod Generator, GoRouter, Hive CE, Firebase Auth, Cloud Firestore, Freezed, and JsonSerializable.
- Firebase Auth identifies users. Firestore stores catalog, orders, reviews, support, feedback, FAQ, and user documents.
- Firestore Security Rules are the authoritative security boundary. GoRouter redirects are UX only.

## Section B - Conventions

- Keep app code feature-first under `lib/features`; keep shared infrastructure under `lib/core`; keep shared models, providers, and repositories under `lib/shared`.
- Prefer generated Riverpod providers (`@riverpod` / `.g.dart`) and immutable Freezed models for new state/data work.
- Wrap widget tests that read providers with `ProviderScope`.
- Override Firebase-backed providers in tests with mock providers or test values, especially `routerProvider`, auth streams, and Firestore repositories.
- Ignore generated platform app folders unless the task is platform config, build config, or native integration.
- Do not edit generated `.g.dart` or `.freezed.dart` files by hand; regenerate them.

## Section C - Modules

Completed:

- Catalog: `watchProductsProvider` streams Firestore `products` through `ProductRepository`.
- Cart: `CartNotifier` supports add, update, remove, clear, totals, and checkout handoff.
- Routing: `GoRouter` uses `StatefulShellRoute.indexedStack` for Catalog, Cart, Orders, and Profile tabs.

Pending / gaps:

- Cart Hive persistence: dependency is present, but box init, adapter registration, hydration, and write-through persistence still need implementation.
- Wishlist: local toggle provider exists; Hive persistence and dedicated screens remain pending.
- Reviews: detail UI and local review provider exist; Firestore-backed submission/moderation remains pending.
- Auth: Firebase init/auth-state plumbing exists; real email/password screens, profiles, and role checks remain pending.
- Orders/support: local order history plus support/FAQ screens exist; Firestore persistence and admin workflows remain pending.

## Section D - Commands

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```
