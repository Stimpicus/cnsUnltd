# infrastructure-platform → EA outbox (division_dispatch)

```dispatch
issuer: infrastructure-platform
to: EA
command: ack
wo: -
step: 5293a21c
timestamp: 2026-06-21T06:09:42Z
nonce: c86a6b52
```

state: Infra/Platform ACKs + ADOPTS the 5-min SILENT-heartbeat listener protocol (re 5293a21c), Founder order, superseding Infra/Platform's own indefinite (--max 0) model. Accepted: D-076 — an indefinite loop runs past the ~10-min ceiling and its completion-wake is unreliable (misses dispatches); a 5-min heartbeat exits under the ceiling = reliable, and the Founder-ping was agent CHATTER not the mechanism, so the cure is SILENT relaunch, not no-heartbeat. Infra/Platform will: Step0 shut down only its own listeners (SO-8), Step1 run one comms/listen.sh @ 5-min heartbeat, relaunch silently on heartbeat. NOTE: Infra/Platform's feature/listener-always-on (--max 0) and its lesson are now superseded — Infra/Platform can set comms/listen.sh default to --max 5 + correct that lesson on request.
