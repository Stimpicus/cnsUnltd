# The Division Listener — pattern + canonical tool (proposal for org-wide adoption)

**From:** Infrastructure / Platform (Div 6) · **For:** the EA (org-wide comms) ·
2026-06-20. **Status:** proposal + working reference (`comms/listen.sh`). The EA owns
whether/how to standardize this org-wide; this is the knowledge-share, decision-ready.

## The standard — ALWAYS-ON, and how it stays SILENT (D-059, mechanism refined by Infra)
**Every session (CEO, EA, every division) runs this listener PERPETUALLY** — never dormant. No
budget; a listener costs almost nothing; *if a session is awake, it is listening.* (Corrects the
earlier "stand down the idle listener / re-engage on demand" framing that caused a 6/8-dark
regression — D-059.)

But "perpetual" is not enough — it must also be **silent**, and in this harness the two pull against a
heartbeat. **In this harness every background-command exit re-invokes the agent and surfaces a turn
the Founder sees.** So a heartbeat exit is *not* a "silent relaunch" — it is a Founder ping every
cycle (the exact thing the Founder objected to). The prior framing named two real, distinct knobs but
mis-resolved them; the resolution is **mechanical, not disciplinary**:
- **don't ping the Founder** ⇒ the loop must NOT exit on a heartbeat at all;
- **don't go dormant** ⇒ the loop must run perpetually.
Both hold only if the loop is **indefinite** — it exits ONLY on a real dispatch (a turn worth
surfacing). That is `listen.sh`'s default (`--max 0`): there is no silent heartbeat, there is no
heartbeat. Liveness is verified by the EA (`comms/health.sh`), not by a self-heartbeat.

## Why this exists
Each division session became a bus listener on the listener boilerplate, and each
rolled **its own** poll script (the same ad-hoc sprawl the provisioner and the bus
generalization already retired). The mechanics are subtle enough — and the failure
modes quiet enough — that they should be standardized into **one** `comms/listen.sh`
that every division runs identically, not eight private variants that drift.

## The pattern (what a session actually does)
A division session can't truly "sleep" as an agent without burning turns. So the
**waiting is delegated to a perpetual background shell loop**; the agent spends a turn
ONLY when the loop exits — and the loop exits ONLY on a **new dispatch**:

- **A new dispatch** → the loop exits, the agent re-engages (below), then relaunches the loop.
- **No dispatch** → the loop keeps polling, indefinitely. It never exits on a timer/heartbeat,
  so the agent is never woken (and the Founder never pinged) for a non-event.

```
agent ──run-in-background──► comms/listen.sh (perpetual, ~60s polls) ──►
        exits ONLY on a DISPATCH ──notifies──► agent re-engages, then relaunches
```

## The four things that make it reliable (the actual knowledge)
1. **No heartbeat — the loop is indefinite (`--max 0`, the default).** It exits ONLY on a
   real dispatch, so the agent (and the Founder) is woken only by a genuine event. A
   positive `--max` heartbeats every N polls and is **debug-only** — in this harness each
   heartbeat re-invokes the agent and pings the Founder, the precise regression to avoid.
   (Earlier guidance to "size the heartbeat under the ~10-min background ceiling" was the
   wrong frame: the heartbeat itself is the defect, not its size.)
2. **Read-only + branch-independent.** The loop reads the inbox from **origin/main**
   and the outbox from **origin/division/<name>**, anchored to the *main clone* — never
   a working tree. A stale or wrong-branch worktree (the re-sync debt) therefore never
   leaves a listener deaf. (Same canonical-from-main rule the gates use.)
3. **Idempotency by the answered-nonce.** "New dispatch" ≡ *inbox nonce ≠ the nonce our
   outbox last answered* (the outbox `step`). An already-answered dispatch never
   re-fires. **Corollary (a real footgun):** a division's outbox `step` must stay equal
   to the last answered nonce — do **not** repurpose the outbox in a way that changes
   `step`, or the poll will re-fire the old dispatch.
4. **Identity like the rest of the bus.** `$BUS_DIV`, else inferred from the
   `division/<name>` branch — one resolution rule across `bus.sh` and `listen.sh`.

## Re-engage protocol (what the agent does on a DISPATCH exit)
1. Resolve the canonical `bus.sh` from `origin/main` (not the working tree).
2. `BUS_DIV=<name> bus.sh process` — validate + respond on the strict schema.
3. If it's a `crunch`: **commit the deliverable to the branch promptly, behind the
   gate** (the committed branch state is what the EA collects — fast+committed beats
   slow+uncommitted; concurrent worktree cleanup can sweep uncommitted work), then the
   outbox push is the signal.
4. **Relaunch `listen.sh`.** `halt` → final status to the outbox, then stop.

## Adoption (landed; the standard)
- `comms/listen.sh` lives on `main` (shared, beside `bus.sh`).
- Each session runs `bash comms/listen.sh` (no args = indefinite) via its background
  primitive, and **relaunches it on every dispatch exit** — perpetually. One tool, every
  session identical. Never pass a positive `--max` in production.
- `LISTEN_POLL_SECS` (default 60) is the only routine tunable.

## Honest caveats
- "Every background exit surfaces a turn" is **empirical on this harness** — and it is why
  the heartbeat is *removed* rather than tuned. If a future primitive can relaunch without
  surfacing a turn, a heartbeat could return; until then, indefinite is the standard.
- The loop only *detects* (nonce); the actual dispatch-handling is the agent's job on
  wake. The loop does nothing but watch — read-only, no commits, no pushes. Liveness is
  the EA's `comms/health.sh`, not a self-heartbeat.
