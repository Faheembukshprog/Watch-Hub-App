# App-WatchHub

Flutter luxury watch commerce application using Riverpod, GoRouter, Hive CE, Firebase Auth, and Cloud Firestore.

## Implementation Status

| Feature Area | Status | Implementation Details |
|---|---|---|
| Catalog | Complete | Firestore products stream via watchProductsProvider with auto-seeding |
| Cart | Complete | CartNotifier with Hive CE write-through local storage and quantity management |
| Wishlist | Complete | Curated wishlist screen with local Hive CE persistence |
| Routing | Complete | GoRouter with StatefulShellRoute bottom tabs and luxury navigation transitions |
| Orders | Complete | Checkout order placement with local Hive CE history and Cloud Firestore sync |
| Support | Complete | Customer Concierge screen with online status indicators and FAQ accordion |
| Auth | Complete | Firebase Auth lazy provider VIP demo shortcut and guest bypass mode |
| Theme | Complete | Dark Obsidian and Slate Royal Light Material 3 design systems |

## Documentation

- [Agent guide](AGENTS.md)
- [Gemini guide](GEMINI.md)
- [Documentation index](markdown/INDEX.md)
- [Architecture](markdown/ARCHITECTURE.md)
- [Testing](markdown/TESTING.md)

## Commands

```bash
flutter pub run build_runner build
flutter analyze
flutter test
```
