# The Division Listener — pattern + canonical tool (proposal for org-wide adoption)

**From:** Infrastructure / Platform (Div 6) · **For:** the EA (org-wide comms) ·
2026-06-20. **Status:** proposal + working reference (`comms/listen.sh`). The EA owns
whether/how to standardize this org-wide; this is the knowledge-share, decision-ready.

## Why this exists
Each division session became a bus listener on the listener boilerplate, and each
rolled **its own** poll script (the same ad-hoc sprawl the provisioner and the bus
generalization already retired). The mechanics are subtle enough — and the failure
modes quiet enough — that they should be standardized into **one** `comms/listen.sh`
that every division runs identically, not eight private variants that drift.

## The pattern (what a session actually does)
A division session can't truly "sleep" as an agent without burning turns. So the
**waiting is delegated to a background shell loop**; the agent only spends a turn on an
**event**. The loop is read-only and exits on one of two things, re-invoking the agent:

1. **A new dispatch** → the agent re-engages (below).
2. **A heartbeat** (no dispatch after N polls) → the agent **silently relaunches** the
   loop. (Heartbeats are overhead noise; do not narrate them.)

```
agent ──run-in-background──► comms/listen.sh ──(polls origin/main ~60s)──►
        exits on DISPATCH or HEARTBEAT ──notifies──► agent re-engages / relaunches
```

## The four things that make it reliable (the actual knowledge)
1. **Size the heartbeat to exit CLEANLY under the background-command ceiling.** A
   backgrounded command is capped (~10 min on this harness). `--max 8` (~8 min @ 60s)
   exits *before* the cap, so re-invocation is a clean, reliable notification. Sizing
   `--max` *past* the ceiling risks a kill-on-timeout, which is not a dependable
   re-invoke. **This is the single non-obvious tuning fact.** (It also means the idle
   re-engagement cadence is ~8 min and cannot be made longer per-loop — it's a ceiling,
   not a choice; lower idle cost would need a different primitive, not a bigger `--max`.)
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

## Proposed adoption (EA's call)
- Land `comms/listen.sh` on `main` (shared, beside `bus.sh`).
- Each division runs `bash comms/listen.sh` via its background primitive and relaunches
  on exit (silently on heartbeat). One tool, eight identical listeners.
- Tune `--max` / `LISTEN_POLL_SECS` only if a session's background ceiling differs from
  the ~10-min assumption above.

## Honest caveats
- The ~10-min ceiling is **empirical on this harness**, not a guarantee — verify per
  environment; that's exactly why it's a tunable `--max`, not a hardcoded sleep.
- The loop proves *liveness* (heartbeat) and *detection* (nonce); the actual
  dispatch-handling is the agent's job on wake. The loop deliberately does nothing but
  watch — read-only, no commits, no pushes.
