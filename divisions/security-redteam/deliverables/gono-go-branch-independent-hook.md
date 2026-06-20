# SECURITY GO/NO-GO — branch-independent pre-commit hook (installed) → **GO**

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** EA install signal — go/no-go on the branch-independent pre-commit hook.
**Install:** R4 hook committed to `origin/main @ 8b3ceb5`; wired via
`core.hooksPath = C:/gitRepos/cnsUnltd/.githooks` (absolute). Scanner resolvable from
`origin/main`. **Companion:** `finding-hook-branch-dependence.md`, `sweep-branch-dependence-gates.md`.

---

## VERDICT: **GO** (one residual flagged below — a cheap follow-up, not a blocker)

The install closes the reported 3rd fail-open and is **R4-compliant on scanner resolution**.
Verified empirically — in-situ against the real wiring **and** in throwaways for the clauses
I can't safely break in the shared clone.

### In-situ (real installed wiring; shared clone; stale division-branch worktree)
The worktree's branch **lacks `.githooks/pre-commit` AND `governance/board-hygiene/secret-scan.sh`
in its tree** (both confirmed absent) — the exact condition that previously meant *no hook and
no gate*. Result: a staged synthetic AWS-key-id was **BLOCKED (exit 1)**. The hook fired via the
absolute `core.hooksPath` and resolved the scanner from `origin/main`'s **object store**. HEAD
unchanged, no stray commit. **The previously-broken scenario is now gated.** ✓

### Throwaway (the remaining clauses)
| Scenario | Result |
|---|---|
| clean staged, scanner on `origin/main` | commit **allowed** (exit 0) ✓ |
| staged secret | **BLOCK** (exit 1) ✓ |
| no `main`/`origin-main` resolvable | **FAIL CLOSED** (exit 1, actionable message) ✓ |
| `+ BOARD_HYGIENE_ALLOW_NO_SCANNER=1` | exit 0 + `[AUDIT]` to stderr (user/branch/time) ✓ |

### Hook content vs R4
- **Clause 1 (fixed canonical source):** satisfied for the **scanner** — `git show
  origin/main:…secret-scan.sh | sh` (object store, not the working tree). ✓
- **Clause 2 (fail closed + scoped audited override):** satisfied. ✓

## The one residual (FLAG — recommend a cheap follow-up; does not block GO)

The hook **file** is resolved via `core.hooksPath = C:/gitRepos/cnsUnltd/.githooks` — an absolute
path into the main clone's **tracked working-tree** `.githooks/` directory. That makes the hook
present for all **worktrees** (good — this is what closes the 3rd fail-open), but the hook *file*
still depends on the **main clone** being on a branch that carries `.githooks/`. If the main
clone ever checks out a stale branch (no `.githooks/`), the file vanishes → no hook → fail-open
for every worktree. So R4 clause 1 ("never read from a working tree") is satisfied for the
*scanner* but not fully for the *hook-file* resolution.

- **Bounded by:** the isolation model (D-035) keeps the main clone on `main` (doctor checks
  "MAIN clone HEAD un-hijacked"); the **binding gate** (`run_gates` from `origin/main`, now
  fail-closed) is the backstop regardless; cnsUnltd is private-permanent.
- **Full-R4 hardening (recommended):** install the hook at **`.git/hooks/pre-commit`** (outside
  the working tree) — or point `core.hooksPath` at a **non-tracked** absolute location — so the
  hook *file* is independent of the main clone's checkout too, matching the scanner's
  branch-independence. Then the file cannot vanish on a checkout.
- **Per-clone wiring:** each clone needs `core.hooksPath` set to *its* absolute `.githooks`
  (worktrees of one clone share it via the common git dir; separate clones each need it). Confirm
  `.githooks/README.md` documents this and every active clone is wired.

## Bottom line

**GO.** The install is a verified, material improvement that closes the reported fail-open; the
hook content is R4-compliant (scanner from `origin/main`, fail-closed, scoped audited override),
and the gate fires correctly on a stale branch that has neither the hook nor the scanner in its
tree. The single residual — the hook *file* still resolves from the main clone's working tree —
is flagged for a cheap follow-up (`.git/hooks/`), bounded by isolation + the binding-gate backstop.

### Gate-resolution workstream status
| Item | State |
|---|---|
| `--staged` BRE bug | fixed + landed (D-031) |
| `run_gates` (binding gate) | verified + signed off → EA integrate `fix/worktrees-gate-failclosed` |
| R4 rule in `board-hygiene-guard.md` | authored → EA integrate `sec/board-hygiene-r4` |
| branch-independent hook | **installed + GO** (residual: move to `.git/hooks` for full hook-file branch-independence) |
| `front1-pusher.sh` | removed with `research-mathsavant` (confirm deletion lands) |
