# FAQ

> Anticipated questions from recruiters, academic reviewers, and contributors. Each answer is concise and cross-references the relevant documentation for depth.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Frequently Asked Questions |
| **Purpose** | Answer anticipated questions about the project's design, scope, and trade-offs |
| **Audience** | Recruiters, academic reviewers, contributors, AI coding agents |
| **Scope** | Q&A only; technical details in cross-referenced docs |
| **Version** | 1.0.0 |
| **Status** | Active — updated when new frequently-asked questions emerge |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [GLOSSARY.md](GLOSSARY.md), [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [DECISIONS.md](DECISIONS.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) |

---

## Table of Contents

1. [Architecture & Design Questions](#1-architecture--design-questions)
2. [Scope & Trade-off Questions](#2-scope--trade-off-questions)
3. [Security Questions](#3-security-questions)
4. [Cost & Budget Questions](#4-cost--budget-questions)
5. [Technical Implementation Questions](#5-technical-implementation-questions)
6. [Process & Timeline Questions](#6-process--timeline-questions)
7. [Post-MVP & Future Questions](#7-post-mvp--future-questions)
8. [References](#8-references)

---

## 1. Architecture & Design Questions

### Q: Why did you choose a Serverless Event-Driven Architecture over a traditional REST API?

**A:** Three constraints drove the choice: a $0 budget cap, a 30-day timeline, and a solo developer. A traditional REST API requires a server (provisioning cost, ops overhead), API design and implementation time (7-10 days of the 30-day budget), and adds a new failure mode. Firebase's managed services give me authentication, real-time data, and CDN distribution without provisioning anything. The trade-off is that complex business logic must live in the client, which I accepted for MVP-grade workflows like cart calculation. Full rationale in [DECISIONS.md](DECISIONS.md) ADR-001.

### Q: Why Flutter instead of React Native or native development?

**A:** Flutter's single-codebase approach to Web + Android was the deciding factor. React Native's web support is less mature than Flutter's, and native development (Kotlin + React) would have doubled the implementation effort infeasibly within 30 days solo. Flutter also has first-class Firebase integration, compile-time type safety via Dart, and excellent performance on both targets. Full rationale in [DECISIONS.md](DECISIONS.md) ADR-011.

### Q: Why Riverpod instead of BLoC or Provider?

**A:** Riverpod gives me compile-time safety (provider references verified at compile time, not runtime), built-in `AsyncValue` for loading/error/data states (no boilerplate), excellent testability (override providers with mocks), and dependency injection built-in. BLoC has too much boilerplate (separate Bloc, Event, State classes per feature) for a solo MVP. Provider lacks compile-time safety. Full rationale in [DECISIONS.md](DECISIONS.md) ADR-004.

### Q: Why GoRouter instead of Navigator 2.0 directly?

**A:** Navigator 2.0 is powerful but notoriously complex — direct use would consume 3-5 days just for setup. GoRouter provides a declarative route table (compile-time verifiable), built-in web deep-linking, and built-in redirect guards (perfect for role-based authz). It's also endorsed by the Flutter team. Full rationale in [DECISIONS.md](DECISIONS.md) ADR-005.

### Q: Why a dual data model (academic ERD + production NoSQL)?

**A:** The academic rubric expects a relational ERD demonstrating normalization knowledge; the production implementation uses NoSQL for $0 budget and real-time streams. Maintaining both proves I know when to break normalization rules for performance and cost. The mapping between them is bijective for MVP scope. Full rationale in [DECISIONS.md](DECISIONS.md) ADR-007.

## 2. Scope & Trade-off Questions

### Q: Why is there no payment integration?

**A:** Payment integration (Stripe, PayPal) introduces per-transaction fees (violates the $0 budget), PCI DSS compliance scope, KYC requirements for the merchant account, and 5-7 days of implementation effort. For an academic MVP demonstrating architecture and UX competence, payment is not essential — the checkout flow terminates at order placement as a non-binding intent. This is documented in [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 and [DECISIONS.md](DECISIONS.md) ADR-010. A clearly visible callout on the checkout page informs users that no payment will be processed.

### Q: Why no push notifications?

**A:** Push notifications (via Firebase Cloud Messaging) add operational complexity — token lifecycle management, permission flows, opt-in UX — without proportional MVP value. Order status updates can be observed by the customer opening the orders page. FCM is deferred to v1.1. See [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5.

### Q: Why USD-only? Why no multi-currency?

**A:** Multi-currency support requires a daily FX rate source, which is either a paid API (violates $0 budget) or a self-hosted scraper (adds ops overhead). For an academic MVP, USD-only is sufficient. Multi-currency is deferred to v1.2 international expansion. See [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5.

### Q: Why no full-text search?

**A:** The MVP catalog is small (12-50 SKUs per assumption A-1 in [PROJECT_SCOPE.md](PROJECT_SCOPE.md)). Filter chips are sufficient for discovery at that scale. Full-text search requires Algolia (paid) or Elastic App Search (paid), both of which violate the $0 budget. Deferred until the catalog exceeds 200 SKUs. See [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5.

### Q: Why is the cart local-only (Hive) instead of synced via Firestore?

**A:** Cart writes are frequent (add, update, remove) and would consume Firestore's daily write quota rapidly. Cart data does not need cross-device sync for MVP (assumption A-7). Local storage gives instant updates, zero cost, and offline-first behavior. Cross-device cart sync is deferred to v1.2. Full rationale in [DECISIONS.md](DECISIONS.md) ADR-008.

### Q: Why no email verification on signup?

**A:** Email verification adds friction to the demo flow without proportional value for academic evaluation. Accepted for MVP; deferred to v1.1 with security implications noted in [SECURITY.md](SECURITY.md) §5.3. See [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-1.10.

## 3. Security Questions

### Q: How do you prevent a user from escalating themselves to admin?

**A:** The Firestore Security Rule blocks any client write to the `isAdmin` field. The rule `request.resource.data.isAdmin == resource.data.isAdmin` on the owner-update path ensures the value cannot change. The first admin must be bootstrapped manually via the Firebase Console (server-side). See [SECURITY.md](SECURITY.md) §3 Admin Bootstrap and §4.1 the rules.

### Q: How can you trust the client if all the code is visible to the user?

**A:** The client is untrusted by design. Any authorization decision in the client (e.g., GoRouter redirecting non-admins away from `/admin`) is UX-only — it provides a good user experience. The authoritative authorization happens at the data layer via Firestore Security Rules. A user who patches the client to skip route guards still cannot read or write protected data because the rules independently reject every unauthorized request. See [SECURITY.md](SECURITY.md) §1 Trust Model.

### Q: What happens if someone discovers a vulnerability in the rules?

**A:** The rules are tested with a comprehensive rules test suite that runs on every push to GitHub. The tests cover positive cases (rule allows intended operation) and negative cases (rule rejects unauthorized operation). If a vulnerability is discovered, the fix is a rule change with a corresponding test. The CI pipeline prevents regressions. See [TESTING.md](TESTING.md) §7.

### Q: How do you handle GDPR right-to-erasure?

**A:** For MVP, erasure is manual: an admin deletes the user's `/users/{uid}` document and the Firebase Auth account via the Console. Cart data (Hive local) is destroyed on app uninstall. Automated erasure workflow is deferred to post-MVP — it requires a Cloud Function to cascade-delete `/orders` documents, which is OUT OF SCOPE due to the Spark Free Tier (no Cloud Functions). See [SECURITY.md](SECURITY.md) §7.2.

### Q: Do you log PII to Crashlytics?

**A:** For MVP, yes — accepted as a documented risk. Crashlytics captures exception stack traces, which may include variables containing PII (e.g., `user.email`). The MVP has no real users, so PII in crash logs is the author's own test data. This will be revisited before public launch — see [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) Q-20.

## 4. Cost & Budget Questions

### Q: How can the project truly cost $0?

**A:** All services used are on the Firebase Spark Free Tier, which has generous daily quotas (50K Firestore reads, 20K writes, 360MB Hosting bandwidth). The expected MVP traffic (academic reviewer + recruiter visits, single-user demo) is far below these limits. GitHub Actions is free for public repos. No paid services (Stripe, Algolia, Cloudinary, Sentry paid tier) are used. See [DEPENDENCIES.md](DEPENDENCIES.md) §5 for the full budget audit.

### Q: What happens if you exceed a Firebase quota?

**A:** Operations fail with `RESOURCE_EXHAUSTED` errors until midnight Pacific time, when quotas reset. For the demo, this is unlikely (single-user traffic). If it happens, wait for reset and retry. See [RISKS.md](RISKS.md) R-1 and [TROUBLESHOOTING.md](TROUBLESHOOTING.md) §4.2.

### Q: Will it stay $0 forever?

**A:** Yes, as long as traffic stays within Spark Tier limits. Post-MVP growth (real customers, higher traffic) may require upgrading to Blaze tier — but that's a business decision tied to revenue, not a technical limitation. See [DECISIONS.md](DECISIONS.md) ADR-012.

### Q: What's the catch with the Spark Free Tier?

**A:** The main limitations are: (1) no Cloud Functions (no server-side business logic), (2) no automated Firestore backups (disaster recovery is manual), (3) daily quota limits, (4) no Firebase Extensions that require Blaze. These are all accepted constraints for MVP. See [DECISIONS.md](DECISIONS.md) ADR-012.

## 5. Technical Implementation Questions

### Q: How does the catalog update in real-time?

**A:** The Flutter client subscribes to a Firestore `snapshots()` stream on the `/products` collection. Every change to any product document (admin edits stock, adds a product, deletes a product) emits a new snapshot, which the Riverpod `StreamProvider` converts to `AsyncData` and the UI re-renders. No polling, no refresh button. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §8.

### Q: How does the cart persist across app restarts?

**A:** Cart state is held in Riverpod and persisted to Hive local storage on every mutation. On app start, the cart provider's `build()` method reads from Hive and populates the in-memory state. Hive is a lightweight key-value store that survives app restarts. The cart is NOT synced to Firestore — see [DECISIONS.md](DECISIONS.md) ADR-008.

### Q: How do you handle offline mode?

**A:** Firestore SDK has built-in offline cache — documents read while online are available offline. Writes are queued locally and synced when connectivity returns. Cart (Hive) is always available offline. The catalog renders the last-seen state when offline. Order placement requires online connectivity (decided in [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md) Q-16).

### Q: Why is the admin dashboard stats calculation client-side?

**A:** Cloud Functions (which would be the natural place for server-side aggregation) are OUT OF SCOPE on the Spark Free Tier. The admin dashboard queries the `/orders` collection and aggregates client-side. For MVP volume (dozens of orders), this is performant. Post-MVP, this should move to a Cloud Function. See [API_REFERENCE.md](API_REFERENCE.md) §5.5.

### Q: How do you test security rules?

**A:** Using the `@firebase/rules-unit-testing` npm package, which spins up a Firestore Emulator instance and runs mocha tests. Each rule has a positive test (rule allows intended operation) and a negative test (rule rejects unauthorized operation). The test suite runs in CI on every push. See [TESTING.md](TESTING.md) §7.

## 6. Process & Timeline Questions

### Q: How did you plan the 30-day timeline?

**A:** Four one-week sprints, each with a single thematic objective: Week 1 = Groundwork (project skeleton, Firebase, CI/CD), Week 2 = Core UX (auth, catalog, cart), Week 3 = Admin Dev (dashboard, inventory, orders), Week 4 = Production (testing, deploy, docs, demo video). Each sprint ends with a milestone gate; if missed, pre-identified descope candidates are deferred. See [ROADMAP.md](ROADMAP.md).

### Q: What if you miss a milestone gate?

**A:** Each gate has pre-identified descope candidates. For example, if Gate 2 (end of Week 2) is missed, filter chips are descoped to single-filter only. The timeline is locked at 30 days — the response to overrun is descope, not extend. See [ROADMAP.md](ROADMAP.md) §3.

### Q: How do you handle being a solo developer?

**A:** Three mitigations: (1) comprehensive documentation tree so a future contributor can pick up the project, (2) all decisions recorded in [DECISIONS.md](DECISIONS.md) so the "why" is preserved, (3) AI coding agents (like the one that helped scaffold this documentation) extend my capacity. The bus factor risk is documented in [RISKS.md](RISKS.md) R-9.

### Q: How do you do code review as a solo developer?

**A:** Self-review against the checklist in [STYLE_GUIDE.md](STYLE_GUIDE.md) §10, plus AI agent review. The PR template in [CONTRIBUTING.md](../CONTRIBUTING.md) enforces the checklist. Branch protection requires PR review (even self-approval) before merge to `main`.

## 7. Post-MVP & Future Questions

### Q: What's the v1.1 plan?

**A:** Email verification, OAuth SSO (Google/Apple), push notifications, product reviews submission flow, custom domain, staging environment, Firebase Auth custom claims for `isAdmin` (eliminates per-rule `get()` cost), automated Firestore backups. See [ROADMAP.md](ROADMAP.md) §4.1.

### Q: When will you add payment integration?

**A:** v1.2 — Growth & International phase. Requires Stripe SDK, `/payments` Firestore collection, Cloud Function for webhook handling, checkout UI update. None of these require changing the existing `/orders` schema or cart flow — see [DECISIONS.md](DECISIONS.md) ADR-010 reversibility.

### Q: Will you publish to Google Play?

**A:** v2.0 — Scale & Enterprise phase. Requires production APK signing (uploading a `.keystore` to GitHub secrets), Play Store listing, screenshots, privacy policy URL, content rating. See [ROADMAP.md](ROADMAP.md) §4.3.

### Q: Will you upgrade to Blaze tier?

**A:** Only when post-MVP growth justifies it (real customer traffic exceeding Spark quotas, or when Cloud Functions are needed for server-side logic). The upgrade is a one-click operation; no code changes required. See [DECISIONS.md](DECISIONS.md) ADR-012.

### Q: Will you add iOS support?

**A:** Not currently planned. iOS is OUT OF SCOPE per [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5. Adding iOS requires: (1) macOS development machine, (2) Apple Developer Program membership ($99/year, violates $0 budget), (3) iOS-specific testing. Deferred indefinitely unless a sponsor covers the Apple Developer fee.

## 8. References

- Internal: [GLOSSARY.md](GLOSSARY.md), [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [DECISIONS.md](DECISIONS.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md), [ROADMAP.md](ROADMAP.md), [SECURITY.md](SECURITY.md), [TESTING.md](TESTING.md), [DEPENDENCIES.md](DEPENDENCIES.md)
- External: n/a (this file references only internal documentation)
