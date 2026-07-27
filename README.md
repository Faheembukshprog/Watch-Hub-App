# App-WatchHub

Flutter luxury watch commerce MVP using Riverpod, GoRouter, Hive CE, Firebase Auth, and Cloud Firestore.

## Current Progress

| Area | Status | Notes |
|---|---|---|
| Catalog | Done | Firestore `products` stream via `watchProductsProvider` |
| Cart | Done / persistence gap | `CartNotifier` handles cart behavior; Hive write-through is still pending |
| Routing | Done | `GoRouter` plus `StatefulShellRoute.indexedStack` bottom tabs |
| Orders | Partial | Checkout creates local order history; Firestore tracking is pending |
| Wishlist | Partial | Toggle provider exists; persistence/screens are pending |
| Reviews | Partial | Product detail review UI exists; Firestore moderation is pending |
| Auth | Partial | Firebase init/auth state exists; real email/password and roles are pending |
| Support | Partial | Support and FAQ screens exist; ticket persistence is pending |

## Key Docs

- [Agent guide](AGENTS.md)
- [Gemini guide](GEMINI.md)
- [Documentation index](markdown/INDEX.md)
- [Architecture](markdown/ARCHITECTURE.md)
- [Testing](markdown/TESTING.md)

## Commands

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```
