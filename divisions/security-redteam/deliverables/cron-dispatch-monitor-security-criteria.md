# SECURITY (BINDING) — cron dispatch-monitor read-path criteria

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-21
**Re:** `claude-code-WO-cron-dispatch-monitor.md` (nonce 5cd0649d) — my BINDING role:
*confirm the cron read-path enforces the bus's existing validation, no downgrade.*
**Status:** criteria stated **up front** (Infra leads the build); my CLEAR/BLOCK review
runs against this checklist once Infra's monitor exists. BLOCK authority stands.

---

## The principle (the whole review in one line)

**A cron reader is a *scheduling* change, not a *validation* change.** The bus's
write-to-execute safety lives entirely in `bus.sh`'s validated path (STEP-5.1 CLEAR). The
cron monitor must **invoke that same path** — ideally just `bus.sh process` on a tick — and
**must not** re-implement parsing/validation. A bespoke reader that re-parses the dispatch
is a validation downgrade and is a **BLOCK** by default until proven equivalent.

**Cleanest path to my CLEAR (recommended to Infra):** the cron tick =
`resolve bus.sh from origin/main → BUS_DIV=<div> bash bus.sh process → stamp liveness`.
That reuses the proven validator verbatim; my review is then trivial.

## Binding invariants (violate any → BLOCK)

1. **Canonical source only — the chokepoint + the F1 fence carried forward.** EA→division
   dispatch is read **only** from `origin/main:divisions/<div>/ea_dispatch.md` (the single-`main`
   chokepoint). **No overridable path.** Any test seam (BUS_INBOX_FILE-style) stays gated behind
   the explicit `CNS_BUS_ALLOW_TEST_INBOX=1` (F1, already fenced) — never honored in the
   production cron tick.
2. **Canonical validator, resolved per R4.** Resolve `bus.sh` from **`origin/main`'s object
   store** (not a mutable working tree — R4), and run its `validate_block`/`process` path: the
   exact 7-key enum, the inbound allowlist `{status,crunch,halt}`, the FORBIDDEN-verb guard
   (`deploy|merge|flash|publish|push|apply|reboot|delete|rotate|sign|install|build` → ATTACK),
   `issuer == EA` + `to == self`, and the nonce/timestamp/step regexes. No fork of this logic.
3. **Never executes file contents.** `command` is a validated enum selecting a **pre-written**
   handler; `wo` and every field are **never** `eval`'d, sourced, or interpolated into a shell
   command. `wo` is charset-restricted and only existence-checked against
   `origin/main:work-orders/` — never run. No `eval`, no `source <dispatch>`, no `$(…)` on a field.
4. **Idempotency preserved.** Compare the inbox `nonce` to the outbox `step`; an already-answered
   nonce is a no-op (no double-fire) — exactly as the listener.
5. **Write scope unchanged.** The tick writes **only** the division's own outbox + its liveness
   stamp, to its **own** branch. No write to `main`, no cross-division write. The liveness stamp
   is **data-only** (a timestamp) — it must not be, or gate, any actuation; a stale/forged stamp
   may mislead the EA's staleness check but must never trigger an action or mask a real dispatch.
6. **No new attack surface from the scheduler.** Whatever fires the tick (OS Task Scheduler /
   in-session) must not introduce a writable command surface (e.g., a script path an attacker
   could swap). The tick script should itself be resolved/verified from a fixed source where
   feasible (same spirit as R4).

## What I will run for the CLEAR (against Infra's build)

- Read the cron tick script: confirm it calls `bus.sh process` (or an equivalent that provably
  routes through `validate_block`), resolves `bus.sh` from `origin/main`, and reads the inbox
  only from `origin/main`.
- Re-run the bus self-test + a forbidden/malformed/forged dispatch through the **cron** reader and
  confirm it is rejected **identically** to the listener (ATTACK on `deploy`, INVALID on injection
  `status; rm -rf /` / forged issuer / extra key).
- Confirm no `eval`/source/interpolation of field values anywhere in the tick path.
- Confirm the F1 fence holds in the cron context (a forged `BUS_INBOX_FILE` is ignored without
  `CNS_BUS_ALLOW_TEST_INBOX=1`).

## Note on the listener stand-down
Per the Founder order, I have **stopped my background listener and will not resume it** — cron
supersedes it. Until the cron monitor is built + Security-CLEARed + QA/EA-accepted, I have **no
autonomous dispatch pickup**; I rely on the Founder-as-runner in the interim (as now). That gap is
expected and is exactly what this WO closes.
