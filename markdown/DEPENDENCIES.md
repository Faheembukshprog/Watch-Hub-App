# Dependencies

> Complete dependency manifest for App-WatchHub. Every direct dependency is listed with version pin, license, free-tier budget impact, and maintenance status. This file is the authoritative source for `pubspec.yaml` content and the budget audit trail.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Dependencies |
| **Purpose** | Document every direct dependency with version, license, budget impact, and maintenance status |
| **Audience** | Maintainers, legal reviewers, security reviewers, AI coding agents |
| **Scope** | Direct dependencies only; transitive dependencies visible in `pubspec.lock` |
| **Version** | 1.0.0 |
| **Status** | Active — updated whenever `pubspec.yaml` changes |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [CONFIGURATION.md](CONFIGURATION.md), [DECISIONS.md](DECISIONS.md), [RISKS.md](RISKS.md), [LICENSE.md](../LICENSE.md), [STYLE_GUIDE.md](STYLE_GUIDE.md) |

---

## Table of Contents

1. [Dependency Policy](#1-dependency-policy)
2. [Direct Dependencies](#2-direct-dependencies)
3. [Dev Dependencies](#3-dev-dependencies)
4. [License Classification](#4-license-classification)
5. [Budget Impact Audit](#5-budget-impact-audit)
6. [Maintenance Status](#6-maintenance-status)
7. [Reference `pubspec.yaml`](#7-reference-pubspecyaml)
8. [References](#8-references)

---

## 1. Dependency Policy

Every dependency added to App-WatchHub is a long-term commitment. Dependencies introduce version-lock risk, supply-chain risk, and potential budget impact. The project enforces a strict policy before any new package is added to `pubspec.yaml`:

1. **Justification required.** The dependency must solve a problem that cannot be solved with stdlib or existing dependencies. The justification is recorded in [DECISIONS.md](DECISIONS.md) if the dependency is architecturally significant.
2. **License audit.** The license must be compatible with the project's intended license (currently `REQUIRES DECISION` — see [LICENSE.md](../LICENSE.md)). Permissive licenses (MIT, Apache 2.0, BSD) are accepted. Copyleft licenses (GPL) are flagged for review.
3. **Budget audit.** If the dependency has a paid tier or usage-based pricing, the free-tier limits must be documented in [RISKS.md](RISKS.md) and the dependency must be acceptable under the $0 budget constraint (C-1).
4. **Maintenance check.** The dependency must be actively maintained (commit within last 6 months) and have a healthy pub.dev score (>= 80).
5. **Lock file commit.** `pubspec.lock` is committed to Git to ensure reproducible builds.
6. **Dependabot configured.** GitHub Dependabot alerts are enabled to catch security vulnerabilities.

The policy is enforced by code review per [CONTRIBUTING.md](../CONTRIBUTING.md) § Review Checklist.

## 2. Direct Dependencies

| Package | Version | Purpose | License | Free-Tier Impact |
|---|---|---|---|---|
| `flutter` | SDK | Cross-platform UI framework | BSD-3-Clause | None |
| `firebase_core` | ^3.0.0 | Firebase initialization | BSD-3-Clause | None |
| `firebase_auth` | ^5.0.0 | Email/password authentication | BSD-3-Clause | None (Spark tier covers) |
| `cloud_firestore` | ^5.0.0 | NoSQL document database | BSD-3-Clause | None (Spark tier covers) |
| `firebase_analytics` | ^11.0.0 | Product analytics events | BSD-3-Clause | None (Spark tier covers) |
| `firebase_crashlytics` | ^4.0.0 | Crash reporting | BSD-3-Clause | None (Spark tier covers) |
| `flutter_riverpod` | ^2.5.0 | State management (AsyncNotifier) | MIT | None |
| `riverpod_annotation` | ^2.3.0 | Code-gen annotations for Riverpod | MIT | None |
| `freezed_annotation` | ^2.4.0 | Immutable model annotations | MIT | None |
| `json_annotation` | ^4.9.0 | JSON serialization annotations | BSD-3-Clause | None |
| `go_router` | ^14.0.0 | Declarative routing with guards | BSD-3-Clause | None |
| `hive_ce` | ^2.0.0 | Local storage (cart/wishlist persistence) | BSD-3-Clause | None |
| `path_provider` | ^2.1.0 | Filesystem path resolution | BSD-3-Clause | None |
| `google_fonts` | ^6.2.0 | Playfair Display + Inter fonts | Apache-2.0 | None (fonts free) |
| `intl` | ^0.19.0 | Number/date formatting (currency display) | BSD-3-Clause | None |
| `cached_network_image` | ^3.4.0 | Image caching (used for admin-uploaded images post-MVP) | MIT | None |
| `flutter_svg` | ^2.0.0 | SVG icon rendering | MIT | None |
| `logger` | ^2.4.0 | Structured logging | MIT | None |

### 2.1 Dependency Rationale Summary

| Package | Why This One | Alternatives Rejected |
|---|---|---|
| `flutter_riverpod` | Compile-time safety, AsyncNotifier, DI built-in | Provider (no compile safety), BLoC (too much boilerplate) — see [DECISIONS.md](DECISIONS.md) ADR-004 |
| `go_router` | Declarative guards, web deep-linking, Flutter team endorsement | auto_route (similar, smaller community) — see ADR-005 |
| `hive_ce` | Lightweight, no native deps, survives offline | SharedPreferences (too simple), SQLite (too heavy) |
| `google_fonts` | Runtime font loading without bundling | Bundling fonts directly (larger binary) |
| `freezed_annotation` | Immutable data classes with code-gen | Manual `==`/`hashCode` (boilerplate) |
| `firebase_analytics` | Native Firebase integration | Amplitude (paid beyond free tier) |
| `firebase_crashlytics` | Native Firebase integration | Sentry (paid beyond free tier) |
| `hive_ce` (Hive Community Edition) | Maintained fork of `hive` (original abandoned 2023) | `hive` original (unmaintained) |

## 3. Dev Dependencies

| Package | Version | Purpose | License |
|---|---|---|---|
| `flutter_test` | SDK | Widget test framework | BSD-3-Clause |
| `integration_test` | SDK | Integration test framework | BSD-3-Clause |
| `build_runner` | ^2.4.0 | Code generation runner | BSD-3-Clause |
| `freezed` | ^2.5.0 | Code generator for freezed_annotation | MIT |
| `json_serializable` | ^6.8.0 | Code generator for json_annotation | BSD-3-Clause |
| `riverpod_generator` | ^2.4.0 | Code generator for riverpod_annotation | MIT |
| `flutter_lints` | ^4.0.0 | Flutter lint rules | BSD-3-Clause |
| `dart_code_metrics` | ^5.7.6 | Static analysis and metrics | MIT |
| `mocktail` | ^1.0.0 | Mock framework for tests | BSD-3-Clause |
| `mocktail_image_network` | ^1.1.0 | Mock network images in tests | BSD-3-Clause |

### 3.1 Dev Dependency Rationale

| Package | Why This One | Alternatives Rejected |
|---|---|---|
| `mocktail` | No code-gen required (vs `mockito`); simpler API | `mockito` (requires annotation code-gen) |
| `dart_code_metrics` | Architecture rule enforcement (folder import bans) | `extra_lints` (less mature) |
| `freezed` | Industry-standard immutable data classes | `equatable` (less features) |

## 4. License Classification

All direct dependencies use permissive licenses compatible with the project's intended MIT license (pending Q-5 in [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md)).

| License | Count | Packages |
|---|---|---|
| MIT | 7 | flutter_riverpod, riverpod_annotation, freezed_annotation, cached_network_image, flutter_svg, logger, dart_code_metrics, freezed, riverpod_generator |
| BSD-3-Clause | 11 | flutter, firebase_core, firebase_auth, cloud_firestore, firebase_analytics, firebase_crashlytics, json_annotation, go_router, hive_ce, path_provider, intl, flutter_test, integration_test, build_runner, json_serializable, flutter_lints, mocktail, mocktail_image_network |
| Apache-2.0 | 1 | google_fonts |

### 4.1 License Compatibility Matrix

| License | Compatible with MIT Project? | Notes |
|---|---|---|
| MIT | Yes | Most permissive; no requirements beyond attribution |
| BSD-3-Clause | Yes | Permissive; no requirements beyond attribution + disclaimer |
| Apache-2.0 | Yes | Permissive; includes patent grant |

No GPL, AGPL, or other copyleft licenses are present. If a future dependency uses copyleft, it must be flagged in code review and the [LICENSE.md](../LICENSE.md) decision must be revisited.

## 5. Budget Impact Audit

Per [PROJECT_SCOPE.md](PROJECT_SCOPE.md) C-1, the total infrastructure cost must be $0/month at steady state. Every dependency with a paid tier is audited here:

| Dependency | Free Tier | Paid Tier Trigger | Risk |
|---|---|---|---|
| Firebase Auth | 50K verifies/day, unlimited users | Blaze tier required for SAML/OIDC | None — MVP uses email/password only |
| Cloud Firestore | 50K reads/day, 20K writes/day, 1GB egress/day | Blaze tier for higher limits | Medium — see [RISKS.md](RISKS.md) R-1 |
| Firebase Hosting | 360MB/day bandwidth, 10GB storage | Blaze tier for higher limits | Low — small static site |
| Firebase Analytics | Unlimited events | None — entirely free | None |
| Firebase Crashlytics | Unlimited crashes | None — entirely free | None |
| google_fonts | Free | None — fonts are open source (OFL) | None |
| GitHub Actions | 2000 min/month for public repos | None for public repos | None — project is public |

### 5.1 Budget Verification

At any time, the total monthly cost can be verified at:

1. **Firebase Console** → Billing (should show $0.00 on Spark tier)
2. **GitHub Actions** → Settings → Billing (should show 0 paid minutes)
3. **No other services** are paid (no Stripe, no Algolia, no Cloudinary, no Sentry paid tier)

If any non-zero charge appears, file an incident in [CHANGELOG.md](../CHANGELOG.md) and an entry in [RISKS.md](RISKS.md).

## 6. Maintenance Status

Each direct dependency's maintenance health is tracked here. A dependency is "at risk" if it has not had a commit in 6+ months or its pub.dev popularity score drops below 80.

| Package | Last Release | pub.dev Score | Status | Notes |
|---|---|---|---|---|
| `firebase_core` | 2026-Q2 | 100 | Healthy | Google-maintained |
| `firebase_auth` | 2026-Q2 | 100 | Healthy | Google-maintained |
| `cloud_firestore` | 2026-Q2 | 100 | Healthy | Google-maintained |
| `firebase_analytics` | 2026-Q2 | 100 | Healthy | Google-maintained |
| `firebase_crashlytics` | 2026-Q2 | 100 | Healthy | Google-maintained |
| `flutter_riverpod` | 2026-Q1 | 100 | Healthy | Active maintainer (Remi Rousselet) |
| `riverpod_annotation` | 2026-Q1 | 100 | Healthy | Same maintainer as above |
| `freezed_annotation` | 2026-Q1 | 100 | Healthy | Same maintainer as above |
| `json_annotation` | 2025-Q4 | 100 | Healthy | Google-maintained |
| `go_router` | 2026-Q2 | 100 | Healthy | Flutter team maintained |
| `hive_ce` | 2026-Q1 | 90 | Healthy | Community fork; active |
| `path_provider` | 2026-Q1 | 100 | Healthy | Flutter team maintained |
| `google_fonts` | 2025-Q4 | 100 | Healthy | Material team maintained |
| `intl` | 2026-Q1 | 100 | Healthy | Dart team maintained |
| `cached_network_image` | 2025-Q4 | 100 | Healthy | Active community maintainer |
| `flutter_svg` | 2026-Q1 | 100 | Healthy | Active community maintainer |
| `logger` | 2025-Q4 | 90 | Healthy | Active community maintainer |

### 6.1 Maintenance Review Cadence

Maintenance status is reviewed quarterly. Any package moving to "At Risk" status triggers a discussion in [DECISIONS.md](DECISIONS.md) about replacement.

## 7. Reference `pubspec.yaml`

The complete reference `pubspec.yaml` for App-WatchHub. This file is the source of truth; the actual `pubspec.yaml` in the repository must match.

```yaml
name: app_watchhub
description: Premium Luxury Watch E-Commerce Platform built on Serverless Event-Driven Architecture.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0

  # State management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Data classes
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Routing
  go_router: ^14.0.0

  # Local storage
  hive_ce: ^2.0.0
  path_provider: ^2.1.0

  # UI
  google_fonts: ^6.2.0
  flutter_svg: ^2.0.0
  cached_network_image: ^3.4.0

  # Utils
  intl: ^0.19.0
  logger: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0

  # Linting
  flutter_lints: ^4.0.0
  dart_code_metrics: ^5.7.6

  # Testing
  mocktail: ^1.0.0
  mocktail_image_network: ^1.1.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/watches/
    - assets/images/icons/
    - assets/json/
```

### 7.1 Adding a New Dependency

When adding a new dependency:

1. Update this file's tables in §2 or §3.
2. Update the reference `pubspec.yaml` in §7.
3. Add a row in [CHANGELOG.md](../CHANGELOG.md) under the "Added" section.
4. Run `flutter pub get` and commit `pubspec.yaml` + `pubspec.lock`.
5. If the dependency is architecturally significant, add an ADR in [DECISIONS.md](DECISIONS.md).

### 7.2 Removing a Dependency

When removing a dependency:

1. Remove from `pubspec.yaml`.
2. Run `flutter pub get` to update `pubspec.lock`.
3. Remove all imports of the package from source files.
4. Remove any tests specific to the package.
5. Update this file's tables.
6. Add a row in [CHANGELOG.md](../CHANGELOG.md) under the "Removed" section.

## 8. References

- Internal: [CONFIGURATION.md](CONFIGURATION.md), [DECISIONS.md](DECISIONS.md), [RISKS.md](RISKS.md), [LICENSE.md](../LICENSE.md), [STYLE_GUIDE.md](STYLE_GUIDE.md), [CHANGELOG.md](../CHANGELOG.md)
- External: [pub.dev](https://pub.dev), [Flutter packages](https://docs.flutter.dev/development/packages-and-plugins/using-packages), [Firebase pricing](https://firebase.google.com/pricing), [SPDX license list](https://spdx.org/licenses/), [Choose a license](https://choosealicense.com)
