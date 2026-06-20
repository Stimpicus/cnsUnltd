# STEP-5.1 — Bus write-to-execute audit → **CLEAR** (2 required hardenings before reliance)

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** CEO — audit the integrated comms bus as a live write-to-execute instance
(roster-source · verb allowlist · single-main-chokepoint write-auth). Clear or BLOCK
(binding). **Subject:** `comms/bus.sh`, `comms/dispatch-schema.md`, `comms/divisions.list`
on `origin/main @ 7437750`. Read-only audit; the implementation was checked against the
schema **and run** (self-test 17/0).

---

## VERDICT: **CLEAR** of the write-to-execute class.

A bus write **cannot carry or cause a gated / founder-button verb** — that load-bearing
property holds **by construction** and is verified. No finding opens a path from a bus
write to a gated or actuating effect, so I do **not** issue a binding BLOCK. Two
write-auth hardenings (§3) bound to *coordination forgery / auditability*, not actuation;
**fence them before the bus is relied on as the tamper-evident dispatch authority.**

The lens: *does a write produce an effect disproportionate to its authorization?* The
maximal effect of any bus write is **mobilize a session to bounded work / halt it** —
never deploy/flash/merge/sign. The catastrophic class is structurally unreachable.

---

## 1. Roster-source → **CLEAR**

Authoritative roster = the committed allowlist `comms/divisions.list` (a deliberate
**8-division** list; D2, founder-decided 2026-06-20). `roster()`/`on_roster()` recognise a
division **only** if listed; membership is **never** auto-granted from a `divisions/<name>/`
dir — auto-discovery is demoted to a `sentinel` that only *flags* drift. Verified: self-test
shows roster = exactly 8, **excludes** `research-mathsavant` (an instrument), sentinel clean.
- *Minor hardening (not a gap):* `roster()` reads `divisions.list` from the working tree
  (`$REPO_ROOT`), not pinned to `origin/main`. This only gates **name resolution**; the
  **effect-bearing** read (the inbox a spoke acts on) is pinned to `origin/main` (§3), so it
  is not a write-to-execute gap. Pinning the roster read to `origin/main` too would align it
  with R4, but is not required for clearance.

## 2. Verb allowlist — the hub cannot emit a gated verb → **CLEAR (strong)**

Defended at **two independent gates**, both verified by code and self-test:
- **Hub** (`cmd_dispatch`): `case "$verb"` permits only `status|halt|crunch`; everything else
  → *"verb not on allowlist … the bus carries no gated verb"* (rc 2). The hub literally
  cannot write a gated verb into an inbox.
- **Spoke** (`validate_block`, inbound): `command ∈ {status,crunch,halt}` only, **and** a
  `FORBIDDEN` set (`deploy|merge|flash|publish|push|apply|reboot|delete|rotate|sign|install|build`)
  is rejected **by name** as `ATTACK` (rc 2) even though it is also off the allowlist.
- **No field is ever the command.** Exactly 7 keys are parsed from one fenced block and
  regex-validated; values are never `eval`/sourced/interpolated. `command` is a validated
  **enum that selects a pre-written handler** (`case`). `wo` is charset-restricted
  (`^[A-Za-z0-9._-]+$`), only path-checked + echoed, never executed. Self-test confirms an
  injection attempt (`command: status; rm -rf /`) → **INVALID**, and `deploy` → **ATTACK**.
- **`crunch` is bounded:** requires a `wo` that **exists on `origin/main`**
  (`git cat-file -e origin/main:work-orders/$wo`) — a session can't be crunched onto an
  arbitrary/forged work order; and the crunched session still runs inside the constitution
  (branch-only, merge≠ship, no `.180`, all downstream gates intact).
- *Minor (cosmetic, not a gap):* `wo` permits a dot-only value (`.`/`..`); the existence
  check then resolves a tree object and the handler writes an `ack` — no read/exec, no
  actuation. Optionally reject dot-only `wo`.

