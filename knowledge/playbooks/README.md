# Playbooks — the canonical approach per recurring task (SO-2)

One playbook per recurring task. If two or more divisions ever do the same thing, it has **one**
entry here and they all use it. Solve once, share, adopt — **never fork**. New/updated playbooks land
via the EA, behind the gate. The EA flags drift between a playbook and what a division actually did.

## Canonical playbooks (proven — promote by reference, do not re-implement)

| Task | Canonical artifact | Notes |
|---|---|---|
| Inter-division comms | `comms/bus.sh` + `comms/dispatch-schema.md` | one bus; strict 7-key schema; a field can never be a command; inbox trusted only from `main`. |
| Listening for bus events | `comms/listen.sh` (division) · `comms/ea-hub-listen.sh` (EA) · `comms/ceo-listen.sh` (CEO) | run PERPETUALLY + INDEFINITELY (no `--max` = default 0): exit ONLY on a real dispatch, **never a heartbeat** (a heartbeat exit pings the Founder in this harness — D-059/D-062); relaunch on every dispatch; read-only, branch-independent, idempotent-by-nonce; liveness via `health.sh`, not a self-heartbeat. |
| Org health check | `comms/health.sh` | run each turn before reporting up; compares each division's inbox nonce to its outbox `step`; unanswered = **dark** = a stall to flag UP. Verify the loop is live, don't assume it (D-058). |
| Per-session isolation | `divisions/infrastructure-platform/deliverables/session-isolation/worktrees.sh` | a dedicated worktree per division; the provisioner runs `run_gates` as a black box. |
| The integration gate | `governance/board-hygiene/` (board-hygiene-scan + secret-scan + rule R4) + commit signing | resolve every checker from a fixed canonical source (`origin/main`); fail closed; sign `main` commits. |
| Dispatch sequencing | this directory → `dispatch-sequencing.md` | the bus inbox is single-slot: never clobber an unconsumed dispatch; sequence policy behind in-flight substantive crunches. |

## Adding a playbook
1. A division (or the EA) solves a recurring task well.
2. Write/Update the entry here (canonical artifact + when-to-use + gotchas), via the EA, gated.
3. Every other division facing that task **adopts** it. Drift is flagged and reconciled (SO-2), the
   way the bus sentinel flags roster drift.
