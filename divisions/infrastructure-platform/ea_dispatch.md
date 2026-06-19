# EA → Infrastructure/Platform — inbox (`ea_dispatch`)

**This branch copy is an inert template.** The *authoritative* inbox is the version
of this file on **`main`**, which only the EA can integrate — that write-auth is the
bus's security boundary (see `deliverables/comms/dispatch-schema.md`). Infra's
listener reads its inbox from `origin/main`, never from this branch.

To dispatch, the EA replaces this file on `main` with exactly one fenced
`dispatch` block (strict 7-key schema). The example below is **indented** (an inert
code block, not a real fence) precisely so the listener does **not** parse a
template as a live command — a doc-embedded block must never be actuable:

    issuer: EA
    to: infrastructure-platform
    command: status
    wo: -
    step: -
    timestamp: 2026-06-19T18:30:00Z
    nonce: a1b2c3d4

In a real dispatch those seven lines sit inside a ```dispatch … ``` fence. Allowed
inbound commands: `status`, `crunch` (with a real `wo:`), `halt`. Anything else —
including any gated/founder-button verb — is ignored and surfaced, never executed.
