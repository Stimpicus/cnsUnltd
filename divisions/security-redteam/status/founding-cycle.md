# FOUNDING CYCLE — Security / Red-Team (Division 2)

**Session:** redTeamClaude **Date:** 2026-06-19
**Branch:** `division/security-redteam` (base `8d869c1`; authored in an isolated
`git worktree` — see §RISK-3 for why).
**Read-only honored:** product repos (`pandora`, `elpis-os`) and `.180`
introspected by reading only — no source edited, no merge, no `.180` mutation, no
secret VALUE quoted. **Loop not started.** This is orientation, not ongoing work.

**Orientation read:** my `CHARTER.md`; `charter/CORNERSTONES.md` + `VALUES.md`;
`REPO-STRUCTURE.md` (branch model); `governance/deliverable-spec.md`,
`development-lifecycle.md`, `merge-autonomy-policy.md`; the division-onboarding
work order. Also *read (not executed)* the three product work orders that scope my
proposed cycle: `claude-code-work-order-protocol-audit.md`,
`claude-code-work-order-security-remediation.md`, and (for context) the master
orchestration + living-article orders.

---

## TL;DR FOR A TIRED FOUNDER

The standing adversary is now stood up. The good news: **audit cycle 1 already ran
and the durable instrument (the write-to-effect map) exists** — the department's
core method is built, not theoretical, and it has already surfaced two new HIGH
findings (H-17, H-16) *by us, before deployment* — exactly what this department is
for. The asks that need **you** (decision-ready in §RISKS and §DEPENDENCIES):

1. **H-17 (HIGH, structural):** the gateway completes a `critical` action (e.g.
   smart-lock **unlock**) with **no signature check on the Confirm message**. The
   one-thing-keeping-it-bounded is that `dispatchToOwners` is still a stub. **Do
   not let `dispatchToOwners`-over-substrate ship until the H-17 fix lands.** I
   recommend a standing `BLOCK` on that coupling.
2. **The H-9 §2 signing-oracle fix is correctly stuck** behind a HARD GATE
   (`verifier-enumeration sweep`) that **has never been run**. Running it is
   read-only and squarely my job — first thing when the loop turns.
