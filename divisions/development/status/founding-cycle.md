# Development (Div 1) — Founding Status

**Session:** devOpsClaude · **Branch:** `division/development` · **Date:** 2026-06-19
**Cycle:** FOUNDING (orientation + one deliverable). The lifecycle loop is not
turning yet — this proposes the first real cycle, then holds.
**Read:** charter + CORNERSTONES + VALUES + REPO-STRUCTURE (branch model) +
deliverable-spec + development-lifecycle + merge-autonomy-policy + master
orchestration WO + decision-ledger (D-001…D-014).

**Bottom line (the one decision this surfaces):** the overnight crunch worked —
the AUTO bulk landed cleanly in both repos. But in `pandora` the **entire REVIEW
set is unlanded, and it contains the trunk plus the whole device-control
product**. The most valuable work the swarm produced is sitting one decision away
from `main`. Development cannot merge it (architect's button) — so the proposed
first cycle is built to **collapse that decision to a single clean REVIEW branch**
and to run the next sprint *threat-informed* by Security's audit, without ever
touching a gated button.

Supporting detail (every claim cited by branch+commit): `deliverables/branch-inventory.md`.

---

## a. Domain inventory (read-only; cited, nothing copied)

Heads at read time: `pandora` `origin/main` @ `a34a427`; `elpis-os` `origin/main`
@ `6618608`. Full table in the supporting artifact; the shape:

- **pandora — LANDED (AUTO):** Lane S (substrate tests/docs) + Lane F (oracle
  robustness) — additive, CI-green, no boundary touch. Exactly what the policy
  bucketed AUTO.
- **pandora — REVIEW (unlanded, awaits architect):** `hotfix/bridge-bind-loopback`
  (foundational trunk tip: H-1 bridge bind fix + the large capability feature),
  `feature/capability-descriptor-controls` (the device-control system),
  the ~20-branch **Lane A** provider/dispatch fan-out (one file per device family,
  honestly stamped `live|partial|template`), `feature/installer-ux` (Lane I),
  `preview/security-invariant-tests` (guards — REVIEW-*coupled* to the trunk), and
  the H-1 bind runbook.
- **elpis-os — LANDED (AUTO, guards first):** parity-regression + security-invariant
  guards, then **Lane G** (the device-handler library, registration-only behind the
  unchanged authorizer, one AppArmor profile per handler), Lane B (wayfire), Lane E
  (overlay scripts), Lane D (13 productization/verify *scripts+docs*).
- **elpis-os — REVIEW/BLOCKED:** the parity-fix base (`consumer-hardening` /
  `device-library-expansion`, D-007 *approved-to-merge* but RED:SECURITY+PARITY —
  human merges; polkit-grant scope = Security audit item #6); the Tier-B security
  branches (`1B/1C/1D`); the extratrees recipe (RISK:PARITY); and the BLOCKED bakes
  (D-008: libndk non-redistributable + no image-build path).
- **The crunch template** (`work-orders/claude-code-MASTER-orchestration-overnight.md`):
  lanes A–E + F/G/H/S + standing Lane I (D-006); Prime Safety Contract + Anti-Idle;
  merge discipline = merge-autonomy-policy (D-001) + integrate-then-gate (D-002).
  **Ran once**; AUTO integrated; **standing loop not yet turning** (D-014).
- **Sibling-division work now in `pandora`** (read-only awareness, not ours to
  change): Security's `preview/audit-cycle-1` (`protocol-audit-findings.md`,
  `write-to-effect-map.md`, GAPs H-16/17/19) and Research's
  `feature/research-living-article` (write-to-execute ARTICLE v0.1.0, PRIVATE).

## b. State assessment (Development's lens)

**In good shape**
- **Lane discipline held.** Disjoint ownership, branch-only work, honest
  `UNPLANNED`/`RISK` tags, clean `sprint/<lane>/<slug>` naming. The crunch produced
  exactly its product: *branches worth landing.*
- **Merge ≠ ship held.** AUTO integrated guards-first in both repos; nothing
  shipped, no `.180` mutation, no secret on a branch surfaced.
- **The two flagship outputs are coherent and clean-room.** The capability-descriptor
  system (one provider file per family, encoder-tested, surface-contract-validated)
  and the elpis-os handler library (per-handler AppArmor confinement behind the
  unchanged authorizer) are both strong, consent-respecting work.

**Broken / missing / at risk**
1. **(RISK, top) The trunk is unlanded and everything rebases on it.**
   `hotfix/bridge-bind-loopback` is REVIEW; the capability feature + the whole
   Lane A fan-out sit on top. Until the architect merges the trunk, every
   next-sprint Lane-A branch rebases on a moving REVIEW target and the highest-value
   work stays off `main`. This is Development's single biggest exposure.
2. **(GAP) pandora `main` has weaker regression protection than elpis-os `main`.**
   pandora's `security-invariant-tests` didn't land (REVIEW-coupled to the trunk),
   so the bridge-bind + secret-scan guards are not live on pandora `main` yet,
   while they are on elpis-os. Next-sprint pandora lanes run without their net.
3. **(GAP) the integrator digest isn't a durable in-repo artifact.** `OVERNIGHT-
   STATUS.md` / `triage-report.md` / `READY-TO-MERGE.md` were scratch (uncommitted
   by design). The board's only durable record of the AUTO run + the REVIEW queue
   is the policy's one-time table + the ledger. A standing loop needs the digest
   landed somewhere citable each cycle.
4. **(BLOCKER, external) no image-build path (mkosi).** Caps Lane D's ceiling and
   keeps the D-008 bakes BLOCKED. Owned by Infrastructure/Platform; named as a
   dependency, not a Development fix.
5. **(STATE) the loop is not turning.** No standing cadence, no division CC
   sessions on the product side, anchor day untuned (D-014 open items). A *real*
   cycle cannot start until the founder turns the loop.

## c. Proposed first REAL cycle (tiered; gated items flagged)

Sequenced to be **threat-informed by construction** (lifecycle: the sprint's input
is the audit's findings + the carried-forward queue). Nothing below merges,
flashes, deploys, or touches `.180` — all gated steps are marked and left for the
founder / Security.

**Tier 1 — highest value, do first**
- **T1a. Collapse the pandora REVIEW trunk to a one-decision branch.** Rebase
  `hotfix/bridge-bind-loopback` + `feature/capability-descriptor-controls` onto
  current `origin/main`, collapse to a single reviewable tip
  (`preview/trunk-capability`), re-run the real build + full test gate to GREEN,
  secret-scan the diff, and hand the architect **one** REVIEW branch instead of a
  tangle. *Development prepares; the merge stays the architect's button (GATED).*
- **T1b. Reproduce + fix the audit GAPs H-16/17/19** (Security's
  `protocol-audit-findings.md`) — one remediation branch each, `RISK: SECURITY`
  tagged → REVIEW. This is the swarm doing its charter §4 job: reproduce and fix
  what the adversary finds. *Security owns the findings + the verdict (GATED on
  their prioritization).*

**Tier 2 — high-volume lane work (AUTO-eligible once the trunk lands)**
- **T2a. Lane A continuation** — extend the provider/dispatch fan-out to remaining
  plausible device families (the backlog generator), each honestly stamped +
  encoder-tested, rebased on the landed/preview trunk. AUTO-eligible once the trunk
  is on `main` and the H-1 bind is deployed.
- **T2b. Lane I (installer)** — mature `feature/installer-ux`; split pure-UI
  (AUTO-eligible) from install-mechanics (REVIEW, trust/boot-adjacent). Coordinate
  with Design/Product (UX) and Infra (image/first-boot seam).
- **T2c. Lane B (windowed Android)** — consolidate + test the per-category window
  policy + window-state persistence already branched; land the additive,
  test-backed pieces AUTO.
- **T2d. Restore pandora's guard parity** — once the trunk lands, land
  `preview/security-invariant-tests` so pandora `main` regains the bridge-bind +
  secret-scan regression net (closes assessment gap #2).

**Tier 3 — GATED / BLOCKED (surface, do not start)**
- **T3a. elpis-os D-lane image bakes** (`bake-firefox-wine`, `bake-waydroid-microg`)
  — **BLOCKED (D-008)** on the image-build env (Infra/mkosi) + the libndk license
  call (IP/Legal). *Founder presses build/flash.*
- **T3b. Parity-fix base merge + polkit-grant verification** — D-007 approved but
  RED; the polkit grant = Security audit item #6. *Architect merges; Security
  verifies.*
- **T3c. Any `.180` live-apply / flash / deploy** — founder's physical buttons,
  full stop.

## d. Dependencies (what I need, and from whom)

- **Founder:** turn the loop (stand up the standing crunch + the product-side CC
  sessions); dispose of the REVIEW sets — at minimum authorize T1a's single
  collapsed `preview/trunk-capability` for one-decision review; tune the EA anchor
  day (ledger open item).
- **EA:** integrate this founding-status branch → `main` under the gate; sequence
  the next crunch inside the usage envelope; **land the Lane C digest as a durable
  per-cycle artifact** (closes gap #3).
- **Security/Red-Team (Div 2):** the prioritized finding set
  (`protocol-audit-findings.md` H-16/17/19 + carried-forward H-9 §2, H-4/11/15) as
  the threat-informed sprint input; the polkit-grant scope verdict (audit item #6).
- **QA/Release-Eng (Div 3):** a working **`ci-verify.sh`** (exit-code-driven) as the
  AUTO gate + the parity harness as the regression floor — confirm `ci-verify.sh`
  actually exists and is green on `origin/main` before the next AUTO run (it gates
  every AUTO merge per D-002).
- **Infrastructure/Platform (Div 6):** the **image-build environment (mkosi — the
  ship-blocker)** to unblock D-008; CI runners for CI-on-push (P-5).
- **Design/Product (Div 5):** installer + device-control UX direction so Lane A/I
  stay coherent across lanes.
- **Docs/DevRel (Div 4):** `CLAUDE.md` source-of-truth reconciliation as lanes land
  (docs-in-commit is an AUTO criterion — drift makes a branch un-AUTO).

---

**Held at:** no product-repo changes (read-only inventory only), no `.180`, no
merges to `main` or any sibling branch, no gated operations, loop not started.
Worktree isolation used (`C:\GitRepos\cnsUnltd-development`) to avoid the shared-
checkout HEAD race. Orient, propose, surface — then hold.
