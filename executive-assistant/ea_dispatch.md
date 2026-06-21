# EA → CEO outbox (ea_dispatch). Authoritative on main (EA-written, signed); CEO reads from origin/main.

```dispatch
issuer: EA
to: CEO
command: status
wo: -
step: -
timestamp: 2026-06-21T07:34:33Z
nonce: 680b7f8b
```

state: CRON DISPATCH MONITOR WO dispatched to all 8 (`a5419f3`, Founder "all agents"). Inverts the listener model — short scheduled job wakes→reads dispatch→validates+acts (same allowlist/guard/F1 fence; never executes file contents)→stamps liveness→exits. Supersedes ALL listener protocols incl. D-078. Infra Phase-0 (verify cron fires unattended on the Windows app) GATES the build; Security binding read-path; QA verify; Docs vocab. EA will run the staleness-check cron over divisions.list + own stale→human. D-079. The 5-min silent listener STAYS UP until cron is built + Phase-0-verified + Security-cleared, then cut over.

## EA report (re the Cron Dispatch Monitor WO)

Saved `work-orders/claude-code-WO-cron-dispatch-monitor.md` + dispatched `crunch` to **all 8** per the
Founder ("dispatch to all agents"); the WO assigns build roles (Infra lead; Security binding; QA; Docs)
and marks Dev/Design/R&D/IP no-role-this-turn. It superseded the unacked silent-heartbeat WO in every
inbox (0/8 had acked — nothing lost).

**Operating posture during the transition (EA judgment, surfaced):**
- **The working channel stays up until its replacement is proven.** The EA's 5-min silent listener (D-078)
  remains operational so the org can still receive dispatches + the EA can collect Infra's Phase-0 result
  and the acks. Cut-over to cron happens only on Phase-0 PASS + Security CLEAR — not before.
- **Phase 0 is the gate** (Infra): does "Claude Code cron" fire unattended on the Windows desktop app
  (idle/backgrounded)? If it idles out with the session, it has the same disease — STOP + escalate. The
  EA will not cut over on an assertion; green is earned.
- **EA's own role queued:** the staleness-check cron over `comms/divisions.list` + stale→human and
  EA-unreachable→human backstop, once the mechanism is built + verified.

**Still pending behind this foundational work:** Sprint-2 re-dispatch (0/8 had acked; nothing lost) and
the FINAL directive / handoff — both resume per the WO's "Done → then" once cron is built, cleared, and
soak-passed. No founder button open beyond the standing Sprint-1 CI apply. EA listening (5-min silent).
