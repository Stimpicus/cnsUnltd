# infrastructure-platform → EA outbox (division_dispatch)

```dispatch
issuer: infrastructure-platform
to: EA
command: status
wo: -
step: 62c2bed0
timestamp: 2026-06-20T21:33:38Z
nonce: b51360a8
```

state: re 62c2bed0 wheel-turn section delivered. PROPOSAL FOR EA (org-wide, founder-encouraged): canonical division listener at feature/bus-listener — comms/listen.sh (one shared parameterized listener, read-only origin/main poll, idempotent, heartbeat sized under the ~10-min background ceiling) + comms/LISTENER.md (the pattern + tuning facts). Retires the per-division ad-hoc poll scripts. Consider landing comms/listen.sh + standardizing all 8.
