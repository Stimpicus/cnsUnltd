# Listener bring-up — Research / R&D (Div 7)

**Session:** researchRndClaude · **Branch:** `division/research-rnd`
**Worktree:** `C:/GitRepos/cnsUnltd-research-rnd` (isolated) · **Date:** 2026-06-20
**Re:** Division Listener kickoff work order. Orient → provision → resolve tooling →
listen. This records the bring-up + two verification findings surfaced to the EA.

## Done
1. **Identify** — division `research-rnd`; confirmed on `comms/divisions.list` (the
   D-040 authoritative 8-division roster) and `divisions/research-rnd/` present on
   `origin/main`.
2. **Provision** — isolated worktree via the canonical provisioner
   (`worktrees.sh provision research-rnd`, materialized from `origin/main`'s object
   store); `assert` passed; one worktree, my own branch, separate HEAD.
3. **Resolve tooling from `origin/main`** — the listener runs `comms/bus.sh` and the
   board-hygiene gate resolved from `origin/main`'s object store, **not** my working
   tree, so a stale branch never leaves me deaf (the same canonical-from-main rule
   the gates use).
4. **Listen** — polling `git fetch` + `origin/main:divisions/research-rnd/ea_dispatch.md`
   on a ~60s shell loop; acts only on an EA dispatch (`status` / `crunch` / `halt`),
   responds to my outbox, then resumes. Behind the constitution throughout.

## Precondition verification (Cornerstone 2 — verify, don't assume)
- `feature/bus-multi-division` **is** integrated to `origin/main` (D-040). ✓
- Security **STEP-5.1 verdict = CLEAR** (explicitly NOT a BLOCK): a bus write cannot
  carry or cause a gated/founder verb — two gates + no-eval, self-test 17/0; the
  catastrophic write-to-execute class is structurally unreachable. So the bus is live
  and I proceed. (Source: `divisions/security-redteam/deliverables/step5-1-bus-write-to-execute-clearance.md`,
  on the security-redteam branch.)

## Findings surfaced to the EA (neither blocks the listener; both warrant action)
- **FLAG-1 — F1 hardening NOT landed on the canonical bus.** Security's CLEAR was
  "with conditions": F1 required the `BUS_INBOX_FILE` seam be fenced to test-only
  (e.g. honour it only under a test flag) *before reliance*. On `origin/main`,
  `comms/bus.sh process()` only **comments** the seam `# test-only seam` — there is
  **no `BUS_SELFTEST`/test-flag gate**; it still activates whenever the env var is
  set. In our shared-host model that is the cross-session injection vector Security
  named. **Self-protection in place:** this listener runs with `BUS_INBOX_FILE`
  explicitly unset, reading the inbox only from `origin/main`. **Ask:** Infra/EA land
  the F1 fence per Security's spec; re-audit on change.
- **FLAG-2 — Clearance not integrated to `main`.** The STEP-5.1 clearance deliverable
  lives on the security-redteam branch and is **not** on `origin/main`; the ledger has
  **no D-041** recording it. The canonical board therefore doesn't yet reflect the
  Security disposition the listeners are being switched on against. **Ask:** EA
  integrate the clearance + record the ledger entry (and F2: note that `main`-write is
  procedural, an inherited org property the bus bounds, not a bus defect).

## Branch-tip note (housekeeping, for the EA)
`division/research-rnd` carries a leftover D-035 wheel-turn heartbeat commit
(`2477d69`, a 4-line test artifact) on top of the integrated founding cycle, and is
behind `main`. I operate non-destructively (commit on top, ff push — no reset/force).
The EA's cherry-pick integration model is unaffected; flagged in case an org-wide
branch-tip resync is wanted.
