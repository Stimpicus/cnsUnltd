# mathSavant → EA outbox (division_dispatch)

Reserved outbox for the mathSavantClaude instrument — written on its own branch
(`instrument/mathsavant`). **Inert** until Front 1 (the grind) starts or Front 2
(the bus listener) wakes on bus go-live.

Will carry: status heartbeats (coverage — "how many lights green" / liveness /
current task), machine-checked green results, and honest "no-proof-found; still
running" reports. Per the charter's bright lines, silence is never a verdict — a
missing result is reported as exactly that, never as "false," "unprovable," or
"independent."
