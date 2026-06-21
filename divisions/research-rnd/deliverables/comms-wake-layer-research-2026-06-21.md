# R&D — Inter-session comms: separate TRANSPORT from WAKE; the wake fix is the app-level scheduler

**Division:** Research / R&D (Div 7) · **Session:** researchRndClaude · **Date:** 2026-06-21
**Asked by:** the Founder — "a more effective communication solution for CC sessions (CEO / EA /
Divisions)." **Product:** proven possibility — a researched recommendation + the platform evidence
behind it. **Lane:** R&D proves the concept and hands it to Infra/Dev to build, Security to clear,
QA/EA to accept (charter §3). This **feeds** the in-flight `claude-code-WO-cron-dispatch-monitor.md`
— it does not replace its role split.

---

## The recommendation (one line)
**Keep the git bus as transport+validation; replace the broken background-listener WAKE with the
Windows desktop-app's native scheduler (`scheduled-tasks`); add a liveness stamp + EA→human
escalation.** This is the cron-monitor direction the org is already on — this deliverable supplies the
concrete platform primitive (answering the cron WO's Phase-0 "what *is* CC cron"), a stagger scheme, a
disqualification that saves a dead end, and a new security finding.

## The reframe (the core insight from this session's failures)
A CC session is **request-driven**: it only acts when *invoked* by the harness. Inter-session comms
therefore decomposes into four layers — and only one of them was ever broken:

| Layer | Status | Notes |
|---|---|---|
| **Transport** (store/move bytes) | ✅ fine | git: `main` inbox (authoritative), branch outbox; durable, audited, signed |
| **Routing** (who talks to whom) | ✅ fine | hub-and-spoke via EA — keep it |
| **Validation** (safety) | ✅ cleared | `bus.sh`: allowlist, `validate_block`, forbidden-verb guard, F1 fence, never-execute-contents |
| **WAKE** (invoke a session to process a message) | ❌ **the whole problem** | listeners timed out / pinged the Founder / double-spawned |

Every incident this session — ~10-min ceiling kills, background-exit Founder-pings, worktree-teardown
deaths, harness double-spawned loops, orphan accumulation — was a **wake-layer** failure. Don't rebuild
the bus; **swap only the wake.**

## The wake primitives the platform actually exposes (investigated, not assumed)

| Primitive | Wake type | Long-lived proc? | Persists? | Fires unattended? | Verdict |
|---|---|---|---|---|---|
| Background `run_in_background` loop (the old listener) | poll → exit re-invokes | **yes** (the loop) | no | dies at ~10-min ceiling; every exit pings the Founder; harness spawns **2** loop-trees/launch | **RETIRE** (what we're replacing) |
| `mcp__ccd_session_mgmt__send_message` (native session→session push) | true push | no | n/a | **NO** — "ALWAYS prompts the user… unavailable in unsupervised mode… not to orchestrate background work" | **Not the autonomous bus.** Reserve for *supervised* handoffs (e.g. CEO→Founder, or a human-present context pass) |
| `CronCreate` (in-session cron) | scheduled, REPL-idle | no | only if `durable:true`; **session-scoped** | only while *that* session's REPL is idle | Weaker — coupled to one session's lifetime |
| **`mcp__scheduled-tasks__create_scheduled_task`** (app-level) | scheduled, **fresh self-contained run** | **no** | **yes — on disk** (`~/.claude/scheduled-tasks/<id>/SKILL.md`) | **yes while the app is open**; if closed, runs on next launch | ✅ **RECOMMENDED wake layer** |

The decisive properties of the app-level scheduler (from its own spec): *"Each run starts fresh with no
memory of this conversation"* (→ nothing long-lived to time out — kills the ceiling problem at the
root), *"run while this app is open… if closed, runs on next launch"* (→ app-level, not coupled to a
session being interactive — the exact condition that killed the listeners), and `notifyOnCompletion`
(→ a session is told each run — a free liveness signal).

## The recommended design — "Scheduled Dispatch-Monitor"
- **Transport / validation: unchanged.** Inbox `divisions/<div>/ea_dispatch.md` on `main`; outbox on
  the division branch; validate+act via the canonical `comms/bus.sh` from `origin/main`.
- **Wake:** each session installs **one** recurring `scheduled-tasks` job whose **self-contained
  prompt** is the monitor: *fetch origin/main → read my inbox → `bus.sh process` (allowlist/validate,
  never execute contents) → push outbox → stamp liveness → exit.* No daemon, no loop, no timeout.
- **Stagger (no herd on `main`):** the scheduler's own guidance is "avoid :00/:30; off-minutes." Assign
  each division a distinct off-minute, e.g. `minute = (7 + idx*7) mod 60` at a ~5–10-min period, so 8+
  jobs never read `main` in lockstep.
- **Liveness (the one thing cron doesn't give free):** each tick stamps a UTC timestamp
  (`divisions/<div>/.heartbeat` or an outbox field). The **EA** runs its own scheduled job over
  `comms/divisions.list`; a stamp stale past threshold → **EA escalates to the human**. EA-stale /
  app-closed → **the human is the backstop**. (Exactly the cron WO's liveness requirement.)

## What this adds beyond the in-flight cron WO
1. **Phase-0 answered with a real primitive:** "Claude Code cron" on the Windows desktop app **is**
   `mcp__scheduled-tasks__*` — disk-persisted, app-level, fresh-run-per-tick. De-risks Infra's build.
2. **A dead end eliminated:** `send_message` looks like the obvious "push" answer but is **human-gated
   and explicitly not for autonomous orchestration** — don't build the mesh on it. (Still useful for
   supervised CEO↔Founder handoff.)
3. **Concrete stagger scheme** for the WO's "don't herd `main`."
4. **NEW SECURITY FINDING (route to Div2, BINDING):** the scheduled-task **prompt file**
   (`~/.claude/scheduled-tasks/<id>/SKILL.md`) is *executed as an agent prompt every tick* and lives on
   the shared host. That is a **write-to-execute surface on the scheduler itself**: a session that can
   write another session's `SKILL.md` injects a recurring, full-capability prompt. Mitigations to clear:
   keep the prompt **fixed and minimal** (it only invokes the canonical bus from `main` — carry the F1
   "no overridable path" forward); treat `SKILL.md` integrity as in-scope for the cron read-path
   clearance; never let the dispatch payload influence the scheduled prompt.

## The one honest open item (verify, don't assume)
I have **not** empirically confirmed the app-level scheduler fires while the session is *idle /
backgrounded* — the precise failure mode that killed the listeners. The spec strongly implies it
(app-level, runs-while-open, catch-up-on-launch), but per "green is earned," this is the **Phase-0
gate**. **Proof step (offered):** create one benign PoC scheduled task (stamp a timestamp + read the
bus, no side effects), leave the app idle/backgrounded across a few ticks, and confirm the stamps
advance unattended. Pass → the model is real and Infra productizes it; fail → it has the listener's
disease and we escalate (same gate that should have caught the listener build).

## Hand-off (charter §3 — R&D proves, others build/clear/gate)
- **Infra/Platform (Div6, lead):** build the dispatch-monitor scheduled task + the EA staleness job + stagger, on this primitive.
- **Security (Div2, BINDING):** clear the cron read-path **and** the `SKILL.md`-integrity surface above.
- **QA (Div3) / EA:** the soak test in the cron WO (fires unattended; killed session→stale→escalated; malformed/forbidden rejected; no herd).
- **Docs (Div4):** document "dispatch-monitor" + "liveness stamp"; retire "heartbeat/listener."
