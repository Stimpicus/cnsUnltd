# Work Order — First Real Wheel-Turn
## Face to Face — "State of the Substrate"
### The org's first real SDLC loop, run autonomously over the live bus

**Issued by:** CEO (Claude) · **Dispatched by:** EA · **Watched by:** Founder (this turn only)
**Classification:** real-payload shakedown. Lands behind gates. No irreversible buttons.

---

## Why this work order exists

This is the org's first turn of the real wheel — the **Audit** phase of the
canonical loop (`sprint → audit → portability → evaluate → sprint`), run for the
first time as a live, autonomous, all-division turn. It is also the org's
functional exam: the EA stands up the bus, dispatches to eight divisions, and
integrates their work, with the founder and CEO watching but not couriering.

The subject is **Face to Face read as exactly what it is — a live instance of
"write-to-execute via subscription substrate."** Every division audits the same
substrate through its own lens. The output is one honest, multi-lens assessment
that becomes the ranked input to the org's first real sprint and matures the
disclosure evidence.

The "what" is real: an accurate, current read of where f2f actually stands —
which the project genuinely needs and does not yet have.

---

## Step 0 — Stand up the nervous system (REQUIRED FIRST)

The wheel-turn rides the bus, so the bus must be real before it turns. It is
proven but not yet live: `feature/bus-multi-division` is unintegrated, the
deliberate roster-source is not yet in, and STEP-5.1 has not been run.
**Merge ≠ ship applies to the bus itself — it carries no real dispatch until it
is integrated and cleared.**

- **EA:** integrate `feature/bus-multi-division` to `main` with
  **`comms/divisions.list` as the authoritative roster-source** (the deliberate
  eight-division allowlist; auto-discovery demoted to a hygiene sentinel that
  flags any `divisions/` dir absent from the list).
- **Security:** run **STEP-5.1** — audit the integrated bus as a live
  write-to-execute instance: the roster-source, the verb allowlist (the hub
  cannot emit a gated verb), and the single-`main`-chokepoint write-auth.
  **Clear or BLOCK.** Security's BLOCK is binding.

The bus does not carry the audit until Security clears it.

---

## Step 1 — Dispatch (EA, over the now-live bus)

The eight divisions are already up and listening — started once, after Step 0,
on the listener boilerplate. The EA places this work order where each can read
it, then issues eight `ea_dispatch` orders — one per division, each an
allowlisted command pointing that division at its lens below. This is the bus's
first real load: eight concurrent dispatches, hub-and-spoke, isolated worktree
per division. No division-to-division mesh; everything routes through the EA.

---

## The eight lenses

Each division produces **one section** of *Face to Face — State of the
Substrate*, on its own worktree, written to
`divisions/<name>/audit/state-of-substrate-<name>.md`. The shared lens is
**write-to-execute via subscription substrate** — each reports the truth from
its angle. Fork-never-block: if a question has no answer on hand, assess both
branches rather than idling.

**Div2 — Security/Red-Team · the adversarial truth.**
Re-verify the documented VECTOR findings against the *live* module — which are
genuinely closed vs. documented-but-unconfirmed: the call-permission probing
oracle (VECTOR-O), context-token harvesting (VECTOR-B/C), the
unauthenticated-confirm → actuation/unlock blocker (H-17), the per-sender signal
caps (VECTOR-4), and the RLS model still blocked on upstream #2810 (M-08). Map
f2f's current attack surface as a write-to-execute instance; rank the open
findings by severity. *The section the disclosure evidence leans on.*

**Div1 — Development · the ground truth on the code.**
The authoritative inventory: implemented vs. stubbed vs. legacy. Flag the
`vrcadia-identity` artifacts that don't describe the real schema
(avatars/levels/VR transforms), the state of the JOIN-filtered subscriptions and
their client-side fallbacks (which `onApplied` paths are live-confirmed vs.
assumed), and the real technical debt behind the green. *The code as it is, not
as documented.*

**Div3 — QA/Release-Eng · the state of "green."**
What the gate actually certifies vs. what it doesn't: reducer test coverage, the
regression/parity posture, and the live-`onApplied` verification still owed (the
JOINs that need a real `.subscribe([...])`, not just `spacetime sql`). Where is
green earned, and where is it asserted? *The merge-≠-ship truth.*

