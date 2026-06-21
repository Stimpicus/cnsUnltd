# REPO STRUCTURE

How `cnsUnltd` — the org's operating system — is laid out today. *(This replaces the original
bootstrap/migration map; the migration it described is long complete.)* For the operating model and
current state see `STATE-OF-THE-ORG-1.0.md`; for the soul and constitution read `charter/`.

## Layout
```
cnsUnltd/                          PRIVATE, permanent — the org as a repo (not product code)
  README.md                        what this repo is; read charter/ first
  REPO-STRUCTURE.md                this file
  STATE-OF-THE-ORG-1.0.md          the operating model + current standing state (the 1.0 snapshot)

  charter/                         the soul + the constitution — read first
    MISSION.md VISION.md VALUES.md CORNERSTONES.md LORE.md  org-chart.md

  ceo/                             the CEO function's authored direction
    standing-orders.md             SO-1..SO-8 — in force every cycle until amended
    synthesis-001-state-of-substrate.md   the CEO's cycle syntheses (one per turn)

  executive-assistant/             the EA — sole dispatcher + sole integrator
    EA-charter.md  cadence.md
    ceo_dispatch.md                CEO -> EA inbox  (issuer CEO)
    ea_dispatch.md                 EA -> CEO outbox (issuer EA, signed)
    state-of-the-substrate.md  founding-intake-rollup.md  wheel-turn-harness/

  divisions/<name>/                one per division (8) — branch = workshop, dir = display case
    CHARTER.md                     the division's charter
    ea_dispatch.md                 EA -> division inbox
    division_dispatch.md           division -> EA outbox
    status/  deliverables/  sprint-*/    the division's work
    (the 8: development, security-redteam, qa-release-eng, docs-devrel,
     design-product, infrastructure-platform, research-rnd, ip-legal-strategy)

  governance/                      how the org decides + guards itself
    decision-ledger.md             append-only; the org's memory of WHY (D-001 ...)
    resource-model.md  deliverable-spec.md  development-lifecycle.md  merge-autonomy-policy.md
    security/
      allowed_signers              the SSH signing roots (CEO + EA) — main is a two-signer channel
      commit-signing.md            per-clone signing setup (re-applied every session)
    board-hygiene/
      board-hygiene-scan.sh        the binding board gate (live-box IPs/MACs/secret patterns)
      secret-scan.sh               the secret scanner (also wired as the pre-commit hook)
      board-hygiene-guard.md

  comms/                           the git-as-message-bus + the listeners
    bus.sh                         dispatch/collect; nonce-linked; forbidden-verb guard
    dispatch-schema.md             the ```dispatch block format + the CEO/EA/division tiers
    divisions.list                 the authoritative division roster
    listen.sh                      the division listener (indefinite, --max 0, no heartbeat)
    ea-hub-listen.sh               the EA hub listener (CEO inbox + 8 division outboxes)
    ceo-listen.sh                  the CEO listener (the EA outbox)
    health.sh                      org-functionality check (does each division answer its EA?)
    LISTENER.md                    the listener model + why it is indefinite

  knowledge/                       the commons — one canonical approach per recurring task
    playbooks/                     how we do recurring things (e.g. dispatch-sequencing)
    lessons/                       what we learned (retrospectives, regressions, fixes)

  work-orders/                     CEO directives the EA dispatches to divisions
  .githooks/                       pre-commit (secret-scan), wired per clone
```

## The model (one breath)
The **Founder / board** (human) holds final authority on anything public, physical, or irreversible —
the only button-presser. The **CEO** (Claude) authors direction + standards and rules on internal
conflict, inside the constitution, never bending it. The **EA** is the sole **dispatcher** to
divisions and sole **integrator** to `main` — it dispatches, integrates behind the gate, reports up,
and presses no button. The **8 divisions** work their own branches and surface deliverables to
`main`. Chain of voice: **division -> EA -> CEO -> Founder**, only the last hop, only when the org
genuinely needs the Founder (SO-1).

## Branch model
- `main` — the org's live board: charters, governance, the ledger, division *delivered* artifacts,
  comms tooling. Always coherent, always signed (CEO + EA, two-signer).
- `division/<name>` — each division's workshop; its CC session works there.
- The **EA integrates** branch -> `main` behind the board gate + the merge-autonomy policy.
  **merge != ship:** landing on `main` is not shipping; only the Founder ships.

## The runtime (how the loop turns)
- **The bus** (`comms/bus.sh`): markdown `dispatch` blocks committed to `main`; nonce-linked (a
  reply's `step` == the inbound `nonce`); a forbidden-verb guard rejects execute-verbs; the inbox is
  trusted only from `origin/main`.
- **Listeners** (`comms/*-listen.sh`): every session runs a **perpetual, indefinite** listener
  (SO-4) — no heartbeat, exit only on a real dispatch (a heartbeat exit would page the Founder in
  this harness). Liveness is measured by `comms/health.sh`, never a self-heartbeat.
- **The gate:** `board-hygiene-scan.sh` (binding) + `secret-scan.sh` (pre-commit), resolved from
  `origin/main`. Green is earned, not asserted.
- **Signing:** SSH ed25519; private keys never committed; `allowed_signers` is the root of trust.
- **A cycle** = one turn of the development loop = one CEO synthesis (the ledger records each).
  Cycle 0 = the watched audit (D-043); Sprint-1 = cycle 1.

Read `charter/` first. It's the point of all of this.
