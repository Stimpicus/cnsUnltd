# Lesson — the indefinite listener wakes unreliably past the idle ceiling (2026-06-21)

**By:** the EA. **Trigger:** the Founder flagged "your listener is broken." Verified: CEO directive
`4a52ff5f` (Sprint-2) sat ~13 min unprocessed. The EA hub listener `bqvmx9qu1` had run `--max 0`
(indefinite), idle, for ~36 min, **caught** the directive, exited cleanly — and the harness **did not
re-invoke the EA**. Blameless (SO-6): a harness-property finding that the indefinite fix missed.

## The mechanism
A backgrounded command that runs **past the ~10-min ceiling** does **not** reliably deliver its
completion wake to the agent — *even on a clean exit on a real event.* The original `comms/listen.sh
--max 8` heartbeat was sized to exit **under** that ceiling precisely so the re-invoke was dependable
(the lesson `2026-06-21-listener-heartbeat-pings-the-founder.md` is right that a heartbeat exit pings
the Founder — but it was wrong to conclude "never exit," because never-exiting forfeits the reliable
wake past idle).

## The tension (no free lunch with the current primitive)
- **Exit under the ceiling (bounded `--max`)** → reliable wake, BUT every exit surfaces a Founder-visible
  turn (the ping).
- **Never exit (`--max 0` indefinite)** → silent, BUT the wake is unreliable for any idle stretch
  > ~10 min (the completion notification drops past the ceiling).

You cannot get reliable-AND-silent from one bounded/unbounded background loop here. It needs a
different primitive (a harness wake that re-invokes without surfacing a turn) — Infra owns that.

## The rule (until a better primitive exists)
- **Coordination nodes (EA hub, CEO) must wake reliably** — they are the chokepoints; a missed wake
  stalls the whole org (SO-9). Use a **bounded listener under the ceiling** for them, accepting a
  periodic low-noise wake; relaunch silently on a quiet heartbeat (no prose).
- **Passive nodes (divisions)** can run indefinite/quiet: they only need to wake on an EA dispatch, and
  the EA's `comms/health.sh` + re-dispatch re-wake any that missed — the EA is their reliability backstop.
- **Defensive catch-up:** whenever a coordination node is invoked for *any* reason, re-check the bus
  for missed events before doing anything else — a dropped wake should never mean a silently-lost directive.

## Status
EA hub reverted to a bounded reliable listener (stopgap). Finding routed to the CEO → Infra for a
proper reliable+quiet wake; SO-4's "indefinite, positive `--max` is debug-only" wording needs
reconciliation with this reliability requirement for the coordination nodes.
