# Configuration

> Setup and configuration reference for App-WatchHub. Covers Firebase project provisioning, environment flavors, emulator configuration, and environment variables. This file is the canonical setup guide — deviations from these instructions are unsupported.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Configuration |
| **Purpose** | Provide complete Firebase setup, flavor configuration, env vars, and emulator instructions |
| **Audience** | Engineers, DevOps, new contributors |
| **Scope** | Configuration only; deployment procedure in [DEPLOYMENT.md](DEPLOYMENT.md) |
| **Version** | 1.0.0 |
| **Status** | Approved — locked for MVP cycle |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [DEPLOYMENT.md](DEPLOYMENT.md), [ARCHITECTURE.md](ARCHITECTURE.md), [SECURITY.md](SECURITY.md), [DEPENDENCIES.md](DEPENDENCIES.md) |

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Firebase Project Provisioning](#2-firebase-project-provisioning)
3. [FlutterFire Configuration](#3-flutterfire-configuration)
4. [Environment Flavors](#4-environment-flavors)
5. [Firebase Emulator Setup](#5-firebase-emulator-setup)
6. [Environment Variables](#6-environment-variables)
7. [Configuration Files Reference](#7-configuration-files-reference)
8. [Verification Checklist](#8-verification-checklist)
9. [References](#9-references)

---

## 1. Prerequisites

The following tools must be installed on the development machine before any setup begins. Version pins are mandatory; deviations may cause build failures that are difficult to diagnose.

| Tool | Required Version | Verification Command | Install Source |
|---|---|---|---|
| Flutter SDK | 4.x (stable channel) | `flutter --version` | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.x (bundled with Flutter) | `dart --version` | Bundled |
| Node.js | 20 LTS | `node --version` | [nodejs.org](https://nodejs.org/) |
| npm | 10.x+ (bundled with Node) | `npm --version` | Bundled |
| Firebase CLI | 13.x+ | `firebase --version` | `npm install -g firebase-tools` |
| FlutterFire CLI | 0.13.x+ | `flutterfire --version` | `dart pub global activate flutterfire_cli` |
| Git | 2.40+ | `git --version` | [git-scm.com](https://git-scm.com/) |
| Android Studio | latest (for Android builds) | n/a | [developer.android.com](https://developer.android.com/studio) |
| VS Code | latest (optional, recommended IDE) | n/a | [code.visualstudio.com](https://code.visualstudio.com/) |

### 1.1 Operating System Support

| OS | Support Status | Notes |
|---|---|---|
| macOS 13+ | Fully supported | Primary development environment |
| Ubuntu 22.04+ | Fully supported | CI runner environment |
| Windows 11 | Supported with caveats | PowerShell paths may need adjustment |
| Windows 10 | Best-effort | Not actively tested |

### 1.2 First-Time Setup Verification

After installing all prerequisites, run the following sequence to confirm the toolchain is healthy:

```bash
flutter doctor -v
firebase --version
flutterfire --version
```

`flutter doctor -v` should report no issues for Flutter, Dart, and Android toolchain. Any red X must be resolved before proceeding.

## 2. Firebase Project Provisioning

App-WatchHub uses a single Firebase project per environment. For MVP, only the `dev` environment is provisioned; `staging` and `prod` are documented but optional.

### 2.1 Project Creation

```bash
# Login to Firebase (opens browser)
firebase login

# Create the dev project (must be globally unique)
firebase projects:create app-watchhub-dev \
  --name "App-WatchHub Dev" \
  --no-interactive

# Verify creation
firebase projects:list
```

### 2.2 Enable Required Services

| Service | Required | How to Enable |
|---|---|---|
| Firebase Authentication | Yes | Console → Authentication → Get Started → Enable Email/Password |
| Cloud Firestore | Yes | Console → Firestore → Create database → Production mode → `nam5` |
| Firebase Hosting | Yes | Console → Hosting → Get Started |
| Firebase Analytics | Yes | Auto-enabled when project created |
| Firebase Crashlytics | Yes | Console → Crashlytics → Enable |
| Cloud Storage | **No** | Intentionally disabled (local assets only) |
| Cloud Functions | **No** | Intentionally disabled ($0 budget) |
| Firebase ML | **No** | Not used |
| Firebase Performance Monitoring | Optional | Auto-enabled with SDK |

### 2.3 Firestore Region Selection

The Firestore database must be created in the `nam5` (multi-region North America) region. This region is free-tier eligible and provides the best latency profile for the presumed North American audience of the MVP demo.

| Region | Selected | Reason |
|---|---|---|
| `nam5` (North America multi-region) | Yes | Free-tier eligible; multi-region HA |
| `eur3` (Europe multi-region) | No | Lower priority for MVP audience |
| `us-central1` (single region) | No | Lower HA than `nam5` |

### 2.4 Upgrade Tier?

**Do NOT upgrade to Blaze tier.** The Spark (free) tier is sufficient for MVP and is a hard constraint per [PROJECT_SCOPE.md](PROJECT_SCOPE.md) C-5. If you receive prompts to upgrade during setup, dismiss them.

## 3. FlutterFire Configuration

FlutterFire CLI generates the platform-specific Firebase configuration files (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, etc.) from your Firebase project.

### 3.1 Generate Configuration

```bash
# From the project root
flutterfire configure \
  --project app-watchhub-dev \
  --platforms android,web \
  --android-package-name com.appwatchhub.app \
  --web-app-id 1:1234567890:web:abcdef123456
```

> **NOTE** — iOS is OUT OF SCOPE for MVP (see [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5). The `--platforms` flag intentionally omits `ios`.

### 3.2 Generated Files

| File | Purpose | Commit to Git? |
|---|---|---|
| `lib/firebase_options.dart` | Dart-side Firebase config | Yes |
| `android/app/google-services.json` | Android Firebase config | Yes (public project ID only) |
| `web/index.html` (modified) | Web Firebase init script | Yes |

> **WARNING** — The `flutterfire configure` command may add `<script>` tags to `web/index.html`. Do NOT remove or modify these manually; re-run `flutterfire configure` if config changes.

### 3.3 Initialize Firebase in Dart

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ... then runApp
}
```

## 4. Environment Flavors

Three environments are defined. For MVP, only `dev` is provisioned; `staging` and `prod` are documented for post-MVP expansion.

| Flavor | Firebase Project | Purpose | Status |
|---|---|---|---|
| `dev` | `app-watchhub-dev` | Local development, emulators | Active |
| `staging` | `app-watchhub-staging` | Pre-prod smoke testing | Not provisioned (post-MVP) |
| `prod` | `app-watchhub-prod` | Public launch | Not provisioned (post-MVP) |

### 4.1 Flavor Configuration

Flavor selection is controlled via `--flavor` flag at build time:

```bash
# Development (default)
flutter run --flavor dev
flutter build web --flavor dev

# Staging (post-MVP)
flutter run --flavor staging
flutter build web --flavor staging

# Production (post-MVP)
flutter run --flavor prod
flutter build web --flavor prod
```

### 4.2 Android Flavor Setup

`android/app/build.gradle` defines the flavors:

```gradle
android {
    flavorDimensions "default"
    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "default"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        prod {
            dimension "default"
        }
    }
}
```

Each flavor has its own `google-services.json` placed at `android/app/src/<flavor>/google-services.json`.

## 5. Firebase Emulator Setup

Local development uses the Firebase Emulator Suite for Auth and Firestore. This eliminates accidental writes to production during development and provides deterministic test data.

### 5.1 Emulator Configuration

`firebase.json` (project root):

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  },
  "emulators": {
    "auth": { "port": 9099 },
    "firestore": { "port": 8080 },
    "ui": { "enabled": true, "port": 4000 },
    "singleProjectMode": true
  }
}
```

### 5.2 Start Emulators

```bash
firebase emulators:start --only auth,firestore
```

Emulator UI is available at `http://localhost:4000`.

### 5.3 Point Flutter at Emulators

```dart
// lib/main.dart (debug-only)
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await _connectToFirebaseEmulator();
  }

  runApp(AppWatchHubApp());
}

Future<void> _connectToFirebaseEmulator() async {
  const host = 'localhost';
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  await FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}
```

### 5.4 Seed Emulator Data

The seed script `scripts/seed_emulator.dart` populates the emulator with deterministic test data:

```bash
dart scripts/seed_emulator.dart
```

Seed data includes:
- 1 admin user (email: `admin@watchhub.test`, password: `Admin123!`)
- 1 customer user (email: `customer@watchhub.test`, password: `Customer123!`)
- 12 products (one per brand in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.2.1)
- 3 sample orders (one each: Processing, Shipped, Delivered)

> **NOTE** — The seed script OVERWRITES existing data in the emulator. Never run it against a production Firebase project (the script has a localhost-only guard).

## 6. Environment Variables

App-WatchHub intentionally minimizes environment variables. All Firebase configuration is generated by FlutterFire CLI; no API keys are stored in `.env` files for MVP.

### 6.1 Environment Variables Table

| Variable | Used By | Required | Default | Notes |
|---|---|---|---|---|
| `FIREBASE_TOKEN` | CI deploy | Yes (CI only) | — | Generated by `firebase login:ci` |
| `FIREBASE_SERVICE_ACCOUNT_APP_WATCH_HUB_DEV` | GitHub Actions | Yes (CI only) | — | JSON key from Firebase Console → Project Settings → Service Accounts |
| `FLUTTER_VERSION` | CI | No | `4.x` | Pinned in workflow file |

### 6.2 No `.env` File

For MVP, there are no `.env` files. All runtime configuration is compiled into the binary via `firebase_options.dart`. If a future feature requires runtime secrets (e.g., Stripe API key), introduce `flutter_dotenv` and document the change here.

### 6.3 Secrets Hygiene

- Never commit `.env` files to Git (`.gitignore` excludes `*.env`).
- Never commit Firebase service account JSON keys to Git.
- GitHub Actions secrets are stored encrypted; they are decrypted only in the runner.
- Rotate the `FIREBASE_SERVICE_ACCOUNT_APP_WATCH_HUB_DEV` secret annually or on team turnover.

## 7. Configuration Files Reference

All configuration files in the project root:

| File | Purpose | Modified By |
|---|---|---|
| `firebase.json` | Firebase CLI configuration (rules path, hosting, emulators) | Manual |
| `firestore.rules` | Firestore Security Rules | Manual (see [SECURITY.md](SECURITY.md)) |
| `firestore.indexes.json` | Composite index declarations | Manual (see [DATABASE_DESIGN.md](DATABASE_DESIGN.md)) |
| `.firebaserc` | Firebase project alias mapping | `firebase use` command |
| `pubspec.yaml` | Dart dependencies | `flutter pub add` command (see [DEPENDENCIES.md](DEPENDENCIES.md)) |
| `pubspec.lock` | Pinned dependency versions | `flutter pub get` |
| `analysis_options.yaml` | Dart analyzer and lint rules | Manual |
| `lib/firebase_options.dart` | FlutterFire generated config | `flutterfire configure` command |
| `android/app/google-services.json` | Android Firebase config | `flutterfire configure` command |
| `.github/workflows/ci.yml` | CI pipeline definition | Manual (see [DEPLOYMENT.md](DEPLOYMENT.md)) |
| `.gitignore` | Git ignore patterns | Manual |

### 7.1 `analysis_options.yaml` (Reference)

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "build/**"
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - require_trailing_commas
    - sort_constructors_first
    - always_declare_return_types

dart_code_metrics:
  metrics:
    cyclomatic-complexity: 20
    maximum-nesting-level: 5
    number-of-parameters: 4
  metrics-exclude:
    - test/**
  rules:
    - avoid-dynamic
    - prefer-trailing-comma
```

## 8. Verification Checklist

After completing setup, verify each item below. Any failure must be resolved before development begins.

| Check | Command / Action | Expected Result |
|---|---|---|
| Flutter toolchain healthy | `flutter doctor -v` | No red X for Flutter, Dart, Android |
| Firebase CLI authenticated | `firebase projects:list` | Lists `app-watchhub-dev` project |
| FlutterFire config generated | `ls lib/firebase_options.dart` | File exists |
| Firestore rules deployed | `firebase deploy --only firestore:rules` | "Deploy complete!" message |
| Firestore indexes deployed | `firebase deploy --only firestore:indexes` | "Deploy complete!" message |
| Emulators start | `firebase emulators:start` | UI at `http://localhost:4000` |
| Seed script runs | `dart scripts/seed_emulator.dart` | "Seeded X products, Y users, Z orders" |
| App launches (web) | `flutter run -d chrome` | Boutique page renders |
| App launches (Android) | `flutter run -d <device>` | Boutique page renders |
| Login works | Use seeded customer credentials | Lands on `/boutique` |
| Admin bootstrap works | Set `isAdmin: true` in Console, re-login | Lands on `/admin` |

## 9. References

- Internal: [DEPLOYMENT.md](DEPLOYMENT.md), [ARCHITECTURE.md](ARCHITECTURE.md), [SECURITY.md](SECURITY.md), [DEPENDENCIES.md](DEPENDENCIES.md), [TESTING.md](TESTING.md)
- External: [Firebase CLI reference](https://firebase.google.com/docs/cli), [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/), [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite), [Firebase Spark plan quotas](https://firebase.google.com/pricing)
