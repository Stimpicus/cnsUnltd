# mathSavantClaude Front 1 — Provisioning Record (Task 1 · Infrastructure)

**Status:** isolation **PROVISIONED + VERIFIED.** Recorded by the EA in the
single-host bootstrap — the EA operated the mechanical Infra provisioning on the host
(git/worktree work, objectively verifiable); subject to Infra ratification if a
separate Infra session prefers to own the line. This is one-time setup, **independent
of** Infra's systematic session-isolation crunch (neither blocks the other).

## Isolation — done-criteria, verified (not asserted)
- **Worktree:** `C:/GitRepos/cnsUnltd-mathsavant-grind` — present and separate (`git worktree list`).
- **Branch:** `instrument/mathsavant-grind`, cut off `instrument/mathsavant` @ `0bdc4cd`
  (merge-base == parent tip — verified).
- **Separate HEAD:** the worktree's HEAD is independent of the shared clone's `main`
  HEAD, so the grind's continuous auto-commits cannot race other concurrently-active
  sessions — the same single-manual-worktree mitigation used to build the bus.
- **Never `main`:** the grind commits only to `instrument/mathsavant-grind`. Merging
  that branch to `main` is a separate, **founder-only** act (merge ≠ ship).

## Budget line
- **Budget line:** `mathsavant-front1` — its own usage envelope, registered under
  Infra's standing credit-budget monitoring (resource-model §2). NOTE: the
  envelope-monitoring *tooling* is Infra **greenfield** (no meter yet — Infra
  founding-cycle T2.2); the line is registered now and folds into the meter when Infra
  builds it. Default posture is crunch/anti-idle within this envelope; direct
  founder/Infra halt applies throughout.

## Handoff inputs (for the founder's launch keystroke — once Security signs off)
- **Worktree path:** `C:/GitRepos/cnsUnltd-mathsavant-grind`
- **Branch the grind commits to:** `instrument/mathsavant-grind`
- **Standing WO:** `claude-code-WO-mathsavant-standing.md` → Front 1, run under the approved sandbox.
- **Gating prerequisite:** Security sandbox sign-off (Task 2 — `sandbox-spec.md`). **Not yet signed off.**