**Conclusion:** the hub cannot emit a gated verb; a write's effect is capped at
status/crunch/halt by two gates plus the no-eval property. This is the core clearance.

## 3. Single-main-chokepoint write-auth → **CLEAR by construction; 2 findings (integrity/auditability, not actuation)**

By design, a spoke trusts its inbox **only when read from `origin/main`** (`process()` →
`git show origin/main:divisions/<div>/ea_dispatch.md`), and writes **only its own** branch's
outbox (`git push origin HEAD:division/<div>`). A division therefore cannot place an
authoritative EA command nor forge another division's command. Two findings:

- **F1 — `BUS_INBOX_FILE` env seam (MEDIUM in the shared-host model; fence before go-live).**
  `process()` reads the inbox from an arbitrary local file if `BUS_INBOX_FILE` is set —
  **bypassing the `main` chokepoint and the git audit trail**, an undocumented deviation from
  the stated "trusted only from `main`" model. The dispatch still must pass `validate_block`,
  so the effect stays **bounded to allowlisted verbs** (no gated verb). It requires control of
  the listener's environment — but in *this* deployment (8 sessions, shared host/working
  copies — see `operational-attack-surface-onboarding.md`), one session influencing another's
  launch environment is a plausible cross-session injection. **Required hardening:** gate the
  seam behind an explicit test flag (e.g. honour it only under `BUS_SELFTEST=1`) or strip it
  from the production entrypoint, and document it in `dispatch-schema.md`. Until then the bus
  is not the tamper-evident authority it claims to be.

- **F2 — `main`-write is PROCEDURAL, not enforced (MEDIUM, org-level — inherited, not
  bus-specific).** The whole dim-3 thesis rests on "only the EA integrates `main`." Verified:
  `origin/main` has **no branch protection** (GitHub free **private** tier — the protection
  API returns 403 "Upgrade to Pro," confirmed), and sessions share push credentials
  (`push: true`). So "only the EA writes `main`" is **discipline, not a control**: any actor
  with push creds could commit a forged `ea_dispatch` to `main`. **But** (a) a forged dispatch
  still passes `validate_block` → **allowlisted verbs only** (no gated verb — the bus caps the
  blast radius), and (b) this is an **org-wide** property the bus *inherits* — the same gap
  lets a session forge a ledger entry or a work-order; the bus neither creates nor widens it.
  **Recommendation (org-infra, not a bus fix):** recognise main-write as procedural; if
  stronger enforcement is wanted later, it is signed commits / a server-side gate / a paid-tier
  branch-protection+CODEOWNERS decision for the founder — out of scope for this clearance.

---

## Evidence
- `bus.sh --self-test` in a clean 8-division tree: **17 passed / 0 failed** — forbidden verb
  → ATTACK; injection, forged issuer, wrong `to`, bad timestamp/nonce, extra key,
  crunch-without-wo → INVALID; roster=8 excl. instrument; sentinel clean.
- Branch-protection probe: `GET …/branches/main/protection` → **403 (unavailable on free
  private)**; repo `private:true`, token `push:true`.
- Schema vs code: implementation matches the security thesis; one stale prose spot — the
  schema's *"Identity & the hub"* paragraph still says the roster is "auto-discovered, not a
  hardcoded list," which the **D2 decision + the code (allowlist)** supersede. Doc-only; the
  code is correct. Recommend updating that paragraph.

## Bottom line
**CLEAR** — the integrated bus is structurally safe against write-to-execute: it cannot emit
or cause a gated verb (two gates + no-eval, verified 17/0), the roster is an explicit
committed allowlist, and the blast radius is capped by construction regardless of write-auth
enforcement. **Two required-before-reliance hardenings:** (F1) fence the `BUS_INBOX_FILE`
seam to test-only; (F2) record that `main`-write is procedural (an inherited org property the
bus bounds, not a bus defect). Neither opens an actuation path, so this is a CLEAR with
conditions, not a BLOCK. Re-audit on any change to the verb allowlist, the `FORBIDDEN` set,
the handler `case`, or the inbox-resolution path.
