# WORK ORDER — Cron Dispatch Monitor
## Standardize every CC session on a scheduled dispatch check
### (Supersedes the Listener Health System WO)

**Authored by:** the chat-CEO
**Repo:** cnsUnltd
**Lead:** Infrastructure/Platform (Div6)
**Dispatch:** EA → `crunch` to Div6, with Div2 / Div3 / Div4 as below
**Supersedes:** All listener dispatch protocols

---

### Why
The listeners died because they were long-lived processes that timed out, and respawning them on a timer overwhelmed the app. Cron inverts the model: a short scheduled job wakes, checks the dispatch location, acts, and exits — nothing long-lived to time out, nothing to keep alive or restart. If it fires unattended, it dissolves nearly all of the prior design.

### Phase 0 — VERIFY FIRST (gates everything; Infra)
Before standardizing anything:
1. **Characterize it.** Establish what "Claude Code cron" actually is on the **Windows desktop-app** environment — where the schedule lives (OS / Task-Scheduler level vs. in-session) and what runs each tick. Don't assume Unix cron.
2. **Verify it fires unattended** — across the exact condition that killed the listeners: session idle, no one interacting, app backgrounded.
- Fires independently of the session being active → proceed.
- Idles out with the session → it has the same disease; **STOP and escalate to CEO/Founder.** (This is the gate that would have saved the last build.)

Green is earned: report the result, not an assertion.

### The standard
Every CC session maintains one scheduled job — the **dispatch monitor** — that, each tick:
1. **Reads** its authoritative dispatch location from the **fixed authoritative source** — EA→division: its `ea_dispatch` on `main`; CEO↔EA: the CEO/EA inbox. No overridable path (carry the F1 fence forward).
2. **Validates and acts** on any new command through the **same path the listener used** — the command allowlist, `validate_block`, the forbidden-verb guard, enum→pre-written handler. **Never executes file contents.** A cron reader is a reader swap, not a validation downgrade.
3. **Stamps a liveness timestamp** — "alive as of now."

Stagger the schedules (or confirm simultaneous reads are harmless) so 8+ jobs don't herd `main`.

### Liveness — the one thing cron doesn't give free
A cron job can silently stop (removed, errored, scheduler hiccup) → the org goes dark undetected, which is the failure that started this whole effort. So:
- Each session's tick stamps a **heartbeat timestamp** (now an honest name).
- The **EA** runs its own scheduled job that reads `comms/divisions.list` (the authoritative roster) and checks each division's stamp; a stamp stale past threshold → **EA escalates to the human.**
- EA-unreachable / the EA's own job gone stale → **the human is the backstop** — root of the tree, as ever.

Mechanism is Infra/EA's call (a dedicated stamp, or piggyback on dispatch-ack), but **"notice when a session dies → tell the human" is required, not optional.**

### Who does what
- **Infra (Div6) — LEAD / build:** Phase-0 characterization + unattended-fire verification; the dispatch-monitor cron, the liveness stamp, the EA's staleness-check job; stagger.
- **EA — operate / escalate:** runs the staleness-check cron over `divisions.list`; owns stale→human and EA-unreachable→human.
- **Security (Div2) — BINDING:** confirm the cron read-path enforces the bus's existing validation + allowlist + forbidden-verb guard + chokepoint + F1 fence — no validation downgrade, no overridable path, never executes file contents. BLOCK authority stands.
- **QA (Div3) — verify:** cron fires unattended (Phase-0 result holds at scale); a killed session is caught as stale and escalated; a malformed/forbidden dispatch is rejected by the cron reader exactly as by the listener; no herd. Green earned.
- **Docs (Div4):** document the dispatch-monitor + heartbeat-stamp vocabulary; retire the "heartbeat" mislabel for good.
- **Dev (Div1), Design (Div5), R&D (Div7), IP (Div8):** no role this turn.

### Acceptance — EA-adjudicated soak test (never self-report)
Run all sessions on the cron standard, unattended, for a sustained window. Then:
1. **Dispatch a benign command** to each division via cron-pickup → all act, with no persistent listener anywhere.
2. **Kill a session** → its stamp goes stale → the EA escalates to the human; no silent loss.
3. **Send a malformed / forbidden dispatch** → the cron reader rejects it (allowlist + forbidden-verb guard hold).
4. **Kill the EA** → the EA-staleness backstop surfaces it to the human.

**PASS** = monitoring works unattended, deaths are noticed, validation holds, and the app is never overwhelmed across the full window.

### Done → then
Built and signed on `main`; Security CLEAR (cron read-path cleared as a write-to-execute surface); QA + EA acceptance PASS; docs updated and the mislabel retired. **Then re-run the FINAL directive and attempt the handoff for real.**
