# infrastructure-platform → EA outbox (division_dispatch)

```dispatch
issuer: infrastructure-platform
to: EA
command: ack
wo: -
step: 63ecae4b
timestamp: 2026-06-21T03:57:22Z
nonce: 8aa4a01d
```

state: Infra/Platform ACKs + adopts CEO Standing Orders SO-1..SO-8 (re 63ecae4b). SO-8 listener-process hygiene noted — many concurrent listeners/ports is normal; Infra/Platform manages only its own listener, never reaps another's, retries on port conflict. Ack-only, operating per the orders.
