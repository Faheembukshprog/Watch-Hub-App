# Changelog

All notable changes to App-WatchHub are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Changelog |
| **Purpose** | Reverse-chronological record of notable changes per release |
| **Audience** | Maintainers, reviewers, contributors |
| **Scope** | Project-wide changes only; commit-level detail in git history |
| **Version** | 1.0.0 |
| **Status** | Active — updated on every release and on any intra-version change |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [README.md](README.md), [ROADMAP.md](docs/ROADMAP.md), [DECISIONS.md](docs/DECISIONS.md), [OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) |

---

## [Unreleased]

### Added

- Documentation tree scaffolded: 20+ Markdown files under `/docs/` per the role's PROJECT DOCUMENTATION STRUCTURE spec. See [docs/INDEX.md](docs/INDEX.md) for the complete map.
- Root-level files: [README.md](README.md), [CHANGELOG.md](CHANGELOG.md), [CONTRIBUTING.md](CONTRIBUTING.md), [LICENSE.md](LICENSE.md).
- Architecture Decision Records (ADRs) for 16 major architectural choices — see [docs/DECISIONS.md](docs/DECISIONS.md).
- Risk register with 15 identified risks and mitigation strategies — see [docs/RISKS.md](docs/RISKS.md).
- Open questions queue tracking 20 unresolved items — see [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md).

### Changed

- Documentation reorganized from single-file SDD to multi-file documentation tree per the Founder's Documentation Architect role spec.
- Mermaid diagrams refactored and extended: added deployment topology, CI/CD pipeline, caching layers, security boundaries, cart state machine, and checkout sequence diagrams.
- Source SDD's security rules hardened with field-level validation, type checks, and order immutability constraints — see [docs/SECURITY.md](docs/SECURITY.md) §4.2.

### Notes

- The original source SDD v1.0.0 (Muhammad Faheem Khan, July 14, 2026) is the academic submission document. This changelog tracks the repository-level evolution of the project, starting from the documentation baseline established on July 15, 2026.

---

## [1.1.0] — 2026-07-15

### Added — Reconciliation with Official `App-WatchHub.doc` Specification

After receiving the official eProject Specification (`App-WatchHub.doc`) and welcome email from eProjects Team, the documentation tree was reconciled to align with the authoritative requirements. Seven feature areas previously marked `OUT OF SCOPE` or omitted are now IN SCOPE.

#### New Functional Requirements (FR-5 through FR-11)

- **FR-5.0 Search** — client-side text matching on catalog stream (ADR-013). 8 sub-requirements.
- **FR-6.0 Reviews and Ratings** — customer review submission, admin moderation, average rating calculation. 11 sub-requirements.
- **FR-7.0 Customer Support** — contact form, in-app FAQ page (Firestore `/faq`), admin FAQ CRUD. 10 sub-requirements.
- **FR-8.0 Feedback and Issue Reporting** — feedback form with anonymous option, admin triage queue. 7 sub-requirements.
- **FR-9.0 User Profile, Addresses, and Order Tracking** — profile page, multiple shipping addresses, order history, real-time order tracking UI. 12 sub-requirements.
- **FR-10.0 Product Detail Enhancements** — image zoom (InteractiveViewer), reviews section on product detail, related products, report-issue link. 8 sub-requirements.
- **FR-11.0 Admin Panel Extensions** — review moderation, support ticket queue, feedback triage, user management, FAQ management, analytics. 8 sub-requirements.

#### New Firestore Collections

- `/reviews/{reviewId}` — customer reviews with moderation status (ADR-014)
- `/supportTickets/{ticketId}` — customer support contact form submissions
- `/feedback/{feedbackId}` — feedback and issue reports (anonymous allowed)
- `/faq/{faqId}` — in-app FAQ content, admin-managed (ADR-015)
- `/users/{uid}.addresses[]` — embedded shipping addresses array

#### New Firestore Security Rules

- `/reviews` — owner can create (status forced to `pending`); public reads approved; owner reads own; admin reads all + moderates
- `/supportTickets` — owner creates + reads own; admin reads all + responds
- `/feedback` — public (anonymous allowed) creates; admin reads + triages
- `/faq` — public reads active; admin CRUDs

#### New Composite Indexes (8 added, total 13)

- `reviews`: (productId, status, createdAt), (userId, createdAt), (status, createdAt)
- `supportTickets`: (userId, createdAt), (status, createdAt)
- `feedback`: (status, createdAt)
- `faq`: (category, displayOrder)

#### New Architecture Decision Records

- **ADR-013** — Client-Side Search over Algolia / Firestore Full-Text
- **ADR-014** — Top-Level `/reviews` Collection over Subcollection
- **ADR-015** — FAQ in Firestore over Static JSON Bundle
- **ADR-016** — Team Project Structure (6 Contributors)

#### New Working Assumptions

- A-8: Team members have Flutter/Dart baseline competency
- A-9: Client-side search on ~50 SKUs is performant (sub-100ms)
- A-10: Reviews volume per product stays under 100 for MVP

#### New Success Criteria (SC-11 through SC-20)

