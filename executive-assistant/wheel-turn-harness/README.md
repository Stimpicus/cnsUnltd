# Wheel-Turn Harness — prove worktree isolation + bus coordination at exact 8×

**Owner:** the **EA** (adjudicates). **Provisioner under test:** Infra's
`divisions/infrastructure-platform/deliverables/session-isolation/worktrees.sh` — called
as a **black box**; the EA does not modify or judge its internals (that is Infra's).

## What PASS means
Eight **truly-parallel** lanes each: provision an isolated worktree (via the provisioner)
→ write a benign heartbeat `divisions/<name>/status/wheel-turn-test-<id>.md` → **guarded
commit** (+push) → dispatch over the bus. **PASS = all eight merge clean under the full
gate, each heartbeat on its OWN branch, the shared MAIN clone HEAD never hijacked** — i.e.
the R-5 HEAD race cannot occur at exact 8× concurrency, and the bus coordinates 8 sessions.

## Design decisions (surfaced + confirmed 2026-06-20 — not guessed)
- **D-H1 true-parallel launch = BARRIER-SYNCHRONIZED.** Each lane provisions + stages, then
  blocks on a shared `GO` barrier; the harness releases all 8 at once, so their guarded-commit
  critical sections fire at the same instant — maximal race exposure, "exact 8×." (Portable
  spin-barrier; no `mkfifo` dependency on Windows Git Bash.)
- **D-H2 race detection = IN-LANE GUARD + POST-HOC ADJUDICATION.** In-lane: the provisioner's
  guarded `commit` asserts `branch==lane` (fail-fast at the instant of race) + each lane's exit
  is recorded. Post-hoc (EA): each branch holds exactly its own heartbeat, none on a wrong
  branch, `worktrees.sh doctor` confirms the MAIN clone HEAD is un-hijacked, all 8 merge clean.

## How to run
1. `bash wheel-turn.sh --preflight` — checks preconditions; **fail-closed**.
2. `CNS_WHEEL_TURN_GO=1 bash wheel-turn.sh --run` — fires the 8 lanes (the founder-gated turn).
3. `bash wheel-turn.sh --adjudicate` — EA post-hoc checks; then the EA performs the **8-way
   merge to `main` under the full gate** (board-hygiene + secret-scan + structural). PASS needs
   all eight to merge with **zero conflict** (disjoint `divisions/<name>/status/` paths ⇒ expected).

## Preconditions — must be met before the live run (surfaced, not assumed)
- **P1 — provisioner available.** `worktrees.sh` must be on the running branch (land
  `feature/session-isolation-provisioner`, or set `CNS_PROVISIONER`); preflight runs its `--self-test`.
- **P2 — bus generalized for 8 divisions.** `comms/bus.sh` is hardcoded `DIV=infrastructure-platform`
  and **cannot dispatch 8 divisions as-is.** Until Infra parameterizes `DIV` (per-division
  inbox/outbox), the dispatch leg is **SKIPPED + flagged** — worktree isolation is still proven,
  but the bus-coordination half of the claim is **deferred**. Generalizing the bus is Infra's
  (the bus is Infra's, like the provisioner). Set `CNS_BUS_GENERALIZED=1` once it accepts `BUS_DIV`.
- **P3 — founder go.** The live 8× turn **is** the founder-gated wheel-turn, and Security's
  bus-clearance (STEP 5.1) precedes any real-load bus use. `CNS_WHEEL_TURN_GO=1` gates `--run`.

## Knobs (env)
`CNS_PROVISIONER` · `CNS_SESSION_REGISTRY` · `CNS_BUS_GENERALIZED` · `CNS_WHEEL_TURN_GO` ·
`CNS_WHEEL_RUN_ID` · `CNS_WHEEL_WORKDIR`.

*Built ready-to-run; the EA does not fire the live turn (founder-gated). The provisioner is
Infra's and under test; the EA adjudicates the result.*
