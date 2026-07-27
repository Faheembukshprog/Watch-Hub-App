# License

> Licensing posture for App-WatchHub. **REQUIRES DECISION** — the project is currently an academic submission; the public-release license has not yet been selected.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — License |
| **Purpose** | Document the project's licensing posture and the decision required before public release |
| **Audience** | Legal reviewers, contributors, academic board |
| **Scope** | Licensing only; dependency licenses in [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) §4 |
| **Version** | 1.0.0 |
| **Status** | **REQUIRES DECISION** — pending resolution of [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5 |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5, [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) §4, [README.md](README.md) §9 |

---

## Table of Contents

1. [Current Status](#1-current-status)
2. [Decision Required](#2-decision-required)
3. [Candidate Licenses](#3-candidate-licenses)
4. [Dependency License Compatibility](#4-dependency-license-compatibility)
5. [University IP Policy Considerations](#5-university-ip-policy-considerations)
6. [Resolution Procedure](#6-resolution-procedure)
7. [References](#7-references)

---

## 1. Current Status

**REQUIRES DECISION** — App-WatchHub is currently an academic project submitted for evaluation. No license has been applied to the source code or documentation. Until a license is selected and recorded in this file, the default copyright applies: **All Rights Reserved** to the author, Muhammad Faheem Khan.

The `REQUIRES DECISION` marker is per the role specification (Founder's Documentation Architect), which forbids fabricating decisions when information is unknown. The decision is tracked in [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5.

Until resolved:

- The repository must NOT be made public on GitHub without first selecting a license.
- Forking, copying, or redistributing the code requires explicit written permission from the author.
- The documentation tree (under `/docs/`) is similarly All Rights Reserved.

## 2. Decision Required

| Field | Value |
|---|---|
| **Decision** | Select a license for the public GitHub release of App-WatchHub |
| **Priority** | High |
| **Decision Needed By** | Before public GitHub release (target: end of Week 4, August 14, 2026) |
| **Decider** | Muhammad Faheem Khan (with academic board consultation if university has IP policy) |
| **Open Question** | [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5 |

## 3. Candidate Licenses

The following licenses are under consideration. The recommended default (per [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5) is **MIT**.

### 3.1 MIT License (Recommended)

- **Type:** Permissive
- **Requirements:** Preserve copyright notice and license text
- **Allows:** Commercial use, modification, distribution, private use
- **Forbids:** Liability
- **Compatibility:** Compatible with all current dependencies (see §4)
- **Signal:** "I'm confident in my work and want it to be widely usable"
- **Used by:** Most Flutter packages, React, jQuery, .NET Core

**Why recommended:** MIT is the most permissive widely-recognized license. It signals confidence (the author is not restricting use) and is standard for portfolio projects. It does not restrict future commercial use by the author or others.

### 3.2 Apache License 2.0

- **Type:** Permissive
- **Requirements:** Preserve notices, state changes, include NOTICE file
- **Allows:** Commercial use, modification, distribution, patent grant
- **Forbids:** Trademark use, liability
- **Compatibility:** Compatible with all current dependencies
- **Signal:** "I'm permissive but want explicit patent protection"
- **Used by:** Flutter, Kubernetes, Android Open Source Project

**Why considered:** Apache 2.0 includes an explicit patent grant, which provides stronger protection against patent litigation. Slightly more complex than MIT but still permissive.

### 3.3 GNU General Public License v3.0 (GPL-3.0)

- **Type:** Copyleft
- **Requirements:** Preserve notices, distribute source code of derivative works under GPL-3.0
- **Allows:** Commercial use, modification, distribution (with copyleft)
- **Forbids:** Closed-source derivatives
- **Compatibility:** Compatible with most dependencies, but copyleft propagates
- **Signal:** "I want derivatives to remain open source"
- **Used by:** Linux kernel, Bash, GCC

**Why considered:** GPL-3.0 ensures any derivative work must also be open source. This is a strong philosophical stance but may limit commercial adoption.

### 3.4 Creative Commons Attribution-NonCommercial 4.0 (CC BY-NC 4.0)

- **Type:** Permissive (non-commercial)
- **Requirements:** Attribution
- **Allows:** Non-commercial use, modification, distribution
- **Forbids:** Commercial use without separate permission
- **Compatibility:** Designed for creative works, not code; uncommon for software
- **Signal:** "You can learn from this, but don't sell it"
- **Used by:** Documentation, educational materials, art

**Why considered:** CC BY-NC would allow academic use while preventing commercial exploitation. However, it is unusual for software and may confuse potential users.

### 3.5 All Rights Reserved (Current Default)

- **Type:** No license
- **Requirements:** Explicit written permission for any use
- **Allows:** Nothing without permission
- **Forbids:** Everything without permission
- **Signal:** "This is my work; ask before using"
- **Used by:** Default copyright in most jurisdictions

**Why considered:** Preserves maximum control. Appropriate for academic submission prior to public release. Once public, this posture discourages collaboration and portfolio value.

## 4. Dependency License Compatibility

All direct dependencies use permissive licenses compatible with the project's intended MIT license. Full audit in [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) §4.

| License | Count | Compatible with MIT? | Compatible with GPL-3.0? |
|---|---|---|---|
| MIT | 7 | Yes | Yes |
| BSD-3-Clause | 11 | Yes | Yes |
| Apache-2.0 | 1 | Yes | Yes (Apache 2.0 is GPL-3.0 compatible) |

No copyleft dependencies (GPL, AGPL, LGPL) are present. Any of the candidate licenses (§3.1-3.4) is technically compatible with the dependency tree.

## 5. University IP Policy Considerations

If the academic institution (the university where the author is enrolled) has an Intellectual Property policy, it may affect licensing options. Common scenarios:

| University IP Policy | Impact on Licensing |
|---|---|
| Student owns their work | Author free to choose any license |
| University owns student work for credit | University must approve license; may require "All Rights Reserved" or university-specific license |
| University owns work only if funded/sponsored | Author free to choose (project is unfunded per [PROJECT_SCOPE.md](docs/PROJECT_SCOPE.md) C-1) |

The author must consult the university's IP policy before selecting a license. If the policy is unclear or restricts the choice, the license remains `REQUIRES DECISION` and the repository stays private until resolved.

## 6. Resolution Procedure

When the license decision is made:

1. Update [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5 with the resolution.
2. Update this file's §1 Current Status to "Resolved" with the selected license.
3. Add the license text to a new `LICENSE` file (no `.md` extension, per convention) in the project root.
4. Update [README.md](README.md) §9 License section.
5. Update the `![License](https://img.shields.io/badge/license-...)` badge in [README.md](README.md).
6. Add a changelog entry under `[Unreleased]` in [CHANGELOG.md](CHANGELOG.md).
7. Make the repository public (if applicable).

### 6.1 Example Resolution

```markdown
## 1. Current Status

**Resolved (2026-MM-DD)** — App-WatchHub is released under the MIT License.
See [LICENSE](LICENSE) for the full text.
```

## 7. References

- Internal: [docs/OPEN_QUESTIONS.md](docs/OPEN_QUESTIONS.md) Q-5, [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) §4, [README.md](README.md) §9, [CHANGELOG.md](CHANGELOG.md)
- External: [Choose a License](https://choosealicense.com), [SPDX License List](https://spdx.org/licenses/), [MIT License text](https://opensource.org/licenses/MIT), [Apache 2.0 License text](https://www.apache.org/licenses/LICENSE-2.0), [GPL-3.0 License text](https://www.gnu.org/licenses/gpl-3.0.html), [Creative Commons Licenses](https://creativecommons.org/licenses/)
