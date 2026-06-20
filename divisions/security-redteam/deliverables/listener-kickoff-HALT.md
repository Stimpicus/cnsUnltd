# Division Listener kickoff — **HALT and report** (precondition not met)

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** the "Become a persistent bus listener" work order. Its precondition: *"Step 0 is
done — `feature/bus-multi-division` is integrated to `main` and Security has cleared it
(STEP-5.1). If the bus isn't live, halt and report."*
**Decision: HALT.** I am **not** starting the listener loop. Reasons + the unblock below.

---

## Why halt (verified on `origin/main @ 7437750`, not assumed)

The precondition "Security has cleared it" is **only partially met.** My STEP-5.1 verdict
(`step5-1-bus-write-to-execute-clearance.md`) was **CLEAR *with two required-before-reliance
hardenings*** — and *becoming a persistent listener is exactly "relying on the bus as the
tamper-evident dispatch authority."* As the **Security division**, I am the holder of that
condition; proceeding while it is unmet is the Boromir exception the charter forbids
("guard the rules hardest when most convinced there's a good reason not to").

1. **F1 is still UNFENCED.** `comms/bus.sh:119` honours `BUS_INBOX_FILE` unconditionally
   (`if [ -n "${BUS_INBOX_FILE:-}" ]` — comment says "test-only seam," but there is **no**
   `BUS_SELFTEST` guard). So a local actor with env control (plausible in the shared-host,
   8-session model — `operational-attack-surface-onboarding.md`) can feed a listener a
   dispatch that never went through `main`/EA — bypassing the single-`main` chokepoint and
   the git audit trail. Bounded to allowlisted verbs (no actuation), but it is precisely the
   "fence before reliance" condition, and the listener is reliance.
2. **The clearance is not integrated to `main` nor ledger-ratified.** The decision ledger
   ends at **D-040**; STEP-5/5.1 remains a **"founder-gated, sequenced, NOT run"** item
   ("only after Security clears it, the bus's first real-load dispatch is `crunch` to
   Infra…each is a separate founder go"). My STEP-5.1 deliverable lives on this division
   branch, **not on `main`.**
3. **The go has not been given.** Infra's inbox on `main`
   (`divisions/infrastructure-platform/ea_dispatch.md`) reads verbatim:
   *"STEP 5 — not placed here until Security clears the bus."* The EA has placed **no**
   dispatch. There is nothing to listen for, and the sequence's gate is still closed.

A sibling division (QA/qaReleaseEngClaude) independently reached the same HALT on this
kickoff — corroboration, not a lone read.

This is not me overriding the CEO's "Security has cleared it." It is me surfacing that the
clearance was **conditional**, a condition is **unmet**, and the org record shows the
founder go is **not yet given** — exactly the disposition the founder (not the CEO, not me)
makes.

## What unblocks it (any of these is the founder's to dispose)

- **U1 — Fence F1 (the clean path; I've specified the exact fix).** Gate the seam behind an
  explicit test flag so production never honours it:
  ```diff
  - if [ -n "${BUS_INBOX_FILE:-}" ]; then            # test-only seam
  + if [ -n "${BUS_INBOX_FILE:-}" ] && [ "${BUS_SELFTEST:-}" = "1" ]; then   # test-only seam (gated)
  ```
  `comms/bus.sh` is Infra's tool — Infra/EA author it, I re-verify (the seam is ignored in
  production; the inbox always resolves from `origin/main`). Trivial, one line.
- **U2 — Integrate + ratify the clearance** (a D-041-style ledger entry recording the
  STEP-5.1 CLEAR + the F1/F2 conditions and their disposition), so "Security has cleared it"
  is a record, not a claim.
- **U3 — The sequenced founder go** for the bus's first real-load dispatch (per D-040 /
  D-034 P3). When the EA places a dispatch in my inbox on `main`, there is something to
  listen for.

On U1+U2 (and the founder's go), I will **immediately** stand up the listener — the
mechanics are ready (isolated worktree + a branch-independent poller reading the inbox from
`origin/main`); only the precondition is missing.

## Held at
No listener loop started. No reliance on the bus. No `.180`, no gated op, no merge to
`main`. I aborted an attempt to bring my (stale) branch current with `main` — note it
tripped the secret-gate on `board-hygiene-scan.sh`'s own private-key-banner *self-test
fixture* (a false positive, the gate erring safe). That is a **minor, separate** finding
worth noting because **every** division branch predates `board-hygiene/` and will hit it
when bringing its branch current — flag for Infra/EA (e.g. make `secret-scan.sh` skip the
scanner files, or self-skip the fixture line). Not a blocker here.
