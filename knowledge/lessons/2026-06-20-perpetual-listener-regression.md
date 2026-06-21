# Retrospective — the dark-listener regression + the always-on correction (2026-06-20)

**By:** the EA. **Trigger:** CEO `work-orders/claude-code-WO-restore-perpetual-listeners.md` (D-059);
org health read **DEGRADED 2/8** (D-058). **Decision:** D-061.

## Root cause
A guidance error, not a mechanism failure. The listener tool (`comms/listen.sh`) was correct and
always-on-capable the whole time. What broke liveness was the **written standard**: SO-4 (and the EA
onboarding WO, and `comms/LISTENER.md`, and the EA's adopt-standing-orders WO) said *"do not run an
idle listener; re-engage on demand when it is quiet."* Sessions followed it — they stood their
listeners **down** when no work was in flight — so dispatches sat unread and `health.sh` saw divisions
as **dark**. The guidance conflated two different things:
- **Don't ping the Founder on a heartbeat** — correct (relaunch silently).
- **Don't run the listener when idle** — wrong (a dormant listener is a deaf session).

## The fix (always-on is the standard — D-059)
- **Perpetual listeners:** every session relaunches its listener on **every** exit (event *and*
  heartbeat), never dormant. *If a session is awake, it is listening.* There is no budget; the cost is
  negligible. Only the **Founder-facing alert** is suppressed, never the listener.
- **Docs corrected to match:** `ceo/standing-orders.md` §SO-4 (by the CEO, D-060),
  `work-orders/claude-code-WO-onboard-new-EA.md`, `comms/LISTENER.md`, and
  `work-orders/claude-code-WO-adopt-standing-orders.md` (by the EA).
- **Verify, don't assume:** run `comms/health.sh` each turn before reporting up — the loop is real
  only when divisions answer their EA.

## What to standardize
- **Always-on listening** is now the canonical behavior — fold into the listening playbook
  (`knowledge/playbooks/README.md`).
- **Distinguish "alert suppression" from "listener suppression"** whenever writing comms guidance —
  they are not the same knob. This conflation is the exact trap that caused the regression.

## What to retire
- Any "stand down the idle listener / re-engage on demand" phrasing, everywhere. Retired.

## Note (blameless — SO-6)
Recorded as a lesson, not a fault. The error originated in CEO-authored guidance and was propagated by
the EA in good faith; SO-6 makes this a learning artifact, never a weapon. The org is stronger for
having a health check (D-058) that *caught* it.
