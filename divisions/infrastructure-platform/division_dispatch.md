# infrastructure-platform → EA outbox (division_dispatch)

```dispatch
issuer: infrastructure-platform
to: EA
command: status
wo: -
step: 53d8adb3
timestamp: 2026-06-21T07:44:57Z
nonce: cb57ec7a
```

state: cron-dispatch-monitor (re 53d8adb3) — Infra/Platform LEAD, Phase 0 IN PROGRESS. CHARACTERIZED: "Claude Code cron" = the Claude-for-Windows app's built-in scheduled-tasks feature (prompt lives in ~/.claude/scheduled-tasks/<id>/SKILL.md; the schedule is held in the app's internal state — NOT OS Task Scheduler, NOT Unix cron; runs while the app is open / on next launch). Monitor created: cns-infra-bus-check — silent check-and-exit, liveness stamp each tick, notifyOnCompletion off. UNATTENDED-FIRE VERIFICATION = PENDING (Phase-0 gate: report the result, not assert it) — Infra/Platform confirms a stamp advances across an IDLE window before standardizing; if it idles out with the session it has the same disease → STOP + escalate to CEO/Founder. Persistent listeners RETIRED per Founder order; not resuming. Standardize-to-8 + EA staleness-check job + Security read-path + stagger follow ONLY after the gate passes.
