# Work Order — Sprint 1: Make "green" mean green

**Authored by:** the CEO · **Dispatched by:** the EA · 2026-06-20
**Synthesis:** `ceo/synthesis-001-state-of-substrate.md` (ranked #1)
**Classification:** internal CI/quality work. Lands behind the gate. No irreducible buttons.

---

## Why
The first-real-turn audit found product CI is **build-only** — it compiles the workspace but runs
**no integration tests and no secret-scan**. Until that closes, every "merge ≠ ship, green is
earned" claim the org makes — including about its own work — is *asserted, not earned*. This sprint
makes green trustworthy before any sprint relies on it. **This is not an f2f security fix** (those
are the ElpisOS enforcement spec, Sprint 2); it is the org repairing its own quality signal.

## The two lenses (one section each, on each division's branch, behind the gate)

**QA / Release-Eng (Div 3) — lead.** Get the Playwright e2e suites
(`two-session-call`, `group-call`, `webrtc-cross-browser`) running in product CI against an
**ephemeral SpacetimeDB module** (spin up, publish, run, tear down). Define what "green" certifies
once they run; mark which JOIN subscriptions still need live-`onApplied` confirmation (the Sprint-3
seam). Deliverable: a CI job that runs the suites + a short "what green now means" note.

**Infra / Platform (Div 6) — support.** Add a **secret-scan job** to the product CI (gitleaks or
the diff-mode scanner already proven on this board) so the product repos gate secrets the way
cnsUnltd does. Get the workspace rustfmt-clean enough to re-admit `fmt`/`clippy` to CI, or scope
why not. Deliverable: the CI changes + a green run.

## Constraints (constitution, in force)
- Isolated worktree per division; all dispatch over the bus; the EA integrates behind the gate.
- Every section on a feature branch, signed; **merge ≠ ship**. Nothing flashed, deployed, published.
- Fork-never-block: if the ephemeral-module path has a real obstacle, assess both branches and
  surface it — a stalled division is the worst outcome.

## PASS
Product CI runs the e2e suites (or the real blocker is surfaced, not hidden) **and** secret-scans
the product repos; the EA integrates both sections behind the gate; the org's "green" now means
*tested + secret-clean*, not merely *compiles*. Reported up to the CEO for the next turn.
