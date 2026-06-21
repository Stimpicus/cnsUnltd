# Work Order — 5-minute SILENT-heartbeat listeners (Founder order)

**Direction authored by:** the Founder (via the EA). **Propagated by:** the EA — **one identical WO to
all eight divisions.** **Classification:** standing listener-protocol change. ACK + adopt; no product
deliverable. Supersedes the indefinite (`--max 0`) listener for every session.

## Why
An indefinite (no-heartbeat) listener silently **missed a CEO directive**: a background command that
runs past the ~10-min ceiling does not reliably deliver its completion wake (D-076). The fix is a
**5-minute heartbeat** — short enough to exit **under** the ceiling, so the re-invoke is dependable —
that is also **SILENT**, so it never pings the Founder. Reliable **and** quiet. (The Founder is pinged
by agent *chatter*, not by the mechanism; so the cure is to relaunch silently, not to stop heartbeating.)

## Step 0 — MANDATORY FIRST: shut down all background tasks THIS session started
Before launching the new listener, **stop every background task your own session started** — most
importantly any listener instance(s) you previously launched — so exactly **one** listener runs under
the new protocol and no stale/duplicate loops linger (duplicate loops cause confused/dropped wakes).
- Stop **only what your session started** (SO-8: never close a listener you did not start — leave other
  sessions' listeners alone).
- Identify yours by command (e.g. processes running `comms/listen.sh`) and the task ids your session
  launched; terminate them; verify none of your own remain.

## Step 1 — launch exactly one listener under the new protocol
Run the canonical listener via your background primitive — **no `--max` argument** (the default is now
the 5-minute heartbeat):

```sh
bash comms/listen.sh        # default --max 5 = 5-min heartbeat @ 60s poll; dispatches still caught within ~60s
```

## The SILENT-heartbeat contract (how every session behaves)
- On a **DISPATCH** exit → re-engage normally: resolve `bus.sh` from `origin/main`, `process` behind the
  gate, push the outbox, then **relaunch the listener** (Step 1). This is a real turn.
- On a **HEARTBEAT** exit (5 min, no dispatch) → **relaunch the listener and say NOTHING.** Zero
  Founder-facing output — no prose, no narration, no status. The heartbeat exists only to keep the
  wake dependable; it must be invisible.
- Liveness is verified by the EA's `comms/health.sh`, not by anything the heartbeat prints.

## ACK
Acknowledge on your outbox (`bus.sh process` → `ack` re this dispatch's nonce). Then run the protocol:
Step 0 (shut down your own background tasks) → Step 1 (launch the one 5-min silent listener) → live it.
