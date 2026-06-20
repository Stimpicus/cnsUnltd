# mathSavantClaude Front 1 — Sandbox Spec (Task 2 · Security / Red-Team)

**STATUS: PROPOSED — AWAITING SECURITY / RED-TEAM BINDING SIGN-OFF.**

Security / Red-Team (Div 2) **defines and approves** the sandbox; it reports to the
**FOUNDER**, not the CEO/EA. **The EA does not self-issue this clearance** — a binding
security gate that is independent of the CEO is the constitution's deliberate
asymmetry, and the Boromir clause says be *most* suspicious of a good reason to
self-clear ("just to start Front 1"). The minimum spec below is transcribed from the
founder's execution order **for Security to ratify, tighten, and sign off** — it is
not pre-approved by the EA.

> **Scope note:** this is the **sandbox sign-off only.** It is NOT the bus-clearance
> (the STEP 5 / bus go-live gate is a separate Security task) — do not conflate.

## Minimum sandbox spec (from the execution order — Security to ratify/tighten)
- **Reads:** the verified corpus and its own worktree only.
- **Writes:** **only** its own worktree/branch (`instrument/mathsavant-grind`) — nothing else.
- **No reach:** into other repos, other worktrees, `main`, the host, `.180`, or any
  reference box.
- **Network: default-deny** — open only what the verifier/toolchain genuinely needs;
  ideally none.

## Sign-off — to be completed by Security / Red-Team (binding)
- [ ] Security ratifies (or tightens) the spec above.
- [ ] A recorded sign-off naming the **approved** spec, committed (gated) + ledgered.
- A **withheld sign-off is a STOP, not a fork** — security is binding here. If the
  spec is insufficient, the gap is fixed **before** launch.

**Until this sign-off is recorded, Front 1 is NOT handed to the founder for launch.**
