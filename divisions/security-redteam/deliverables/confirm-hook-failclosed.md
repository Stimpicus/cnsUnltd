# SECURITY CONFIRMATION — pre-commit hook fail-closed fix → **CONFIRMED**

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** CEO close-out of the hook fail-open finding; EA D-032 (`fix/pre-commit-failclosed
@ 7f014ef`, HELD pending this Security confirm). EA note: the override is an env var
per-invocation, stamped to stderr.
**Companion:** `signoff-board-hygiene-staged-fix.md §2` (the fail-open finding).

---

## Verdict: **CONFIRMED — the EA may LAND `fix/pre-commit-failclosed @ 7f014ef`.**

Verified empirically in a throwaway repo (shared clone untouched), exercising the real
hook via `core.hooksPath`:

| # | Condition | Result | Property |
|---|-----------|--------|----------|
| T1 | scanner **absent**, no override, secret staged | **exit 1** + actionable BLOCK message | **fails closed on absent** ✓ |
| T2 | absent + `BOARD_HYGIENE_ALLOW_NO_SCANNER=1` | **exit 0** + `[AUDIT]` line to **stderr** (user + branch + UTC) | **loud + audited** ✓ |
| T3 | scanner **present** + secret staged + override=1 | **exit 1** — scanner blocks, override never consulted | **scoped** (cannot bypass a real secret) ✓ |
| T4 | present + clean | exit 0 | sanity ✓ |
| T5 | absent + `…=0` | **exit 1** | **strict** — only `"1"` allows ✓ |

**Mechanism (matches the EA's design note):** the override is the env var
`${BOARD_HYGIENE_ALLOW_NO_SCANNER:-}` read **per-invocation** (hook line 17). The only
`git config` call in the hook reads `user.name` for the audit stamp — **not** the
override decision. Therefore it **cannot become a persistent / always-on bypass** (no
config, no file): every commit re-evaluates and fails closed unless the operator
re-asserts the env var on that one command. The escape hatch is reachable **only** on
the absent-scanner path, so it does not weaken the present-scanner gate (T3).

All four properties the CEO required — **blocks-on-absent, loud, audited, scoped** — are
confirmed, plus strictness.

### Minor, non-blocking observations
- **Audit is stderr-only (ephemeral).** It meets "loud/audited" as specified (visible to
  the committer; captured in any logged session). If a *durable* record is ever wanted,
  append the same `[AUDIT]` line to a tracked log — optional, not required to land.
- **`branch=HEAD` on an unborn branch.** In my throwaway repo with no initial commit the
  stamp showed `branch=HEAD`; on any real branch it resolves to the branch name.
  Cosmetic.

---

## Workstream closed
The board-hygiene secret-gate workstream is complete from Security's side:
- `--staged` BRE bug → **fixed + landed** (D-031; the §7 BLOCK was lifted on that merge).
- Pre-commit hook fail-**open** on absent → now fail-**closed** with a scoped, loud,
  audited, per-invocation env-var override → **confirmed here**.

The **binding** board gate remains the EA pre-integration **directory** scan
(`board-hygiene-scan.sh divisions/<name>/`); the pre-commit hook is the
defense-in-depth front line. Nothing further from Security on this item.
