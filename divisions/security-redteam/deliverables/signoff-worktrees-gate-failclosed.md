# SECURITY SIGN-OFF — `run_gates` fix + R4 authored

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** CEO — verify Infra's `run_gates` fix; author R4 into `board-hygiene-guard.md`;
re-confirm the branch-independent hook on the EA's install signal.
**Companion:** `sweep-branch-dependence-gates.md` (the sweep that surfaced both items).

---

## 1. SIGN-OFF — `fix/worktrees-gate-failclosed @ 23e0a17` → **APPROVED**

Infra's stated property — the guarded commit gate (a) reads its checker only from
canonical `origin/main` (not a mutable working tree) and (b) cannot be bypassed by a
missing/unresolvable checker (fail-closed) — is **verified by running it** (throwaway
repos, the shared clone untouched):

- **Resolves from `origin/main`'s object store, not the tree.** `resolve_gate` now does
  `git -C "$MAIN" show "origin/main:<path>"` and materializes it. On a **stale branch
  whose working tree lacks the scanner**, `resolve_gate` still returned the full 111-line
  canonical checker (from `origin/main`). ✓
- **Fail-closed on an unresolvable checker.** `run_gates` does
  `resolve_gate || { log "...FAIL CLOSED..."; return 1; }`. Verified: a bogus
  `CNS_GATE_PATH` → `run_gates` returns **1 (BLOCK)**; an empty/unreadable checker →
  `[ -s ]` rejects → fail-closed. The old `return 0` (fail-open) is gone. ✓
- **End-to-end.** On a stale branch, a staged secret (private IP) → **BLOCK (exit 1)**;
  a clean staged set → exit 0. ✓
- **Self-test 10 passed / 0 failed** (with the registry co-located), including the two
  new assertions `gate resolves from origin/main` and `gate miss => run_gates FAILS
  CLOSED`, plus the ERE diff-extract guard. ✓
- **Scope:** only `worktrees.sh` changed (26±). ✓

**Verdict: SIGN OFF.** The EA may integrate `fix/worktrees-gate-failclosed → main` under
the gate. This closes the latent fail-open in the binding gate (sweep finding §2, row 2):
the binding gate no longer depends on the main clone sitting on `main`, and no longer
passes when the checker can't be located.

## 2. R4 authored → `sec/board-hygiene-r4 @ 28d3887` (for EA integration)

Per the CEO, R4 is written into `governance/board-hygiene/board-hygiene-guard.md` as a
**Security addendum** (authored on `sec/board-hygiene-r4` off `origin/main`; board-hygiene
scan CLEAN; the live pre-commit hook ran and passed on commit). The rule, in two
mandatory clauses:
1. **Resolve the checker from a FIXED canonical source** (`origin/main` object store /
   self-contained / absolute) — never the checked-out tree or a relative `core.hooksPath`.
2. **Fail CLOSED** if the checker is unresolvable; any override is a per-invocation,
   loudly-audited env var scoped to the unresolvable case.

It generalizes the existing ERE rule (ERE = *how* a checker matches; R4 = *where it comes
from* and *what happens when absent*) and records the three instances + their fixes.
**EA to integrate `sec/board-hygiene-r4`** alongside `fix/worktrees-gate-failclosed`.

## 3. Hook post-install re-confirm — STILL OWED (pending EA signal)

The branch-independent hook (`finding-hook-branch-dependence.md`, fix `4911768`) is not
yet installed. The moment the EA signals it is, I will re-confirm the same battery:
stale/scanner-less branch still gated **from `origin/main`**, fail-closed when `main` is
unresolvable, and the scoped/audited override. (Incidental data point: committing R4 on a
current branch exercised the *existing* `.githooks` hook and it passed — the gap is only
the stale-branch / absent-hook case, which the branch-independent fix closes.)

---

## Status of the gate-resolution workstream
| Item | State |
|---|---|
| `worktrees.sh run_gates` (binding gate) | **fix verified + signed off** → EA integrate `fix/worktrees-gate-failclosed` |
| R4 rule in `board-hygiene-guard.md` | **authored** → EA integrate `sec/board-hygiene-r4` |
| `.githooks/pre-commit` branch-independence | fix authored (`4911768`); **pending EA install + Security re-confirm** |
| `front1-pusher.sh` | removed with `research-mathsavant` (deletion was uncommitted at sweep time — confirm it lands) |
