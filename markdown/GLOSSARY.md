# Glossary

> Terminology reference for App-WatchHub. Defines every domain term, abbreviation, and technical concept used in the documentation tree. This file is the canonical source for term definitions — every other document should use terms consistently with the definitions here.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Glossary |
| **Purpose** | Define all terminology, abbreviations, and domain terms used across the documentation |
| **Audience** | All audiences — first stop when an unfamiliar term appears |
| **Scope** | Terminology only; technical details in topic-specific docs |
| **Version** | 1.0.0 |
| **Status** | Active — updated when new terms enter the project vocabulary |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [INDEX.md](INDEX.md), [FAQ.md](FAQ.md), [PROJECT_SCOPE.md](PROJECT_SCOPE.md) |

---

## Table of Contents

1. [How to Use This Glossary](#1-how-to-use-this-glossary)
2. [Architecture & Infrastructure Terms](#2-architecture--infrastructure-terms)
3. [Framework & Library Terms](#3-framework--library-terms)
4. [Database & Data Terms](#4-database--data-terms)
5. [Security Terms](#5-security-terms)
6. [DevOps & CI/CD Terms](#6-devops--cicd-terms)
7. [Domain Terms (Horology)](#7-domain-terms-horology)
8. [Acronyms](#8-acronyms)
9. [Project-Specific Terms](#9-project-specific-terms)
10. [Portfolio Defense Script](#10-portfolio-defense-script)
11. [References](#11-references)

---

## 1. How to Use This Glossary

This file is the canonical source for term definitions across the App-WatchHub documentation. When a term is introduced in another document, it should be defined here in parallel. When a reader encounters an unfamiliar term, this is the first place to look.

Terms are organized by category for browsing. If you cannot find a term, search this file (Ctrl+F / Cmd+F). If the term is genuinely missing, file an entry in [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) so it can be added.

Definitions are intentionally concise — typically one to three sentences. For deep technical context, follow the cross-reference to the relevant topic document.

## 2. Architecture & Infrastructure Terms

### Serverless Architecture
A cloud computing model where the cloud provider dynamically manages the allocation and provisioning of servers. Developers write code without managing infrastructure; billing is based on actual usage rather than reserved capacity. In App-WatchHub, serverless refers specifically to Firebase's managed services (Auth, Firestore, Hosting) — there is no custom server process. See [ARCHITECTURE.md](ARCHITECTURE.md) §1.

### SEDA (Serverless Event-Driven Architecture)
An architectural pattern where serverless services communicate via events rather than synchronous request-response calls. In App-WatchHub, the "events" are Firestore document changes that propagate to subscribed clients via `snapshots()` streams. There is no custom event bus; the Firestore SDK provides the event pipeline. See [ARCHITECTURE.md](ARCHITECTURE.md) §1 and [DECISIONS.md](DECISIONS.md) ADR-001.

### Edge Computing
Deploying computational resources and routing logic as close to the user's geographic location as possible. Firebase Hosting uses a global CDN with ~100 points of presence (PoPs), serving the Flutter Web binary from the edge nearest to each user. See [ARCHITECTURE.md](ARCHITECTURE.md) §4.

### Edge Firewall (in this project)
Colloquial term for Firestore Security Rules, which execute at the database edge (not in a custom middleware) to authorize every read/write. The "firewall" is conceptual — there is no separate network appliance; the rules engine is part of the Firestore service. See [SECURITY.md](SECURITY.md) §1.

### Trust Boundary
A logical perimeter separating components with different trust levels. App-WatchHub has three trust boundaries: (1) network/CDN edge, (2) client (untrusted — source visible to user), (3) Firebase Auth + Firestore Rules (authoritative — server-side). See [SECURITY.md](SECURITY.md) §1.

### Clean Architecture
A software design philosophy that separates concerns into concentric layers (domain, application, infrastructure, presentation) with dependency inversion pointing inward. App-WatchHub uses a pragmatic adaptation — three layers (presentation, state, domain+infrastructure) rather than four. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §1 and §2.

### Feature-First Organization
A code organization strategy where folders are grouped by business feature (auth, catalog, cart, orders, admin) rather than by technical layer (controllers, views, models). Each feature folder contains its own presentation, state, and widgets. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §3.

## 3. Framework & Library Terms

### Flutter
Google's open-source UI toolkit for building natively compiled applications for mobile, web, and desktop from a single Dart codebase. App-WatchHub targets Flutter 4.x with Material 3. See [ARCHITECTURE.md](ARCHITECTURE.md) §2.

### Dart
The programming language used by Flutter. Strongly-typed, garbage-collected, with sound null safety. App-WatchHub uses Dart 3.x. See [DEPENDENCIES.md](DEPENDENCIES.md).

### Material 3 (Material You)
Google's latest design system, emphasizing dynamic color, large shape variations, and improved typography. App-WatchHub uses Material 3 components but overrides the default color scheme with a custom dark luxury palette. See [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) §8.

### Riverpod
A reactive caching and data-binding framework for Flutter applications. Provides compile-time-safe dependency injection and state management via providers. App-WatchHub uses Riverpod 2.x with AsyncNotifier as the primary provider type. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §4 and [DECISIONS.md](DECISIONS.md) ADR-004.

### AsyncNotifier
A Riverpod provider type that manages asynchronous state with explicit loading/error/data transitions. Encapsulates `AsyncValue<T>` and provides methods for state mutation. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §4.1.

### GoRouter
A declarative routing package for Flutter that supports web deep-linking, route guards, and nested navigation. App-WatchHub uses GoRouter 14.x. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §5 and [DECISIONS.md](DECISIONS.md) ADR-005.

### Freezed
A Dart code generation package for creating immutable data classes with value equality, copyWith, and JSON serialization. App-WatchHub uses Freezed for all domain models. See [STYLE_GUIDE.md](STYLE_GUIDE.md) §7.

### Hive CE
A lightweight key-value database for Flutter, persisted to local storage. The "CE" stands for Community Edition — a fork of the original `hive` package, which was abandoned in 2023. App-WatchHub uses Hive CE for cart and wishlist persistence. See [DECISIONS.md](DECISIONS.md) ADR-008.

## 4. Database & Data Terms

### NoSQL
A non-relational database structure enabling flexible document storage. Unlike SQL, NoSQL databases do not enforce a fixed schema; documents in the same collection can have different fields. App-WatchHub uses Cloud Firestore (document NoSQL). See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §1.

### Cloud Firestore
Firebase's NoSQL document database. Stores data in documents (key-value maps) organized into collections. Supports real-time streams, offline cache, and security rules. See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §3 and [DECISIONS.md](DECISIONS.md) ADR-002.

### Document
A single record in Firestore, analogous to a row in SQL. Identified by a path like `/products/{productId}`. Documents contain key-value fields; values can be strings, numbers, booleans, arrays, maps, timestamps, or references to other documents.

### Collection
A group of documents in Firestore, analogous to a table in SQL. Identified by a path like `/products`. Collections do not enforce a schema; documents within can have different fields.

### Composite Index
A pre-built data structure in Firestore that accelerates queries with multiple filter or sort fields. Composite indexes must be explicitly declared in `firestore.indexes.json` and deployed. See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §5.

### Snapshots (Firestore)
A method on Firestore queries (`collection.snapshots()`) that returns a `Stream<QuerySnapshot>` — every change to the underlying data emits a new snapshot. This is the mechanism that powers real-time catalog updates in App-WatchHub. See [API_REFERENCE.md](API_REFERENCE.md) §4.1.

### Denormalization
The practice of storing the same data in multiple places to optimize reads. In App-WatchHub, order items include `modelName` and `unitPrice` denormalized from the product catalog so that historical orders remain accurate even if the product is later renamed or its price changes. See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.4.

### ERD (Entity-Relationship Diagram)
A visual representation of a relational database schema showing entities, their attributes, and the relationships between them. App-WatchHub maintains an academic ERD alongside its production NoSQL schema per [DECISIONS.md](DECISIONS.md) ADR-007. See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §2.

### Cardinality (in ERD)
The numerical relationship between two entities. Common cardinalities: one-to-one, one-to-many, many-to-many. In App-WatchHub's ERD, `USERS` to `ORDERS` is one-to-many (one user can place many orders); `ORDERS` to `ORDER_ITEMS` is one-to-many. See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §2.

## 5. Security Terms

### Authz (Authorization)
The process of determining whether an authenticated user is permitted to perform a specific action. Distinct from Authn (Authentication), which verifies identity. In App-WatchHub, authz is enforced by Firestore Security Rules at the data edge. See [SECURITY.md](SECURITY.md) §1.

### Authn (Authentication)
The process of verifying a user's identity. In App-WatchHub, authn is handled by Firebase Authentication via email/password. See [SECURITY.md](SECURITY.md) §5.

### ID Token
A JSON Web Token (JWT) issued by Firebase Auth after successful login. Contains the user's UID and claims (e.g., email). Sent with every Firestore request; verified server-side. Tokens expire after 1 hour and are auto-refreshed by the Firebase SDK. See [SECURITY.md](SECURITY.md) §5.1.

### Firestore Security Rules
A declarative language for authorizing Firestore operations. Rules are deployed to Firebase and evaluated on every read/write. App-WatchHub's rules are documented in [SECURITY.md](SECURITY.md) §4.1.

### STRIDE
A threat modeling framework developed by Microsoft. Categorizes threats into six types: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege. App-WatchHub's threat model is in [SECURITY.md](SECURITY.md) §2.

### PII (Personally Identifiable Information)
Data that can be used to identify a specific individual. In App-WatchHub, PII is limited to email and fullName. See [SECURITY.md](SECURITY.md) §7.1.

### Privilege Escalation
A security attack where a user gains elevated permissions they should not have. In App-WatchHub, the most common escalation attempt would be a customer trying to set their own `isAdmin` flag to `true`. This is blocked by Firestore rules. See [SECURITY.md](SECURITY.md) §2.

### Admin Bootstrap
The manual procedure of setting `isAdmin: true` on a user's `/users/{uid}` document via the Firebase Console, since the rules block client-side writes to this field. See [SECURITY.md](SECURITY.md) §3.

## 6. DevOps & CI/CD Terms

### CI (Continuous Integration)
The practice of automatically building and testing code on every push. App-WatchHub uses GitHub Actions for CI. See [DEPLOYMENT.md](DEPLOYMENT.md) §1.

### CD (Continuous Deployment)
The practice of automatically deploying code to production after CI passes. App-WatchHub deploys to Firebase Hosting on every push to `main`. See [DEPLOYMENT.md](DEPLOYMENT.md) §1.

### GitHub Actions
GitHub's CI/CD platform. Workflows are defined in YAML files under `.github/workflows/`. App-WatchHub's workflow is documented in [DEPLOYMENT.md](DEPLOYMENT.md) §3. See [DECISIONS.md](DECISIONS.md) ADR-006.

### Branch Protection
GitHub settings that enforce workflow rules on a branch (e.g., require PR review, require status checks). App-WatchHub's `main` branch is protected per [DEPLOYMENT.md](DEPLOYMENT.md) §4.

### Pipeline / Workflow
A series of automated steps executed on every code change. App-WatchHub's pipeline has four stages: Verify, Test, Build, Deploy. See [DEPLOYMENT.md](DEPLOYMENT.md) §2.

### Firebase Emulator Suite
A local development environment that simulates Firebase services (Auth, Firestore, Hosting) on the developer's machine. Eliminates accidental writes to production during development. See [CONFIGURATION.md](CONFIGURATION.md) §5.

### Flavor (in Flutter)
A build configuration that targets a specific environment (dev, staging, prod). Each flavor has its own Firebase project and configuration files. See [CONFIGURATION.md](CONFIGURATION.md) §4.

## 7. Domain Terms (Horology)

### Horology
The study of time and timekeeping devices, including watches and clocks. App-WatchHub is positioned in the "luxury horology market" — the high-end segment of watch retail.

### Movement
The internal mechanism of a mechanical watch that drives the hands and complications. Types include automatic (self-winding via rotor), manual (hand-wound), and quartz (battery-powered). The `specs.movement` field in the product schema stores this as a string (e.g., "Automatic 3235"). See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.2.

### Power Reserve
The duration a mechanical watch can run after being fully wound, measured in hours. Stored in `specs.powerReserve` (e.g., "70 Hours").

### Water Resistance
The depth rating at which a watch can withstand water pressure, measured in meters (m) or atmospheres (ATM). Stored in `specs.waterResistance` (e.g., "300m"). Note: this is a pressure rating, not a depth to which the watch can actually be taken.

### Complication
Any function beyond simple timekeeping. Common complications: date, chronograph (stopwatch), GMT (second time zone), perpetual calendar, tourbillon. Used as a categorization axis in `category` field. See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.2.2.

### Case Material
The metal used for the watch case. Common materials: Oystersteel (Rolex's 904L stainless steel), gold (yellow, rose, white), platinum, titanium, ceramic.

### Boutique (in luxury retail)
A retail store or online shop selling premium goods from one or more luxury brands. App-WatchHub's customer-facing experience is called "the boutique."

### SKU (Stock Keeping Unit)
A unique identifier for a distinct product variant. In App-WatchHub, the `productId` field serves as the SKU. The MVP catalog is small (~12-50 SKUs per assumption A-1).

## 8. Acronyms

| Acronym | Expansion | Definition Location |
|---|---|---|
| ADR | Architecture Decision Record | [DECISIONS.md](DECISIONS.md) |
| API | Application Programming Interface | [API_REFERENCE.md](API_REFERENCE.md) |
| APK | Android Package (Android app binary format) | [DEPLOYMENT.md](DEPLOYMENT.md) §6 |
| Authn | Authentication | §5 above |
| Authz | Authorization | §5 above |
| CDN | Content Delivery Network | [ARCHITECTURE.md](ARCHITECTURE.md) §4 |
| CI | Continuous Integration | §6 above |
| CD | Continuous Deployment | §6 above |
| CRUD | Create, Read, Update, Delete | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-4 |
| DFD | Data Flow Diagram | [ARCHITECTURE.md](ARCHITECTURE.md) §8 |
| DI | Dependency Injection | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §4 |
| DoS | Denial of Service | [SECURITY.md](SECURITY.md) §2 |
| ERD | Entity-Relationship Diagram | §4 above |
| FCM | Firebase Cloud Messaging | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| FR | Functional Requirement | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) §2 |
| GDPR | General Data Protection Regulation (EU) | [SECURITY.md](SECURITY.md) §7 |
| HTTP | HyperText Transfer Protocol | [API_REFERENCE.md](API_REFERENCE.md) |
| HTTPS | HTTP Secure (HTTP over TLS) | [SECURITY.md](SECURITY.md) §1 |
| ID | Identifier | Various |
| JSON | JavaScript Object Notation | [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4 |
| JWT | JSON Web Token | §5 above |
| KYC | Know Your Customer (compliance) | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| MVP | Minimum Viable Product | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §1 |
| NFR | Non-Functional Requirement | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) §3 |
| OAuth | Open Authorization (SSO protocol) | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| PCI DSS | Payment Card Industry Data Security Standard | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| PII | Personally Identifiable Information | §5 above |
| PoP | Point of Presence (CDN) | [ARCHITECTURE.md](ARCHITECTURE.md) §4 |
| PR | Pull Request | [CONTRIBUTING.md](../CONTRIBUTING.md) |
| QA | Quality Assurance | [TESTING.md](TESTING.md) |
| RPO | Recovery Point Objective | [DEPLOYMENT.md](DEPLOYMENT.md) §8.2 |
| RTO | Recovery Time Objective | [DEPLOYMENT.md](DEPLOYMENT.md) §8.2 |
| SDK | Software Development Kit | [API_REFERENCE.md](API_REFERENCE.md) |
| SEDA | Serverless Event-Driven Architecture | §2 above |
| SK | Secret Key (in HMAC context) | n/a |
| SKU | Stock Keeping Unit | §7 above |
| SSO | Single Sign-On | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| SQL | Structured Query Language | [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §2 |
| SSL | Secure Sockets Layer (now TLS) | [SECURITY.md](SECURITY.md) §1 |
| STRIDE | Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation of Privilege | §5 above |
| TLS | Transport Layer Security | [SECURITY.md](SECURITY.md) §7.3 |
| UID | User Identifier (Firebase Auth) | [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.1 |
| URI | Uniform Resource Identifier | Various |
| URL | Uniform Resource Locator | Various |
| UX | User Experience | Various |
| WCAG | Web Content Accessibility Guidelines | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) NFR-14 |
| XSS | Cross-Site Scripting | [SECURITY.md](SECURITY.md) §2.1 |

## 9. Project-Specific Terms

### App-WatchHub
The project name. A combination of "App" (software application) and "WatchHub" (a hub for watches). Pronounced "app-watch-hub".

### Boutique
The customer-facing landing page after login. Renders the catalog with filters. Route: `/boutique`. Distinct from the admin dashboard.

### Catalog
The collection of all products visible to customers. Backed by the `/products` Firestore collection. Rendered as a real-time stream.

### Cart State Machine
The state model governing cart transitions: Empty → Populated → Checkout → OrderPlaced. Documented in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §6.

### Dark Luxury Horology Design Paradigm
The project's name for its visual design system: dark charcoal background, gold accents, serif typography. Specified in [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) §8.

### Admin Bootstrap
The one-time manual procedure of setting `isAdmin: true` for the first admin user via Firebase Console. Documented in [SECURITY.md](SECURITY.md) §3.

### Role-Based Routing
The pattern of redirecting users to different routes based on their role (`isAdmin` true or false). Documented in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §5. Note: this is UX-only; the actual security boundary is Firestore Rules.

### Spark Free Tier
Firebase's free pricing tier. App-WatchHub operates entirely within Spark limits per [PROJECT_SCOPE.md](PROJECT_SCOPE.md) C-1. See [RISKS.md](RISKS.md) §3 for quota details.

### Portfolio Defense Script
The 5-10 minute talking-points script used by the author when presenting the project to recruiters or reviewers. Included in §10 below.

## 10. Portfolio Defense Script

When presenting this architecture to a recruiter or academic reviewer, the following talking points are recommended. They distill the project's key engineering decisions into a 60-second pitch that can be expanded based on listener interest.

### 10.1 The 60-Second Pitch

> "I deliberately designed a Serverless Event-Driven Architecture leveraging Flutter and Firebase. To eliminate network overhead and avoid infrastructure cost friction entirely within a compressed 30-day MVP schedule, I integrated optimized local vector assets for media content, while deploying serverless JavaScript validation configurations directly at the database firewall layer using Firestore Security Rules. This ensured multi-tenant client isolation with zero middle-tier operating costs."

### 10.2 Expanded Talking Points

If the listener shows interest, expand on these themes:

**On architecture choice:**
> "I chose SEDA over a traditional three-tier stack because the $0 budget constraint and 30-day timeline made a custom backend infeasible. Firebase's managed services — Auth, Firestore, Hosting — give me authentication, real-time data, and CDN distribution without provisioning a single server. The trade-off is that complex business logic must live in the client, which I accepted for MVP-grade workflows."

**On security:**
> "Because there's no custom API server, all authorization has to happen at the data layer. I used Firestore Security Rules to enforce that customers can only read their own orders, only admins can mutate products, and crucially, the `isAdmin` flag cannot be self-set by a client. The first admin is bootstrapped manually via the Firebase Console, then the rules take over."

**On documentation:**
> "The repo has 20+ production Markdown files in `/docs/` — architecture, database design, API reference, security model, testing strategy, ADRs for every major decision. Every gap in the source spec is marked `UNKNOWN` or `OUT OF SCOPE` rather than fabricated. The docs are structured so an AI coding agent can read them and extend the codebase without architectural surprises."

**On testing:**
> "I have unit tests for business logic, widget tests for UI components, integration tests for end-to-end flows, and a security rules test suite that runs against the Firebase Emulator on every push. The CI pipeline is four stages — verify, test, build, deploy — and the whole thing runs on GitHub Actions for free."

**On trade-offs:**
> "The biggest trade-off is no payment integration. Stripe would have added PCI scope, KYC requirements, and per-transaction fees incompatible with the $0 budget. The checkout flow terminates at order placement — the order is recorded as a non-binding intent. That's documented in the ADRs as a deliberate exclusion, not a missing feature."

### 10.3 Anticipated Questions

For anticipated questions and answers, see [FAQ.md](FAQ.md).

## 11. References

- Internal: [INDEX.md](INDEX.md), [FAQ.md](FAQ.md), [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [ARCHITECTURE.md](ARCHITECTURE.md), [SECURITY.md](SECURITY.md), [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [DECISIONS.md](DECISIONS.md)
- External: [Firebase glossary](https://firebase.google.com/docs/glossary), [Flutter glossary](https://docs.flutter.dev/reference/glossary), [Web.dev glossary](https://web.dev/learn/html/glossary), [Cloud Firestore data model](https://firebase.google.com/docs/firestore/data-model)
