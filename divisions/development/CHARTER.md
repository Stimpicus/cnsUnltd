# DEPARTMENT CHARTER — Development
## Division 1. The swarm that builds.

**Status:** founding charter, for the founder/board. Authored by the CEO function.
**Why first:** Development is the org's reason for the machinery around it. It is the
parallel multi-agent build swarm that runs "crunch time" — the engine the lifecycle
loop turns, the source of the branches every other division gates, audits, and
proves. The whole apparatus (the merge-autonomy policy, the standing adversary, the
gate) exists so this swarm can move fast *without* the founder re-reviewing 127
branches by hand. Its operating template is
`work-orders/claude-code-MASTER-orchestration-overnight.md`; its merge discipline is
`governance/merge-autonomy-policy.md`.

---

## 1. MANDATE
Build the product — the Pandora protocol, Elpis OS, Face to Face — as a fleet of
parallel agent lanes working their own branches, under anti-idle cadence, fast and
in volume. Turn the **sprint/crunch** phase of the lifecycle: many lanes in flight,
each producing branch-scoped, individually-verifiable work.

Its product is **branches worth landing**: changes scoped, self-tested, and tagged
so QA can gate them and the integrator can land the AUTO tier without the founder in
the loop. Product code lives in the product repos (`pandora`, `elpis-os`) and is
referenced here **by commit, never copied**.

---

## 2. WHAT IT OWNS
- **The crunch swarm** — the parallel build lanes (A–H and successors), each on its
  own branch with a clear deliverable, run under the anti-idle "a turning loop is the
  goal" mandate. Idle or blocked is the worst outcome.
- **Lane discipline** — one concern per lane, branch-only work, self-verification
  before handoff, and honest RISK tagging (`RISK: SECURITY` / live / physical) so the
  policy can route each branch to AUTO / REVIEW / BLOCKED correctly.
- **Lane I — Installer** (standing parallel workstream, D-006): install-mechanics and
  installer UX as a permanent lane; install-mechanics land REVIEW (trust/boot-adjacent),
  pure UI is AUTO-eligible. Coordinates with Design/Product (Lane D).
- **The feature/fix backlog** — what gets built next cycle, sequenced with the CEO's
  direction and the carried-forward queue in the decision ledger.

## 3. THE LINE IT HOLDS
- **Merge ≠ ship, absolutely.** Development produces and pushes branches; it does
  **not** land its own work to `main` outside the ratified AUTO tier, and it never
  flashes, applies to the reference box, or deploys. Landing is QA/the integrator
  under the gate; shipping is the founder's physical button.
- **Builds verifiably, never on a hunch.** Where a proper way exists to confirm a
  change won't break the project, the lane does it before handoff — "verify, don't
  assume" applies to the swarm first.
- A Security/Red-Team `BLOCK` is binding on it absolutely; no velocity argument
  overrides a security veto.
- **No secret ever reaches a branch** — secret-scan is standing hygiene on every
  commit, in every lane (the product repos are private-now/public-trajectory; a
  secret committed while private is a permanent public-history leak).

## 4. RELATIONSHIP TO THE OTHER ORGANS
- **QA/Release-Eng** receives its branches, gates them, and lands the AUTO set;
  returns the REVIEW set to the founder. Development serves the gate, never bypasses it.
- **Security/Red-Team** can block anything it produces; its `RISK: SECURITY` tags
  force REVIEW. The swarm reproduces and fixes what the adversary finds.
- **Infrastructure/Platform** provides the ground the swarm runs on (orchestration
  substrate, build capability, the usage-envelope meter); Development's cadence
  depends on it.
- **CEO function** sets direction, priority, and standards; the **EA** turns the
  crunch on its cadence and sequences lanes to stay inside the usage envelope.
- **Founder/board** disposes of REVIEW/BLOCKED and presses every ship button.

## 5. ANTI-IDLE BACKLOG
There is always another lane to run: the feature backlog, the carried-forward
hardening queue (e.g. the H-series verifier sweep), installer maturation, parity
and regression fixes surfaced by QA, and the remediation branches Security raises.
A blocked lane advances the lanes that can move and surfaces the blocker — it never
stalls the loop.

## 6. NOT
Not the decider of what ships (founder). Not its own merge authority beyond the
ratified AUTO tier (QA/integrator lands; founder disposes of REVIEW/BLOCKED). Not a
ship button — merge ≠ ship. Not able to override a security veto. Not a home for
product code (that lives in `pandora` / `elpis-os`, referenced by commit).
