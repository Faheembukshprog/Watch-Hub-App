# Troubleshooting

> Diagnostic guide for common failure modes in App-WatchHub. Each entry documents symptoms, root cause, diagnostic steps, and resolution. This file is the first stop when something goes wrong — before reaching for Stack Overflow or AI assistance.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Troubleshooting |
| **Purpose** | Document common failure modes, diagnostics, and recovery procedures |
| **Audience** | Engineers, QA, contributors, AI coding agents |
| **Scope** | Diagnostic procedures only; root-cause fixes documented in code and [CHANGELOG.md](../CHANGELOG.md) |
| **Version** | 1.0.0 |
| **Status** | Active — updated whenever a new failure mode is diagnosed |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [CONFIGURATION.md](CONFIGURATION.md), [DEPLOYMENT.md](DEPLOYMENT.md), [SECURITY.md](SECURITY.md), [TESTING.md](TESTING.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) |

---

## Table of Contents

1. [How to Use This File](#1-how-to-use-this-file)
2. [Build & Setup Failures](#2-build--setup-failures)
3. [Runtime Errors](#3-runtime-errors)
4. [Firebase-Specific Issues](#4-firebase-specific-issues)
5. [Riverpod State Issues](#5-riverpod-state-issues)
6. [GoRouter Issues](#6-gorouter-issues)
7. [Deployment Issues](#7-deployment-issues)
8. [Performance Issues](#8-performance-issues)
9. [References](#9-references)

---

## 1. How to Use This File

Each entry follows a consistent format: **Symptom** (what you observe), **Root Cause** (why it happens), **Diagnosis** (how to confirm), **Resolution** (how to fix), and **Prevention** (how to avoid recurrence). When encountering an error, scan the Symptom column of the relevant section; if your error matches, follow the Diagnosis steps to confirm before applying the Resolution.

If your error is not documented here, file a new entry after resolving it. The rule is: every error that takes more than 5 minutes to diagnose earns an entry in this file. This compounds the project's institutional memory and prevents the same diagnostic time from being spent twice.

When in doubt, enable verbose logging:

```bash
# Flutter verbose logs
flutter run --verbose

# Firebase CLI debug
firebase --debug <command>

# Firestore SDK debug (in Dart)
FirebaseFirestore.instance.setLoggingEnabled(true);
```

## 2. Build & Setup Failures

### 2.1 `flutter pub get` Fails with Version Conflict

| Field | Value |
|---|---|
| **Symptom** | `flutter pub get` exits with `Because app_watchhub depends on X which depends on Y, version solving failed` |
| **Root Cause** | Two dependencies require incompatible versions of a shared transitive dependency |
| **Diagnosis** | Run `flutter pub deps` to see the dependency tree. Identify the conflict. Check `pubspec.lock` for the previously-resolved versions. |
| **Resolution** | (1) Pin the conflicting transitive dependency to a compatible version in `pubspec.yaml` `dependency_overrides`. (2) If that fails, upgrade or downgrade one of the direct dependencies. (3) As last resort, run `flutter pub upgrade --major-versions` (may break other things — test thoroughly). |
| **Prevention** | Run `flutter pub get` after every dependency change; commit `pubspec.lock`. Review Dependabot PRs promptly. |

### 2.2 `dart analyze` Fails with `invalid_annotation_target`

| Field | Value |
|---|---|
| **Symptom** | `error: invalid_annotation_target - The annotation 'freezed' is only allowed on classes` |
| **Root Cause** | Freezed code generator emits code that the analyzer flags as invalid in strict mode |
| **Diagnosis** | Confirm the error is in a `.freezed.dart` or `.g.dart` file (generated code) |
| **Resolution** | Add the following to `analysis_options.yaml` under `analyzer.errors`:<br>`invalid_annotation_target: ignore` |
| **Prevention** | Already in [CONFIGURATION.md](CONFIGURATION.md) §7.1 `analysis_options.yaml` reference |

### 2.3 `flutterfire configure` Fails with `FirebaseProjectNotFoundError`

| Field | Value |
|---|---|
| **Symptom** | `flutterfire configure --project app-watchhub-dev` exits with project not found |
| **Root Cause** | (a) Project not yet created; (b) Firebase CLI not authenticated; (c) Project ID typo |
| **Diagnosis** | Run `firebase projects:list` — does `app-watchhub-dev` appear? If not, the project does not exist or you are not authenticated. |
| **Resolution** | (a) Create the project: `firebase projects:create app-watchhub-dev`. (b) Authenticate: `firebase login`. (c) Verify project ID in Firebase Console. |
| **Prevention** | Run `firebase projects:list` before `flutterfire configure` to confirm |

### 2.4 Android Build Fails with `minSdkVersion` Conflict

| Field | Value |
|---|---|
| **Symptom** | Gradle error: `Uses-sdk:minSdkVersion 21 cannot be smaller than version 29 declared in library` |
| **Root Cause** | A dependency requires a higher `minSdkVersion` than the project default |
| **Diagnosis** | Read the error message — it names the offending library and required version |
| **Resolution** | Update `android/app/build.gradle`:<br>`minSdkVersion 29` (per NFR-13 in [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md)) |
| **Prevention** | Document minimum SDK in [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) NFR-13 |

## 3. Runtime Errors

### 3.1 `LateInitializationError: Field has not been initialized`

| Field | Value |
|---|---|
| **Symptom** | App crashes with `LateInitializationError: Field '_auth' has not been initialized` |
| **Root Cause** | A `late` field is accessed before its first assignment. Common cause: Firebase initialization is async but the field is accessed synchronously before `await Firebase.initializeApp()` completes. |
| **Diagnosis** | Stack trace points to the access site. Trace back to where the field should have been initialized. |
| **Resolution** | (1) Move `await Firebase.initializeApp()` to the very start of `main()`. (2) If the field is in a service class, ensure the service is constructed AFTER Firebase init. (3) Consider using `GetIt` or Riverpod provider for async-initialized services instead of `late`. |
| **Prevention** | Avoid `late` for async-initialized fields. Use `Future<T>` or nullable types instead. |

### 3.2 `Null check operator used on a null value`

| Field | Value |
|---|---|
| **Symptom** | App crashes with `Null check operator used on a null value` |
| **Root Cause** | Code uses `!` on a nullable that is actually null |
| **Diagnosis** | Stack trace points to the `!` site. Inspect the variable — why is it null? |
| **Resolution** | Replace `!` with a null-safe pattern: `if (value != null) { ... } else { ... }` or `value ?? defaultValue`. |
| **Prevention** | Enable `strict-casts: true` in `analysis_options.yaml` (already configured per [CONFIGURATION.md](CONFIGURATION.md) §7.1). |

### 3.3 `Bad state: Stream has already been listened to`

| Field | Value |
|---|---|
| **Symptom** | Error when subscribing to a stream that was already subscribed |
| **Root Cause** | A single-subscription stream is being subscribed to multiple times. Common with Firestore `snapshots()` if not wrapped in a broadcast stream. |
| **Diagnosis** | Stack trace points to the second subscription. Identify the stream source. |
| **Resolution** | Use Riverpod's `StreamProvider` which manages a single subscription and broadcasts to multiple watchers. Never call `.listen()` directly on a Firestore stream in widget code. |
| **Prevention** | All Firestore streams go through `StreamProvider` per [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §4. |

### 3.4 `Unhandled Exception: [firebase_auth/invalid-email]`

| Field | Value |
|---|---|
| **Symptom** | Login or register fails with `invalid-email` error |
| **Root Cause** | Email string is not a valid email format (missing `@`, invalid domain, etc.) |
| **Diagnosis** | Inspect the email string passed to `signInWithEmailAndPassword` |
| **Resolution** | Add client-side validation: `Validators.isValidEmail(email)` before Firebase call. Show inline error if invalid. |
| **Prevention** | All form inputs validated before submission per [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §10. |

## 4. Firebase-Specific Issues

### 4.1 `PERMISSION_DENIED` on Firestore Operation

| Field | Value |
|---|---|
| **Symptom** | Firestore `get`, `set`, `update`, or `delete` throws `FirebaseException: [cloud_firestore/permission-denied]` |
| **Root Cause** | Firestore Security Rules rejected the operation. Either the user is unauthenticated, not the owner, or not an admin. |
| **Diagnosis** | (1) Check current auth state: `FirebaseAuth.instance.currentUser?.uid`. (2) Read the rules in `firestore.rules` for the affected path. (3) Test the rule against the actual request using Firebase Emulator. |
| **Resolution** | Depends on root cause: (a) If unauthenticated, redirect to login. (b) If wrong uid, fix the path or rule. (c) If admin rule failing, verify `/users/{uid}.isAdmin == true` in Console. |
| **Prevention** | Every rule has a corresponding test in [TESTING.md](TESTING.md) §7. Run rules tests in CI. |

### 4.2 `RESOURCE_EXHAUSTED` on Firestore Operation

| Field | Value |
|---|---|
| **Symptom** | Firestore operation fails with `RESOURCE_EXHAUSTED` |
| **Root Cause** | Spark Free Tier daily quota exceeded (50K reads, 20K writes, 20K deletes, 1GB egress) |
| **Diagnosis** | Open Firebase Console → Firestore → Usage. Check daily quota bars. |
| **Resolution** | (1) Wait until midnight Pacific time for quota reset. (2) Identify which operation is consuming quota (often: a `snapshots()` stream left running in a background tab). (3) Reduce read frequency: use `get()` instead of `snapshots()` where real-time is not needed. |
| **Prevention** | Use Firebase Emulator for development. Monitor quota in Console daily. Documented in [RISKS.md](RISKS.md) R-1. |

### 4.3 Firestore `FAILED_PRECONDITION` Requires Composite Index

| Field | Value |
|---|---|
| **Symptom** | Firestore query fails with `FAILED_PRECONDITION: The query requires an index` |
| **Root Cause** | A query with multiple `where` clauses or `where` + `orderBy` requires a composite index not yet declared |
| **Diagnosis** | Error message includes a URL to create the index in Firebase Console |
| **Resolution** | (1) Click the URL in the error message (in dev) — Firebase Console opens with the index pre-configured. (2) Click "Create". (3) Wait 2-5 minutes for index to build. (4) For permanent solution, add the index to `firestore.indexes.json` and deploy via `firebase deploy --only firestore:indexes`. |
| **Prevention** | All required indexes declared in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §5.2. |

### 4.4 Firebase Emulator Data Lost on Restart

| Field | Value |
|---|---|
| **Symptom** | Data added to Firebase Emulator is gone after restart |
| **Root Cause** | Emulator does not persist data by default |
| **Diagnosis** | Run `firebase emulators:start` — does the data persist? |
| **Resolution** | (1) Use `firebase emulators:start --export-on-exit=./emulator-data` to auto-export on exit. (2) Use `firebase emulators:start --import=./emulator-data` to import on start. (3) Or: just re-run `dart scripts/seed_emulator.dart` after each restart. |
| **Prevention** | Configure `firebase.json` with `emulators.firestore.export-on-exit` per [CONFIGURATION.md](CONFIGURATION.md) §5.1. |

## 5. Riverpod State Issues

### 5.1 Provider State Stuck in `AsyncLoading`

| Field | Value |
|---|---|
| **Symptom** | UI shows loading spinner indefinitely; provider never resolves to `AsyncData` or `AsyncError` |
| **Root Cause** | (a) The provider's `build()` method has an infinite await. (b) The repository method being awaited never completes. (c) Network call hangs without timeout. |
| **Diagnosis** | Add print statements or use DevTools to inspect provider state. Check if the underlying Future ever completes. |
| **Resolution** | (1) Add a timeout: `await repo.fetch().timeout(Duration(seconds: 10))`. (2) Verify the repository implementation. (3) Check network connectivity. |
| **Prevention** | All async operations have timeouts per [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §10. |

### 5.2 Provider Rebuilds Excessively (Performance)

| Field | Value |
|---|---|
| **Symptom** | Widget rebuilds frequently; DevTools shows high rebuild count |
| **Root Cause** | Provider depends on another provider that emits frequently (e.g., a stream without `distinct()`) |
| **Diagnosis** | Use Riverpod DevTools to inspect provider dependencies and emit frequency |
| **Resolution** | (1) Add `.distinct()` to the stream before exposing it. (2) Use `select()` in widget to subscribe only to relevant slices of state. (3) Split a large provider into smaller, more focused providers. |
| **Prevention** | Code review checklist includes "did you check rebuild count?" |

### 5.3 `ProviderNotFoundException`

| Field | Value |
|---|---|
| **Symptom** | App crashes with `ProviderNotFoundException` |
| **Root Cause** | Widget tries to read a provider that is not in scope (e.g., a provider overridden in a subtree is accessed from outside that subtree) |
| **Diagnosis** | Stack trace shows which provider was requested and from where |
| **Resolution** | (1) Verify the provider is defined at the correct scope. (2) If using `ProviderScope` overrides, ensure the consuming widget is a descendant. |
| **Prevention** | Use global providers for app-wide state; scoped providers only for feature-specific state. |

## 6. GoRouter Issues

### 6.1 Redirect Loop (Infinite Redirect)

| Field | Value |
|---|---|
| **Symptom** | Browser tab hangs; URL changes rapidly between two paths (e.g., `/login` ↔ `/boutique`) |
| **Root Cause** | Two route guards redirect to each other. Example: `/login` redirects to `/boutique` if authenticated, but `/boutique` redirects to `/login` if not authenticated, and the auth state is unstable. |
| **Diagnosis** | Open browser DevTools → Network tab → see redirect chain. Inspect `authProvider` state. |
| **Resolution** | (1) Add a third state to auth: `AuthState.loading` — during initial load, neither redirect fires. (2) Ensure `redirect` callback returns `null` (no redirect) during loading. (3) Verify `authStateChanges()` emits a stable value (not flapping between null and a user). |
| **Prevention** | Documented in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §5.2 guard implementation. |

### 6.2 Web Deep Link Returns 404 on Refresh

| Field | Value |
|---|---|
| **Symptom** | Navigating to `https://app-watchhub-dev.web.app/product/p1` works, but refreshing the page returns 404 |
| **Root Cause** | Firebase Hosting is serving the static `index.html` only at `/`; all other paths return 404 unless rewrites are configured |
| **Diagnosis** | Check `firebase.json` `hosting.rewrites` |
| **Resolution** | Add SPA rewrite rule per [DEPLOYMENT.md](DEPLOYMENT.md) §5.1:<br>`"rewrites": [{ "source": "**", "destination": "/index.html" }]` |
| **Prevention** | Already in `firebase.json` template |

### 6.3 Route Guard Does Not Block Access

| Field | Value |
|---|---|
| **Symptom** | Non-admin user can navigate to `/admin` URL directly |
| **Root Cause** | (a) Guard returns `null` (no redirect) when it should redirect. (b) Guard runs before auth state is loaded. (c) Guard logic incorrect. |
| **Diagnosis** | Add print statements in `guardRoute` to log decisions. Verify auth state is loaded before guard runs. |
| **Resolution** | (1) Ensure `redirect` is async and awaits auth state initialization. (2) Verify `isAdmin` is read from `/users/{uid}` snapshot, not just from `FirebaseAuth.instance.currentUser`. (3) Test with a non-admin account manually. |
| **Prevention** | This is UX-only enforcement — Firestore rules still block data access. See [SECURITY.md](SECURITY.md) §1. |

## 7. Deployment Issues

### 7.1 GitHub Actions Deploy Fails with Authentication Error

| Field | Value |
|---|---|
| **Symptom** | CI deploy step fails with `Error: Failed to authenticate to Firebase` |
| **Root Cause** | (a) `FIREBASE_SERVICE_ACCOUNT_APP_WATCH_HUB_DEV` secret not set or expired. (b) Service account lacks deploy permissions. (c) Project ID mismatch. |
| **Diagnosis** | Check GitHub repo Settings → Secrets. Verify the service account JSON in Firebase Console → Project Settings → Service Accounts. |
| **Resolution** | (1) Re-generate service account key in Firebase Console. (2) Update GitHub secret with new JSON. (3) Re-run workflow. |
| **Prevention** | Rotate service account keys annually per [CONFIGURATION.md](CONFIGURATION.md) §6.3. |

### 7.2 Deploy Succeeds but Site Shows Old Version

| Field | Value |
|---|---|
| **Symptom** | `firebase deploy` reports success, but visiting the URL shows the previous version |
| **Root Cause** | CDN cache has not yet propagated (typically < 60 seconds) |
| **Diagnosis** | Hard-refresh browser (Ctrl+Shift+R / Cmd+Shift+R). Check Firebase Console → Hosting → release history — is the new release listed? |
| **Resolution** | Wait 60 seconds and refresh. If still old, manually purge cache via Console or `firebase hosting:channel:invalidate`. |
| **Prevention** | Documented in [DEPLOYMENT.md](DEPLOYMENT.md) §7.4 Rollback Limitations. |

### 7.3 APK Build Exceeds 25MB Target

| Field | Value |
|---|---|
| **Symptom** | `flutter build apk` produces APK > 25MB (NFR-6 violation) |
| **Root Cause** | (a) Uncompressed images in `assets/`. (b) Debug symbols included. (c) Unnecessary dependencies. |
| **Diagnosis** | Run `flutter build apk --analyze-size` to see size breakdown |
| **Resolution** | (1) Compress images: `cwebp input.png -o output.webp -q 80`. (2) Use `--split-per-abi` (already configured). (3) Enable ProGuard/R8 minification. (4) Remove unused dependencies. |
| **Prevention** | Run `--analyze-size` before any release per [DEPLOYMENT.md](DEPLOYMENT.md) §6.2. |

## 8. Performance Issues

### 8.1 Slow Page Transitions (> 1.5s)

| Field | Value |
|---|---|
| **Symptom** | Page navigation takes > 1.5 seconds (NFR-1 violation) |
| **Root Cause** | (a) Heavy synchronous work on the UI isolate during transition. (b) Large widget tree rebuilt on navigation. (c) Image loading blocks transition. |
| **Diagnosis** | Use Flutter DevTools → Performance tab → record a transition. Identify jank frames. |
| **Resolution** | (1) Move heavy work to `compute()` (background isolate). (2) Use `const` constructors for static widgets. (3) Pre-load images with `precacheImage()`. (4) Use Riverpod `select()` to limit rebuild scope. |
| **Prevention** | Performance budget enforced in CI via Lighthouse audit. |

### 8.2 Slow First Paint on Web (> 2s)

| Field | Value |
|---|---|
| **Symptom** | Web first contentful paint > 2 seconds (NFR-5 violation) |
| **Root Cause** | (a) Large JS bundle. (b) No code splitting. (c) Heavy initialization in `main()`. |
| **Diagnosis** | Run Lighthouse audit on the deployed URL |
| **Resolution** | (1) Enable `--tree-shake-icons` flag (already configured). (2) Use deferred imports for rarely-used features. (3) Defer non-critical initialization to after first paint. |
| **Prevention** | Lighthouse audit in CI per [DEPLOYMENT.md](DEPLOYMENT.md) §9. |

### 8.3 Catalog List Scrolling Janky

| Field | Value |
|---|---|
| **Symptom** | Catalog list scrolling stutters; frame rate drops below 60fps |
| **Root Cause** | (a) `ProductCard` widget is too heavy (rebuilds too much). (b) Image decoding on UI isolate. (c) List items not properly virtualized. |
| **Diagnosis** | Flutter DevTools → Performance → record scroll. Identify slow frames. |
| **Resolution** | (1) Use `ListView.builder` (not `ListView` with `children:`). (2) Add `const` to `ProductCard` constructor. (3) Use `cacheWidth` and `cacheHeight` on `Image.asset()`. (4) Memoize expensive computations. |
| **Prevention** | Code review checklist includes "is the list virtualized?" |

## 9. References

- Internal: [CONFIGURATION.md](CONFIGURATION.md), [DEPLOYMENT.md](DEPLOYMENT.md), [SECURITY.md](SECURITY.md), [TESTING.md](TESTING.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [RISKS.md](RISKS.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md)
- External: [Flutter debugging docs](https://docs.flutter.dev/testing/debugging), [Firebase troubleshooting](https://firebase.google.com/docs/projects/troubleshoot-firebase), [Riverpod troubleshooting](https://riverpod.dev/docs/advanced/faq), [GoRouter debugging](https://pub.dev/documentation/go_router/latest/topics/Debugging-topic.html)
