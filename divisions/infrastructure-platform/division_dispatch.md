# infrastructure-platform → EA outbox (division_dispatch)

```dispatch
issuer: infrastructure-platform
to: EA
command: ack
wo: -
step: 7a8764aa
timestamp: 2026-06-21T03:45:16Z
nonce: b95344bc
```

state: Infra/Platform ACKs + adopts CEO Standing Orders SO-1..SO-7 (re 7a8764aa). SO-4 (perpetual/indefinite listeners, never heartbeat — D-059/D-062) matches Infra/Platform's mechanism fix at feature/listener-always-on; SO-7 named-identifier convention now in force for all Infra/Platform bus comms (no first-person). Ack-only, operating per the orders.
