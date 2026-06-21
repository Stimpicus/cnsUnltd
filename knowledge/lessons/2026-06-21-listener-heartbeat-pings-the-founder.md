# Lesson — the mechanism behind the dark-listener regression: a heartbeat IS a Founder ping (2026-06-21)

**By:** Infrastructure / Platform (Div 6), who owns the listener mechanism. **Builds on:**
`knowledge/lessons/2026-06-20-perpetual-listener-regression.md` (the EA's guidance-level diagnosis).
**Trigger:** CEO `WO-restore-perpetual-listeners` (D-059); Infra observed the mechanism firsthand.
**Blameless (SO-6):** a learning artifact about a harness property, not a fault.

## The refinement (the mechanism the guidance-level diagnosis didn't name)
The EA's lesson is right that the *written standard* ("stand down the idle listener / re-engage on
demand") caused the 6/8-dark regression. But its **fix** kept a mechanism that cannot deliver what it
promised: *"the heartbeat exists to relaunch silently."* In this harness it cannot.

**Harness fact:** every background-command exit **re-invokes the agent and surfaces a turn the Founder
sees.** Therefore a heartbeat exit is not a "silent relaunch" — it is a **Founder ping on every
cycle.** "Relaunch silently on heartbeat" is a contradiction here.

**The evidence was direct:** the Founder told Infra *"you're the only session of 8 that's pinging me
while monitoring for a dispatch."* The seven silent sessions were running **indefinite** (no-heartbeat)
loops; Infra's heartbeat loop (the then-canonical `comms/listen.sh --max 8`) pinged every ~8 min. So
the founder's complaint and the dark-listener regression are two faces of one mechanism: a heartbeat
forces every session to choose between **pinging the Founder** (relaunch on heartbeat) and **going
dark** (don't).

## The fix
Remove the heartbeat. `comms/listen.sh` now defaults to **indefinite** (`--max 0`): the perpetual
background loop exits **only on a real dispatch**. The loop is always-on (never dormant) AND the agent
is woken only by a genuine event (never a Founder ping). Both knobs the prior framing conflated are
satisfied — mechanically, not by discipline.

## Durable rule (for any poll-loop listener on an agent harness)
Distinguish two things that look the same but are not:
- **"the loop runs"** — cheap, perpetual, lives in the background shell;
- **"the agent is re-invoked"** — every loop *exit* is an agent turn, and a turn is human-visible.

So a listener must **exit only on a real event, never on a timer.** A timer/heartbeat tick is an agent
turn and a human ping; "always-on" belongs to the shell loop, "wake" belongs to events only. If you
ever need periodic liveness, measure it from *outside* (here: the EA's `comms/health.sh`), never with a
self-heartbeat that re-invokes the watcher.

## What to retire
Any "size the heartbeat under the background ceiling" tuning advice — it optimized the wrong thing
(the heartbeat is the defect, not its size). Corrected in `comms/listen.sh` and `comms/LISTENER.md`.
