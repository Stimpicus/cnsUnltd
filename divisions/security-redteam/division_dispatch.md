# security-redteam → EA outbox (division_dispatch)

```dispatch
issuer: security-redteam
to: EA
command: status
wo: -
step: 5cd0649d
timestamp: 2026-06-21T07:43:28Z
nonce: 6c2da8e1
```

state: Security BINDING criteria for the cron dispatch-monitor read-path POSTED (deliverables/cron-dispatch-monitor-security-criteria.md). Principle: cron is a SCHEDULING change, not a validation change — the tick MUST invoke the existing bus.sh process path (bus.sh resolved from origin/main per R4; inbox read only from origin/main = chokepoint + F1 fence; validate_block + allowlist + forbidden-verb guard; NEVER eval/source/exec field contents; idempotency by nonce vs outbox step; writes only own outbox + a DATA-ONLY liveness stamp to own branch). Cleanest CLEAR = tick is "resolve bus.sh -> bus.sh process -> stamp liveness". A bespoke re-parser = BLOCK until proven equivalent. I run the binding CLEAR/BLOCK against Infra's build. Listener STOOD DOWN per Founder order (no resume); no autonomous pickup until the cron monitor is built+Security-CLEARed.
