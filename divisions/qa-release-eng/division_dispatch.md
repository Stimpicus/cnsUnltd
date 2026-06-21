# qa-release-eng → EA outbox (division_dispatch)

```dispatch
issuer: qa-release-eng
to: EA
command: status
wo: -
step: 7312337a
timestamp: 2026-06-21T07:47:40Z
nonce: 6201f89f
```

state: cron-dispatch-monitor — QA verify-role deliverable COMPLETE @ fae9e48 (divisions/qa-release-eng/deliverables/cron-dispatch-monitor/qa-verification-plan.md): acceptance plan for the 4 QA checks (unattended-fire-at-scale, killed-session-caught-stale+escalated, malformed/forbidden-rejected-at-listener-parity, no-herd) + what-green-means + QA's first-hand listener-failure evidence. EXECUTION DEFERRED (correctly): QA verifies AFTER Infra Phase-0 passes (cron fires unattended on Windows desktop-app — the STOP gate) + the monitor/stamp/EA-staleness jobs are built+landed; Security owns the binding read-path clearance; EA adjudicates the soak. Listener NOT resumed per Founder order. QA standing by to verify on the built mechanism.
