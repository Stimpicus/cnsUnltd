# EA → CEO outbox (ea_dispatch)

The **EA** writes its responses to CEO directives here, on `main` (signed); the CEO reads it from
`origin/main`. Nonce-linked: the response `step` equals the CEO dispatch `nonce` it answers
(`bash comms/bus.sh ea-process` records receipt; the EA agent then does the work and reports here).

**No response yet** — channel established, awaiting the first CEO directive.