- SC-11: eProject Report submitted with all required sections
- SC-12: Status Report submitted at 2 milestones
- SC-13: Feedback Form submitted
- SC-14 through SC-20: Feature-specific verification criteria

### Changed

- **Constraint C-3** updated from "Single developer (solo project)" to "Team project — 6 student contributors; work must be parallelizable via feature branches"
- **Constraint C-7** added: "All features in `App-WatchHub.doc` must be implemented — no feature may be deferred without an ADR"
- **PROJECT_SCOPE.md §5** — moved search, reviews submission, customer support, FAQ, feedback, order tracking, and shipping addresses from OUT OF SCOPE to IN SCOPE
- **SECURITY.md §7.1 PII Inventory** — `Delivery address` changed from "NOT COLLECTED" to "Stored as `addresses[]` in `/users/{uid}`" with High sensitivity
- **ROADMAP.md §2** — sprint plan rebaselined for expanded scope with team parallelization; task assignments distributed across 6 contributors
- **README.md** — added feature coverage table (§6.1) and team section (§6.5)
- **SYSTEM_DESIGN.md §3** — added 7 new feature folders (search, reviews, support, faq, feedback, profile, plus extended admin)
- **SYSTEM_DESIGN.md §5.1** — added 9 new routes for the new features
- **API_REFERENCE.md** — added §5.7 through §5.11 covering reviews, support tickets, feedback, FAQ, and addresses operations

### Sources

- Official specification: `App-WatchHub.doc` (Aptech eProjects, 6 pages, 998 words)
- Welcome email: PDF from `eprojects@aglsm.com` dated Mon, Jul 13, 2026 at 7:13 AM
- Team enrollment: 6 students (Muhammad Asim Siddiqui, Musaib Zahid, Maaz, Muhammad Faheem Khan, Muhammad Mubeen, Ahmed Ali)
- Project window: 14-Jul-2026 to 14-Aug-2026
- Required deliverables: video, working application (source + compiled), eProject Report, Status Report (2 milestones), Feedback Form

---

---

## [1.0.0] — 2026-07-14

### Added

- Initial System Baseline Architecture & SDD Core Compilation.
- Project vision, problem statement, business goals documented.
- Functional requirements FR-1.0 through FR-4.0 defined.
- Non-functional requirements NFR-1 through NFR-4 defined.
- Production tech stack selected: Flutter 4.x, Riverpod, GoRouter, Firebase Auth, Cloud Firestore, local asset bundles.
- Component architecture diagram (Mermaid `graph TD`).
- Folder structure architecture (Feature-First layout).
- Data flow diagram (DFD Level 0 — Context Level).
- Role-based routing sequence diagram.
- Academic ERD (USERS, PRODUCTS, ORDERS, ORDER_ITEMS) in Crow's Foot notation.
- Production Firestore NoSQL schemas for `/users`, `/products`, `/orders` collections.
- Firestore Security Rules (`firestore.rules`) with `isUserAuthenticated`, `isDocumentOwner`, `isSystemAdmin` predicates.
- UI/UX luxury design system specifications: color matrix, typography (Playfair Display + Inter).
- 4-week production sprint timeline (Gantt chart).
- Technical glossary (SEDA, NoSQL, Riverpod, Glassmorphism, Edge Computing).
- Portfolio defense strategy script.

### Reviewed By

- Academic Review Board (Reviewer / Approver per source SDD revision history).

---

## Changelog Conventions

### Categories

| Category | When Used |
|---|---|
| **Added** | New features, new documentation files, new capabilities |
| **Changed** | Changes in existing functionality, refactors, schema migrations |
| **Deprecated** | Soon-to-be removed features |
| **Removed** | Removed features (with rationale) |
| **Fixed** | Bug fixes |
| **Security** | Vulnerability fixes, rule hardening |
| **Notes** | Informational entries that don't fit other categories |

### Version Increments

Per [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

| Change Type | Version Bump | Example |
|---|---|---|
| Breaking change (schema, API, public interface) | MAJOR | 1.0.0 → 2.0.0 |
| New feature (backward-compatible) | MINOR | 1.0.0 → 1.1.0 |
| Bug fix (backward-compatible) | PATCH | 1.0.0 → 1.0.1 |
| Documentation-only change | None (use `Unreleased` section) | n/a |

### Entry Format

Each entry follows:

```markdown
- <Category>: <Brief description>. See [docs/<file>.md](docs/<file>.md) §<section> for details.
```

Cross-references to documentation are mandatory for entries that change behavior visible to users, admins, or contributors. Internal refactors that do not change observable behavior may omit the cross-reference.

### Review Cadence

- **On every PR merge to `main`:** add entries to the `[Unreleased]` section.
- **On every release:** rename `[Unreleased]` to `[X.Y.Z] — YYYY-MM-DD` and start a new `[Unreleased]` section.
- **On incident:** add an entry under `Security` or `Fixed` with a link to the post-mortem (if applicable).

---

## References

- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html)
- Internal: [README.md](README.md), [docs/INDEX.md](docs/INDEX.md), [docs/ROADMAP.md](docs/ROADMAP.md), [docs/DECISIONS.md](docs/DECISIONS.md), [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md)
