# mathSavantClaude Front 1 — Sandbox Spec (Task 2 · Security / Red-Team)

**STATUS: BASE SPEC RATIFIED BY THE FOUNDER — 2026-06-19** (per the
durability-realignment order, which affirms this spec verbatim: *"Keep it"*).
Security / Red-Team reports to the **FOUNDER**, so that written affirmation is the
binding sign-off the gate awaited; the EA **records** it, and still never self-issues
it. The base spec below stands as approved. **Option (b) durability leaves this spec
UNCHANGED** (the savant stays network-dark; the host pushes) — so no amendment was
needed.

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
