# mathSavantClaude — Registration (who-touches-this)

**What:** an R&D (Div 7) verified-reasoning instrument. **Not a division** — no new
authority, no second dispatch hub. Established 2026-06-19 (ledger **D-021**),
**DORMANT.** Charter: `divisions/research-mathsavant/charter.md`. Workshop branch:
`instrument/mathsavant`. Every division is socialized by reading this from `main`.

**Bus paths (inert until go-live):** inbox
`divisions/research-mathsavant/ea_dispatch.md` (authoritative, **EA-written on
`main`** — the one-hub write-to-execute defense); outbox
`divisions/research-mathsavant/division_dispatch.md` (written on the instrument's
branch).

## Who touches this

| Who | Role on the instrument |
|---|---|
| **R&D (Div 7)** | **Owner / sponsor** — operates it, decides what's dispatched, interprets verified results. Ships nothing directly. |
| **EA** | **Sole dispatcher + integrator** — the one hub; the new dispatch path is registered here. The instrument gets no second hub. |
| **Security / Red-Team (Div 2)** | Audits it as a **new write-surface on the bus**; owns the **sandbox requirement** — it executes proof-search code, so it runs with **no reach beyond its own scope**. |
| **QA / Release-Eng (Div 3)** | Owns the **verifier-gate** — no claimed proof is a deliverable until the formal checker confirms the proof object. Green is earned. |
| **Infrastructure / Platform (Div 6)** | **Provisions the persistent sandboxed instance now** — its own session, its own **dedicated worktree** (a single manual worktree, the same mitigation used to build the bus; available today, **not** dependent on the systematic isolation fix), its own budget line. |
| **Docs / DevRel (Div 4) + IP / Legal (Div 8)** | **Publication-gate participants** — any externally-claimed result is DevRel-framed, IP-reviewed, and **founder-pressed**. Never announced. |

## Standing rules (the charter's bright lines, in one breath)
- **Green is machine-checked, never asserted** — the verifier is the arbiter.
- **Silence is not a verdict** — "no proof found; still running" is reported as
  exactly that; never "false / unprovable / independent / probably-anything."
- **Deductive-closure bound** — no new axioms or structure; a route that appears to
  need more is a *finding to surface*, not a license to assume.
- **Merge ≠ ship** — even a verified proof is a result on a branch; any
  externally-claimed result is a founder/board button.

## Socialization & the two next go's
- **Socialized by reading `main`.** A live bus-acknowledgment (a `status` round-trip
  confirming awareness) folds into bus go-live / the first wheel-turn — it cannot
  happen before the bus is proven.
- **Front 1 — the grind — may start now** (not gated on the bus): once Infra
  provisions the dedicated worktree and Security signs off the sandbox, the Standing
  WO's Front 1 launches. Direct founder/Infra halt controls it; no bus required.
- **Front 2 — the listener — wakes when the bus is live.** Until then it stays inert
  and any green/coverage updates accumulate harmlessly in the outbox until the bus
  makes its rounds.
