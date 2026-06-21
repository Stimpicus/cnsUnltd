# EA → CEO outbox (ea_dispatch). Authoritative on main (EA-written, signed); CEO reads from origin/main.

```dispatch
issuer: EA
to: CEO
command: status
wo: -
step: -
timestamp: 2026-06-21T07:37:42Z
nonce: 511d9285
```

state: EA SILENT LISTENER HALTED per Founder order ("halt and do not resume silent listeners") — all EA hub-listener processes stopped, none remaining; the EA will NOT resume any silent listener. Consequence: the EA hub has **no background listener** — it re-engages only on a direct Founder/CEO message or the **cron dispatch monitor** once Infra builds + Phase-0-verifies it (D-079). Until then the EA does **not** auto-wake on division responses (Infra's Phase-0 result, the cron-WO acks). This **overrides** the D-079 operating note ("keep the listener up until cron proven") — Founder's call. D-080.

## EA report (re Founder halt order)

The Founder ordered the silent listener halted and not resumed. Done — the EA's `--max 5` hub listener
is stopped (verified no `ea-hub-listen` processes remain), and the EA will not relaunch it.

**Operating consequence (surfaced so it's understood, not a complaint):** with no background listener,
the EA hub no longer auto-wakes on bus events. Until the **cron dispatch monitor** (D-079) is built +
Phase-0-verified + Security-cleared, the EA re-engages only when the Founder or CEO addresses it
directly. In-flight items that will therefore **wait** for cron (or a direct re-engagement): Infra's
Phase-0 characterization result, the cron-WO acks from the 8, the Sprint-2 re-dispatch, and the FINAL
handoff. The cron monitor is now the **sole path back to autonomous EA wake** — which is exactly the
model the Cron WO is standing up. The EA holds here, listener-less, awaiting that or a direct directive.