3. **The entire H-1..H-15 findings register + the H-9 design + the live-box
   baselines live ONLY in an unversioned local folder** (`C:\GitRepos\overnight\`,
   not a git repo). Single point of failure. Needs a permanent home — your call on
   where (§DEPENDENCIES D-3).
4. **The 8-session shared-working-copy hazard is real and I watched it happen to me
   this cycle** (§RISK-3). It is the operational attack surface the onboarding work
   order asked me to look for. Cheap structural fix (per-session worktrees/clones),
   but it's Infra's to implement.

Nothing here is deployed or merged. Every fix is staged or proposed; every
dangerous transition is flagged GATED to you.

---

## a. DOMAIN INVENTORY (read-only; cited by path/commit, nothing copied)

The department owns six living instruments. Current location + state:

### A-1. Threat model / findings register — **H-1..H-15**
- Canonical source: `security-review.md` (H-1..H-15, ~80 KB), with
  `SECURITY-REMEDIATION.md` (sequencing) and `H9-signer-design.md` (the approved
  §2 signer design). **Location: `C:\GitRepos\overnight\` — an UNVERSIONED folder,
  not inside either product repo** (confirmed `not a git repository`). See RISK-4.
- The F2F application also carries committed security docs in-repo:
  `pandora` `applications/face-to-face/SECURITY.md` and `KNOWN_ISSUES.md`.

### A-2. The AUDIT (lifecycle AUDIT phase, cycle 1) — **DONE, not merged**
- On `pandora` branch `preview/audit-cycle-1` (`f22a284`, also on origin):
  `audit-inventory.md`, `write-to-effect-map.md`, `protocol-audit-findings.md`.
- **The write-to-effect map exists** — i.e. the department's repeatable instrument
  is built. It keys write surfaces as `IMPL.surface` for mechanical next-cycle diff.
- New findings this cycle: **H-16, H-17** (both HIGH), **H-18** (INFO/latent),
  **H-19** (LOW); pre-existing H-1..H-15 re-confirmed with live `.180` status.
- Correctly **not merged to `main`** (REVIEW-tier; merge ≠ ship).

### A-3. Implementation inventory (what the lens is applied to)
Per `audit-inventory.md`: the general-protocol reference (`substrate/module`
`command-dispatch-demo` + its Postgres twin), the F2F SpacetimeDB module, the
device-control plane (`applications/pandora-substrate-api` bridge, `elpis-shell`,
`elpis-run`), and the elpis-os privileged helpers (`pandora-home-gateway`,
`pandora-dispatch`, `pandora-identity/tpm-signer`).

### A-4. Remediation staging — **all branch-only, NONE deployed**
| Cut | Finding | Branch | Commit |
|---|---|---|---|
| 1A | H-1 loopback bind | `pandora` `hotfix/bridge-bind-loopback` | `956fdf7` |
| 1B | H-9 §4 dedicated `pandora-sign` group | `elpis-os` `sprint/tierB/1B-sign-group` | `d836300` |
| 1C | H-2/H-14 append-only audit logs | `elpis-os` `sprint/tierB/1C-audit-append-only` | `fd57a3a` |
| 1D | H-10 firewall cap-drop | `elpis-os` `sprint/tierB/1D-firewall-caps` | `c503912` |

### A-5. Invariant regression suite
`preview/security-invariant-tests` on both repos (`pandora` `f03abb6`, `elpis-os`
`2cdfdf2`) + the `elpis-os` `preview/qa/parity-regression-harness`. Holds the
bind-loopback guard and the permissionless-primitive posture pin.

### A-6. Reference-instance ledger (the article's evidence feed)
Currently the `ARTICLE LEDGER CANDIDATES` section **inside**
`protocol-audit-findings.md`: AL-1 (H-17, the unauthenticated confirmation), AL-2
(H-16, the parallel ungated plane), AL-3 (H-9, the unconstrained signing oracle),
AL-4 (H-11, open-by-design → injection). **Not yet a standing, separate ledger** —
reconciliation into the living article is the evaluate phase's job (deliberately
deferred to avoid a write-collision with the article work order).

### A-7. Live reference-instance baselines
`baseline-180.txt`, `p7-180-backup.txt` — also only in `C:\GitRepos\overnight\`.

---

## b. STATE ASSESSMENT (through the adversarial lens)

### In good shape
- **The method works.** Audit cycle 1 produced the write-to-effect map and caught
  H-16/H-17 proactively. "Found by us, before deployment" is happening.
- **F2F module: clean (DD-1, 0 GAP).** Sentinel-guard rule holds (every sensitive
  reducer calls `require_authenticated`/`require_admin`; `auth.rs` is lifecycle-
  only). OIDC issuer/audience enforced; permission-first ordering (VECTOR-O); the
  "User unavailable" collapse removes the probing oracle. No reducer turns a write
  into another client's action without a writer gate.
- **`merge ≠ ship` is being honored end-to-end** — four Tier-1 cuts staged, zero
  deployed; audit on a preview branch, not main.
- **The install polkit grant is in the tight form** on `elpis-os` `main` (`2c614ce`):
  `49-elpis-install.rules` is scoped to BOTH `program === /usr/local/bin/elpis-install`
  AND `subject.user === "elpis"` — the form H-6 praised.

### Broken / missing / at risk
- **H-17 (HIGH, LIVE-structural) — unauthenticated Confirm → `critical` actuation.**
  `pandora-home-gateway` `router.ts` returns on the Confirm/Deny branch *before* the
  M1 signature check; `confirmation.ts` checks only the spoofable `from_identity`
  hex column. An attacker who learns the nonce forges the Confirm with a garbage
  signature and completes a `critical` action (e.g. unlock). Bounded *today* only by
  `dispatchToOwners` being a stub — the moment it delivers the nonce over the
  substrate, the bypass is fully live. **The signature hole is independent of that
  bound.** Fix (N1) is small (`verifySignature` on Confirm/Deny) but **unaddressed —
  no branch yet.**
- **H-16 (HIGH, LIVE while bridge binds `0.0.0.0`) — ungated parallel actuation
  plane.** The bridge `device_command` path actuates a TV (incl. arbitrary
  `SendKey`) with no signature/signer-allow/consent, bypassing the gateway gate
  entirely — *less* authz than the internal authenticated plane. Closed by deploying
  the staged H-1 loopback bind (1A) — staged, not deployed.
- **H-9 (LIVE) — unconstrained signing oracle.** `sign.sock root:pandora 0660`;
  `pandora-sign` group absent; `elpis ∈ pandora`; the bridge runs as `pandora`. Any
  `pandora`-group member signs arbitrary bytes → device-identity forgery. Fix 1B
  staged, not deployed.
- **H-2 / H-4 / H-10 LIVE.** Audit logs not fs-append-only (1C staged); the
  network-facing bridge is the only unconfined `pandora` daemon, no AppArmor / no
  systemd hardening (**H-4 has no branch**); firewall helper full-cap root (1D staged).
- **THE STAGE-2 VERIFIER SWEEP HAS NEVER RUN.** `verifier-sweep.md` and `recon.md`
  exist nowhere on disk (confirmed). The remediation sequence makes this a **HARD
  GATE**: H-9 §2 (domain-separated signing — the **highest-latent-value** fix) is
  correctly **BLOCKED** until the sweep returns GREEN. This is the single most
  important carried-forward item and it is **read-only — entirely in my lane.**
- **Carried-forward #6 (`7ad628c` polkit / self-pair) is NOT closed on record.** The
  rule reads tight on inspection (above), but a grep of all three audit deliverables
  for `polkit` / `self-pair` / `7ad628c` returns **nothing** — no written verdict
  exists, and the **self-pair first-boot behavior** (`pandora-pair`, `elpis-install`,
  the `postinst` step added by `7ad628c`: *does it auto-pair anything, to what, under
  whose authority?*) is **unverified on record.** Open. Verify-don't-assume: I will
  not call it closed because the rule "looks fine."
- **Continuity (RISK-4):** the H-1..H-15 register, the H-9 design, the gate tooling
  (`secret-scan.sh`, `ci-verify.sh`), and the `.180` baselines exist **only** in
  unversioned `C:\GitRepos\overnight\`. The audit register even references them by
  absolute path. Lose that folder and the canonical security knowledge base is gone.
- **Operational attack surface (RISK-3):** the 8 division sessions + EA operate on
  **shared single working copies** of the repos. Confirmed live this cycle (details
  in the deliverable). Read-only-against-product is a *prompt-level* posture, not a
  structurally enforced one.

---

## c. PROPOSED FIRST REAL CYCLE (when the loop turns; tiered; gated marked)

Mapped to the charter's standing workstreams. **Authoring/reading = in-lane.
Every merge and every deploy/`.180`/public action = GATED to you (and I never
press it).**

### TIER 1 — read-only, in-lane, do first (no gate needed to *produce*)
- **S1 — Run the verifier-enumeration sweep (the HARD GATE). [TOP PRIORITY]**
  Produce `verifier-sweep.md` + `recon.md`; binary GREEN/RED. This is the gate the
  whole H-9 §2 fix waits on; it is pure read/grep across both repos + reasoning
  about off-box peers. **Unblocks or formally holds the highest-value latent fix.**
- **S2 — Close carried-forward #6.** Read `7ad628c` before/after and the self-pair
  first-boot chain; write the `scope-still-tight` verdict or a hardening finding.
- **S3 — Promote the write-to-effect map to a maintained, diffable instrument.**
  Re-run vs current `main`; diff against the cycle-1 map; in particular check the
  WIP `capability-descriptor-controls` surface (a new device-control write path) and
  confirm H-16/H-17/H-19 status + whether `dispatchToOwners` went live (escalates
  H-17).
- **S4 — Stand the reference-instance ledger up as its own artifact** (AL-1..AL-4),
  ready for the evaluate phase to reconcile into the living article.

### TIER 2 — authoring of fixes/tests (branch-only; MERGE is the founder/EA's)
- **N1/H-17 fix** authored on a branch (move Confirm/Deny below M1 / verify inside
  `handleConfirmationResponse`) **+ a regression test** (garbage-sig Confirm ⇒
  `invalid_signature`, no actuation). `RISK: SECURITY`. *I author the finding + test;
  Development owns the source fix* (this dept is "not a fix-it shop").
- **H-4** AppArmor profile + systemd hardening for `pandora-substrate-api` (no branch
  exists). Natural pair to H-1.
- **Grow the invariant suite:** guards for H-17 (confirm must be signed), H-16 (no
  second ungated actuation plane), H-9 (socket ACL). Hand to QA to wire into the gate.

### TIER 3 — GATED (I surface; the founder disposes / presses)
- **Deploy 1A H-1 loopback bind to `.180`** (closes H-16 + H-19 remote entry) —
  AMBER, reversible, attended. **GATED.**
- **Deploy 1B `pandora-sign` ACL / 1C append-only / 1D firewall caps to `.180`** —
  **GATED**, each with its tested rollback.
- **H-9 §2 domain-separated signing (STAGE 3)** — **BLOCKED** until S1 == GREEN;
  phased (verifiers dual-accept before the signer emits v2); every apply **GATED**.
- **Merge of any audit/remediation/feature branch to a product `main`** — the EA /
  founder under the merge-autonomy policy (these carry `RISK: SECURITY`/`PARITY` ⇒
  REVIEW-tier, never AUTO).

---

## RISKS / FLAGS (mandatory; routed to the founder/board per charter)

- **FLAG-1 — H-17 (HIGH, trust-boundary + physical).** Recommend a standing
  **BLOCK**: do not ship `dispatchToOwners`-over-substrate, and do not enable any
  `critical` capability whose nonce could reach an unauthenticated `command_dispatch`
  writer, **until N1 lands.** Disposition: founder.
- **FLAG-2 — H-16 (HIGH, physical).** Do not ship a LAN-facing bridge: it actuates
  with less authz than the internal plane. Deploy the loopback bind (GATED).
- **FLAG-3 — Multi-session shared-working-copy hazard (process/safety).** Confirmed
  live this cycle. See `deliverables/operational-attack-surface-onboarding.md`.
- **FLAG-4 — Unversioned security knowledge base (continuity).** `C:\GitRepos\overnight\`
  is the only home of H-1..H-15 + the H-9 design + gate tooling + `.180` baselines.
- **FLAG-5 — H-9 §2 blocked on the un-run verifier sweep (gate hygiene).** The fix
  cannot safely proceed; the sweep (S1) must run first.

---

## d. DEPENDENCIES (what I need to start, and from whom)

- **D-1 (Founder):** disposition on FLAG-1 (does H-17/N1 block `dispatchToOwners`?).
  Recommendation: **yes, BLOCK the coupling.**
- **D-2 (Founder):** confirm the verifier sweep (S1) may run — it is read-only but
  reasons about off-box peers and `.180` outbound signatures. Recommendation: **go**
  (it's the gate everything else waits on).
- **D-3 (Founder):** decide the **permanent home** for the unversioned security
  knowledge base (FLAG-4). Options: a private `security/` dir in `pandora` (keeps it
  with the code it describes; but the disclosure article must stay separate per the
  invariant) — *recommended*; OR a dedicated private security repo; OR keep it on
  the host with an explicit backup. Trade-off: in-repo gives version history + the
  prior-art lineage benefit, at the cost of one more thing the secret-scan must guard.
- **D-4 (EA):** integrate the three `preview/audit-cycle-1` docs to `pandora` `main`
  (display case) so the findings register has a canonical, citable home; and confirm
  the **branch-isolation model** for the 8 sessions (per-session worktrees or clones)
  to close FLAG-3.
- **D-5 (Development, Div 1):** owns the N1/H-17 **source** fix and the Tier-1 cut
  merges. I provide the finding + the regression test; they remediate.
- **D-6 (Infra/Platform, Div 6):** implement the per-session worktree/clone change on
  the host (FLAG-3); provide read-only `.180` access for the sweep's live half.
- **D-7 (QA/Release-Eng, Div 3):** wire the invariant suite + the write-to-effect-map
  diff into the gate so a regression of any of these surfaces mechanically.
- **D-8 (Research/R&D, Div 7):** the evaluate-phase reconciliation of my AL-1..AL-4
  candidates into the living article.

---

## STOP / HOLD CONFIRMATION
No product-repo changes. No `.180` mutation (read-only introspection only). No merges
to `main` (mine or product). No gated/public/physical action taken. Loop not started.
Held — awaiting the founder turning the loop.
