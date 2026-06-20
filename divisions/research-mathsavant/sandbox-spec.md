# mathSavantClaude Front 1 — Sandbox Spec (Task 2 · Security / Red-Team)

**STATUS: NETWORK-DARK REQUIREMENT SUPERSEDED BY THE FOUNDER — 2026-06-19 (D-025).**
The savant runs **directly on the host alongside the other CC directors**, not in an
isolated/network-dark runtime — the founder judged that level of isolation
unnecessary. **What still holds:** the **write-scope** model — the savant works in its
**own dedicated worktree on its own branch** (`instrument/mathsavant-grind`), the same
isolation every director uses; it does not touch `main`, other worktrees, or other
repos. **What is dropped:** the network-dark / no-egress requirement and the VM
runtime (`sandbox-runtime-plan.md`, retracted) — a CC-session savant must reach the
Anthropic API, so literal zero-egress was never achievable anyway.

> Historical note: this spec was earlier ratified as a conservative network-dark
> sandbox; the founder simplified it to the director-standard model. The independent
> Security write-surface audit + the bus-clearance (STEP 5) remain separate, still-open
> Security items, unchanged by this simplification.

> **Honest caveat:** this is the founder's ratification of a conservative spec — it is
> NOT a substitute for the independent Security / Red-Team audit of the savant as a
> new write-surface (and the bus-clearance / STEP 5). Those remain **separate, still-open
> Security items** and are not conflated with this sandbox sign-off.

> **Scope note:** this is the **sandbox sign-off only.** It is NOT the bus-clearance
> (the STEP 5 / bus go-live gate is a separate Security task) — do not conflate.

## Minimum sandbox spec (from the execution order — Security to ratify/tighten)
- **Reads:** the verified corpus and its own worktree only.
- **Writes:** **only** its own worktree/branch (`instrument/mathsavant-grind`) — nothing else.
- **No reach:** into other repos, other worktrees, `main`, the host, `.180`, or any
  reference box.
- **Network: default-deny** — open only what the verifier/toolchain genuinely needs;
  ideally none.

## Sign-off
- [x] **Base spec ratified by the FOUNDER** (2026-06-19, durability-realignment order) — the authority Security reports to.
- [x] Recorded + ledgered (**D-023**). Option (b) leaves the spec unchanged; no amendment.
- [ ] **Separate, still-open Security items** (not done by this order, not conflated):
  the independent audit of the savant as a new write-surface, and the bus-clearance
  (STEP 5).

A withheld/insufficient sign-off is a STOP, not a fork — but the base spec is
conservative (network-dark) and founder-affirmed, and option (b) relaxes nothing.