**Div4 — Docs/DevRel · doc-versus-reality.**
Diff `CLAUDE.md` / `SECURITY.md` / `ADMIN_GUIDE` against the code: the legacy
`vrcadia` references (flag for removal), the currency of the API-discrepancy
notes, the accuracy of the Maincloud deployment checklist, and an honest read on
public-framing readiness for the disclosure article — *without overclaiming*.
*Accuracy, and framing that doesn't write a check the code can't cash.*

**Div5 — Design/Product · the product against its principles.**
Assess f2f against "Apple-simple, not Apple-locked-down," runs-on-a-toaster, and
user-above-all: the presence / DND / visibility model, the call lifecycle, and
crucially whether the security posture *preserves* user control rather than
achieving simplicity by removing it. *Taste, and the user's seat at the table.*

**Div6 — Infrastructure/Platform · the platform reality.**
The build environment (mkosi, the `wasm32-unknown-unknown` target); the resource
characteristics — does the documented RAM-per-connection scaling and the
hardware-sizing table hold against the live module?; Maincloud deploy-readiness;
and CI's actual coverage, including the known no-secret-scan gap on the product
repos. *The platform and the scaling math, ground-truthed.*

**Div7 — Research/R&D · the frontier.**
The state of the attack-class theory (how f2f instantiates write-to-execute, and
how far the generalization is carried), and the portability readiness — the
RealtimeStore/Identity four-way proof matrix (SpacetimeDB + OIDC vs.
PostgreSQL + keypair): what is proven, what is open. *The theory edge and the
portability proof.*

**Div8 — IP/Legal-Strategy · the prior-art posture.**
The currency of the prior-art record (the VECTOR findings and their safeguards
*are* the record — the patent-to-disclose mechanism), the filing status of
invention #3 (universal device command dispatch — the hard precondition on
publication, not yet filed), license-compliance (incl. libndk/GPLv3), and the
status of the disclosure-gate preconditions. **Records, coordinates, and preps
only — does not practice law; counsel and the founder make every legal call.**
*The record and the gate-preconditions.*

---

## Step 2 — Integrate (EA)

The EA collects the eight sections (the `collect` half of the bus), assembles
them into one *Face to Face — State of the Substrate* document, resolves
conflicts only within its authorization (doc-union / additive non-overlapping
keys — anything else is flagged, not decided), and runs the full gate
(board-hygiene + secret-scan + `run_gates`) on the integrated result before it
lands on `main`. Green is earned, not section-reported.

The EA then hands the assembled assessment up for the CEO synthesis and **stands
down to idle.** The EA going idle is the completion signal for this turn — in
steady autonomous operation the EA persists and keeps orchestrating; for this
watched shakedown it stands down so the result can be inspected.

---

## Step 3 — Synthesize (CEO)

The EA hands the integrated assessment up. The CEO writes the strategic
through-line no single lens produces: where the write-to-execute risk
concentrates across the eight readings, what is genuinely closed vs. open, the
**ranked backlog for the first real sprint**, and the disclosure-evidence
implications. This synthesis seeds the next turn of the loop.

---

## Constraints (constitution, in force)

- Isolated worktree per division (the provisioner).
- All dispatch over the bus; hub-and-spoke; EA is sole dispatcher, integrator,
  and adjudicator.
- Every section lands on a feature branch behind the gate. Merge ≠ ship.
- **Nothing is flashed, deployed, published, or applied.** This is an
  assessment — it *reads* the substrate. Any fix it surfaces is a later sprint,
  not this turn. No irreversible button is touched.
- Security retains binding BLOCK authority on anything the audit would land that
  crosses a trust boundary.
- Anti-idle: a blocked or idle division is the worst outcome; fork on decisions,
  land on pushed branches.

---

## Adjudication — what PASS means (EA-adjudicated, CEO-reviewed)

- All eight sections landed cleanly on their branches and integrated by the EA
  behind the gate.
- The bus carried eight concurrent real dispatches with no coordination
  failure — no cross-talk, no lost dispatch, no mesh.
- The integrated assessment exists on `main`; the CEO synthesis exists.
- Nothing was flashed, deployed, or published.

**PASS = the org turned a real wheel autonomously.** That is the functional bar.
