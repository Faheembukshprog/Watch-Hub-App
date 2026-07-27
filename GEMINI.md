# App-WatchHub — Project Instructions

This file serves as the team-shared engineering blueprint, coding conventions, and architectural rules for the App-WatchHub project. All developers and AI assistants must strictly adhere to these mandates.

---

## 1. Core Architectural Mandates

### Feature-First Clean Architecture Adaptation
The codebase is structured under `lib/` using feature modules to isolate concerns and prevent spaghetti dependencies:
* `lib/core/`: Global, cross-cutting infrastructure (theme, main router configuration, utility extensions).
* `lib/features/`: Fully self-contained functional domain boundaries. Each feature isolates its presentation, state/business logic, domain models, and repositories:
  * **Presentation**: Widgets, Screens, and Form Validation. UI must render reactive `AsyncValue` states elegantly (e.g., using shimmer loading blocks).
  * **State**: Riverpod Providers (using `@riverpod` annotations and auto-generated classes) to orchestrate data-flow.
  * **Domain**: Freezed models (`@freezed`) and abstract repository definitions.
  * **Infrastructure**: Concrete implementations (e.g., Firestore connections, Hive storage drivers).

### Database Security at the Edge
* Client-side route guards (via GoRouter) exist exclusively for user experience (UX) redirects.
* **The true security boundary is the Firestore Security Rules layer.** Do not rely on client-side state or presentation logic to enforce read/write access permissions.

---

## 2. Coding Standards & Style Guidelines

### A. State Management & Serialization
* **Riverpod**: Use Riverpod Generator for code-generated providers. Prefer `AsyncNotifier` for complex stateful operations. Avoid legacy raw Provider boilerplate.
* **Immutability**: All data models must be immutable Freezed classes. Always use `.fromJson` and `.toJson` generation blocks.
* **Code Generation**: Ensure you run `flutter pub run build_runner build --delete-conflicting-outputs` when modifying models or providers.

### B. Navigation & Deep-Linking
* Use `GoRouter` exclusively. Utilize `StatefulShellRoute.indexedStack` for persistent state when switching between bottom-bar tabs.
* Full-screen views (like product details or checkout screens) that cover the bottom navigation bar must specify the `parentNavigatorKey: _rootNavigatorKey`.

### C. Design Aesthetics
* Deeply reflect premium luxury horology.
* Maintain a modern dark/light contrast theme using Material 3, cohesive micro-animations, glassmorphism card layouts, and subtle shimmer loaders during async states.

---

## 3. Testing Rules & Setup

### A. Coverage Target
* **Minimum Overall Coverage**: **60%** (enforced in CI pipeline).
* Models, utils, and core services should maintain high coverage (>80%).

### B. Firebase Test Bootstrapping
* **Critical**: During widget tests, `routerProvider` or auth streams are constructed synchronously. Because Firebase is not initialized in standard unit/widget tests, they will crash with `No Firebase App [DEFAULT] has been created`.
* **Standard Resolution**: Always mock or override the `routerProvider` or Firebase Auth/Firestore dependencies inside the test container using Riverpod's `overrides` parameters:
  ```dart
  ProviderScope(
    overrides: [
      routerProvider.overrideWithValue(mockRouter),
    ],
    child: const AppWatchHub(),
  )
  ```

---

## 4. Operational Commands
* **Run Tests**: `flutter test`
* **Run Linter**: `flutter analyze`
* **Trigger Code Gen**: `flutter pub run build_runner build --delete-conflicting-outputs`
