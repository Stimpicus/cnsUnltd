# FOUNDING STATUS — Documentation / Developer Relations (Division 4)

**Session:** docsDevRelClaude · **Branch:** `division/docs-devrel` ·
**Date:** 2026-06-19 · **Status:** founding cycle (orient → propose → surface →
hold). The loop is not turning yet (ledger D-014); nothing below is executed.

**Discipline note.** Everything here is read-only introspection of the product
repos, cited by path/commit, copied nowhere. This division *drafts* and
*proposes*; it never publishes and never commits to the product repos. Every
product-repo adoption of a doc below is **gated** (merge tier per
`governance/merge-autonomy-policy.md`); anything public-facing — a repo going
public, the disclosure, an adoption guide that reveals architecture, the brand —
is the **founder's** button, and any doc exposing pre-disclosure architecture is
**Security/Red-Team-flagged** (charter §3–4). Truthful or it doesn't ship.

---

## a. DOMAIN INVENTORY — what exists today

My domain (onboarding table): the `CLAUDE.md` source-of-truth discipline across
both repos; the adoption path; README/architecture docs; contributor enablement;
disclosure public-framing readiness (the *content* is Security's). Paths below are
`pandora` unless prefixed `elpis-os`. Drift baseline: `pandora` root docs were
last written at `64b868e` (2026-06-09); **60 commits** have landed since
(`64b868e..HEAD` → `d2fa794`).

### The `CLAUDE.md` source-of-truth discipline (my standing law — charter §2)
- **`pandora` root `CLAUDE.md`** (`12c862e`, 2026-06-09) — deep, accurate
  documentation of the `face-to-face` module + project-wide SpacetimeDB 2.x API
  notes. But it is **face-to-face-centric** and predates the subsystems added
  across the 60 intervening commits: the `substrate/` command-dispatch reference,
  `applications/elpis-shell` (Tauri device-control UI), the capability-descriptor
  control system (`d2fa794`), the `windows-oracle`/`android-oracle`, and the
  `file-broadcast`/`file-sharing`/`secure-messaging`/`theme-sync`/`home-gateway`
  apps. No top-level or per-module canonical doc covers these.
- **`elpis-os` `CLAUDE.md`** (`2c614ce`, 2026-06-18) — current, tracks HEAD; the
  in-commit discipline is working there.
- **Net:** the source-of-truth rule holds in `elpis-os`, drifts in `pandora`'s
  newer subsystems. The rule (AUTO-tier criterion #4 in the merge policy) is
  defined but **unevenly enforced** in `pandora`.

### The adoption path (charter §2 — explicitly mine)
- **`docs/adoption-path.md`** (`64b868e`, 2026-06-09) is a **4-line placeholder**
  that states outright "the adoption strategy has not been written yet." It is
  cross-referenced by `README.md` and `ARCHITECTURE.md`. This is the
  single highest-priority unwritten artifact I own.

### README / architecture docs
- **`README.md` + `ARCHITECTURE.md`** (both `64b868e`, 2026-06-09) — clear, well
  written protocol framing, but **stale by 60 commits**: both list file-transfer
  / messaging / smart-home as **`[future]`**, yet `applications/` now ships 14
  apps (face-to-face, secure-messaging, file-broadcast, file-sharing,
  home-gateway, theme-sync, pandora-native, elpis-shell, windows-oracle,
  android-oracle, demo-console, elpis-run, wasm-demo, pandora-substrate-api) plus
  the entire `elpis-os` OS embodiment — none reflected. `README` "Status:
  attorney meeting June 12" is now historical (today 2026-06-19). `ARCHITECTURE`'s
  substrate table omits the Postgres second substrate that is now *proven*.
  Cross-references that exist resolve (e.g. `docs/threat-model.md` is present,
  `8d…`-era, 27 KB); the `README` Structure block's `docs/` listing is incomplete
  (9 files exist) but not broken.
- **`substrate/WHAT-THIS-DEMONSTRATES.md` + `substrate/SUBSTRATE.md`** (`41d4ae7`,
  2026-06-09) — **excellent, honest portability proof**: the de-facto "second
  substrate" contributor story already exists in seed form (SpacetimeDB vs.
  Postgres LISTEN/NOTIFY, one URL param). Carries two self-flagged TODOs
  (recording date, commit hash) — minor.
- **`elpis-os` `README.md`/`CONTRIBUTING.md`/`ROADMAP.md`/`SECURITY.md`/
  `CODE_OF_CONDUCT.md`** (`61f8588`, 2026-06-12) — a **complete, honest,
  non-overclaiming OSS doc set** with DCO + GPLv3 and even a device-library
  `CONTRIBUTING.md`. The strongest contributor-onboarding surface in either repo.

### Contributor enablement / OSS scaffolding
- **`pandora` (the disclosure vehicle) has NO `LICENSE`, NO `CONTRIBUTING`, NO
  `CODE_OF_CONDUCT`** tracked anywhere. The repo that *becomes* the open-source
  artifact at the gate has zero contributor scaffolding.
- **`elpis-os` (public-trajectory)** has the full set. **Readiness is inverted
  relative to the disclosure timeline.**

### Disclosure public-framing readiness (content = Security's; framing = mine)
- **`docs/threat-model.md`** (2026-06-14, ~27 KB) — the WTES note
  ("write-to-execute via subscription substrate"); already includes "(6) a
  responsible disclosure plan." This is the living-article seed; per the SDLC
  (`governance/development-lifecycle.md`) and my charter, its **content is
  Security/Red-Team's**. It cross-refs `applications/face-to-face/SECURITY.md`
  (`a97357d`) and `elpis-os` `ARCHITECTURE.md §5`.
- **There is no DevRel public-framing / packaging layer** yet — no explainer, no
  responsible-disclosure packaging, no presentation framing. That layer is my
  future, gated work (charter §2–4).
- **Codename/brand split:** `README` and `elpis-os` `README` both flag "Pandora"
  as a development codename, public name TBD; Design/Product's founding doc
  (branch `division/design-product`) treats the product as "Elpis." Every
  public-facing doc inherits this unresolved naming.

---

## b. STATE ASSESSMENT — through the docs/devrel lens

Pressure-tested against the mandate (charter §1): *understanding that travels* —
and against the standing rule that honesty is a security property (charter §3,
VALUES "we will not overclaim").

**In good shape**
- The **`elpis-os` OSS doc set** is genuinely adoptable — honest, DCO/GPLv3,
  threat-model-first CONTRIBUTING rules. A stranger could orient from it today.
- The **substrate portability proof** (`WHAT-THIS-DEMONSTRATES` + `SUBSTRATE`) is
  the "second substrate" story in seed form — the exact artifact the disclosure
  needs to prove generality to outsiders.
- **`docs/threat-model.md`** is a substantive, honest disclosure seed (Security's
  content) — the gate will not face a "write the disclosure" scramble.
- **`elpis-os` `CLAUDE.md` discipline** is current — the in-commit rule works.

**At risk / missing / drifting (doc-debt register)**
| # | Gap | Mandate touched | Evidence |
|---|---|---|---|
| DR1 | **`adoption-path.md` is a placeholder** — a charter-named deliverable is unwritten. | adoption path | `docs/adoption-path.md` (`64b868e`) |
| DR2 | **`pandora` README/ARCHITECTURE stale by 60 commits** — `[future]` apps now exist; Postgres second substrate proven but unlisted; historical status line. Stale public docs = overclaim-by-omission = honesty/security liability. | legibility; honesty-as-security | `64b868e..HEAD`; `applications/` |
| DR3 | **`pandora` has no OSS scaffolding** (`LICENSE`/`CONTRIBUTING`/`CODE_OF_CONDUCT`) — the disclosure vehicle is unprepared; readiness inverted vs `elpis-os`. | contributor enablement; disclosure | `git ls-files` (none tracked) |
| DR4 | **`pandora` `CLAUDE.md` source-of-truth drift** — face-to-face-centric; doesn't cover substrate/elpis-shell/oracles/device-control. My standing law is unevenly enforced. | source-of-truth discipline | `12c862e`; merge-policy criterion #4 |
| DR5 | **No DevRel public-framing layer** around the disclosure (`threat-model.md`) — needed against the publication gate. | disclosure presentation | `docs/threat-model.md`; charter §2 |
| DR6 | **No consolidated "build a second substrate" guide** — material exists (`SUBSTRATE.md`) but isn't packaged as an outsider walkthrough. | contributor enablement | `substrate/SUBSTRATE.md` |
| DR7 | **Codename→public-name unresolved** across all public docs — drift multiplies on every new surface. | brand/voice coherence | `README`; `elpis-os README`; Design doc |

None are safety *defects*; all are **legibility/adoptability gaps** — exactly this
division's mandate. DR2 and DR3 are the two with consequences beyond tidiness: DR2
is honesty-as-security (a stale public doc overstates/misstates the system), DR3
is disclosure-gate readiness.

---

## c. PROPOSED FIRST REAL CYCLE (for when the loop turns)

My outputs are **drafts/specs on this branch**; every *product-repo adoption* is
flagged **GATED** with its disposer. Nothing here is started now.

### P0 — foundational (author on this branch; the *merge/publish* is gated)
- **P0-1 — Source-of-truth audit + drift register (DR4).** Catalogue every
  `pandora` subsystem lacking a current canonical doc; propose where each
  `CLAUDE.md`/module-doc lives; stand up a maintained drift register. The
  in-commit rule is *already* AUTO criterion #4 — so this is **enforcement, not
  invention**. *Authoring ungated; adopting as an enforced gate input = **QA
  (Div 3) + founder** (decision D-3).*
- **P0-2 — Write `docs/adoption-path.md` for real (DR1).** The outsider's path
  from "interesting" → "running it on their own substrate," anchored on the
  existing proofs (`SUBSTRATE.md`, `WHAT-THIS-DEMONSTRATES.md`). *Draft mine;
  merge to `pandora` = **REVIEW** + **Security-flagged** (it narrates
  pre-disclosure architecture).*
- **P0-3 — README/ARCHITECTURE drift-correction draft (DR2).** Move the
  `[future]` apps to present; add the `elpis-os` embodiment + the Postgres second
  substrate; fix the historical status line. *Draft mine; merge to `pandora` =
  **REVIEW** + **Security reviews what it exposes** pre-disclosure.*

### P1 — high-value
- **P1-1 — `pandora` OSS scaffolding, prepared not added (DR3).** A license-
  options brief (with IP/Legal, Div 8), plus `CONTRIBUTING`/`CODE_OF_CONDUCT`
  drafts — **staged against the disclosure gate, not committed.** *Adding any of
  these to the repo = **founder + IP/Legal**; the license choice is not mine to
  make.*
- **P1-2 — "Build a second substrate" contributor guide (DR6).** Package the
  `SUBSTRATE.md` material into a reproducible adoption walkthrough — the
  portability proof outsiders can re-run. *Draft mine; publish-facing = gated.*
- **P1-3 — Disclosure public-framing kit, draft only (DR5).** The explainer +
  responsible-disclosure packaging that wraps Security's article. **Content stays
  Security's; I draft framing/presentation and serve their review.** *Strictly
  gated: Security-flagged + founder presses publish. Prepare, never publish.*

### P2 — forward-looking
- **P2-1 — Honest-narrative / project-story outline** (the YouTube documentation
  idea, charter §2): truthful, non-hyped. *Draft only; any publication = founder.*
- **P2-2 — Cross-repo doc-consistency standard** (with Design/Product, Div 5):
  one wordmark, one tagline, one honest voice across README/installer/first-run/
  adoption docs (DR7). *Coordination; public brand = founder.*
- **P2-3 — Per-app README sweep** for the undocumented `pandora` apps (oracles,
  theme-sync, file-broadcast, …) so each subsystem is legible. *Mostly
  AUTO-eligible docs; surfaced to **Development (Div 1)**.*

---

## d. DEPENDENCIES — what I need, and from whom

- **Founder:** presses every publish button (repo-public, disclosure, an adoption
  guide that reveals architecture, the public name/brand); disposes the `pandora`
  LICENSE choice (D-2); ratifies whether the source-of-truth check becomes a
  standing gate (D-3). I never publish.
- **EA:** integrate this branch → `main` (display case); slot the source-of-truth
  drift check into the cadence.
- **Security/Red-Team (Div 2):** owns the `threat-model`/disclosure *content*;
  **reviews every public-facing draft I produce** (adoption path, README
  correction, disclosure kit) for what it exposes pre-disclosure. A Security
  **BLOCK halts any public draft.** Outranks me on every tie.
- **QA/Release-Eng (Div 3):** co-owns making "docs current in-commit" an enforced
  gate criterion (already AUTO #4); gates doc changes that ride product merges.
- **Development (Div 1):** feeds the technical truth and implements adopted doc
  changes in the product repos; needed to land README/`CLAUDE.md` corrections.
- **IP/Legal-Strategy (Div 8):** the LICENSE choice + license-compliance framing
  (GPLv3 / Firefox / Wine / libndk) in any public doc.
- **Design/Product (Div 5):** shared brand/voice standard (P2-2) and the
  codename→public-name resolution (DR7).

---

## DECISIONS-NEEDED (for the founder's queue)
1. **D-1 (public-facing — founder): resolve the codename → public name.** `README`
   + `elpis-os README` say "public name TBD"; Design treats it as "Elpis."
   *Recommendation:* founder fixes the public name (or ratifies "Elpis") **before**
   I correct README/ARCHITECTURE, so the drift-fix doesn't bake a provisional name
   into more surfaces. *Trade-off:* deciding now prevents another drift round;
   forecloses nothing reversible.
2. **D-2 (founder + IP/Legal): `pandora` LICENSE choice for the gate.** The
   disclosure vehicle has no LICENSE; `elpis-os` chose GPLv3. *Recommendation:* I
   prepare a license-options brief with IP/Legal; **founder disposes** — I do not
   add a LICENSE unilaterally. *Trade-off:* preparing early makes the gate cheap;
   the commons-vs-enclosure call is load-bearing (VALUES: "we disclose").
3. **D-3 (founder + QA): make "canonical docs current in-commit" a standing
   enforced gate.** It is already merge-policy AUTO criterion #4 but unevenly
   applied in `pandora` (DR4). *Recommendation:* adopt as a QA-enforced check;
   DevRel maintains the drift register. *Trade-off:* one lightweight check per
   merge vs. the silent drift this division exists to prevent.
4. **D-4 (sequencing — founder/Security): may I draft the adoption path + README
   correction now**, on-branch and unpublished, given they describe pre-disclosure
   architecture? *Recommendation:* yes to drafting on-branch; every product-repo
   merge and any architecture exposure stays **Security-flagged + gated**.
   *Trade-off:* drafting now (gated, cheap branch swap) vs. a scramble at the gate.

## RISKS / FLAGS
- **Public-facing (founder's button):** adoption path, README/ARCHITECTURE
  corrections, OSS scaffolding, disclosure kit, brand — I **prepare, never
  publish.**
- **Security-flagged:** any doc revealing pre-disclosure architecture routes
  through Security/Red-Team; a **BLOCK halts it.** The disclosure kit's *content*
  is Security's, not mine.
- **Honesty-as-security (DR2):** stale/overclaiming public docs are themselves a
  liability (charter §3; VALUES). Flagged — not a BLOCK.
- **Inverted readiness (DR3):** the disclosure vehicle (`pandora`) lags the
  public-trajectory repo (`elpis-os`) on contributor scaffolding — a gate risk if
  disclosure approaches before it closes.
- No new cost / physical / trust-boundary items originate from this division.

## NEXT (once the loop turns)
Author P0-1 (source-of-truth audit + drift register) and P0-2 (the real
adoption-path draft) on this branch; bring the README/ARCHITECTURE correction to
Development + Security as a gated REVIEW; await D-1…D-4. Until then: **held.**
