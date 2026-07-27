# Decisions

> Architecture Decision Records (ADRs) for App-WatchHub. Every significant technical choice in this project has a recorded ADR explaining the context, the decision, the alternatives considered, and the consequences. This file is the secret weapon of the repository — it proves engineering judgment, not just execution.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Architecture Decision Records |
| **Purpose** | Record every significant architectural decision with context, alternatives, and consequences |
| **Audience** | Recruiters, reviewers, maintainers, AI coding agents, future contributors |
| **Scope** | Architectural decisions only; tactical choices captured in commit messages |
| **Version** | 1.0.0 |
| **Status** | Active — append-only, ADRs are never deleted |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [ARCHITECTURE.md](ARCHITECTURE.md), [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [RISKS.md](RISKS.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [SECURITY.md](SECURITY.md) |

---

## Table of Contents

- [ADR Index](#adr-index)
- [ADR-001: Serverless Event-Driven Architecture over Custom REST Backend](#adr-001-serverless-event-driven-architecture-over-custom-rest-backend)
- [ADR-002: Cloud Firestore (NoSQL) over SQL for MVP](#adr-002-cloud-firestore-nosql-over-sql-for-mvp)
- [ADR-003: Local Asset Bundles over Firebase Storage](#adr-003-local-asset-bundles-over-firebase-storage)
- [ADR-004: Riverpod over Provider / BLoC](#adr-004-riverpod-over-provider--bloc)
- [ADR-005: GoRouter over Navigator 2.0 Directly](#adr-005-gorouter-over-navigator-20-directly)
- [ADR-006: GitHub Actions over Jenkins / CircleCI / No CI](#adr-006-github-actions-over-jenkins--circleci--no-ci)
- [ADR-007: Dual Data Model (Academic ERD + Production NoSQL)](#adr-007-dual-data-model-academic-erd--production-nosql)
- [ADR-008: Cart in Local Storage (Hive) over Firestore](#adr-008-cart-in-local-storage-hive-over-firestore)
- [ADR-009: Dark Luxury Theme over Default Material](#adr-009-dark-luxury-theme-over-default-material)
- [ADR-010: Payment Integration OUT OF SCOPE for MVP](#adr-010-payment-integration-out-of-scope-for-mvp)
- [ADR-011: Single Codebase for Web + Android over Native Split](#adr-011-single-codebase-for-web--android-over-native-split)
- [ADR-012: Firebase Spark Free Tier over Blaze Paid Tier](#adr-012-firebase-spark-free-tier-over-blaze-paid-tier)
- [ADR Format](#adr-format)
- [References](#references)

---

## ADR Index

| ADR | Title | Status | Date |
|---|---|---|---|
| [ADR-001](#adr-001) | SEDA over Custom REST Backend | Accepted | 2026-07-14 |
| [ADR-002](#adr-002) | Cloud Firestore (NoSQL) over SQL for MVP | Accepted | 2026-07-14 |
| [ADR-003](#adr-003) | Local Asset Bundles over Firebase Storage | Accepted | 2026-07-14 |
| [ADR-004](#adr-004) | Riverpod over Provider / BLoC | Accepted | 2026-07-14 |
| [ADR-005](#adr-005) | GoRouter over Navigator 2.0 Directly | Accepted | 2026-07-14 |
| [ADR-006](#adr-006) | GitHub Actions over Jenkins / CircleCI / No CI | Accepted | 2026-07-14 |
| [ADR-007](#adr-007) | Dual Data Model (Academic ERD + Production NoSQL) | Accepted | 2026-07-14 |
| [ADR-008](#adr-008) | Cart in Local Storage (Hive) over Firestore | Accepted | 2026-07-14 |
| [ADR-009](#adr-009) | Dark Luxury Theme over Default Material | Accepted | 2026-07-14 |
| [ADR-010](#adr-010) | Payment Integration OUT OF SCOPE for MVP | Accepted | 2026-07-14 |
| [ADR-011](#adr-011) | Single Codebase for Web + Android over Native Split | Accepted | 2026-07-14 |
| [ADR-012](#adr-012) | Firebase Spark Free Tier over Blaze Paid Tier | Accepted | 2026-07-14 |
| [ADR-013](#adr-013) | Client-Side Search over Algolia / Firestore Full-Text | Accepted | 2026-07-15 |
| [ADR-014](#adr-014) | Top-Level `/reviews` Collection over Subcollection | Accepted | 2026-07-15 |
| [ADR-015](#adr-015) | FAQ in Firestore over Static JSON Bundle | Accepted | 2026-07-15 |
| [ADR-016](#adr-016) | Team Project Structure (6 Contributors) | Accepted | 2026-07-15 |

---

## ADR-001: Serverless Event-Driven Architecture over Custom REST Backend

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The project requires authentication, catalog browsing, cart management, order placement, and admin governance — a typical e-commerce workload. The conventional approach is a three-tier stack: Flutter client → custom REST/GraphQL API server (Node.js, Spring, etc.) → SQL database. This is the pattern taught in most academic curricula and is the default reflex for senior engineers coming from enterprise backgrounds.

However, the project operates under two hard constraints documented in [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §6: total budget $0/month (C-1) and 30-day timeline (C-2). A custom backend introduces:

- A server to provision, deploy, scale, and pay for (violates C-1)
- An API layer to design, document, implement, and test (consumes 7-10 days of the 30-day timeline, violates C-2)
- A new failure mode (server downtime, cold starts, deployment complexity)
- An additional authz boundary (API server must trust or verify the client's auth token)

The question is whether modern serverless platforms (Firebase) can replace the custom backend entirely without sacrificing security or functionality.

### Decision

We will adopt a **Serverless Event-Driven Architecture (SEDA)** in which the Flutter client communicates directly with Firebase's managed services (Authentication, Cloud Firestore, Hosting). There will be no custom API server, no Cloud Functions intermediary, and no container orchestration. All authorization will be enforced by Firestore Security Rules at the database edge.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Custom Node.js + Express REST API** | Violates C-1 (server cost) and C-2 (timeline); adds deployment complexity |
| **Cloud Functions for Firebase** | Free tier exists but cold starts add 1-3s latency; complexity not justified for MVP-grade logic (cart math, validation) |
| **Supabase (PostgreSQL + Edge Functions)** | Viable alternative, but Firestore's snapshot streams are better fit for real-time catalog updates; team has deeper Firebase familiarity |
| **Appwrite (self-hosted BaaS)** | Self-hosting violates C-1 (server cost) and C-2 (ops overhead) |

### Consequences

**Positive:**
- Zero infrastructure cost at steady state (Spark Free Tier)
- Real-time catalog updates without custom WebSocket infrastructure
- Security enforced at the data edge (cannot be bypassed by client bugs)
- 7-10 days of timeline saved (no API design/implementation)
- Simplified deployment story (deploy frontend only)

**Negative:**
- Complex business logic must live in client (acceptable for MVP; cart math is simple)
- No server-side scheduled jobs (no daily reports, no automated emails beyond Firebase Auth's built-in)
- Cloud Functions deferred to v2.0 (see [ROADMAP.md](ROADMAP.md) §4.3)
- Risk of client-side business logic duplication (mitigated by repository abstraction — see [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §2)

**Reversibility:** High. If SEDA proves insufficient, a Cloud Functions layer can be introduced between client and Firestore without rewriting the client (Firestore SDK calls remain the same; Functions intercept via HTTPS trigger or Firestore trigger). This is the post-MVP path documented in [ROADMAP.md](ROADMAP.md) §4.3.

---

## ADR-002: Cloud Firestore (NoSQL) over SQL for MVP

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The application needs to store users, products, and orders. The conventional choice is a SQL database (PostgreSQL, MySQL). SQL provides strong consistency, ACID transactions, and a normalized schema that prevents data anomalies. Most academic curricula teach SQL as the default.

However, the project constraints ([PROJECT_SCOPE.md](PROJECT_SCOPE.md) §6) favor a NoSQL choice:

- C-1 ($0 budget): Managed SQL databases (Cloud SQL, Aurora Serverless) have minimum monthly costs even at zero usage. Firestore's Spark tier is genuinely $0 at low volume.
- C-2 (30-day timeline): SQL requires schema design, migration scripts, and an ORM. Firestore's schemaless model allows faster iteration.
- Real-time catalog updates: SQL requires polling or a separate WebSocket layer. Firestore's `snapshots()` provides this natively.
- Offline-first: SQL requires custom sync logic. Firestore's SDK has built-in offline cache.

### Decision

We will use **Cloud Firestore (NoSQL document database)** as the sole persistence layer for production data. The schema is documented in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §3. An academic ERD is maintained in parallel for evaluation purposes (see ADR-007).

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Cloud SQL (PostgreSQL)** | Minimum cost ~$10/month on free tier; violates C-1 |
| **Supabase (managed PostgreSQL)** | Free tier exists but limited to 500MB; offline sync requires custom logic |
| **Realtime Database (Firebase's older NoSQL)** | Less query-friendly than Firestore; larger JSON tree; recommended against by Firebase docs for new projects |
| **MongoDB Atlas** | Free tier exists but no offline sync; separate auth needed |

### Consequences

**Positive:**
- $0 cost at low volume (Spark Free Tier)
- Native offline cache (Firestore SDK)
- Native real-time streams (`snapshots()`)
- Schemaless — easy iteration during MVP
- Integrated with Firebase Auth and Security Rules (single-vendor stack)

**Negative:**
- No ACID transactions across collections (Firestore has limited transactions; not used in MVP)
- Denormalization required for performance (e.g., `modelName` snapshot in order items)
- No JOIN queries (requires client-side composition or denormalization)
- Composite indexes must be declared manually (see [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §5)
- Risk of data anomalies if denormalized fields drift (mitigated by snapshot-at-order-time pattern in `/orders`)

**Reversibility:** Medium. Migrating from Firestore to SQL post-MVP would require a data export/import script and client repository reimplementation. The repository abstraction in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §2 isolates this to the Infrastructure layer.

---

## ADR-003: Local Asset Bundles over Firebase Storage

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The catalog contains product images (watch photographs). Two options exist for serving these images:

1. **Firebase Cloud Storage** — upload images to a bucket; client fetches via URL. Standard approach for production apps.
2. **Local Asset Bundles** — bundle images directly into the Flutter binary (`assets/images/watches/*.png`); client reads from local disk.

The MVP catalog is small (12-50 products per A-1 in [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §6) and stable (no user-uploaded images in MVP scope). Image sizes are pre-optimized to < 200KB each.

### Decision

We will use **local asset bundles** for all product images in MVP. No Firebase Cloud Storage bucket will be provisioned. Images live in `assets/images/watches/` and are referenced by `assetPath` in the product document.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Firebase Cloud Storage** | Free tier is generous (5GB) but egress beyond free tier is $0.12/GB; introduces network latency (50-300ms per image); adds another SDK to integrate |
| **External CDN (Cloudinary, Imgix)** | Paid services; violates C-1 |
| **Base64-encode images in Firestore** | Bloats documents; Firestore document size limit 1MB; bad practice |

### Consequences

**Positive:**
- Zero network latency for image load (< 50ms local disk read)
- Zero storage cost (no Storage bucket needed)
- Zero egress cost (no network transfer)
- Deterministic first-paint (no loading spinner for images)
- Offline-first (images work without network)

**Negative:**
- Larger APK/web bundle size (12 images × 200KB = ~2.4MB added to binary)
- App update required to add or change images (no runtime image swap)
- Cannot accept user-uploaded images (acceptable for MVP — admin uploads via build)
- Hits APK size target ceiling if catalog grows beyond ~50 items (mitigation: split APK per ABI; see [DEPLOYMENT.md](DEPLOYMENT.md) §6)

**Reversibility:** High. To migrate to Cloud Storage post-MVP, change `assetPath` field to a Storage URL; the `Product.assetPath` field is already a string — no schema change required.

---

## ADR-004: Riverpod over Provider / BLoC

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

Flutter state management has multiple viable options: Provider, BLoC, Riverpod, GetX, MobX. Each has tradeoffs in terms of boilerplate, testability, compile-time safety, and learning curve. The project requires state management for: auth state, cart state, catalog stream, filter state, admin dashboard state, and order history. The choice must support the testability requirement (NFR-9: 60% coverage on `lib/core/` and `lib/features/`).

### Decision

We will use **Riverpod 2.x with AsyncNotifier** as the sole state management solution. The choice is documented in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §4.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Provider** | Lacks compile-time safety (relies on runtime type resolution); no built-in async state handling; weaker testing story |
| **BLoC** | Excellent for large teams but heavy boilerplate (separate Bloc, Event, State classes per feature); overkill for solo MVP |
| **GetX** | Popular but anti-pattern: mixes routing, state, DI, and storage in one package; framework lock-in risk; not recommended by Flutter team |
| **MobX** | Requires code generation; observable pattern is less intuitive than Riverpod's notifier pattern for this use case |

### Consequences

**Positive:**
- Compile-time safety (provider references verified at compile time)
- Built-in `AsyncValue` for loading/error/data states (no boilerplate)
- Excellent testability (override providers in tests with mocks)
- Dependency injection built-in (no separate DI framework needed)
- Active maintenance; official Flutter team endorsement

**Negative:**
- Learning curve (concepts: `Provider`, `Notifier`, `AsyncNotifier`, `family`, `autoDispose`)
- Code generation required for `@riverpod` annotations (build_runner adds 5-15s to dev iteration)
- Less ecosystem content than Provider (though growing fast)

**Reversibility:** Low. State management choice pervades the codebase; switching post-MVP would be a significant rewrite. Mitigated by the repository abstraction — domain layer is state-management-agnostic.

---

## ADR-005: GoRouter over Navigator 2.0 Directly

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

Flutter's Navigator 2.0 API is powerful but notoriously complex. Direct use requires understanding `Router`, `RouteInformationParser`, `RouteInformationProvider`, and `RouterDelegate` — a steep learning curve for a 30-day MVP. The project needs web deep-linking, role-based route guards, and declarative route configuration.

### Decision

We will use **GoRouter** (package `go_router`) as the routing solution. Route table is documented in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §5.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Navigator 1.0 (imperative)** | No web deep-linking support; cannot use declarative route guards; deprecated for new projects |
| **Navigator 2.0 direct** | Too complex for 30-day MVP; would consume 3-5 days just to set up |
| **auto_route** | Viable alternative; similar feature set; chose GoRouter for larger community and simpler API |

### Consequences

**Positive:**
- Declarative route table (compile-time verifiable)
- Built-in web deep-linking
- Built-in redirect guards (perfect for role-based authz)
- Simpler API than Navigator 2.0 direct
- Active maintenance; Flutter team endorsement

**Negative:**
- Another dependency to maintain
- Some advanced scenarios (nested navigators) require workarounds
- Documentation examples sometimes lag behind API changes

**Reversibility:** Medium. Switching routers would require rewriting all `context.go()` and `context.push()` calls. Mitigated by centralizing all routes in `app_router.dart`.

---

## ADR-006: GitHub Actions over Jenkins / CircleCI / No CI

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The project requires CI/CD to satisfy NFR-8 (documentation coverage) and demonstrate engineering maturity. Options range from no CI (manual builds) to self-hosted Jenkins to cloud CI services.

### Decision

We will use **GitHub Actions** as the CI/CD platform. The pipeline is documented in [DEPLOYMENT.md](DEPLOYMENT.md) §2.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **No CI (manual build + deploy)** | Violates NFR-8; demonstrates weak engineering practice to reviewers |
| **Jenkins (self-hosted)** | Requires server (violates C-1); ops overhead; slower setup |
| **CircleCI** | Free tier exists but limited; less integrated with GitHub than Actions |
| **GitLab CI** | Requires GitLab migration; project is on GitHub |
| **Codemagic** | Flutter-specific; viable but free tier limited to 500 min/month |

### Consequences

**Positive:**
- Free for public repos (unlimited minutes)
- Deep GitHub integration (PR checks, branch protection, status checks)
- Large ecosystem of pre-built actions
- Native Firebase deployment via `firebaseextended/action-hosting-deploy`
- YAML-based config (version-controlled)

**Negative:**
- Runner environment is shared (security: use secrets, never log sensitive data)
- Linux-only runners on free tier (Windows/macOS runners cost extra)
- Workflow YAML can become verbose for complex pipelines

**Reversibility:** High. CI/CD config is isolated to `.github/workflows/`; switching platforms requires rewriting the workflow file but not the application code.

---

## ADR-007: Dual Data Model (Academic ERD + Production NoSQL)

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The academic evaluation rubric expects a relational ERD demonstrating understanding of normalization, cardinality, and referential integrity. The production implementation uses Firestore (NoSQL) per ADR-002. These appear contradictory: either we use SQL (academic expectation) or NoSQL (production reality).

### Decision

We will maintain a **dual data model**: an academic ERD in classical relational notation (documented in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §2) AND a production Firestore NoSQL schema (documented in §3). Both representations are kept in sync; the mapping between them is documented in §3.2.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **SQL only (academic compliance)** | Violates ADR-002 (production needs NoSQL for $0 budget) |
| **NoSQL only (production purity)** | Fails academic evaluation; misses opportunity to demonstrate relational design knowledge |
| **NoSQL with relational commentary** | Half-measure; reviewers cannot verify normalization claims without ERD |

### Consequences

**Positive:**
- Satisfies academic rubric (ERD with normalization)
- Reflects production reality (NoSQL schema)
- Demonstrates that author knows when to break normalization rules (denormalization for read performance)
- Documents the mapping explicitly (bijective for MVP scope)

**Negative:**
- Maintenance overhead: schema changes require updating both representations
- Risk of drift between ERD and NoSQL schema (mitigated by code review checklist)
- Slightly longer documentation (acceptable for the educational value)

**Reversibility:** Low. The dual model is now part of the project's identity; removing either representation would compromise either academic or production validity.

---

## ADR-008: Cart in Local Storage (Hive) over Firestore

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The cart is transient state — items the user is considering purchasing but has not yet committed to. Two options exist for persistence:

1. **Firestore `/users/{uid}/cart` collection** — synced across devices, real-time updates
2. **Local storage (Hive)** — device-only, no sync, no Firestore cost

Cart data does not need cross-device sync for MVP (assumption A-7 in [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §6). Cart mutations are frequent (add, update, remove) and would consume Firestore write quota rapidly.

### Decision

We will persist cart state in **Hive local storage** only. No `/carts` or `/users/{uid}/cart` collection will exist in Firestore. On order placement, the cart snapshot is converted to an `/orders/{orderId}` document and the local cart is cleared.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Firestore `/users/{uid}/cart`** | Consumes write quota (each add/update = 1 write); unnecessary for transient state; cross-device sync is OUT OF SCOPE per A-7 |
| **SharedPreferences** | Too simple for list-of-objects data; no schema validation |
| **SQLite (sqflite)** | Heavier than needed; Hive's key-value model is sufficient |

### Consequences

**Positive:**
- Zero Firestore write cost for cart operations
- Instant cart updates (no network round-trip)
- Offline-first (cart works without network)
- Simpler security model (no rules needed for cart)

**Negative:**
- Cart not visible on second device (acceptable per A-7)
- Cart lost on app uninstall (acceptable; cart is transient)
- No admin visibility into "abandoned carts" (acceptable for MVP; deferred analytics)

**Reversibility:** High. To migrate cart to Firestore post-MVP, add a `/users/{uid}/cart` subcollection and update `CartRepository` implementation. The Hive interface and Riverpod provider remain unchanged.

---

## ADR-009: Dark Luxury Theme over Default Material

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The product targets the luxury horology market. Default Material 3 theming (light background, blue accents) signals "generic app" — antithetical to the premium positioning. The brand aesthetic of luxury watch houses (Rolex, Patek Philippe, Audemars Piguet) is dark, restrained, gold-accented, and uses serif typography for heritage signaling.

### Decision

We will implement a **Dark Luxury Horology Design Paradigm**: deep charcoal obsidian background (`#121212`), muted anthracite surface cards (`#1E1E1E`), luxury gold accents (`#D4AF37`), Playfair Display serif for headings, Inter sans-serif for body. Full spec in [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) §8 (referenced from source SDD).

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Default Material 3 light theme** | Generic; signals "tutorial app" to reviewers |
| **Light theme with gold accents** | Light backgrounds conflict with luxury positioning (luxury = dark, restrained) |
| **Multiple themes (user-selectable)** | Adds complexity; not justified for MVP |

### Consequences

**Positive:**
- Premium aesthetic aligns with brand positioning
- Differentiates from generic Flutter demo apps
- WCAG AA contrast ratios achievable (NFR-14)
- Serif headings signal heritage (matches luxury watch brand aesthetic)

**Negative:**
- Accessibility constraints (must validate contrast carefully)
- Font loading adds ~500KB to bundle (Playfair Display + Inter)
- Risk of "trying too hard" if not executed with restraint (mitigated by minimalist composition)

**Reversibility:** High. Theme is isolated to `lib/core/theme/`; swapping to default Material is a one-line change in `main.dart`.

---

## ADR-010: Payment Integration OUT OF SCOPE for MVP

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

Payment integration (Stripe, PayPal, etc.) is a standard e-commerce feature. However, it introduces significant complexity:

- Per-transaction fees (violates C-1 $0 budget if any transaction occurs)
- PCI DSS compliance scope (even with tokenized payments, the app becomes "in scope" for PCI)
- KYC requirements for the merchant account
- Webhook handling for payment status updates
- Refund / cancellation logic

For an academic MVP demonstrating architecture and UX competence, payment is not essential. The checkout flow can terminate at "order placement" — the order is recorded in Firestore as a non-binding intent.

### Decision

Payment integration is **OUT OF SCOPE for MVP**. The checkout flow ends at order creation in Firestore. A clearly visible callout on the checkout page informs the user that no payment will be processed and that a representative will contact them to confirm availability and arrange payment.

This exclusion is documented in [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 and is reflected in the checkout UI per [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §7.2.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Stripe with test mode only** | Test mode still requires Stripe account setup; doesn't demonstrate production-grade payment handling; misleading to reviewers |
| **Stripe live with $0 transactions** | Live mode requires KYC; not feasible for academic project |
| **Fake "payment successful" screen** | Dishonest; misrepresents the system's capabilities |

### Consequences

**Positive:**
- Eliminates PCI compliance scope
- Eliminates KYC requirements
- Saves 5-7 days of timeline (Stripe SDK integration, webhook handling, refund logic)
- Honest representation of system capabilities

**Negative:**
- Cannot demonstrate end-to-end purchase flow
- Reviewer may ask "why no payments?" (answer documented in [FAQ.md](FAQ.md))
- Order data model lacks payment fields (mitigated: fields can be added post-MVP without schema migration since Firestore is schemaless)

**Reversibility:** High. Stripe integration post-MVP requires: Stripe SDK, `/payments` Firestore collection, Cloud Function for webhook handling, checkout UI update. None of these require changing the existing `/orders` schema or cart flow.

---

## ADR-011: Single Codebase for Web + Android over Native Split

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The project requires deployment to both Web (for live evaluation at a URL) and Android (for demonstration video). Options:

1. **Single Flutter codebase** — compile to both Web and Android from one `lib/` directory
2. **Native split** — separate Flutter Web project and Flutter Android project
3. **Native (Kotlin + React)** — separate native Android app and React web app

The constraint is solo developer + 30-day timeline (C-2, C-3). Maintaining two codebases would at minimum double the implementation effort.

### Decision

We will use a **single Flutter codebase** targeting both Web and Android. Platform-specific code is isolated to `android/` and `web/` shell directories; all business logic lives in `lib/` and is platform-agnostic.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Native split (Flutter Web + Flutter Android)** | Doubles maintenance; risk of feature drift between platforms |
| **Native (Kotlin + React)** | Two languages, two frameworks, two deployment pipelines; infeasible in 30 days solo |
| **React Native (single codebase)** | Viable alternative, but RN's web support is less mature than Flutter's; team has deeper Flutter experience |

### Consequences

**Positive:**
- Single source of truth for business logic
- Single test suite covers both platforms
- Single CI pipeline builds both targets
- Feature parity guaranteed by construction
- Faster development (write once, run on both)

**Negative:**
- Platform-specific UX compromises (e.g., Android back button vs. browser back button)
- Larger binary size (Flutter engine bundled)
- Some platform-specific plugins may not work on both targets (mitigated by checking plugin compatibility before adding)

**Reversibility:** Low. Splitting into native post-MVP would be a full rewrite. Mitigated by the clean architecture — domain layer is platform-agnostic and could be extracted to a shared package.

---

## ADR-012: Firebase Spark Free Tier over Blaze Paid Tier

**Date:** 2026-07-14
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

Firebase offers two pricing tiers:

- **Spark (Free)** — generous free quotas for Auth, Firestore, Hosting, Storage; no Cloud Functions; no automated Firestore backups; daily quota limits
- **Blaze (Pay-as-you-go)** — pay only for usage above free tier; enables Cloud Functions, automated backups, higher quotas, no daily limits

The project constraint C-1 mandates $0/month at steady state. Blaze tier could still be $0 if usage stays within free quotas, but the risk of accidental charges (e.g., infinite loop in Cloud Function) is non-zero without billing alerts configured.

### Decision

We will use the **Firebase Spark Free Tier** exclusively. No Cloud Functions, no automated Firestore backups, no Firebase Extensions that require Blaze tier. This is enforced by simply not enabling Blaze tier on the project.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Blaze tier with billing caps** | Blaze tier has billing caps but they are soft (caps can be exceeded before enforcement); risk of $5-50 surprise bill; not worth the marginal benefit for MVP |
| **Blaze tier with strict alerts** | Alerts are reactive (notify after spend); doesn't prevent charges; adds operational overhead |

### Consequences

**Positive:**
- Hard guarantee of $0 cost (no Blaze tier = no possible charges)
- Simplifies billing concern documentation
- Forces architectural discipline (no Cloud Functions = business logic in client, which is acceptable for MVP per ADR-001)

**Negative:**
- No Cloud Functions (no server-side business logic, no webhooks, no scheduled jobs)
- No automated Firestore backups (disaster recovery is manual — see [DEPLOYMENT.md](DEPLOYMENT.md) §8.1)
- Daily quota limits (50K Firestore reads/day, 20K writes/day) — risk of hitting limits during demo if load testing not careful
- No Firebase Extensions that require Blaze

**Reversibility:** High. Upgrading to Blaze is a one-click operation in Firebase Console. No code changes required. Upgrade decision deferred to v2.0 per [ROADMAP.md](ROADMAP.md) §4.3.

---

## ADR-013: Client-Side Search over Algolia / Firestore Full-Text

**Date:** 2026-07-15
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The official `App-WatchHub.doc` specification §Search and Filters requires "robust search functionality" allowing users to find specific watches. The previous v1.0.0 of this documentation marked search as `OUT OF SCOPE` because Algolia (the industry standard for Firebase search) charges per operation beyond its free tier, and Elastic App Search is fully paid.

However, per the user directive ("if the spec says to build it, we need to build it"), search is now IN SCOPE. The question is how to implement it without violating the $0 budget constraint (C-1) and without introducing a paid third-party service.

### Decision

We will implement search **client-side** as a text-matching filter on the catalog stream. The catalog `StreamProvider` (already used for filter chips) emits `List<Product>`; the search provider applies a case-insensitive `contains()` match against `modelName`, `brand`, and `category` fields. The search query is debounced 300ms to avoid excessive re-computation.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Algolia** | Paid beyond 10K operations/month; introduces external service dependency; violates C-1 if traffic grows |
| **Elastic App Search** | Fully paid; self-hosting requires server (violates C-1) |
| **Firestore `where` with `array-contains`** | Requires pre-tokenizing product names into keyword arrays at write time; complex; doesn't handle partial matches |
| **Firestore `where` with `>=` and `<=` prefix matching** | Only supports prefix matching, not substring; doesn't match "submariner" when user types "marine" |
| **Cloud Function with full-text search library** | Cloud Functions OUT OF SCOPE on Spark tier (ADR-012) |

### Consequences

**Positive:**
- Zero cost — no external service
- Zero additional Firestore reads — search operates on the already-loaded catalog stream
- Instant results (sub-100ms for ~50 SKUs per A-9)
- Composes naturally with existing filter chips (AND semantics)
- No additional indexes required

**Negative:**
- Does not scale beyond ~200 SKUs (acceptable per A-1)
- No fuzzy matching or typo tolerance (e.g., "rolx" won't match "Rolex") — documented as FR-5.7 Won't
- No full-text search on product descriptions (only name/brand/category) — documented as FR-5.8 Won't
- Search operates on the cached catalog; if the user is offline and the catalog has not yet loaded, search returns no results

**Reversibility:** High. If catalog grows beyond 200 SKUs, migrate to Algolia by replacing the `searchQueryProvider`'s implementation. The `SearchBar` widget and the rest of the UI remain unchanged.

---

## ADR-014: Top-Level `/reviews` Collection over Subcollection

**Date:** 2026-07-15
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

Per App-WatchHub.doc §Reviews and Ratings, customers must be able to leave reviews on products. Two storage options exist:

1. **Top-level `/reviews/{reviewId}` collection** with `productId` and `userId` fields
2. **Subcollection `/products/{productId}/reviews/{reviewId}`** nested under the product

### Decision

We will use a **top-level `/reviews` collection** with `productId` and `userId` as indexed fields. This is documented in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.4.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Subcollection `/products/{productId}/reviews/{reviewId}`** | Harder to query admin moderation queue across all products (requires collection group query); harder to enforce "one review per user per product" uniqueness; makes the user's review history query require collection group query across all product subcollections |

### Consequences

**Positive:**
- Simple admin moderation query: `where('status', '==', 'pending')` returns all pending reviews across all products
- Simple user-history query: `where('userId', '==', uid)` returns all reviews by a user
- Composite index on `(productId, status, createdAt)` is efficient for the product detail page query
- Uniqueness check (one review per user per product) is a simple query: `where('userId', '==', uid).where('productId', '==', pid).get()`

**Negative:**
- Requires composite indexes for product-scoped queries (already declared in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §5)
- Product document does not automatically contain its reviews (must query separately) — acceptable, as reviews are loaded lazily on product detail page

**Reversibility:** Low. Migrating from top-level to subcollection post-MVP would require a data migration script and rewriting all review queries. Mitigated by the repository abstraction — only `ReviewRepository` would change.

---

## ADR-015: FAQ in Firestore over Static JSON Bundle

**Date:** 2026-07-15
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

Per App-WatchHub.doc §Customer Support, the app must include an in-app FAQ section. Two storage options:

1. **Static JSON** bundled in `assets/json/faq.json` — admin updates require app rebuild
2. **Firestore `/faq` collection** — admin can CRUD via admin dashboard without app rebuild

### Decision

We will use a **Firestore `/faq` collection** for FAQ content. This is documented in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.7.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Static JSON in assets** | Admin cannot update FAQs without app rebuild; violates the "admin panel manages all content" pattern; would require redeployment for every FAQ change |

### Consequences

**Positive:**
- Admin can CRUD FAQs via admin dashboard (FR-7.9)
- FAQs update in real-time on the customer FAQ page (via snapshots)
- Consistent with other admin-managed content (products, etc.)
- No app rebuild required for FAQ changes

**Negative:**
- Consumes Firestore reads (one per FAQ document per page load) — acceptable on Spark tier
- FAQ page requires network connectivity (no offline FAQ) — acceptable; FAQ is non-critical
- Slightly more complex than static JSON (requires `FaqRepository` and `FaqProvider`)

**Reversibility:** High. To migrate to static JSON post-MVP (if Firestore reads become a concern), change `FaqRepository` implementation to read from `rootBundle`. The `FaqProvider` and `FaqPage` remain unchanged.

---

## ADR-016: Team Project Structure (6 Contributors)

**Date:** 2026-07-15
**Status:** Accepted
**Decider:** Muhammad Faheem Khan

### Context

The welcome email from eProjects Team confirms this is a **6-person team project**, not a solo project as the v1.0.0 documentation assumed. The team members are:

- Muhammad Asim Siddiqui (1540238)
- Musaib Zahid (1593575)
- Maaz (1591053)
- Muhammad Faheem Khan (1593766) — documentation architect
- Muhammad Mubeen (1593765)
- Ahmed Ali (1557184)

The previous documentation's assumption of "solo developer" (constraint C-3 in v1.0.0) is incorrect and must be updated. The team context affects: branching strategy, code review process, ADR decision-makers, risk register (bus factor), and CONTRIBUTING.md.

### Decision

We will adopt a **team-based development model** with the following structure:

1. **Feature-branch workflow** — each team member works on feature branches; PRs require at least 1 review (can be from any team member) before merging to `main`.
2. **Documentation architect role** — Muhammad Faheem Khan owns the `/docs/` tree and reviews all documentation changes.
3. **Shared repository** — single GitHub repository with all team members as collaborators.
4. **ADRs are team decisions** — any ADR can be proposed by any team member; acceptance requires team consensus (recorded in the ADR's Decider field as "Team consensus").
5. **Worklog** — each team member appends to the shared worklog at `/home/z/my-project/worklog.md` per the role spec.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Solo development by Faheem, others do separate work** | Violates the eProject team requirement; doesn't demonstrate team collaboration skills |
| **Monorepo with per-person folders** | Anti-pattern; defeats code reuse and review |
| **Multi-repo (one per person)** | Fragments the project; complicates integration |

### Consequences

**Positive:**
- Parallelizes development — 6 features can be built simultaneously
- Demonstrates team collaboration to recruiters
- Reduces bus factor risk (R-9 in v1.0.0 is now mitigated)
- Code review by peers catches more issues than self-review

**Negative:**
- Coordination overhead — requires daily standups (synchronous or async via worklog)
- Merge conflicts more likely with 6 contributors
- Requires stricter branch protection and PR review enforcement
- Onboarding overhead for team members unfamiliar with Flutter/Riverpod (mitigated by [STYLE_GUIDE.md](STYLE_GUIDE.md))

**Reversibility:** Low. The team structure is fixed by the academic enrollment; cannot be changed mid-project.

---

## ADR Format

Each ADR in this file follows the [Michael Nygard ADR template](https://github.com/joelparkerhenderson/architecture-decision-record/tree/main/templates/record/template-michael-nygard):

```text
## ADR-NNN: Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-MMM
**Decider:** Name

### Context
(Why is this decision needed? What is the problem? What are the constraints?)

### Decision
(What is the change being made? Be precise.)

### Alternatives Considered
(Table of alternatives and why they were rejected.)

### Consequences
(Positive: ... | Negative: ... | Reversibility: High | Medium | Low)
```

### ADR Lifecycle Rules

1. ADRs are **append-only**. Once Accepted, an ADR is never edited except to change Status to Deprecated or Superseded.
2. To reverse a decision, create a new ADR that Supersedes the prior one. The old ADR remains in the file with Status `Superseded by ADR-NNN`.
3. New ADRs are numbered sequentially (ADR-013, ADR-014, ...).
4. Every ADR must be linked from the [ADR Index](#adr-index).
5. ADRs are written in past tense ("We decided...") to reflect that the decision has been made.

## References

- Internal: [ARCHITECTURE.md](ARCHITECTURE.md), [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [SECURITY.md](SECURITY.md), [DEPLOYMENT.md](DEPLOYMENT.md), [RISKS.md](RISKS.md), [ROADMAP.md](ROADMAP.md)
- External: [Michael Nygard's ADR article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions), [ADR GitHub organization templates](https://github.com/joelparkerhenderson/architecture-decision-record)
