# Dispatch Monitor & Liveness-Stamp Vocabulary
## Canonical terms for the cron dispatch-monitor model — and the retirement of the "heartbeat" mislabel

**Author:** Docs/DevRel (Div 4) · **Date:** 2026-06-21 · **For:** the EA (org-wide
comms vocabulary) · **Crunch:** `work-orders/claude-code-WO-cron-dispatch-monitor.md`
(Div 4 task: *"document the dispatch-monitor + heartbeat-stamp vocabulary; retire the
'heartbeat' mislabel for good"*).

**Scope.** This fixes shared *terminology* for the cron dispatch-monitor model that
supersedes all listener dispatch protocols. The *mechanism* (the scheduled job, the
liveness stamp, the EA staleness check) is **Infrastructure/Platform's to build** and is
gated on its Phase-0 unattended-fire verification; **Security** clears the read-path;
**QA/EA** run acceptance. This document is the **vocabulary layer** — so all eight
divisions + the EA name the same things the same way. It introduces no mechanism and no
new behavior, and edits no other division's files.

---

## 1. The model in one sentence
A **dispatch monitor** is a short *scheduled* job that, each **tick**, wakes, reads its
authoritative **dispatch location**, **validates and acts** on any new command through the
existing bus path, writes a **liveness stamp**, and exits — nothing long-lived to time
out, nothing to keep alive or respawn. It inverts the listener model, whose long-lived
loops timed out past the ~10-min process ceiling and dropped wakes (the failure recorded
at D-076; `claude-code-WO-cron-dispatch-monitor.md` §Why).

## 2. Canonical terms

| Term | Means | Replaces / contrast |
|---|---|---|
| **Dispatch monitor** | the one scheduled job per session that checks for and acts on dispatches | replaces **"listener"** (a resident loop). A monitor is *scheduled and short-lived*, not *resident*. |
| **Tick** | one scheduled firing of the dispatch monitor (wake → read → act → stamp → exit) | replaces the listener's poll-loop *iteration* and its self-timer "heartbeat exit." A tick is a *whole* wake-act-exit, not a relaunch trigger. |
| **Dispatch location** (inbox) | the fixed authoritative source a tick reads — EA→division: `divisions/<name>/ea_dispatch.md` on **`main`**; CEO↔EA: the CEO/EA inbox | **non-overridable** — the F1 fence carries forward (no `BUS_INBOX_FILE`-style override in production). |
| **Validate-and-act** | the unchanged bus path: command **allowlist** → `validate_block` → **forbidden-verb guard** → **enum→pre-written handler**; field values are **never executed** | a *reader swap*, **not** a validation downgrade (Security-binding, per the WO). |
| **Liveness stamp** | the timestamp a tick writes meaning "this session was alive as of now," read by the EA's staleness check | the **honest** referent for "heartbeat" (see §3). |
| **Staleness check** | the EA's own scheduled job that reads the authoritative roster (`comms/divisions.list`) and flags any session whose stamp is older than a threshold → **escalates to the human** | the liveness backstop cron does not give for free. "Notice a death → tell the human" is **required, not optional.** |
| **Escalation backstop** | EA-unreachable, or the EA's own stamp stale → **the human** is the root-of-tree backstop | unchanged trust root. |

## 3. Retiring the "heartbeat" mislabel (the crux)

**The mislabel.** Across the listener era, "heartbeat" named the listener's **self-timer
exit** — the `--max N` relaunch trigger (e.g. the 5-minute exit in `comms/listen.sh`,
`comms/LISTENER.md`, `comms/ea-hub-listen.sh`, introduced by D-078). That event **signaled
liveness to no one.** It existed solely to re-invoke the agent under the process ceiling so
the loop could relaunch. Calling it a "heartbeat" implied a pulse some observer was
watching — there was none. The name described the property we *wished* it had (proof of
life) rather than what it *did* (a silent self-relaunch). A reader who saw "heartbeat"
reasonably assumed the org could detect a dead session from it; it could not — and that gap
is precisely the failure the cron model exists to close (a session could die and no
"heartbeat" would tell anyone — D-076). Honesty is a safety property here: a name that
overclaims observability is a liability, not a cosmetic issue.

**The honest term.** Under the cron model a **heartbeat *is* a liveness stamp** — a
timestamp a tick writes that the **EA's staleness check reads** to detect death. It is now
a pulse something listens for. So "heartbeat" becomes accurate *only* when it refers to the
liveness stamp.

**The rule (in force going forward):**
- A scheduled firing of a monitor is a **tick** — never a "heartbeat."
- A self-exit / relaunch timer is a **relaunch interval** (or just "the schedule") — never
  a "heartbeat."
- "**Heartbeat**" = **liveness stamp** *only*: the timestamp written for, and read by, the
  EA's staleness check. **If nothing reads it, it is not a heartbeat.**
- Liveness is asserted by the **stamp** and verified by the **EA** — never by anything a
  tick prints back to the session.

## 4. Existing usages to reconcile (Infra-owned; surfaced to the EA, not edited here)

To retire the mislabel "for good," these canonical files still carry the old *self-timer*
sense of "heartbeat" and should be reconciled to §3 when Infra lands the cron monitor.
Docs/DevRel will draft the edits; the files are Infra's mechanism, integrated by the EA
(per SO-1 / hub-and-spoke — surfaced to the EA for routing, not a direct division-to-
division edit):

- **`comms/listen.sh`** (9 uses) — "5-min HEARTBEAT" = self-timer exit → rename to the
  *relaunch interval*, or retire with the listener itself.
- **`comms/LISTENER.md`** (18 uses) — the whole "silent heartbeat" framing → supersede with
  the dispatch-monitor model + this vocabulary.
- **`comms/ea-hub-listen.sh`** (6 uses) — same self-timer sense.
- **`comms/dispatch-schema.md`** (2 uses) — `status` "doubles as the liveness heartbeat" is
  closer to honest (a dispatch the EA reads), but should be aligned: call the **stamp** the
  heartbeat and `status` a **liveness probe**.

## 5. Status & dependencies
- **Vocabulary:** complete (this document) — ready for the EA to integrate and hand to
  Infra as the naming reference for the build.
- **Blocked-on (not Docs):** **Infra Phase-0** — verify "Claude Code cron" fires
  **unattended** on the **Windows desktop-app** environment (idle session, app
  backgrounded). If it idles out with the session, it has the listener's disease → STOP +
  escalate (the WO's gate). Until that passes green, the vocabulary stands but the mechanism
  is unproven — and this doc claims only the former.
- **Security (binding):** the cron read-path must clear — allowlist + forbidden-verb guard +
  chokepoint + F1 fence + never-execute-contents. BLOCK authority stands.
- **QA/EA acceptance:** unattended fire at scale; a killed session caught as stale and
  escalated; a malformed/forbidden dispatch rejected by the cron reader exactly as by the
  listener; no herd on `main`.

**No overclaiming:** this deliverable is terminology only. It does not assert the cron
mechanism works — that is Infra's Phase-0 result to earn and report.
