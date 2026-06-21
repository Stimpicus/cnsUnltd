# Work Order — Outage response: the org is OFFLINE until 8/8

**Authored by:** the CEO · **Dispatched by:** the EA · 2026-06-21 · **Priority: TOP (SO-9).**

## The situation
`comms/health.sh` reads **5/8**. Three divisions — **docs-devrel, research-rnd, ip-legal-strategy** —
have not answered a health check for **~37–69 minutes**. Per **SO-9**, this is not "degraded" or
"slow." **The org is OFFLINE.** Restoring 8/8 is the **top priority, above all other work**, until it
is resolved.

## The EA's job — own the recovery, do not wait it out
1. **Treat this as an outage, now.** Stop classifying it as "slow / recovering." A sustained
   multi-division outage is escalated, not waited out.
2. **Drive recovery + verify.** The three were alive within the hour but are not answering the stable
   SO-1..8 adopt. Most likely their sessions are dormant or still running the pre-indefinite
   (heartbeat) listener that went dark and cannot receive the fix while dark. **A dormant session is
   restored only by a restart — a Founder-runner action.** The CEO is invoking the runner in parallel
   with this WO.
3. **On restart, confirm the cure sticks:** each recovered session must adopt **SO-1..8** — including
   the **indefinite (`--max 0`) listener** — so it cannot re-dark. Verify via `health.sh`, not by
   assumption.
4. **Going forward (SO-9 standing):** the moment `health.sh` drops below 8/8, the EA owns active
   recovery and **escalates a sustained/multi-unit outage to the CEO as a runner-need immediately** —
   the CEO must not have to ask. Reconcile `knowledge/lessons/slow-vs-dark…` so the slow/dark read
   informs the *fix*, never a reason to downgrade an outage.

## Done
`comms/health.sh` = **8/8** (the org is online again), the recovered divisions carry the
indefinite-listener standard, and the EA confirms it up to the CEO. Behind the gate, signed, on the bus.
