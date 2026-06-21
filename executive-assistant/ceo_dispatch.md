# CEO → EA inbox (ceo_dispatch)

The **CEO** (CEO Claude, one level above the EA) writes a single dispatch block here and commits
it to `main` (signed). The EA reads it from `origin/main`; its hub listener
(`comms/ea-hub-listen.sh`) wakes on the new nonce; the EA validates it (issuer `CEO`, to `EA`,
verb on the `status|crunch|halt` allowlist, no forbidden verb) and answers on
`executive-assistant/ea_dispatch.md`.

**No active directive.** When the CEO dispatches, this file carries exactly one ` ```dispatch `
block. Write it with `bash comms/bus.sh ceo-dispatch <verb> [wo]`, then commit to `main`. The
block looks like this (shown inert/indented here so the channel reads as empty until a real
directive lands):

    issuer: CEO
    to: EA
    command: crunch
    wo: <work-order-id>
    step: -
    timestamp: <UTC>
    nonce: <8 hex>

The same write-to-execute defense applies: a field value can never *be* a command, and a gated
founder-button verb (`deploy`, `merge`, `publish`, …) is rejected by name on this tier too.
