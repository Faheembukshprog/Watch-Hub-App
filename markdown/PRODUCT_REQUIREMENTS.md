# Product Requirements

> Formal specification of what App-WatchHub must do (functional) and how it must behave (non-functional). Each requirement is traceable to a feature in [PROJECT_SCOPE.md](PROJECT_SCOPE.md) and is testable against the criteria in [TESTING.md](TESTING.md).

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Product Requirements |
| **Purpose** | Define functional and non-functional requirements, user stories, personas, and acceptance criteria |
| **Audience** | Product managers, academic reviewers, QA engineers, contributors |
| **Scope** | Requirements only; implementation details in [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) and [ARCHITECTURE.md](ARCHITECTURE.md) |
| **Version** | 1.0.0 |
| **Status** | Approved — locked for MVP cycle |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [API_REFERENCE.md](API_REFERENCE.md), [TESTING.md](TESTING.md) |

---

## Table of Contents

1. [Personas](#1-personas)
2. [Functional Requirements](#2-functional-requirements)
3. [Non-Functional Requirements](#3-non-functional-requirements)
4. [User Stories](#4-user-stories)
5. [Acceptance Criteria](#5-acceptance-criteria)
6. [Requirements Traceability Matrix](#6-requirements-traceability-matrix)
7. [References](#7-references)

---

## 1. Personas

The product is designed for two primary personas. Every requirement in this document must serve at least one of them; requirements that serve neither are candidates for the [OUT OF SCOPE list](PROJECT_SCOPE.md#5-out-of-scope-exclusions).

### 1.1 Persona A — The Collector (Customer)

**Name:** Alexander Sterling
**Demographics:** 42 years old, net worth >$5M, based in Geneva, Switzerland
**Behavioral Profile:** Alexander researches watches for 6–12 months before purchase. He visits boutique sites daily, expects sub-second navigation, and abandons sites that show loading spinners or layout shift. He values discretion — he does not want popups, newsletter prompts, or social-share buttons cluttering his browsing experience.
**Technical Profile:** Uses an iPhone 15 Pro and a MacBook Pro 16". Browses primarily on mobile during commutes and on desktop in the evening. Expects dark-mode parity across devices.
**Success Criterion for App-WatchHub:** Alexander can browse the catalog, filter by brand, add to wishlist, move items to cart, and place an order in under 3 minutes total session time without ever seeing a loading spinner longer than 500ms.

### 1.2 Persona B — The Curator (Administrator)

**Name:** Beatrice Laurent
**Demographics:** 38 years old, luxury retail operations manager
**Behavioral Profile:** Beatrice manages inventory for a boutique. She needs to add new SKUs as they arrive, update stock counts after in-store sales, and audit orders placed through the digital channel. She expects a clean admin panel with sortable tables and bulk-action shortcuts where possible.
**Technical Profile:** Uses a desktop browser (Chrome on Windows). Does not want to learn SQL or the Firebase Console — she wants CRUD directly in the app.
**Success Criterion for App-WatchHub:** Beatrice can log in, see today's orders at a glance, update a product's stock count, and change an order's status — all without leaving the admin panel or consulting documentation.

## 2. Functional Requirements

Functional requirements are versioned at the major level (FR-1, FR-2) and decomposed into sub-requirements at the minor level (FR-1.1, FR-1.2). Each sub-requirement is independently testable.

### 2.1 FR-1.0 — Identity Management

The system must allow users to register, authenticate via secure email/password, modify personal delivery configurations, and initiate password recovery routines. This requirement is decomposed as follows:

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-1.1 | The system shall allow a new user to register with a valid email and a password meeting complexity rules (see §2.1.1) | Must | FR-1.0 |
| FR-1.2 | The system shall prevent duplicate registrations for the same email address | Must | FR-1.0 |
| FR-1.3 | The system shall authenticate a registered user with email + password and issue a Firebase ID token | Must | FR-1.0 |
| FR-1.4 | The system shall persist a user profile document at `/users/{uid}` upon first successful authentication | Must | FR-1.0 |
| FR-1.5 | The system shall allow an authenticated user to update their `fullName` and delivery address fields | Must | FR-1.0 |
| FR-1.6 | The system shall allow a user to request a password reset email via Firebase Auth's `sendPasswordResetEmail` API | Must | FR-1.0 |
| FR-1.7 | The system shall sign out a user and clear all in-memory session state upon explicit logout | Must | FR-1.0 |
| FR-1.8 | The system shall persist the authenticated session across app restarts (Firebase Auth auto-restores the ID token) | Must | FR-1.0 |
| FR-1.9 | The system shall display validation errors inline on the registration and login forms | Should | FR-1.0 |
| FR-1.10 | The system shall NOT require email verification before login (deferred to v1.1) | Won't | OUT OF SCOPE |

#### 2.1.1 Password Complexity Rules

| Rule | Value | Rationale |
|---|---|---|
| Minimum length | 8 characters | Firebase Auth default floor |
| Required character classes | Lowercase + uppercase + digit | Balanced UX/security for MVP |
| Special character required | No | Avoids UX friction for luxury demo |
| Maximum length | 64 characters | Prevents DoS on hash computation |
| Common-password blacklist | No (deferred) | Would require custom logic; Firebase does not enforce |

### 2.2 FR-2.0 — Dynamic Catalog Discovery

The client must render structured luxury watch collections filtered concurrently by brand, horological category, pricing tiers, and inventory availability metrics.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-2.1 | The system shall render a catalog view of all products in `/products` collection, sorted by `createdAt` descending | Must | FR-2.0 |
| FR-2.2 | The system shall allow filtering by `brand` (multi-select, OR semantics within filter) | Must | FR-2.0 |
| FR-2.3 | The system shall allow filtering by `category` (multi-select, OR semantics within filter) | Must | FR-2.0 |
| FR-2.4 | The system shall allow filtering by price tier (preset ranges; see §2.2.1) | Must | FR-2.0 |
| FR-2.5 | The system shall allow filtering by availability (`inStock` = `stockCount > 0`) | Must | FR-2.0 |
| FR-2.6 | The system shall apply multiple filters concurrently (AND semantics across filter types) | Must | FR-2.0 |
| FR-2.7 | The system shall render a product detail view when a catalog item is tapped, showing full specs | Must | FR-2.0 |
| FR-2.8 | The system shall stream catalog updates in real-time via Firestore `snapshots()` (admin inventory changes reflect instantly on customer view) | Must | FR-2.0 |
| FR-2.9 | The system shall display a fallback empty-state when no products match the active filters | Must | FR-2.0 |
| FR-2.10 | The system shall NOT implement pagination for MVP (catalog under 50 SKUs per A-1) | Won't | A-1 |

#### 2.2.1 Price Tier Definitions

| Tier Label | Range (USD) | Target Brands |
|---|---|---|
| Entry | $1,000 – $5,000 | Tudor, Hamilton, Longines |
| Mid | $5,001 – $15,000 | Omega, Breitling, IWC |
| High | $15,001 – $50,000 | Rolex, Cartier, Panerai |
| Prestige | $50,001+ | Patek Philippe, Audemars Piguet, Vacheron Constantin |

Tier boundaries are defined as constants in `lib/core/constants/catalog_constants.dart` and may be re-tuned without code changes if the catalog shifts.

### 2.3 FR-3.0 — Persisted Cart & Wishlist

The application must manage active checkout sessions, calculating line-item aggregates, tax evaluations, and shifting states dynamically between wishlists and transactional carts.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-3.1 | The system shall maintain a per-user cart in Riverpod state, persisted to local storage (Hive) for offline durability | Must | FR-3.0 |
| FR-3.2 | The system shall allow adding a product to the cart with quantity >= 1 | Must | FR-3.0 |
| FR-3.3 | The system shall prevent adding a product whose `stockCount` is 0 | Must | FR-3.0 |
| FR-3.4 | The system shall prevent adding a quantity greater than the product's `stockCount` | Must | FR-3.0 |
| FR-3.5 | The system shall recalculate the cart subtotal on every add/remove/update operation | Must | FR-3.0 |
| FR-3.6 | The system shall calculate tax as `subtotal * taxRate`, where `taxRate` is a constant (`UNKNOWN` — see [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) Q-1) | Should | FR-3.0 |
| FR-3.7 | The system shall maintain a separate wishlist, distinct from the cart | Must | FR-3.0 |
| FR-3.8 | The system shall allow moving an item from wishlist to cart in a single action | Must | FR-3.0 |
| FR-3.9 | The system shall allow moving an item from cart to wishlist in a single action | Must | FR-3.0 |
| FR-3.10 | The system shall persist cart and wishlist across app restarts (local storage only; cross-device sync is OUT OF SCOPE) | Must | FR-3.0 |
| FR-3.11 | The system shall clear the cart upon successful order placement | Must | FR-3.0 |
| FR-3.12 | The system shall NOT persist cart to Firestore (no `/carts` collection) — local-only per A-7 | Won't | A-7 |

### 2.4 FR-4.0 — Unified Governance Panel

Accounts flag-verified with `isAdmin: true` must bypass customer paths, rendering transactional auditing modules, inventory CRUD utilities, and review moderation controls.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-4.1 | The system shall render an admin dashboard at route `/admin` when an authenticated user's `isAdmin` field is `true` | Must | FR-4.0 |
| FR-4.2 | The system shall redirect non-admin users attempting to access `/admin` to `/boutique` | Must | FR-4.0 |
| FR-4.3 | The system shall redirect unauthenticated users attempting to access `/admin` to `/login` | Must | FR-4.0 |
| FR-4.4 | The admin dashboard shall display a summary panel: total orders today, total revenue today, low-stock products (< 5 units) | Must | FR-4.0 |
| FR-4.5 | The admin dashboard shall render an inventory CRUD table: list products, create, update, delete | Must | FR-4.0 |
| FR-4.6 | The admin dashboard shall render an orders table: list orders, update `orderStatus` | Must | FR-4.0 |
| FR-4.7 | The admin dashboard shall render a review moderation queue: approve, reject, or delete pending reviews (see FR-6 for submission flow) | Must | FR-4.0 + App-WatchHub.doc §Reviews |
| FR-4.8 | The system shall enforce all admin mutations via Firestore Security Rules (admin writes blocked at firewall if `isAdmin != true`) | Must | FR-4.0 |
| FR-4.9 | The first admin must be bootstrapped manually by editing the `/users/{uid}` document in Firebase Console — see [SECURITY.md](SECURITY.md) § Admin Bootstrap | Must | FR-4.0 |
| FR-4.10 | The system shall NOT support admin-to-admin role delegation in MVP (no `promoteToAdmin` action) | Won't | OUT OF SCOPE |
| FR-4.11 | The admin dashboard shall render a support ticket queue: view tickets, update status, respond | Must | App-WatchHub.doc §Customer Support |
| FR-4.12 | The admin dashboard shall render a feedback/issue report queue: view, triage, dismiss | Must | App-WatchHub.doc §Feedback and Reviews |
| FR-4.13 | The admin dashboard shall render a user management table: list users, view profile, disable account (mark `isActive: false`) | Should | App-WatchHub.doc §Admin Panel |

### 2.5 FR-5.0 — Search

Per App-WatchHub.doc §Search and Filters, the system must provide robust search functionality allowing users to find specific watches by name, brand, or category. The catalog is small (~50 SKUs per A-1) so search is implemented client-side via text matching on the catalog stream — see [DECISIONS.md](DECISIONS.md) ADR-013.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-5.1 | The system shall render a search bar on the boutique page (top of catalog) | Must | App-WatchHub.doc §Search |
| FR-5.2 | The system shall filter the catalog in real-time as the user types (debounced 300ms) | Must | App-WatchHub.doc §Search |
| FR-5.3 | The search shall match against `modelName`, `brand`, and `category` fields (case-insensitive) | Must | App-WatchHub.doc §Search |
| FR-5.4 | The search shall compose with filter chips (brand, category, price tier, availability) via AND semantics | Must | App-WatchHub.doc §Search + §Filters |
| FR-5.5 | The search shall display a "No results for '<query>'" empty state when no products match | Must | App-WatchHub.doc §Search |
| FR-5.6 | The search shall clear when the user taps the X button in the search bar | Must | App-WatchHub.doc §Search |
| FR-5.7 | The search shall NOT support fuzzy matching or typo tolerance in MVP (deferred — see [DECISIONS.md](DECISIONS.md) ADR-013) | Won't | ADR-013 |
| FR-5.8 | The search shall NOT support full-text search on product descriptions in MVP (only name/brand/category) | Won't | ADR-013 |

### 2.6 FR-6.0 — Reviews and Ratings

Per App-WatchHub.doc §Reviews and Ratings, users must be able to leave reviews and ratings for watches. Reviews are subject to admin moderation (FR-4.7) before public visibility.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-6.1 | The system shall allow an authenticated user to submit a review on a product: star rating (1-5), title, body text | Must | App-WatchHub.doc §Reviews |
| FR-6.2 | The system shall store reviews in Firestore `/reviews` collection with `status: 'pending'` by default | Must | App-WatchHub.doc §Reviews |
| FR-6.3 | The system shall prevent a user from submitting more than one review per product (one review per user per product) | Must | App-WatchHub.doc §Reviews |
| FR-6.4 | The system shall display approved reviews (`status: 'approved'`) on the product detail page | Must | App-WatchHub.doc §Reviews |
| FR-6.5 | The system shall calculate and display the average star rating per product (mean of approved reviews) | Must | App-WatchHub.doc §Reviews |
| FR-6.6 | The system shall allow sorting reviews by date (newest/oldest) and by rating (highest/lowest) | Must | App-WatchHub.doc §Reviews |
| FR-6.7 | The system shall allow filtering reviews by star rating (e.g., show only 5-star reviews) | Should | App-WatchHub.doc §Reviews |
| FR-6.8 | The system shall allow the review author to edit or delete their own review (within 24h of submission; status returns to `pending`) | Should | App-WatchHub.doc §Reviews |
| FR-6.9 | The system shall display a "Review submitted — pending moderation" confirmation to the user after submission | Must | App-WatchHub.doc §Reviews |
| FR-6.10 | The system shall NOT display the reviewer's email; only their `fullName` | Must | PII protection |
| FR-6.11 | The admin shall be able to approve, reject, or delete pending reviews via the admin dashboard (FR-4.7) | Must | App-WatchHub.doc §Admin Panel |

### 2.7 FR-7.0 — Customer Support

Per App-WatchHub.doc §Customer Support, users must be able to contact customer support. The spec allows "in-app chat OR contact form" — App-WatchHub implements the contact form option (simpler, sufficient for MVP; real-time chat deferred per [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5). The spec also requires an in-app FAQ section.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-7.1 | The system shall render a "Contact Support" page accessible from the customer navigation drawer | Must | App-WatchHub.doc §Customer Support |
| FR-7.2 | The system shall render a contact form: subject (dropdown), message body, optional order ID reference | Must | App-WatchHub.doc §Customer Support |
| FR-7.3 | The system shall persist submitted support tickets to Firestore `/supportTickets` collection with `status: 'open'` | Must | App-WatchHub.doc §Customer Support |
| FR-7.4 | The system shall display a confirmation message with ticket ID after submission | Must | App-WatchHub.doc §Customer Support |
| FR-7.5 | The system shall render an in-app FAQ page accessible from the customer navigation drawer and from the contact support page | Must | App-WatchHub.doc §Customer Support |
| FR-7.6 | The FAQ page shall render FAQs grouped by category (e.g., "Orders", "Shipping", "Account", "Payments") | Must | App-WatchHub.doc §Customer Support |
| FR-7.7 | The FAQ page shall support an in-page search to filter FAQs by keyword | Should | App-WatchHub.doc §Customer Support |
| FR-7.8 | The FAQ content shall be stored in Firestore `/faq` collection (admin-managed) | Must | App-WatchHub.doc §Customer Support |
| FR-7.9 | The admin shall be able to CRUD FAQ entries via the admin dashboard | Should | App-WatchHub.doc §Admin Panel |
| FR-7.10 | The system shall NOT implement real-time in-app chat in MVP (contact form is sufficient per spec) | Won't | ADR-015 |

### 2.8 FR-8.0 — Feedback and Issue Reporting

Per App-WatchHub.doc §Feedback and Reviews, users must be able to provide feedback and report issues directly from the app. This is distinct from customer support (FR-7) — feedback is product improvement input, not a support request.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-8.1 | The system shall render a "Report an Issue" / "Send Feedback" option in the customer navigation drawer | Must | App-WatchHub.doc §Feedback |
| FR-8.2 | The system shall render a feedback form: category (bug/suggestion/compliment/other), description, optional screenshot URL | Must | App-WatchHub.doc §Feedback |
| FR-8.3 | The system shall persist submitted feedback to Firestore `/feedback` collection with `status: 'new'` | Must | App-WatchHub.doc §Feedback |
| FR-8.4 | The system shall display a thank-you confirmation after submission | Must | App-WatchHub.doc §Feedback |
| FR-8.5 | The system shall allow anonymous feedback (unauthenticated users can submit) with an `isAnonymous: true` flag | Should | App-WatchHub.doc §Feedback |
| FR-8.6 | The admin shall be able to view and triage feedback via the admin dashboard (FR-4.12) | Must | App-WatchHub.doc §Admin Panel |
| FR-8.7 | The system shall NOT support file uploads in feedback (screenshot URL only — file storage OUT OF SCOPE per [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5) | Won't | ADR-003 |

### 2.9 FR-9.0 — User Profile, Addresses, and Order Tracking

Per App-WatchHub.doc §User Profiles, users must be able to manage personal information, shipping addresses, view order history, and track orders. The original FR-1.0 covered identity management; this FR covers the profile, address, and tracking aspects.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-9.1 | The system shall render a "My Profile" page accessible from the customer navigation drawer | Must | App-WatchHub.doc §User Profiles |
| FR-9.2 | The profile page shall display the user's `fullName`, `email` (read-only), and a list of shipping addresses | Must | App-WatchHub.doc §User Profiles |
| FR-9.3 | The system shall allow the user to add a shipping address: recipient name, street, city, state/province, postal code, country, phone | Must | App-WatchHub.doc §User Profiles |
| FR-9.4 | The system shall allow the user to edit and delete shipping addresses | Must | App-WatchHub.doc §User Profiles |
| FR-9.5 | The system shall allow the user to mark one address as "default" (used at checkout pre-fill) | Should | App-WatchHub.doc §User Profiles |
| FR-9.6 | The system shall persist addresses as `addresses[]` array embedded in the `/users/{uid}` document | Must | App-WatchHub.doc §User Profiles |
| FR-9.7 | The system shall enforce a maximum of 5 addresses per user | Should | UX constraint |
| FR-9.8 | The profile page shall render an "Order History" section listing past orders (most recent first) | Must | App-WatchHub.doc §User Profiles |
| FR-9.9 | The system shall render an "Order Tracking" page when a user taps an order in history | Must | App-WatchHub.doc §User Profiles |
| FR-9.10 | The order tracking page shall display: order ID, order date, current status, status timeline (Processing → Confirmed → Shipped → Delivered), items, totals | Must | App-WatchHub.doc §User Profiles |
| FR-9.11 | The order tracking page shall update in real-time when admin changes the order status (Firestore stream) | Must | App-WatchHub.doc §User Profiles |
| FR-9.12 | The system shall display estimated delivery date (calculated as `createdAt + 5 business days`) on the tracking page | Should | App-WatchHub.doc §User Profiles |

### 2.10 FR-10.0 — Product Detail Enhancements

Per App-WatchHub.doc §Product Details, the product detail page must include images, descriptions, specifications, prices, image zoom, and availability/stock info. Some of this was already covered in FR-2.0; this FR consolidates the detail-page-specific requirements.

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-10.1 | The product detail page shall display the product image with tap-to-zoom (Hero animation + InteractiveViewer) | Must | App-WatchHub.doc §Product Details |
| FR-10.2 | The product detail page shall display: `modelName`, `brand`, `category`, `price`, `stockCount`, `specs` map, description | Must | App-WatchHub.doc §Product Details |
| FR-10.3 | The product detail page shall display the average rating and review count (links to reviews section) | Must | App-WatchHub.doc §Product Details + §Reviews |
| FR-10.4 | The product detail page shall render an "Add to Cart" button (disabled if `stockCount == 0`) | Must | App-WatchHub.doc §Product Details |
| FR-10.5 | The product detail page shall render an "Add to Wishlist" toggle button | Must | App-WatchHub.doc §Wishlist |
| FR-10.6 | The product detail page shall render a reviews section showing approved reviews (FR-6.4) and a "Write a Review" button | Must | App-WatchHub.doc §Reviews |
| FR-10.7 | The product detail page shall display related products (same brand, excluding current) | Should | App-WatchHub.doc §Product Details |
| FR-10.8 | The product detail page shall display a "Report an Issue with this Product" link (routes to FR-8 feedback form pre-filled) | Should | App-WatchHub.doc §Feedback |

### 2.11 FR-11.0 — Admin Panel Extensions

Per App-WatchHub.doc §Admin Panel, the admin must manage product listings, user data, reviews, and orders. FR-4.0 covered the core admin panel; this FR adds management of the new collections (reviews, support tickets, feedback, FAQ, users).

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-11.1 | The admin dashboard shall render a review moderation queue (covered by FR-4.7) | Must | App-WatchHub.doc §Admin Panel |
| FR-11.2 | The admin dashboard shall render a support ticket queue (covered by FR-4.11) | Must | App-WatchHub.doc §Admin Panel |
| FR-11.3 | The admin dashboard shall render a feedback/issue triage queue (covered by FR-4.12) | Must | App-WatchHub.doc §Admin Panel |
| FR-11.4 | The admin dashboard shall render a user management table (covered by FR-4.13) | Should | App-WatchHub.doc §Admin Panel |
| FR-11.5 | The admin dashboard shall render a FAQ management page (CRUD — covered by FR-7.9) | Should | App-WatchHub.doc §Admin Panel |
| FR-11.6 | The admin dashboard shall render analytics: total users, total orders, total revenue, avg order value, top products | Should | App-WatchHub.doc §Admin Panel |
| FR-11.7 | The admin dashboard shall support filtering all tables by date range | Should | App-WatchHub.doc §Admin Panel |
| FR-11.8 | The admin shall be able to respond to support tickets (updates `status` and appends `adminResponse` to ticket) | Must | App-WatchHub.doc §Customer Support |

## 3. Non-Functional Requirements

Non-functional requirements specify quality attributes. Each NFR is paired with the architectural solution that satisfies it; full justification lives in [DECISIONS.md](DECISIONS.md).

| ID | Parameter | Target Metric / Constraint | Architectural Solution | Verification |
|---|---|---|---|---|
| **NFR-1** | Performance — Page Transition Latency | < 1.5 seconds (95th percentile) on Chrome desktop | Riverpod pre-fetching, local asset bundles, GoRouter declarative transitions | Firebase Performance Monitoring trace |
| **NFR-2** | Security — Unauthorized Mutations | Zero unauthorized mutations at data layer | Declarative Firebase Security Rules; no client-side trust | Security rules test suite (see [TESTING.md](TESTING.md)) |
| **NFR-3** | Availability — Uptime | 99.99% across deployments (best-effort on free tier) | Multi-region Firebase Hosting Edge; Firestore multi-region default | Firebase Status Dashboard |
| **NFR-4** | Budget — Operating Cost | $0.00 / month at steady state | Firebase Spark Free Tier; local asset bundles; no Cloud Functions | Firebase billing console |
| **NFR-5** | Performance — First Contentful Paint (Web) | < 2.0 seconds on Chrome desktop, cable connection | Flutter Web canvas renderer; deferred image hydration | Lighthouse audit |
| **NFR-6** | Performance — APK Size (Android) | < 25 MB release build | Asset compression, ProGuard/R8 minification, no large media in bundle | `flutter build apk --analyze-size` |
| **NFR-7** | Security — PII Storage | Email + fullName only; no payment data, no addresses beyond delivery city/country | Firestore schema enforces field whitelist; no `/payments` collection | Schema review in [DATABASE_DESIGN.md](DATABASE_DESIGN.md) |
| **NFR-8** | Maintainability — Documentation Coverage | 100% of `/docs/` files exist and contain no `TODO`/`PLACEHOLDER` | Documentation tree per [INDEX.md](INDEX.md) | `grep -r "TODO\|PLACEHOLDER" docs/` returns zero |
| **NFR-9** | Testability — Unit Test Coverage | >= 60% line coverage on `lib/core/` and `lib/features/` | Riverpod testability, repository abstraction | `flutter test --coverage` |
| **NFR-10** | Observability — Crash Reporting | 100% of uncaught exceptions logged | Firebase Crashlytics integrated in `main.dart` zone wrapper | Crashlytics dashboard |
| **NFR-11** | Observability — Product Analytics | Key events logged (sign_up, login, add_to_cart, place_order, admin_action) | Firebase Analytics wired through `AnalyticsService` | Analytics dashboard |
| **NFR-12** | Compatibility — Browser Support | Chrome 120+, Safari 17+, Edge 120+, Firefox 121+ | Flutter Web default targets; no legacy polyfills | Manual smoke test |
| **NFR-13** | Compatibility — Android | Android 10 (API 29) and above | Flutter `minSdkVersion` = 29 | Build configuration |
| **NFR-14** | Accessibility — Color Contrast | WCAG AA compliance (4.5:1 body, 3:1 large text) | Dark theme palette validated against contrast checker | Automated `flutter test` accessibility pass |
| **NFR-15** | Internationalization — Locale | English (`en_US`) only for MVP | Flutter `intl` wired; single-message arb file | `gen_l10n` output |

## 4. User Stories

User stories follow the Connextra format: *As a `<role>`, I want `<capability>`, so that `<value>`.* Each story maps to one or more functional requirements.

### 4.1 Customer Stories

| Story ID | Story | Maps to FR | Acceptance Criterion |
|---|---|---|---|
| US-1 | As a Collector, I want to register an account with my email, so that I can persist my cart and order history across sessions | FR-1.1, FR-1.4 | Registration succeeds; `/users/{uid}` document exists post-signup |
| US-2 | As a Collector, I want to log in with biometric-free email/password, so that I can access my account from any device | FR-1.3 | Login succeeds; ID token issued; session persists across restart |
| US-3 | As a Collector, I want to filter watches by brand, so that I can compare models from houses I trust | FR-2.2 | Multi-select brand filter narrows catalog in real-time |
| US-4 | As a Collector, I want to see only watches in stock, so that I do not fall in love with a piece I cannot buy | FR-2.5 | Availability filter excludes `stockCount == 0` items |
| US-5 | As a Collector, I want to add a watch to my wishlist without committing to purchase, so that I can revisit it later | FR-3.7, FR-3.10 | Wishlist persists across app restarts |
| US-6 | As a Collector, I want to move an item from wishlist to cart in one tap, so that checkout friction is minimized | FR-3.8 | Tap moves item; cart subtotal recalculates |
| US-7 | As a Collector, I want to place an order and see a confirmation, so that I have confidence my purchase was recorded | FR-3.11, [DATABASE_DESIGN.md](DATABASE_DESIGN.md) `/orders` | Order document created in Firestore; cart cleared; receipt screen shown |
| US-8 | As a Collector, I want to recover my password if I forget it, so that I am not locked out of my account permanently | FR-1.6 | Reset email arrives within 60 seconds |

### 4.2 Admin Stories

| Story ID | Story | Maps to FR | Acceptance Criterion |
|---|---|---|---|
| US-9 | As a Curator, I want to see today's orders at a glance, so that I can prioritize fulfillment | FR-4.4, FR-4.6 | Admin dashboard renders order count and revenue for current day |
| US-10 | As a Curator, I want to add a new product to the catalog, so that new inventory is visible to customers immediately | FR-4.5 | Product creation form persists document to `/products`; catalog stream updates |
| US-11 | As a Curator, I want to update stock counts after in-store sales, so that digital customers see accurate availability | FR-4.5 | Stock edit persists; catalog `inStock` badge updates for customers in real-time |
| US-12 | As a Curator, I want to change an order's status (Processing → Shipped → Delivered), so that the customer has visibility into fulfillment | FR-4.6 | Order status update persists; customer's order history reflects new status |
| US-13 | As a Curator, I want non-admins to be unable to access the admin panel, so that I have confidence in the system's integrity | FR-4.2, FR-4.3, FR-4.8 | Manual attempt to navigate to `/admin` as non-admin redirects to `/boutique`; direct Firestore write blocked by rules |

## 5. Acceptance Criteria

Each user story has a corresponding acceptance criterion (column above). The full set of acceptance criteria forms the manual QA checklist in [TESTING.md](TESTING.md) § Manual QA. A story is considered "done" when:

1. Its acceptance criterion passes manual verification.
2. Its underlying FR sub-requirements pass automated tests where applicable.
3. The implementation has been code-reviewed against [STYLE_GUIDE.md](STYLE_GUIDE.md).
4. The implementation is covered by at least one widget or integration test.
5. The implementation is documented (if it changes behavior visible to users or admins).

## 6. Requirements Traceability Matrix

| Feature (PROJECT_SCOPE) | FR | NFR | User Story | Test | Doc Reference |
|---|---|---|---|---|---|
| F-1 Identity | FR-1.1–1.10 | NFR-2, NFR-7, NFR-12, NFR-13 | US-1, US-2, US-8 | [TESTING.md](TESTING.md) § Auth | [SECURITY.md](SECURITY.md) |
| F-2 Catalog | FR-2.1–2.10 | NFR-1, NFR-5 | US-3, US-4 | [TESTING.md](TESTING.md) § Catalog | [DATABASE_DESIGN.md](DATABASE_DESIGN.md) |
| F-3 Cart & Wishlist | FR-3.1–3.12 | NFR-1, NFR-9 | US-5, US-6, US-7 | [TESTING.md](TESTING.md) § Cart | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) § Cart State |
| F-4 Admin | FR-4.1–4.10 | NFR-2, NFR-7 | US-9, US-10, US-11, US-12, US-13 | [TESTING.md](TESTING.md) § Admin | [SECURITY.md](SECURITY.md) § Rules |
| F-5 Design System | (cross-cutting) | NFR-1, NFR-5, NFR-14 | (cross-cutting) | [TESTING.md](TESTING.md) § Theme | [STYLE_GUIDE.md](STYLE_GUIDE.md) |
| F-6 Routing | FR-4.1–4.3 | NFR-1 | US-13 | [TESTING.md](TESTING.md) § Routing | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) § Router |
| F-7 Cross-Platform | (cross-cutting) | NFR-3, NFR-5, NFR-6, NFR-12, NFR-13 | (cross-cutting) | [TESTING.md](TESTING.md) § Platform | [DEPLOYMENT.md](DEPLOYMENT.md) |
| F-8 Edge Security | (cross-cutting) | NFR-2, NFR-7 | US-13 | [TESTING.md](TESTING.md) § Rules Tests | [SECURITY.md](SECURITY.md) |
| F-9 CI/CD | (cross-cutting) | NFR-8 | (cross-cutting) | [TESTING.md](TESTING.md) § CI | [DEPLOYMENT.md](DEPLOYMENT.md) |
| F-10 Telemetry | (cross-cutting) | NFR-10, NFR-11 | (cross-cutting) | [TESTING.md](TESTING.md) § Telemetry | [CONFIGURATION.md](CONFIGURATION.md) |

## 7. References

- Source SDD v1.0.0 § 2 (Functional & Non-Functional Requirements)
- Internal: [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [SECURITY.md](SECURITY.md), [TESTING.md](TESTING.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md)
- External: [Firebase Authentication docs](https://firebase.google.com/docs/auth), [Cloud Firestore query docs](https://firebase.google.com/docs/firestore/query-data/get-data), [Flutter testing docs](https://docs.flutter.dev/testing)
