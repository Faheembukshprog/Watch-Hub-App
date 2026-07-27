# Open Questions

> Consolidated list of gaps requiring stakeholder input, ambiguous specifications, and deferred decisions. Every `UNKNOWN`, `REQUIRES DECISION`, or `OUT OF SCOPE` marker in the documentation tree traces back to an entry here. This file is the project's queue of unresolved questions.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Open Questions |
| **Purpose** | Track every unresolved question, gap, and deferred decision in the project |
| **Audience** | Maintainers, stakeholders, academic reviewers |
| **Scope** | Open questions only; resolved decisions moved to [DECISIONS.md](DECISIONS.md) |
| **Version** | 1.0.0 |
| **Status** | Active — reviewed at every milestone gate |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md), [DECISIONS.md](DECISIONS.md), [RISKS.md](RISKS.md), [FAQ.md](FAQ.md) |

---

## Table of Contents

1. [How to Use This File](#1-how-to-use-this-file)
2. [Open Questions Register](#2-open-questions-register)
3. [Question Detail Cards](#3-question-detail-cards)
4. [Resolution Workflow](#4-resolution-workflow)
5. [References](#5-references)

---

## 1. How to Use This File

This file is the project's canonical queue of unresolved questions. The role specification forbids fabricating information; instead, every gap is marked `UNKNOWN`, `REQUIRES DECISION`, or `OUT OF SCOPE` inline in the documentation, and a corresponding entry is filed here with full context.

When a question is resolved, it is NOT deleted from this file. Instead, the entry's Status is updated to `Resolved`, a Resolution field is added with the answer and date, and a new ADR is created in [DECISIONS.md](DECISIONS.md) if the resolution has architectural implications. This preserves the audit trail of how the project's understanding evolved.

Reviewers and contributors should treat this file as the single source of truth for "what we don't know yet." Before asking the author a question, check this file — the answer may already be tracked here.

## 2. Open Questions Register

| ID | Question | Category | Priority | Status | Raised In |
|---|---|---|---|---|---|
| Q-1 | What is the tax rate to apply at checkout? | Requirements | High | Open | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-3.6 |
| Q-2 | Should `fullName` be validated server-side in Firestore rules? | Security | Medium | Open | [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.1 |
| Q-3 | What is the maximum catalog size before pagination is required? | Architecture | Low | Open | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-1 |
| Q-4 | Should the demo video be recorded on Web or Android? | Operations | Medium | Open | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-7 |
| Q-5 | What is the licensing posture for the public GitHub release? | Legal | High | Open | [LICENSE.md](../LICENSE.md) |
| Q-6 | Should email verification be required before login? | Security | Medium | Deferred to v1.1 | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-1.10 |
| Q-7 | What happens to cart items if a product is deleted by admin mid-session? | Requirements | Medium | Open | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §6 |
| Q-8 | Should the admin dashboard support bulk product import? | Requirements | Low | Deferred to v1.2 | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| Q-9 | What is the expected concurrent user load for the demo? | Operations | Medium | Open | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-2 |
| Q-10 | Should the project support RTL (right-to-left) languages? | Requirements | Low | Deferred to v1.2 | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| Q-11 | What is the policy for abandoned carts (no checkout)? | Requirements | Low | Deferred to v1.2 | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §6 |
| Q-12 | Should the admin be able to delegate admin role to other users? | Security | Medium | Deferred to post-MVP | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-4.10 |
| Q-13 | What is the maximum image size allowed for product photos? | Architecture | Low | Open | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-3 |
| Q-14 | Should the project support product variants (e.g., different strap options)? | Requirements | Low | Deferred to v1.2 | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| Q-15 | What is the expected session duration for a customer? | Operations | Low | Open | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-7 |
| Q-16 | Should the app support offline order placement? | Architecture | Medium | Open | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §7 |
| Q-17 | What is the policy for handling reviews that contain profanity? | Requirements | Low | Deferred to v1.1 | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §5 |
| Q-18 | Should the admin dashboard show revenue in real-time or daily aggregate? | Requirements | Low | Open | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-4.4 |
| Q-19 | What is the maximum number of items allowed in a single order? | Architecture | Low | Resolved (50) | [SECURITY.md](SECURITY.md) §4.1 |
| Q-20 | Should the project log PII to Crashlytics? | Security | High | Open | [SECURITY.md](SECURITY.md) §7 |

## 3. Question Detail Cards

Detailed cards for High and Medium priority open questions. Low priority questions are tracked in the register above.

### Q-1: What is the tax rate to apply at checkout?

| Field | Value |
|---|---|
| **Category** | Requirements |
| **Priority** | High |
| **Status** | Open |
| **Raised In** | [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) FR-3.6 |
| **Question** | The system must calculate tax on cart subtotal (FR-3.6), but the rate is not specified in the source SDD. What rate should be used? |
| **Context** | Tax calculation is required for the MVP demo. Options: (a) flat rate (e.g., 8%); (b) rate by jurisdiction (requires user address); (c) no tax (display $0.00). |
| **Options Considered** | (a) Flat 8% — simplest; defensible for academic demo. (b) Jurisdiction-based — complex; requires address form and rate table; out of scope for MVP. (c) No tax — inaccurate; fails to demonstrate calculation logic. |
| **Recommendation** | Flat 8% rate, hardcoded as constant `TAX_RATE = 0.08` in `lib/core/constants/catalog_constants.dart`. Document as a known simplification. |
| **Decision Needed By** | End of Week 2 (Gate 2) — required for checkout page implementation. |
| **Decider** | Author (with academic reviewer consultation if needed) |

### Q-2: Should `fullName` be validated server-side in Firestore rules?

| Field | Value |
|---|---|
| **Category** | Security |
| **Priority** | Medium |
| **Status** | Open |
| **Raised In** | [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.1 |
| **Question** | The current Firestore rules validate `fullName` length (2-100 chars) on create, but not on update. Should updates also be validated server-side? |
| **Context** | Client-side validation exists; server-side validation adds defense-in-depth but increases rule complexity. |
| **Options Considered** | (a) Add `request.resource.data.fullName.size() >= 2 && <= 100` to update rule. (b) Trust client-side validation only. (c) Add a Cloud Function for validation (deferred — Blaze tier). |
| **Recommendation** | Option (a) — minimal added complexity, max defense-in-depth. |
| **Decision Needed By** | End of Week 3 (Gate 3) — before security rules finalization. |
| **Decider** | Author |

### Q-4: Should the demo video be recorded on Web or Android?

| Field | Value |
|---|---|
| **Category** | Operations |
| **Priority** | Medium |
| **Status** | Open |
| **Raised In** | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-7 |
| **Question** | The demonstration video must show the app in use. Should it be recorded on Chrome (Web) or on an Android device? |
| **Context** | Web shows cross-platform capability and is easier to record (screen capture). Android shows native performance and is closer to a "real" product demo. Both are valid deployment targets per ADR-011. |
| **Options Considered** | (a) Web only — easier to record; demonstrates cross-platform. (b) Android only — native performance; more impressive UX. (c) Both — split-screen or sequential; more work but most impressive. |
| **Recommendation** | Option (c) — record both, edit into a single video showing web → Android transition. ~30 seconds extra recording time, significantly stronger demo. |
| **Decision Needed By** | Start of Week 4 — required for video planning. |
| **Decider** | Author |

### Q-5: What is the licensing posture for the public GitHub release?

| Field | Value |
|---|---|
| **Category** | Legal |
| **Priority** | High |
| **Status** | Open |
| **Raised In** | [LICENSE.md](../LICENSE.md) |
| **Question** | The project will be published on GitHub. What license should be applied? |
| **Context** | Academic project; author is a student. Options range from "All Rights Reserved" (no use without permission) to MIT (permissive open source). |
| **Options Considered** | (a) MIT — permissive; allows commercial use with attribution. (b) Apache 2.0 — permissive with patent grant. (c) GPL-3.0 — copyleft; derivative works must be open. (d) CC BY-NC 4.0 — non-commercial; allows sharing with attribution. (e) All Rights Reserved — no use without permission. |
| **Recommendation** | Option (a) MIT — most permissive; signals confidence; standard for portfolio projects; does not restrict future commercial use. |
| **Decision Needed By** | Before public GitHub release (end of Week 4). |
| **Decider** | Author (with academic board consultation if university has IP policy) |

### Q-7: What happens to cart items if a product is deleted by admin mid-session?

| Field | Value |
|---|---|
| **Category** | Requirements |
| **Priority** | Medium |
| **Status** | Open |
| **Raised In** | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §6 |
| **Question** | If a customer has a product in their cart and an admin deletes that product from the catalog, what should the customer experience? |
| **Context** | Cart is local (Hive); product deletion removes the Firestore document. The cart still references the `productId`, but the product no longer exists. |
| **Options Considered** | (a) Show "Product no longer available" badge in cart; allow removal but not checkout. (b) Silently remove from cart on next cart open. (c) Block checkout with a modal listing unavailable items. |
| **Recommendation** | Option (c) — block checkout with a modal listing unavailable items, requiring user to remove them before proceeding. Most transparent; least surprising. |
| **Decision Needed By** | End of Week 2 (Gate 2) — required for cart implementation. |
| **Decider** | Author |

### Q-9: What is the expected concurrent user load for the demo?

| Field | Value |
|---|---|
| **Category** | Operations |
| **Priority** | Medium |
| **Status** | Open |
| **Raised In** | [PROJECT_SCOPE.md](PROJECT_SCOPE.md) A-2 |
| **Question** | How many concurrent users should the MVP support during the demonstration? |
| **Context** | Affects Firestore quota planning (R-1) and load testing scope. |
| **Options Considered** | (a) 1-5 (single reviewer at a time). (b) 10-50 (small audience demo). (c) 100+ (load test scenario). |
| **Recommendation** | Option (a) — academic demo is single-user; concurrent load testing OUT OF SCOPE per [PROJECT_SCOPE.md](PROJECT_SCOPE.md). Document as accepted limitation. |
| **Decision Needed By** | Already implicitly decided — confirm before Gate 4. |
| **Decider** | Author |

### Q-16: Should the app support offline order placement?

| Field | Value |
|---|---|
| **Category** | Architecture |
| **Priority** | Medium |
| **Status** | Open |
| **Raised In** | [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §7 |
| **Question** | If the user is offline, should they be able to place an order that syncs when connectivity returns? |
| **Context** | Firestore SDK supports offline writes (queued and synced when online). Cart is already offline-capable (Hive). Enabling offline order placement is technically straightforward. |
| **Options Considered** | (a) Enable — writes queue locally, sync on reconnect. (b) Disable — require online connection to place order; show "You are offline" error. |
| **Recommendation** | Option (b) — disable for MVP. Offline order placement introduces UX complexity (what if stock changed before reconnect? what if user closes app?). Acceptable to require online for the demo. |
| **Decision Needed By** | End of Week 2 (Gate 2) — required for checkout implementation. |
| **Decider** | Author |

### Q-20: Should the project log PII to Crashlytics?

| Field | Value |
|---|---|
| **Category** | Security |
| **Priority** | High |
| **Status** | Open |
| **Raised In** | [SECURITY.md](SECURITY.md) §7 |
| **Question** | Firebase Crashlytics captures exception stack traces. If a stack trace includes a variable containing PII (e.g., `user.email`), that PII is logged to Crashlytics. Should this be allowed? |
| **Context** | Crashlytics is a debugging tool; PII in crash logs aids debugging but may violate GDPR / CCPA. |
| **Options Considered** | (a) Allow — debugging value > privacy risk for MVP. (b) Strip — wrap all PII-bearing variables in a redaction utility before they enter exception paths. (c) Disable Crashlytics entirely — lose crash visibility. |
| **Recommendation** | Option (a) — allow for MVP, document as accepted risk in [SECURITY.md](SECURITY.md) §9. The MVP has no real users, so PII in crash logs is the author's own test data. Revisit before public launch. |
| **Decision Needed By** | End of Week 1 (Gate 1) — before Crashlytics integration. |
| **Decider** | Author |

## 4. Resolution Workflow

When a question is resolved, the workflow is:

1. Update the question's `Status` field to `Resolved`.
2. Add a `Resolution` field with the answer and date.
3. If the resolution has architectural implications, create a new ADR in [DECISIONS.md](DECISIONS.md).
4. Update the originating document (the file referenced in `Raised In`) to replace `UNKNOWN` / `REQUIRES DECISION` with the resolved value.
5. Update [CHANGELOG.md](../CHANGELOG.md) with the resolution under the appropriate version.
6. Commit with message `docs(questions): resolve Q-N - <short summary>`.

### 4.1 Resolution Example

```markdown
| Q-19 | What is the maximum number of items allowed in a single order? | Architecture | Low | Resolved (50) | [SECURITY.md](SECURITY.md) §4.1 |

**Resolution (2026-07-14):** Maximum 50 items per order. Enforced in Firestore rule:
`request.resource.data.items.size() <= 50`. Documented in [SECURITY.md](SECURITY.md) §4.1.
Rationale: 50 items exceeds any realistic luxury watch purchase; bounded size prevents
DoS via huge order payload.
```

### 4.2 Deferral Workflow

When a question is deferred (not resolved, but pushed to a future version):

1. Update `Status` to `Deferred to vN.N`.
2. Add a `Deferred Reason` field explaining why it is deferred.
3. Update [ROADMAP.md](ROADMAP.md) §4 Post-MVP Backlog with the deferred item.
4. Commit with message `docs(questions): defer Q-N to vN.N - <short summary>`.

## 5. References

- Internal: [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md), [DECISIONS.md](DECISIONS.md), [RISKS.md](RISKS.md), [ROADMAP.md](ROADMAP.md), [FAQ.md](FAQ.md), [LICENSE.md](../LICENSE.md)
- External: [RFC 2119 (Requirement Levels)](https://www.rfc-editor.org/rfc/rfc2119), [5 Whys root cause analysis](https://en.wikipedia.org/wiki/Five_whys)
