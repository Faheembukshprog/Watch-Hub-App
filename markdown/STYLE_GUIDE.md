# Style Guide

> Coding conventions and architectural discipline rules for App-WatchHub. This file is the authoritative reference for code review — every PR is checked against the rules below.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Style Guide |
| **Purpose** | Define coding conventions, naming, file structure discipline, and review checklist |
| **Audience** | Contributors, code reviewers, AI coding agents |
| **Scope** | Dart/Flutter source code only; documentation style is implicit in the doc tree itself |
| **Version** | 1.0.0 |
| **Status** | Active — updated when conventions evolve |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [CONFIGURATION.md](CONFIGURATION.md) §7.1 analysis_options, [DEPENDENCIES.md](DEPENDENCIES.md) |

---

## Table of Contents

1. [Core Principles](#1-core-principles)
2. [File Naming Conventions](#2-file-naming-conventions)
3. [Folder Structure Discipline](#3-folder-structure-discipline)
4. [Class & Member Naming](#4-class--member-naming)
5. [Riverpod Provider Naming](#5-riverpod-provider-naming)
6. [Widget Naming](#6-widget-naming)
7. [Model Conventions (Freezed)](#7-model-conventions-freezed)
8. [Repository Conventions](#8-repository-conventions)
9. [Error Handling Conventions](#9-error-handling-conventions)
10. [Code Review Checklist](#10-code-review-checklist)
11. [References](#11-references)

---

## 1. Core Principles

The style guide is anchored on three principles. Every rule below derives from one of these; if a rule's underlying principle is unclear, the rule should be challenged in code review.

1. **Readability over cleverness.** Code is read 10x more often than it is written. Optimize for the reader, not the writer. This means: explicit over implicit, verbose over terse, simple over clever. If a junior engineer cannot understand a snippet in 30 seconds, it is too clever.

2. **Compile-time safety over runtime flexibility.** Prefer strongly-typed APIs that fail at compile time over dynamic APIs that fail at runtime. This means: avoid `dynamic`, avoid `Map<String, dynamic>` outside JSON boundaries, prefer sealed classes over tagged unions, prefer Riverpod's compile-time provider references over Provider's runtime type resolution.

3. **Single source of truth over duplication.** Every piece of logic, every constant, every UI pattern must live in exactly one place. If you find yourself copying code, extract it. If you find yourself repeating a constant, move it to `lib/core/constants/`. If you find yourself writing the same widget twice, promote it to `lib/shared/widgets/`.

These principles are not negotiable. A PR that violates them will be rejected with a request to refactor.

## 2. File Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Source files | `snake_case.dart` | `product_repository.dart` |
| Test files | `<source_name>_test.dart` | `product_repository_test.dart` |
| Generated files | `<source_name>.g.dart` or `<source_name>.freezed.dart` | `product_model.freezed.dart` |
| Widget files | `<widget_name>_widget.dart` or just `<widget_name>.dart` for pages | `luxury_button.dart`, `login_page.dart` |
| Provider files | `<feature>_provider.dart` | `auth_provider.dart` |
| Model files | `<entity>_model.dart` | `product_model.dart` |
| Repository files | `<entity>_repository.dart` | `product_repository.dart` |
| Service files | `<service_name>_service.dart` | `analytics_service.dart` |
| Constant files | `<domain>_constants.dart` | `catalog_constants.dart` |
| Utility files | `<utility_name>.dart` (singular) | `formatters.dart`, `validators.dart` |

### 2.1 File Header

Every `.dart` file must begin with a brief doc comment explaining its purpose:

```dart
/// Product repository contract.
///
/// Defines the abstract interface for product data operations.
/// Implementations live in [FirebaseProductRepository].
library product_repository;

import 'package:app_watchhub/shared/models/product_model.dart';

abstract class ProductRepository {
  // ...
}
```

The `library` directive is optional but recommended for files that export a single conceptual module.

## 3. Folder Structure Discipline

The folder structure defined in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §3 is enforced by `dart_code_metrics` lint rules. The key rules:

| Rule | Enforcement |
|---|---|
| `lib/features/X/` MAY NOT import from `lib/features/Y/` | `dart_code_metrics` `ban-dependencies` config |
| `lib/features/X/presentation/` MAY NOT call Firestore directly | Code review |
| `lib/features/X/state/` MUST depend on `lib/shared/repositories/` (interfaces), NOT `lib/core/services/` (implementations) | Code review |
| `lib/core/` MAY be imported by any layer | — |
| `lib/shared/` MAY be imported by any layer | — |
| A new shared widget must be promoted from `features/X/widgets/` to `shared/widgets/` only after use in >= 2 features | Refactor trigger |

### 3.1 Import Order

Imports within a file must be grouped and ordered:

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter / Material
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Project imports (alphabetical)
import 'package:app_watchhub/core/constants/app_constants.dart';
import 'package:app_watchhub/shared/models/product_model.dart';
import 'package:app_watchhub/shared/repositories/product_repository.dart';

// 5. Relative imports (within same feature folder)
import 'product_card.dart';
import '../state/catalog_provider.dart';
```

The `dart_code_metrics` `sort-directives` rule enforces alphabetical order within each group.

## 4. Class & Member Naming

| Element | Convention | Example |
|---|---|---|
| Classes | `PascalCase` | `ProductRepository`, `AuthService` |
| Enums | `PascalCase` (singular) | `OrderStatus`, `AuthState` |
| Enum values | `camelCase` | `OrderStatus.processing`, `AuthState.authenticated` |
| Extensions | `PascalCase` + descriptive suffix | `StringValidators`, `BuildContextExtensions` |
| Mixins | `PascalCase` | `DisposableMixin` |
| Constants | `lowerCamelCase` for top-level; `SCREAMING_SNAKE_CASE` for compile-time constants | `defaultPageSize = 20`; `const TAX_RATE = 0.08;` |
| Variables | `lowerCamelCase` | `currentUser`, `cartItems` |
| Final variables | `lowerCamelCase` | `final productName = 'Submariner';` |
| Private members | prefix `_` (underscore) | `_authService`, `_isLoading` |
| Boolean variables / getters | `is`/`has`/`can`/`should` prefix | `isAuthenticated`, `hasItems`, `canCheckout` |
| Methods | `lowerCamelCase`, verb-first | `fetchProducts()`, `addToCart()`, `validateEmail()` |
| Async methods | verb-first, return `Future<T>` | `Future<User> fetchUser()` |
| Streams | verb-first, return `Stream<T>` | `Stream<List<Product>> watchProducts()` |
| Getters | noun or adjective | `get isLoggedIn`, `get cartTotal` |

### 4.1 Type Annotations

- Always annotate public API return types and parameters.
- For local variables where the type is obvious from the initializer, inference is acceptable.
- Never use `dynamic` in public API; if a type is truly unknown, use `Object` and cast.

```dart
// GOOD
Future<List<Product>> fetchProducts() async { ... }
User parseUser(Map<String, dynamic> json) { ... }  // dynamic only at JSON boundary

// BAD
fetchProducts() async { ... }  // missing return type
parseUser(json) { ... }  // missing parameter type
```

## 5. Riverpod Provider Naming

| Provider Type | Naming Convention | Example |
|---|---|---|
| `Provider<T>` | `<thing>Provider` | `analyticsServiceProvider` |
| `FutureProvider<T>` | `<thing>Provider` | `productDetailProvider` |
| `StreamProvider<T>` | `<thing>Provider` | `catalogStreamProvider` |
| `AsyncNotifierProvider` | `<thing>Provider` (notifier class is `<Thing>Notifier`) | `cartProvider` (class `CartNotifier`) |
| `NotifierProvider` | `<thing>Provider` (notifier class is `<Thing>Notifier`) | `filterProvider` (class `FilterNotifier`) |
| `Provider.family<T, Param>` | `<thing>Provider` | `productByIdProvider` |

### 5.1 Provider Definition Pattern

Use the `@riverpod` annotation for code generation:

```dart
@riverpod
class Cart extends _$Cart {
  @override
  CartState build() {
    // Load from Hive on init
    return CartState.empty();
  }

  Future<void> addItem(Product product, int quantity) async { ... }
  Future<void> removeItem(String productId) async { ... }
  void clear() { ... }
}

@riverpod
Stream<List<Product>> catalogStream(CatalogStreamRef ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchAll();
}
```

### 5.2 Provider Consumption Pattern

```dart
// In a widget:
class CatalogPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogStreamProvider);

    return catalogAsync.when(
      data: (products) => ProductGrid(products: products),
      loading: () => const LoadingIndicator(),
      error: (e, st) => ErrorStateWidget(
        message: 'Failed to load catalog',
        onRetry: () => ref.invalidate(catalogStreamProvider),
      ),
    );
  }
}
```

## 6. Widget Naming

| Widget Type | Naming Convention | Example |
|---|---|---|
| Pages (full-screen) | `<Feature>Page` | `CatalogPage`, `LoginPage`, `AdminDashboardPage` |
| Reusable widgets (atomic) | `<Description>` (noun) | `LuxuryButton`, `GlassCard`, `PriceTag` |
| Reusable widgets (composite) | `<Description><Type>` | `ProductCard`, `FilterChipBar`, `OrderListItem` |
| Dialogs | `<Feature>Dialog` | `StockMismatchDialog`, `ConfirmOrderDialog` |
| Forms | `<Feature>Form` | `LoginForm`, `RegisterForm` |
| Form fields | `<Field>Field` | `EmailField`, `PasswordField` |
| Appbars | `<Feature>AppBar` | `CatalogAppBar`, `AdminDashboardAppBar` |

### 6.1 Widget Construction

- Use `const` constructors wherever possible.
- Pass data via constructor parameters; do not fetch data inside `build()`.
- Use named parameters for widgets with more than 2 parameters.

```dart
// GOOD
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showStockBadge = true,
  });

  final Product product;
  final VoidCallback onTap;
  final bool showStockBadge;

  @override
  Widget build(BuildContext context) { ... }
}
```

## 7. Model Conventions (Freezed)

All data models use `freezed` for immutability and `json_serializable` for JSON round-trip.

```dart
@freezed
class Product with _$Product {
  const factory Product({
    required String productId,
    required String modelName,
    required String brand,
    required double price,
    required int stockCount,
    required String assetPath,
    @Default({}) Map<String, dynamic> specs,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
```

### 7.1 Model Rules

| Rule | Enforcement |
|---|---|
| All models use `@freezed` | Code review |
| All models have `fromJson` factory | Code review |
| All models are immutable (no setters) | Freezed enforces |
| All required fields are `required` | Freezed enforces |
| Optional fields are nullable (`?`) | Freezed enforces |
| Default values use `@Default(...)` | Freezed enforces |
| Models do not contain business logic | Code review — logic goes in services or repositories |
| Models do not contain UI concerns | Code review |
| DateTime fields are always `DateTime` (Dart), never `Timestamp` (Firestore) | Conversion in repository |

### 7.2 Firestore Timestamp Conversion

The Firestore SDK returns `Timestamp` objects. Convert to `DateTime` in the repository layer before constructing the model:

```dart
Product _fromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Product.fromJson({
    ...data,
    'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    'updatedAt': data['updatedAt'] != null
        ? (data['updatedAt'] as Timestamp).toDate().toIso8601String()
        : null,
  });
}
```

## 8. Repository Conventions

```dart
abstract class ProductRepository {
  Future<Product> getProduct(String productId);
  Stream<List<Product>> watchAll();
  Future<void> create(Product product);
  Future<void> update(Product product);
  Future<void> delete(String productId);
}

class FirebaseProductRepository implements ProductRepository {
  FirebaseProductRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Product> getProduct(String productId) async { ... }

  // ... other methods
}
```

### 8.1 Repository Rules

| Rule | Enforcement |
|---|---|
| Repository is an `abstract class` (or `abstract interface class` in Dart 3) | Code review |
| Implementation class is named `<Backend><Entity>Repository` | Code review |
| Implementation is injected via Riverpod `Provider` override | Code review |
| Repository methods return domain models, never raw `Map<String, dynamic>` | Code review |
| Repository methods return `Future<T>` or `Stream<T>`, never `void` for writes | Code review |
| Repository methods throw typed exceptions (see §9) | Code review |

## 9. Error Handling Conventions

```dart
// Define typed exceptions
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class StockException extends AppException {
  const StockException(super.message, this.productId);
  final String productId;
}

class NetworkException extends AppException {
  const NetworkException(super.message, this.originalError);
  final Object originalError;
}
```

### 9.1 Error Handling Rules

| Rule | Enforcement |
|---|---|
| Throw typed exceptions, never `Exception('msg')` | Code review |
| Never `catch (e) { /* ignore */ }` | `dart_code_metrics` rule |
| All async errors propagate to `AsyncValue.error` | Code review |
| UI renders errors via `ErrorStateWidget` | Code review |
| All errors logged to Crashlytics | Code review |
| Error messages shown to users are human-readable, never raw exception text | Code review |

### 9.2 Error Translation Layer

Firebase exceptions are translated to typed `AppException` subclasses at the repository boundary:

```dart
@override
Future<Product> getProduct(String productId) async {
  try {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) {
      throw AppException('Product not found: $productId');
    }
    return _fromDoc(doc);
  } on FirebaseException catch (e) {
    throw _translateFirebaseException(e);
  }
}

AppException _translateFirebaseException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return const AuthException('You do not have permission to perform this action.');
    case 'unavailable':
      return NetworkException('Network error. Check your connection.', e);
    default:
      return AppException('Unexpected error: ${e.message}');
  }
}
```

## 10. Code Review Checklist

Every PR must pass this checklist before merge. Reviewers (the author themselves for solo dev, plus AI agents) verify each item.

### 10.1 Architecture Checklist

- [ ] No cross-feature imports (e.g., `features/auth/` does not import from `features/cart/`)
- [ ] Presentation layer does not call Firestore directly
- [ ] State layer depends on repository interfaces, not implementations
- [ ] New shared widget promoted only if used by >= 2 features
- [ ] No business logic in models or widgets

### 10.2 Naming & Style Checklist

- [ ] Files follow `snake_case.dart` convention
- [ ] Classes follow `PascalCase`; members follow `lowerCamelCase`
- [ ] Booleans prefixed with `is`/`has`/`can`/`should`
- [ ] Private members prefixed with `_`
- [ ] Imports grouped and ordered per §3.1
- [ ] `const` constructors used where possible

### 10.3 Type Safety Checklist

- [ ] No `dynamic` in public API (except JSON boundary)
- [ ] All public methods have explicit return types
- [ ] All public method parameters have explicit types
- [ ] Nullable types marked with `?` (no implicit nulls)

### 10.4 Error Handling Checklist

- [ ] No silent `catch (e) {}` blocks
- [ ] Typed exceptions thrown (not raw `Exception`)
- [ ] Errors propagated to `AsyncValue.error` in providers
- [ ] UI uses `ErrorStateWidget` for error display
- [ ] Errors logged to Crashlytics

### 10.5 Testing Checklist

- [ ] Unit tests added for new business logic
- [ ] Widget tests added for new UI components
- [ ] Rules tests added for any Firestore rule changes
- [ ] Coverage threshold (60%) maintained
- [ ] Tests follow naming convention: `test('describes behavior', ...)`

### 10.6 Documentation Checklist

- [ ] Public API has dartdoc comments
- [ ] Complex business logic has explanatory comments
- [ ] If architectural change: ADR added to [DECISIONS.md](DECISIONS.md)
- [ ] If new dependency: [DEPENDENCIES.md](DEPENDENCIES.md) updated
- [ ] If new error mode: [TROUBLESHOOTING.md](TROUBLESHOOTING.md) updated
- [ ] If new risk: [RISKS.md](RISKS.md) updated

### 10.7 Performance Checklist

- [ ] No heavy synchronous work in `build()` methods
- [ ] Lists use `ListView.builder` (not `ListView(children: ...)`)
- [ ] Images have `cacheWidth`/`cacheHeight` where applicable
- [ ] Provider `select()` used to limit rebuild scope where applicable

## 11. References

- Internal: [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [CONFIGURATION.md](CONFIGURATION.md) §7.1 analysis_options, [DEPENDENCIES.md](DEPENDENCIES.md), [TESTING.md](TESTING.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- External: [Effective Dart](https://dart.dev/guides/language/effective-dart), [Flutter style guide](https://docs.flutter.dev/cookbook), [Riverpod best practices](https://riverpod.dev/docs/advanced/best-practices), [Freezed documentation](https://pub.dev/packages/freezed)
