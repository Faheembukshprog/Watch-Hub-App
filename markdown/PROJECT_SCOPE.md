# Project Scope

> Canonical definition of what App-WatchHub is, what it is not, and how success will be measured. Every other document in this tree derives its scope from this file.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Project Scope |
| **Purpose** | Define project vision, problem, goals, in-scope features, explicit exclusions, and success criteria |
| **Audience** | All stakeholders — academic reviewers, recruiters, contributors, AI agents |
| **Scope** | Project boundary definition only; requirements detail in [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) |
| **Version** | 1.1.0 |
| **Status** | Approved — reconciled with official eProject Specification (`App-WatchHub.doc`) |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) — on behalf of 6-person team |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [README.md](../README.md), [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md), [ROADMAP.md](ROADMAP.md), [DECISIONS.md](DECISIONS.md), [RISKS.md](RISKS.md) |

---

## Table of Contents

1. [Project Vision](#1-project-vision)
2. [Problem Statement](#2-problem-statement)
3. [Business Goals & Value Proposition](#3-business-goals--value-proposition)
4. [In-Scope Features (MVP)](#4-in-scope-features-mvp)
5. [Out-of-Scope Exclusions](#5-out-of-scope-exclusions)
6. [Constraints & Assumptions](#6-constraints--assumptions)
7. [Success Criteria](#7-success-criteria)
8. [Stakeholders](#8-stakeholders)
9. [References](#9-references)

---

## 1. Project Vision

**App-WatchHub** is an enterprise-grade, high-fidelity e-commerce client ecosystem designed specifically for the premium luxury horology market. By dropping traditional, resource-heavy middleware in favor of a modern **Serverless Event-Driven Architecture (SEDA)**, the platform balances rich client-side rendering with zero-cost cloud services. The frontend is built on a single, cross-platform Flutter codebase targeting both desktop-class web presentation shells and native mobile execution packages.

The vision is to demonstrate that a senior-grade product experience — the kind of polish a buyer expects from Rolex, Patek Philippe, or Audemars Piguet's own digital flagships — can be delivered by a 6-person student team on a $0 infrastructure budget inside a 30-day window. The project is therefore not just an e-commerce app; it is a proof-of-concept that modern serverless platforms, combined with disciplined architecture and aggressive cost engineering, can collapse the cost structure of premium software delivery. The team context is documented in [CONTRIBUTING.md](../CONTRIBUTING.md) § Team Structure.

The vision explicitly rejects the "move fast and ship sloppy" trope. Every architectural choice is documented as an Architecture Decision Record in [DECISIONS.md](DECISIONS.md). Every gap in the source specification is marked `UNKNOWN`, `REQUIRES DECISION`, or `OUT OF SCOPE` — never silently fabricated. The documentation itself is part of the deliverable and is graded alongside the running application.

## 2. Problem Statement

The high-end timepiece market requires a digital flagship experience characterized by minimalist aesthetics, high typographical legibility, and near-zero latency execution. Traditional web-retail platforms introduce structural bottlenecks via heavy multi-tier server hops, slow SQL relational queries, and unoptimized cloud storage network requests. These bottlenecks manifest as perceptible page-transition latency, layout shift during media hydration, and inconsistent theming across customer and admin journeys — all of which corrode the perceived premium quality that luxury buyers expect.

Compounding the technical problem is a cost problem. A traditional three-tier stack (load balancer, API server, SQL database) requires continuous provisioning even when traffic is zero. For a solo developer building a portfolio piece or an MVP, this means either absorbing monthly cloud costs during the development phase or accepting that the deployed artifact will be torn down the moment the academic evaluation period ends. Neither outcome supports the project's goal of producing a long-lived, demonstrable artifact that survives years past the graduation date.

App-WatchHub resolves these issues by utilizing pre-compiled cross-platform native bundles, localized resource caching, and edge-computed security guards. The Flutter client renders the entire UI; Firebase Authentication and Cloud Firestore handle identity and data; Firestore Security Rules enforce authorization at the database edge without a custom API server; and all media assets are bundled locally to eliminate storage-network latency and billing. The result is a system whose marginal cost of operation is exactly zero and whose first-paint latency is bounded by client compute, not network round-trips.

## 3. Business Goals & Value Proposition

The business goals are deliberately constrained to what a 30-day MVP can deliver while still being demonstrably enterprise-grade:

- **Rapid Market Penetration.** Deploy a minimum viable product (MVP) targeting high-net-worth watch consumers within a compressed 30-day lifecycle. The MVP must be live on Firebase Hosting and recorded as a demonstration video by August 14, 2026.
- **Zero Operational Overhead.** Leverage a fully managed, serverless backend to eliminate infrastructure maintenance, database scaling locks, and server provisioning costs. The system must remain runnable at $0/month indefinitely post-deployment.
- **High Engagement Conversions.** Utilize premium micro-animations, glassmorphism UI structures, and zero-latency local asset caching to optimize user retention and conversion pathways. Conversion is defined as a completed checkout flow (cart → order placement), not as a paid transaction — see §5 for the payment exclusion rationale.
- **Demonstrable Engineering Maturity.** Produce a codebase and documentation set that a hiring manager can audit in under 15 minutes and conclude that the author understands architecture, security, testing, CI/CD, and documentation discipline at a mid-to-senior level.

The value proposition to the user (the luxury watch buyer persona) is a digital boutique that feels like the brands it sells: dark, restrained, gold-accented, fast, and quiet. The value proposition to the reviewer (recruiter or academic) is a project that exemplifies modern engineering practice without hiding behind the "we'll fix it in v2" excuse.

## 4. In-Scope Features (MVP)

The features below are derived from the official eProject Specification (`App-WatchHub.doc`) provided by the academic institution. **Every feature in the specification is IN SCOPE** — none may be deferred without an explicit ADR justifying the deferral and a documented trade-off.

| ID | Feature | Description | Source |
|---|---|---|---|
| F-1 | Identity Management | Email/password registration, login, logout, password recovery, profile update | App-WatchHub.doc §User Authentication |
| F-2 | Dynamic Catalog Discovery | Luxury watch collections categorized by brand, type, price range; filtering by price/brand/popularity; **search feature** | App-WatchHub.doc §Browse Watches, §Search and Filters |
| F-3 | Product Details | Detailed product pages with images, descriptions, specifications, prices, image zoom, availability/stock info | App-WatchHub.doc §Product Details |
| F-4 | Persisted Cart & Wishlist | Active checkout sessions with line-item aggregates, tax evaluation, wishlist ↔ cart shifts | App-WatchHub.doc §Shopping Cart, §Wishlist |
| F-5 | User Profile & Shipping Addresses | Personal info management, **shipping addresses** (multiple), order history, **order tracking** | App-WatchHub.doc §User Profiles |
| F-6 | Reviews & Ratings | Customers can **leave reviews and ratings** for products; sort/filter reviews by helpfulness and date; admin moderation | App-WatchHub.doc §Reviews and Ratings |
| F-7 | Customer Support | **In-app contact form** (or chat) for support; **in-app FAQ section** | App-WatchHub.doc §Customer Support |
| F-8 | Feedback & Issue Reporting | Users can **provide feedback and report issues** directly from the app | App-WatchHub.doc §Feedback and Reviews |
| F-9 | Unified Admin Governance Panel | Admin-only dashboards for product CRUD, user management, review moderation, order management | App-WatchHub.doc §Admin Panel |
| F-10 | Luxury Design System | Dark theme, Playfair Display + Inter typography, gold accents, glassmorphism surfaces; intuitive, accessible UI | App-WatchHub.doc NFRs |
| F-11 | Role-Based Routing | GoRouter guards redirect `isAdmin: true` to admin panel, others to boutique | (derived from F-9) |
| F-12 | Cross-Platform Delivery | Single Flutter codebase shipping to Web (Firebase Hosting) and Android (APK) | (architectural) |
| F-13 | Edge Security | Firestore Security Rules enforce all authz; no custom backend | (architectural) |
| F-14 | CI/CD Pipeline | GitHub Actions: lint, test, build, deploy on every push to `main` | (inferred — free-tier enterprise feature) |
| F-15 | Crash & Analytics Telemetry | Firebase Crashlytics + Analytics wired for post-deploy observability | (inferred — free-tier enterprise feature) |
| F-16 | User Documentation | In-app user guide, FAQ page, onboarding tooltips | App-WatchHub.doc NFR §User Documentation |
| F-17 | Developer Documentation | This `/docs/` tree + Developer's Guide section of eProject Report | App-WatchHub.doc NFR §Developer Documentation |
| F-18 | Demonstration Video | 5-10 minute video showing complete working of the application | App-WatchHub.doc NFR §Video |

### 4.1 Scope Reconciliation Note (v1.1.0)

This scope was reconciled on 2026-07-15 against the official `App-WatchHub.doc` specification. The previous v1.0.0 of this document marked several features as `OUT OF SCOPE` that the official spec requires. The following features were **moved from OUT OF SCOPE to IN SCOPE**:

| Feature | Previous Status (v1.0.0) | New Status (v1.1.0) | Reason |
|---|---|---|---|
| Full-text search | OUT OF SCOPE (Algolia paid) | IN SCOPE (client-side filtering — see [DECISIONS.md](DECISIONS.md) ADR-013) | App-WatchHub.doc §Search and Filters requires it |
| Customer review submission | Deferred to v1.1 | IN SCOPE (MVP) | App-WatchHub.doc §Reviews and Ratings requires it |
| Customer support contact form | Not documented | IN SCOPE (MVP) | App-WatchHub.doc §Customer Support requires it |
| In-app FAQ section | Not documented (only docs/FAQ.md existed) | IN SCOPE (MVP) | App-WatchHub.doc §Customer Support requires it |
| Feedback / issue reporting | Not documented | IN SCOPE (MVP) | App-WatchHub.doc §Feedback and Reviews requires it |
| Order tracking UI | Not documented (only order history) | IN SCOPE (MVP) | App-WatchHub.doc §User Profiles requires it |
| Shipping addresses | NOT COLLECTED (PII) | IN SCOPE (MVP) — collected as `addresses[]` in user profile | App-WatchHub.doc §User Profiles requires it |

## 5. Out-of-Scope Exclusions

The following items are explicitly **OUT OF SCOPE** for the MVP cycle. They are listed here to prevent scope creep and to give reviewers an honest accounting of what the project does not claim to deliver.

> **IMPORTANT** — Per the v1.1.0 reconciliation, features required by the official `App-WatchHub.doc` specification are NO LONGER listed here. Only features that the specification does NOT require (or that violate hard constraints) remain out of scope.

| Exclusion | Rationale | Re-evaluation Trigger |
|---|---|---|
| **Payment Gateway Integration (Stripe, PayPal, etc.)** | The official spec does not require payment processing — it requires order placement and order tracking, both of which work without payment capture. Payment processors charge per-transaction fees and require KYC/PCI compliance incompatible with $0 budget. Checkout terminates at order placement as a non-binding intent. | Post-MVP if a paid pilot is authorized. |
| **Push Notifications (FCM)** | Official spec does not require push notifications. Order status is visible in-app via the orders page. | v1.1 — see [ROADMAP.md](ROADMAP.md). |
| **Multi-Currency Support** | Official spec does not require multi-currency. Pricing is USD-only. FX conversion would require a daily-rate source (paid API). | v1.2 — international expansion phase. |
| **Order Cancellation / Refund Workflow** | Without payments, refunds are meaningless. Admins can update `orderStatus` (including `Cancelled`) but no automated refund logic exists. | Tied to payment integration. |
| **Wishlist Persistence Across Devices** | Official spec requires wishlist but does not require cross-device sync. Wishlist is local to the authenticated session via Hive. | v1.2. |
| **SSO / OAuth (Google, Apple)** | Official spec requires authentication but does not require OAuth specifically. Email/password is sufficient. | v1.1. |
| **Internationalization (i18n) / Localization (l10n)** | Official spec does not require multi-language support. English-only for MVP. | v1.2. |
| **Server-Side Rendering (SSR) for SEO** | Official spec does not require SEO. Flutter Web renders client-side. | If a public marketing landing page is added. |
| **A/B Testing Infrastructure** | Official spec does not require A/B testing. | Post-MVP growth phase. |
| **Rate Limiting / DDoS Protection** | Official spec does not require custom rate limiting. Firebase Spark Tier includes built-in abuse protections. | If abuse is observed in production. |
| **Custom Backend / API Server** | Architectural exclusion — see [DECISIONS.md](DECISIONS.md) ADR-001. | Out of scope indefinitely. |
| **In-app Chat (real-time messaging)** | Official spec allows "in-app chat OR contact form" — App-WatchHub implements the contact form option (simpler, sufficient for MVP). Real-time chat would require WebSocket infrastructure. | v1.2. |

If a stakeholder requests any of the above during the MVP cycle, the request must be filed in [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) and triaged against the 30-day timeline and $0 budget.

## 6. Constraints & Assumptions

### 6.1 Hard Constraints

| ID | Constraint | Source |
|---|---|---|
| C-1 | Total infrastructure cost must not exceed $0.00/month at steady state | Project brief |
| C-2 | Development timeline must not exceed 30 calendar days (July 14 – August 14, 2026) | Welcome email |
| C-3 | Team project — 6 student contributors; work must be parallelizable via feature branches | Welcome email |
| C-4 | Cross-platform delivery must use a single Flutter codebase (no native rewrite for Android) | Project brief |
| C-5 | Backend must be Firebase Spark Free Tier — no Cloud Functions, no paid Firebase extensions | Budget |
| C-6 | All authz must be enforced by Firestore Security Rules — no custom API layer | Architecture |
| C-7 | **All features in `App-WatchHub.doc` must be implemented** — no feature may be deferred without an ADR | Official spec |

### 6.2 Working Assumptions

These assumptions are inferred where the source SDD is silent. They are documented here so they can be challenged during review. Any assumption that proves false must be escalated to [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md).

| ID | Assumption | Risk if False |
|---|---|---|
| A-1 | Catalog size will not exceed 50 SKUs during MVP | Filter UX may need pagination |
| A-2 | Concurrent users will not exceed 50 during demo | Firestore Spark Tier connection limits (1M reads/month, 200K writes/day) are sufficient |
| A-3 | Product images are pre-optimized PNG/WebP under 200KB each | Local bundle size could bloat APK/web binary |
| A-4 | All product metadata is entered manually by the admin via the admin panel | No bulk-import feature required |
| A-5 | Tax calculation is a flat percentage (rate `UNKNOWN` — see [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) Q-1) | Tax engine complexity could escalate |
| A-6 | Users will use modern browsers (Chrome 120+, Safari 17+, Edge 120+) and Android 10+ | No legacy compatibility shims required |
| A-7 | Demo video will be recorded on a single device (Android or Chrome) | No multi-device demonstration script needed |
| A-8 | Team members have Flutter/Dart baseline competency | Onboarding overhead; mitigated by [STYLE_GUIDE.md](STYLE_GUIDE.md) |
| A-9 | Client-side search on ~50 SKUs is performant (sub-100ms) | May need Firestore `where`-based pre-filtering |
| A-10 | Reviews volume per product stays under 100 for MVP | May need pagination for high-volume products |

## 7. Success Criteria

Success is defined by measurable, observable outcomes — not by feature completion alone. The MVP is considered successful if and only if all of the following are true by August 14, 2026.

| Criterion | Measurement | Verification |
|---|---|---|
| SC-1 | Application is live at a public Firebase Hosting URL | URL returns HTTP 200 with the boutique shell rendered |
| SC-2 | All four FR-1.0 through FR-4.0 flows work end-to-end | Manual QA checklist in [TESTING.md](TESTING.md) § Manual QA passes 100% |
| SC-3 | Admin role bypass works correctly | Login as `isAdmin: true` lands on admin dashboard; login as `false` lands on boutique |
| SC-4 | Firestore Security Rules reject all unauthorized mutations | Security rules test suite in [TESTING.md](TESTING.md) § Rules Tests passes 100% |
| SC-5 | Total monthly infrastructure cost = $0.00 | Firebase Console billing page shows $0.00 across all services |
| SC-6 | Page transition latency < 1.5 seconds on Chrome desktop | Firebase Performance Monitoring trace confirms |
| SC-7 | GitHub Actions CI pipeline runs green on `main` | Latest workflow run status is `success` |
| SC-8 | Demonstration video (5–10 minutes) recorded and uploaded | Video file exists in repository or linked cloud storage |
| SC-9 | Documentation tree is complete (all files in [INDEX.md](INDEX.md) exist and are non-stub) | `find docs/ -name "*.md" | wc -l` >= 20; no file contains `TODO` or `PLACEHOLDER` |
| SC-10 | No `UNKNOWN` markers remain in requirements-critical docs (PROJECT_SCOPE, PRODUCT_REQUIREMENTS, SECURITY) | `grep -r UNKNOWN docs/PROJECT_SCOPE.md docs/PRODUCT_REQUIREMENTS.md docs/SECURITY.md` returns zero hits |

SC-10 is the most aggressive criterion: it forces every ambiguity to be resolved or explicitly converted to an ADR-justified `OUT OF SCOPE` before the project is declared complete.

## 8. Stakeholders

| Stakeholder | Role | Interest |
|---|---|---|
| Muhammad Faheem Khan | Author, sole developer, architect | Project delivery, academic credit, portfolio value |
| Academic Review Board | Reviewer / Approver | Compliance with SDD rubric, demonstration of competence |
| Hiring Managers (future) | Recruiters | Engineering judgment, documentation discipline |
| Future Maintainers (post-MVP) | Contributors | Onboarding speed, code clarity, decision traceability |
| AI Coding Agents | Automated assistants | Documentation readability for machine understanding |

## 9. References

- Source SDD v1.0.0 (Muhammad Faheem Khan, July 14, 2026) — internal academic submission
- [Firebase Spark Plan quotas](https://firebase.google.com/pricing) — referenced for budget verification
- [Flutter 4.x documentation](https://docs.flutter.dev) — referenced for cross-platform claims
- [Cloud Firestore Security Rules reference](https://firebase.google.com/docs/firestore/security/rules-structure)
- Internal cross-references: [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md), [ROADMAP.md](ROADMAP.md), [DECISIONS.md](DECISIONS.md), [RISKS.md](RISKS.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md)
