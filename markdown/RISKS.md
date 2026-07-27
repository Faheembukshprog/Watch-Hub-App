# Risks

> Risk register for App-WatchHub. Every identifiable risk to the project's success is listed with likelihood, impact, mitigation, and contingency. This file is the single source of truth for project risk; the [ROADMAP.md](ROADMAP.md) sprint plan is calibrated against this register.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — Risks |
| **Purpose** | Identify, assess, and document every project risk with mitigation and contingency |
| **Audience** | Maintainers, stakeholders, reviewers |
| **Scope** | Project risks only; technical decisions in [DECISIONS.md](DECISIONS.md) |
| **Version** | 1.0.0 |
| **Status** | Active — reviewed weekly during MVP cycle |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [PROJECT_SCOPE.md](PROJECT_SCOPE.md), [ROADMAP.md](ROADMAP.md), [DECISIONS.md](DECISIONS.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |

---

## Table of Contents

1. [Risk Assessment Methodology](#1-risk-assessment-methodology)
2. [Risk Register](#2-risk-register)
3. [Quota Risks (Firebase Spark Tier)](#3-quota-risks-firebase-spark-tier)
4. [Timeline Risks](#4-timeline-risks)
5. [Security Risks](#5-security-risks)
6. [Operational Risks](#6-operational-risks)
7. [Risk Review Cadence](#7-risk-review-cadence)
8. [References](#8-references)

---

## 1. Risk Assessment Methodology

Risks are scored on two dimensions: **Likelihood** (probability of occurrence) and **Impact** (severity if it occurs). The combination yields a Risk Level that drives prioritization.

### 1.1 Likelihood Scale

| Level | Meaning | Probability |
|---|---|---|
| **Very Low** | Almost certainly will not occur | < 5% |
| **Low** | Unlikely but possible | 5-20% |
| **Medium** | Could go either way | 20-50% |
| **High** | Likely to occur | 50-80% |
| **Very High** | Almost certainly will occur | > 80% |

### 1.2 Impact Scale

| Level | Meaning | Consequence |
|---|---|---|
| **Negligible** | No measurable effect | Project continues unaffected |
| **Minor** | Slight delay or cosmetic issue | < 1 day delay; easily fixed |
| **Moderate** | Noticeable impact on scope or timeline | 1-3 day delay; partial descope needed |
| **Major** | Significant scope/timeline impact | 3-7 day delay; major descope or scope reduction |
| **Critical** | Project failure; cannot deliver MVP | Cannot complete MVP; academic failure |

### 1.3 Risk Level Matrix

| Likelihood \ Impact | Negligible | Minor | Moderate | Major | Critical |
|---|---|---|---|---|---|
| Very Low | Low | Low | Low | Medium | Medium |
| Low | Low | Low | Medium | Medium | High |
| Medium | Low | Medium | Medium | High | High |
| High | Medium | Medium | High | High | Critical |
| Very High | Medium | High | High | Critical | Critical |

### 1.4 Risk Response Strategies

| Strategy | When to Use | Example |
|---|---|---|
| **Avoid** | Critical risk; cannot be mitigated | Choose alternative architecture |
| **Mitigate** | Reduce likelihood or impact | Add tests, add monitoring, add documentation |
| **Transfer** | Move risk to third party | Use managed service instead of self-hosted |
| **Accept** | Low risk; mitigation cost exceeds impact | Document and monitor |

## 2. Risk Register

The complete risk register. Risks are numbered `R-N` and tracked through their lifecycle (Identified → Mitigated → Realized → Closed).

| ID | Risk | Likelihood | Impact | Level | Strategy | Status |
|---|---|---|---|---|---|---|
| R-1 | Firestore Spark Tier quota exceeded during demo | Medium | Major | High | Mitigate | Active |
| R-2 | 30-day timeline overrun | Medium | Major | High | Mitigate | Active |
| R-3 | Data loss (no automated Firestore backup) | Low | Critical | High | Accept | Active |
| R-4 | Admin bootstrap procedure error | Medium | Moderate | Medium | Mitigate | Active |
| R-5 | Catalog asset size bloats APK beyond 25MB | Low | Moderate | Medium | Mitigate | Active |
| R-6 | Riverpod learning curve delays development | Low | Moderate | Medium | Mitigate | Active |
| R-7 | GoRouter redirect loop on auth state edge case | Low | Moderate | Medium | Mitigate | Active |
| R-8 | Firestore Security Rules regression post-deploy | Low | Critical | High | Mitigate | Active |
| R-9 | Solo developer bus factor | Very High | Major | Critical | Accept | Active |
| R-10 | Browser compatibility issue on Safari | Low | Moderate | Medium | Mitigate | Active |
| R-11 | Firebase Auth rate limiting triggers false-positive | Very Low | Minor | Low | Accept | Active |
| R-12 | Image optimization tools produce oversized WebP | Low | Minor | Low | Mitigate | Active |
| R-13 | Documentation drift from implementation | Medium | Moderate | Medium | Mitigate | Active |
| R-14 | Demo device failure during video recording | Low | Major | Medium | Mitigate | Active |
| R-15 | GitHub Actions runner unavailable during demo | Very Low | Minor | Low | Accept | Active |

### 2.1 Risk Detail Cards

Detailed cards for High and Critical risks. Low and Medium risks are tracked in the register above.

#### R-1: Firestore Spark Tier Quota Exceeded During Demo

| Field | Value |
|---|---|
| **Description** | During the demonstration video recording or live evaluation, the Firestore Spark Free Tier daily quota (50K reads, 20K writes) is exceeded, causing `PERMISSION_DENIED` or `RESOURCE_EXHAUSTED` errors. |
| **Likelihood** | Medium — depends on demo iteration count |
| **Impact** | Major — demo fails mid-recording; video must be re-recorded |
| **Triggers** | Repeated full-app refreshes; integration test runs against production (misconfiguration); catalog stream left running in multiple browser tabs |
| **Mitigation** | (1) Use Firebase Emulator for all development and testing; (2) Monitor quota in Firebase Console before recording; (3) Record demo in single pass to minimize re-takes; (4) Catalog stream auto-disposes when no watchers (Riverpod autoDispose) |
| **Contingency** | If quota hit during recording: wait until midnight Pacific time for quota reset (typically < 4 hours); re-record next day |
| **Owner** | Author |
| **Review Date** | Weekly |

#### R-2: 30-Day Timeline Overrun

| Field | Value |
|---|---|
| **Description** | One or more sprints overrun their allocated time, pushing the final delivery past August 14, 2026. |
| **Likelihood** | Medium — solo dev, aggressive timeline |
| **Impact** | Major — academic late submission; grade penalty |
| **Triggers** | Underestimation of UI polish effort; unexpected Firebase configuration issues; scope creep (adding features beyond MVP) |
| **Mitigation** | (1) Strict adherence to milestone gates in [ROADMAP.md](ROADMAP.md) §3; (2) Pre-identified descope candidates per sprint; (3) Daily time-tracking against sprint plan; (4) No new features added after Week 2 without explicit replanning |
| **Contingency** | If Gate 2 missed: descope filter chips (single-filter only). If Gate 3 missed: descope admin dashboard stats (basic table only). If Gate 4 missed: submit as-is with documented known limitations |
| **Owner** | Author |
| **Review Date** | Daily |

#### R-3: Data Loss (No Automated Firestore Backup)

| Field | Value |
|---|---|
| **Description** | Accidental deletion or corruption of Firestore data with no automated backup to restore from. |
| **Likelihood** | Low — Firestore is durable; accidental deletion requires explicit Console action |
| **Impact** | Critical — all production data lost; cannot restore |
| **Triggers** | Author accidentally deletes collection in Console; Firebase project accidentally deleted; Google-side data loss (extremely rare) |
| **Mitigation** | (1) Manual Firestore export before any destructive operation (Console → Export Data); (2) Document destructive operations in [CHANGELOG.md](../CHANGELOG.md); (3) Use Firebase Emulator for all development to avoid touching production data |
| **Contingency** | If data lost: re-seed from `scripts/seed_emulator.dart` (loses all real user data, but MVP has no real users). Accept data loss; document as incident in CHANGELOG. |
| **Owner** | Author |
| **Review Date** | On any destructive operation |

#### R-8: Firestore Security Rules Regression Post-Deploy

| Field | Value |
|---|---|
| **Description** | A rules change deployed to production inadvertently weakens security (e.g., allows public write to `/products`). |
| **Likelihood** | Low — rules are tested in CI per [TESTING.md](TESTING.md) §7 |
| **Impact** | Critical — unauthorized data mutation or exfiltration |
| **Triggers** | Rule change made without updating tests; CI rules tests skipped or failing-then-passing-by-coincidence |
| **Mitigation** | (1) Every rule change must include a corresponding test (positive + negative); (2) CI fails build on any rules test failure; (3) Manual rules test run after every deploy via `firebase emulators:exec`; (4) Periodic manual audit of rules vs. [SECURITY.md](SECURITY.md) §6 Authorization Matrix |
| **Contingency** | If regression detected: immediately `git checkout HEAD~1 firestore.rules && firebase deploy --only firestore:rules` to roll back rules; audit Firestore audit logs (if available) for unauthorized access |
| **Owner** | Author |
| **Review Date** | Per deploy |

#### R-9: Solo Developer Bus Factor

| Field | Value |
|---|---|
| **Description** | Project has a single contributor. If the contributor becomes unavailable (illness, emergency, lost interest), the project stalls. |
| **Likelihood** | Very High — by definition, solo project |
| **Impact** | Major — project cannot continue without author |
| **Triggers** | Author illness; family emergency; motivation loss; competing priorities |
| **Mitigation** | (1) Comprehensive documentation tree (this entire `/docs/` folder); (2) All decisions recorded in [DECISIONS.md](DECISIONS.md); (3) All work logged in [worklog.md](/home/z/my-project/worklog.md); (4) Code committed daily to GitHub (no local-only state); (5) Daily progress check-ins (self-imposed) |
| **Contingency** | If author unavailable > 3 days: project pauses; academic board notified; timeline may be re-negotiated |
| **Owner** | Author |
| **Review Date** | Weekly |

## 3. Quota Risks (Firebase Spark Tier)

Firebase Spark Free Tier has daily quotas. Exceeding any quota causes `RESOURCE_EXHAUSTED` errors until midnight Pacific time.

| Resource | Daily Quota | Risk | Mitigation |
|---|---|---|---|
| Firestore reads | 50,000 | Medium — admin dashboard with snapshots() can consume many reads if rendered repeatedly | Use Riverpod autoDispose; admin dashboard polls rather than streams if read volume becomes issue |
| Firestore writes | 20,000 | Low — writes are infrequent (orders, admin CRUD) | Monitor in Console |
| Firestore deletes | 20,000 | Very Low — deletions rare | n/a |
| Firestore data transfer (egress) | 1 GB / day | Low — small catalog, local assets | Monitor in Console |
| Firebase Authentication | 50K verifies / day | Very Low | n/a |
| Hosting bandwidth | 360 MB / day | Low — small static assets | Monitor in Console |
| Hosting storage | 10 GB | Very Low | n/a |
| Cloud Function invocations | **0 (not available on Spark)** | n/a — Cloud Functions OUT OF SCOPE | n/a |

### 3.1 Quota Monitoring

| Check | Frequency | Where |
|---|---|---|
| Firestore reads/writes today | Daily before demo | Firebase Console → Firestore → Usage |
| Hosting bandwidth this month | Weekly | Firebase Console → Hosting → Usage |
| Auth verifies today | Daily before demo | Firebase Console → Authentication → Usage |

### 3.2 Quota Exceeded Recovery

If a quota is exceeded mid-demo:

1. Stop all Firestore operations (close browser tabs).
2. Wait until midnight Pacific time (typically < 4 hours from any time zone).
3. Verify quota reset in Firebase Console.
4. Re-attempt the demo.

For Hosting bandwidth, no reset is needed (monthly quota).

## 4. Timeline Risks

The 30-day timeline is the project's primary schedule risk. Detailed in R-2 above. Additional timeline risks:

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Flutter SDK breaking change mid-project | Very Low | Major | Pin Flutter version in CI; do not upgrade mid-cycle |
| Firebase Console UI change | Low | Minor | Adapt; documentation screenshots may need update |
| Dependency package abandoned mid-project | Low | Moderate | All dependencies are popular and actively maintained — see [DEPENDENCIES.md](DEPENDENCIES.md) |
| Internet outage during demo recording | Low | Major | Record demo early (Week 4 day 1-3) to allow retry |

## 5. Security Risks

Security risks are detailed in [SECURITY.md](SECURITY.md) §9 Known Limitations. Summary:

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Credential stuffing on login | Medium | High | Firebase Auth has built-in abuse detection; deferred rate limiting per [ROADMAP.md](ROADMAP.md) §4.1 |
| Privilege escalation via `isAdmin` write | High attempt | Critical | Firestore rule blocks client writes to `isAdmin` — see [SECURITY.md](SECURITY.md) §4.1 |
| Fake email registration (no verification) | High | Low | Accepted for MVP; email verification deferred per [ROADMAP.md](ROADMAP.md) §4.1 |
| Cart tampering (negative quantity) | Medium | High | Client validates; rules also validate `quantity >= 1` |
| Order tampering (post-create mutation) | Medium | Critical | Rules block customer updates entirely; admin can only update `orderStatus` |

## 6. Operational Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| GitHub outage during CI | Very Low | Minor | Wait for recovery; CI is non-blocking for local dev |
| Firebase service outage | Very Low | Major | Check Firebase Status Dashboard; wait for recovery |
| Domain registrar issue (post-MVP) | Very Low | Minor | Use Firebase-managed domain for MVP |
| Laptop failure (dev environment) | Low | Major | All code on GitHub; all config in repo; can resume on any machine in < 2 hours |

## 7. Risk Review Cadence

| Risk Category | Review Frequency | Reviewer |
|---|---|---|
| All High and Critical risks | Weekly (Mondays) | Author |
| All Medium risks | Bi-weekly | Author |
| All Low risks | Monthly | Author |
| New risks | As identified | Author |
| Realized risks (incidents) | Immediate | Author + Academic Review Board (if Critical) |

### 7.1 Risk Review Process

1. Open [RISKS.md](RISKS.md) (this file).
2. For each risk, ask: "Has the likelihood or impact changed since last review?"
3. If yes, update the risk card and the register table.
4. If a mitigation has been implemented, update Status to `Mitigated`.
5. If a risk has been realized, create an incident entry in [CHANGELOG.md](../CHANGELOG.md) and update Status to `Realized`.
6. Commit changes with message `docs(risks): weekly review - <date>`.

## 8. References

- Internal: [PROJECT_SCOPE.md](PROJECT_SCOPE.md) §6 Constraints & Assumptions, [ROADMAP.md](ROADMAP.md) §3 Milestone Gates, [DECISIONS.md](DECISIONS.md), [SECURITY.md](SECURITY.md) §9 Known Limitations, [TROUBLESHOOTING.md](TROUBLESHOOTING.md), [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md)
- External: [Firebase Spark plan quotas](https://firebase.google.com/pricing), [Firebase Status Dashboard](https://status.firebase.google.com/), [Risk Management (PMI)](https://www.pmi.org/learning/library/risk-management-project-7445)
