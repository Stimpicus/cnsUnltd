# The Pandora / ElpisOS Development Lifecycle
## A self-reinforcing loop where security is structural, not bolted on

**Status:** the canonical SDLC for the Pandora Protocol / ElpisOS project.
Authored 2026-06-19. This is the organizing structure the project runs on; the
phase-level work orders (crunch-time, the protocol audit, the living article) are
instances of its phases.

---

## THE LOOP

```
      ┌────────────────────────────────────────────────────────────┐
      │                                                            │
      ▼                                                            │
  ┌─────────────┐                                                  │
  │ SPRINT END  │  the crunch produced & merged a pile of change   │
  └─────┬───────┘                                                  │
        ▼                                                          │
  ┌──────────────────────┐   feeds → reproduced findings,         │
  │ AUDIT THE SUBSTRATE  │          reference instances           │
  │ (all implementations)│                                        │
  └─────┬────────────────┘                                        │
        ▼                                                          │
  ┌──────────────────────┐   feeds → generalizes the threat       │
  │ IMPROVE PORTABILITY  │          model (2nd substrate)         │
  └─────┬────────────────┘                                        │
        ▼                                                          │
  ┌──────────────────────┐   SHARPENS → the living article        │
  │ EVALUATE THE SECURITY│   (versioned; reconciles audit         │
  │ LANDSCAPE            │    candidates into the ledger)         │
  └─────┬────────────────┘                                        │
        ▼                                                          │
  ┌──────────────────────┐   threat-informed priorities          │
  │ BEGIN NEW SPRINT     │ ─────────────────────────────────────┘
  └──────────────────────┘

         ⟂ at the chosen milestone (legal track ready + article mature):
            PUBLISH = declare + identify the living article's current version
                    → unlocks responsible scaled / public deployment
```

The loop is **self-reinforcing**: each phase produces the input the next one needs.
It is not a punch-list; it closes on itself and runs every cycle.

---

## WHY THIS ORDER (the dependencies that make it work)

The sequence is deliberate — each arrow is a real dependency, not a convention:

1. **Sprint end → Audit.** The substrate is at its most-changed, least-examined
   moment right after a sprint merges the AUTO tier. Auditing *here* means nothing
   downstream is built on an unexamined foundation. The audit is the "what did we
   actually just create" checkpoint.

2. **Audit → Portability.** You cannot responsibly abstract a substrate whose
   security properties you don't understand. Abstracting *before* the audit risks
   encoding a substrate-specific assumption — or weakness — into the portability
   interface itself. The audit tells you where the real trust boundaries are, so
   the `RealtimeStore` / `Identity` seams get drawn along them.

3. **Portability → Evaluate.** Once the protocol runs on a *second* substrate
   (e.g. Postgres + keypair, not only SpacetimeDB + OIDC), the security question
   stops being "is this product safe" and becomes "what does write-to-execute look
   like across *substrate-agnostic* surface" — the real, general form of the
   attack class. Portability doesn't just prove the thesis; it **generalizes the
   threat model**, which is what the evaluate phase needs.

4. **Evaluate → New sprint.** The landscape evaluation is the next sprint's
   priority input. The sprint isn't "what features do we want" — it's "what did the
   threat surface tell us to harden or build." The sprint is **threat-informed by
   construction.**

The property this buys: **security is the bookend of every cycle** — you audit
what you built, and you evaluate the landscape before you build again.
Write-to-execute is not a finding that was filed; it is the **lens the whole loop
looks through.** That is the right shape for a project whose reason to exist is
"the capability was already in the technology; we build the safeguards that decide
whether it is catastrophic or beneficial." *The lifecycle is the elpis.*

---

## THE RESEARCH THREAD (how the article and publication weave in)

The disclosure article and its publication are not a separate track — they are two
halves of one mechanism threaded through the loop:

- **The article is the continuously-sharpened output of the EVALUATE phase.** It is
  a private, versioned working document that accretes across cycles. Each evaluate
  phase reconciles the audit's `ARTICLE LEDGER CANDIDATES` into its reference-
  instance ledger and updates its threat model. It matures turn by turn.
- **Publication is a milestone GATE — a state transition of that same document.**
  When the architect judges the article mature and the legal track ready,
  publishing fixes the then-current version as canonical and **declares + identifies**
  it. That act unlocks responsible scaled / public deployment.
- **The gate is cheap because the loop did the work continuously.** By the time you
  publish, the article is already mature — there is never a "write the disclosure"
  scramble blocking deployment. (Same principle as the merge-autonomy policy: don't
  let a necessary gate become a bottleneck by deferring all its work to the moment
  you hit it.)
- **The version history IS the prior-art record** — dated, versioned lineage that
  establishes when the class was identified and described (the attorney/IP track).

---

## PHASE → INSTRUMENT MAP (the repeatable work orders)

Each phase has a repeatable instrument so the loop runs the same way every cycle:

| Phase | Instrument (work order / artifact) | Repeatable mechanism |
|---|---|---|
| **Sprint** | `claude-code-MASTER-orchestration-overnight.md` ("crunch time", Thursdays) + `merge-autonomy-policy.md` | anti-idle multi-lane swarm; Lane C auto-merges the AUTO tier under the combined-QA gate; human is merge authority for REVIEW/BLOCKED |
| **Audit** | `claude-code-work-order-protocol-audit.md` | the **write-to-effect map** per implementation; next cycle diffs against the prior map |
| **Portability** | `RealtimeStore` / `Identity` abstraction + the 4-way proof matrix (SpacetimeDB+OIDC vs Postgres+keypair), scoped to communication payloads | re-run the proof matrix as substrates/interfaces change |
| **Evaluate** | the living article (`...-living-article.md`) — versioned | reconcile audit candidates into the ledger; update the threat model; bump version + changelog |
| **(Gate)** | publication of the article's current version | architect-triggered when mature + legal-ready; unlocks scaled deployment |

---

## INVARIANTS (hold across every phase, every cycle)

These are the project's standing rules — they do not bend for speed:

- **Security above all; never trade speed for security.** Where a proper way exists
  to verify a change won't break the project, do that thing — every time.
- **Merge ≠ ship.** Code landing on `main` is gated separately from the dangerous
  transitions (flash / reference-box apply / deploy), which always require the architect.
- **The human is the merge authority** for REVIEW/BLOCKED; the integrator may only
  auto-merge the constrained, CI-gated AUTO tier under the ratified policy.
- **The reference box is never live-mutated unattended** except reversible,
  auto-rollback steps; never rebooted unattended.
- **`elpis-os` is private now but public-trajectory** (a consumer OS destined to
  open-source). Therefore: it **never receives a secret** (the secret-scan is a
  standing invariant, not contingent on current visibility — a secret committed
  while private becomes a permanent public-history leak the day it opens), and it
  **never receives the disclosure article** (which stays in the private `pandora`
  repo until the publication gate, regardless of either repo's visibility).
- **Verify, don't assume** — gates that protect against project-breaking impact are
  hard stops, not forks (e.g. the verifier-enumeration gate before a signing-
  contract change).
- **Write-to-execute is the lens** — every audit and every evaluate phase looks at
  the substrate through it.

---

## CURRENT POSITION
As of 2026-06-19: a sprint has just ended (the overnight crunch; AUTO tier policy
ratified). The loop is in the **AUDIT phase** — the multi-repo protocol audit and
the living-article seed are running concurrently. Next: portability, then evaluate,
then the next sprint.
