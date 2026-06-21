# WORK ORDER (TRACKING STUB) — Infra Crunch: Systematic Per-Session Isolation

> **STATUS: TRACKED — authored content pending; not yet run.** Placed on `main` per
> CEO directive (2026-06-19) so the WO is visible on the board. The full instructions
> were *referenced* (by the comms-bus and mathSavant WOs) but were never authored into
> the repo. This stub records **identity + status only** — it does not invent the WO's
> steps. Replace it verbatim with the authored WO when it arrives (same migrate-discipline).

**Owner:** Infrastructure / Platform (Div 6). **Dispatch / integrate:** EA.
**Type:** the *systematic* per-session isolation fix — the durable replacement for the
manual single-worktree stopgap.

## What it is
The systematic fix for the **R-5** defect: the division / EA / instrument sessions share
one working clone, so concurrent checkouts race the global `HEAD` and a commit can land
on the wrong branch (observed live during founding intake). This WO builds per-session
isolation so the 8× swarm can run concurrently without the race.

## Current state (what IS, as of 2026-06-19)
- **Mitigation in place:** the **manual single `git worktree` per session** (the same
  stopgap used to build the bus and the savant grind). This is *not* the systematic fix.
- **Systematic fix:** **NOT built.**
- **Validation — the EA-adjudicated 8× concurrent wheel-turn:** **NOT run.**
- **Gating:** this is the first real-load `crunch` on the comms bus, reserved as a
  **founder-gated** step (bus STEP 5 / first wheel-turn). The founder presses.
- **Candidate implementation (queued, NOT adjudicated — CEO 2026-06-19):** Infra's branch
  `feature/session-isolation-provisioner` @ `840eef5` carries the provisioner work. It is
  in the EA's hands for the **eventual** wheel-turn integration; per CEO direction it is
  **not adjudicated yet** (no review, no integration decision) — it waits on the founder go
  and the Security-cleared bus.

## Carried references
- The bus it would ride: `comms/dispatch-schema.md`, `comms/bus.sh`.
- Ledger / findings: Infra R-5, Security FLAG-3, D-020 (bus proven), D-022 / D-025
  (manual worktrees), and the re-sync debt logged alongside this (see decision ledger).
