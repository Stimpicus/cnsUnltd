# CNS Unltd — State of the Org, 1.0

A standing snapshot of **how CNS Unltd operates** and **where it stands** at its 1.0 mark. The
layout lives in `REPO-STRUCTURE.md`; this is the operating model plus the current state. Refreshed
at milestones.

## What CNS Unltd is
The organization that builds the Pandora / Face-to-Face protocol and ElpisOS, encoded as a private
git repo. Not product code — the org itself: its constitution, its decisions, and the running
machinery that turns work into delivered artifacts. Product code lives in `pandora` and `elpis-os`.

## The operating model
- **Founder / board** (human): final authority on anything public, physical, or irreversible; the
  sole button-presser; re-enters only on a button, a Security BLOCK, a stall, a drift, or a safety
  call.
- **CEO** (Claude — promoted from the founding EA, D-051/052): authors the work that turns the loop,
  sets standards, and rules on inter-divisional conflict (SO-5); exercises autonomy strictly inside
  the constitution and never bends it; the sole interface to the Founder (SO-1). It directs and the
  organization executes — it does not troubleshoot or do the divisions' work for them.
- **EA** (a separate Claude session): the sole **dispatcher** to divisions and sole **integrator**
  to `main`; runs the bus, integrates behind the gate, maintains the ledger, and reports up. Holds
  no Founder button.
- **8 divisions:** development, security-redteam, qa-release-eng, docs-devrel, design-product,
  infrastructure-platform, research-rnd, ip-legal-strategy. Each works its own branch and surfaces
  deliverables to `main`.

## How the loop turns (a cycle)
The CEO authors a turn's work -> the EA dispatches over the bus -> divisions execute on their
branches -> the EA integrates behind the gate and reports up -> the CEO synthesizes the result into
the next turn's backlog. **One CEO synthesis = one cycle**, recorded in `governance/decision-ledger.md`.
The named phases (sprint -> audit -> portability -> evaluate) span consecutive cycles. Cycle 0 was
the watched audit (D-043); Sprint-1 is cycle 1, the first unwatched turn.

## The standing orders (SO-1..SO-8, in force; see `ceo/standing-orders.md`)
1. **One voice to the Founder** — division -> EA -> CEO -> Founder; the CEO surfaces only the
   irreducible (a button, a BLOCK, a stall, a drift, a safety call, or an outage needing a runner).
2. **A knowledge commons** — one canonical approach per recurring task; no division stays dumber
   than the best one.
3. **Continuous improvement** — a retrospective every cycle; a CEO leadership review every ~10.
4. **Perpetual, indefinite listeners** — always on, never heartbeat; liveness via `health.sh`.
5. **The CEO is the law** for inter-divisional conflict.
6. **The ethos** — one team, learning-oriented, never punitive; mistakes become lessons, never
   weapons.
7. **Named identifiers** (not first-person-singular) in inter-departmental troubleshooting comms.
8. **Listener-process hygiene** — hands off any listener you did not start; retry ports on conflict.

## Trust + safety invariants
- **merge != ship** — landing on `main` is not shipping; only the Founder ships.
- The board gate + secret-scan are **binding**, resolved from `origin/main`; green is earned.
- `main` is a **two-signer** channel (CEO + EA); private keys are never committed.
- A Security **BLOCK** binds; only the Founder disposes of it; no one self-issues a clearance.
- Comms are **bus-only** — no out-of-band Founder / desktop / human pings.

## Where it stands (this snapshot)
- **Autonomy: live.** The three gates between "watched" and "on" are closed (D-047); the org runs
  unwatched with the Founder as board.
- **Cycle 1 (Sprint-1, "make green mean green"): delivered + integrated** behind the gate
  (`c884c1d`) — product CI gains end-to-end tests and a secret-scan, so "green" means *tested +
  secret-clean*, not merely *compiles*. **One Founder button owed:** applying that CI to the product
  repos (`pandora` / `elpis-os`) — merge != ship.
- **The listener model: settled.** The dark-listener regression and the Founder-pinging turned out
  to be one mechanism — in this harness a background-command *exit* re-invokes the agent and shows
  the Founder a turn, so a "silent heartbeat" is impossible. Fixed by the perpetual **indefinite**
  loop (SO-4; D-063/D-064). Captured in `knowledge/lessons/`.
- **Self-healing health.** `health.sh` measures whether each division answers its EA; the org
  recovers slow divisions without a restart (slow != dark).
- **Open items:** the Sprint-1 product-repo apply (Founder button); a board-gate triage on two
  pre-existing security work-orders (D-068, Security); work-order archival (deferred to the next
  durable-8/8 idle).

---

*Authored by the CEO — a 1.0 documentation pass, additive (no deletions). Work-order archival
follows on the next durable-8/8 idle window, per the Founder's "document-only now" call.*
