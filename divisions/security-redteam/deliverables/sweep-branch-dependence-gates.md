# SECURITY SWEEP — gates resolved via relative `core.hooksPath` / checked-out-tree path

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** CEO — sweep cnsUnltd for the branch-dependence root cause (a gate that resolves
its tool through a relative `core.hooksPath` or a checked-out-tree path); report findings.
**Scope:** `origin/main @ d6387b2`, all gate/gate-runner scripts + hooks.
**Adjustment (founder, this turn):** `research-mathsavant` deleted — see §0.

---

## 0. Adjustment — `research-mathsavant` deletion (verified state)

The founder reported `research-mathsavant` deleted. **Verified:** the deletion is
**LOCAL + UNCOMMITTED** in the shared main clone — `git status` shows all 8
`divisions/research-mathsavant/` files as ` D` (deleted, unstaged) on `main @ d6387b2`.
It is **not committed or pushed**: `origin/main` still carries the directory, and no
branch holds a deletion commit; the `instrument/mathsavant*` branches still exist on
origin. So the removal is intended but not yet on the canonical board. **Effect on this
sweep:** `front1-pusher.sh`'s defects (§2, row 3) are **moot once the deletion lands** —
no fix needed, just confirm it commits+pushes.

> **Operational note (cross-ref `operational-attack-surface-onboarding.md`):** those
> uncommitted deletions now sit in the *shared* main clone's working tree. A session that
> commits in that clone could entangle them (or a `git add -A` would stage them). I left
> them untouched and worked from an isolated worktree.

---

## 1. Method

Enumerated every gate/gate-runner on `origin/main` and classified each by **how it
resolves its gate TOOL**: **FIXED** (an origin ref / `$MAIN`-pinned / self-contained /
absolute path → branch-independent) vs **BRANCH-DEPENDENT** (relative `core.hooksPath` /
`$(git rev-parse --show-toplevel)`-tree path / current-branch ref → vanishes on a branch
that lacks the file). Also re-hunted the **BRE silent-pass** extraction (`grep -v
'^\+\+\+'`) since it is the partner failure.

## 2. Findings

| Gate / runner | Resolves its tool from | Verdict |
|---|---|---|
| `.githooks/pre-commit` | relative `core.hooksPath .githooks` **+** `$(git rev-parse --show-toplevel)/governance/.../secret-scan.sh` | **BRANCH-DEPENDENT** — known; fix authored `4911768`, pending EA install |
| `…/session-isolation/worktrees.sh` `run_gates`/`find_gate` | `$MAIN` = the **main clone's working tree** (`git worktree list` 1st entry, line 38); fallbacks tree-relative; **miss → `return 0` (FAIL-OPEN)** | **LATENT (LOW-MED)** — robust while the main clone sits on `main` (held 8× CLEAN, D-035), but `$MAIN` is branch-dependent if that clone leaves `main` (it *does* flip), and the no-scanner path fails OPEN. Harden. |
| `divisions/research-mathsavant/front1-pusher.sh` | Gate-1 `$ROOT/governance/.../board-hygiene-scan.sh` (show-toplevel; `if [ -f ]` → **fail-open skip**); Gate-2 inline secret-scan with **BRE** `grep -v '^\+\+\+'` (silent-empty) | **DEFECTIVE — but BEING DELETED** (§0) → moot-on-landing |
| `comms/bus.sh` | `git show origin/main:…` / `git cat-file -e origin/main:…` (FIXED ref) | **SAFE** |
| `executive-assistant/wheel-turn-harness/wheel-turn.sh` | `show-toplevel` only for a scratch `WORKDIR`; heartbeats via `origin/<branch>` refs; enforcement delegated to `run_gates` | **SAFE** (no tree-relative gate tool) |
| `governance/board-hygiene/{secret-scan,board-hygiene-scan}.sh` | the tools themselves (operate on given input); `core.hooksPath` appears only in a comment | **SAFE** (the wiring is owned by the resolvers above) |

**Empirical confirmations (this sweep):**
- `front1-pusher.sh` Gate-2 BRE extraction: fed a dirty range (private IP + AWS key) →
  `ADDED` came back **empty** → Gate-2 verdict **PASS (silent)**; the ERE form catches
  both. Same bug as `--staged`. (Moot — being deleted.)
- The BRE silent-pass appears in **no other live script**. `run_gates` already uses
  `grep -Ev '^\+\+\+'` *with an explicit comment citing the BRE pitfall* — the org applied
  the `--staged` lesson (D-031) here. Good.

## 3. What the sweep concludes

Beyond the already-known hook, the branch-dependence root cause recurs in exactly **two**
live places: **`worktrees.sh run_gates`** (latent — `$MAIN`-is-working-tree + fail-open
on a scanner miss) and **`front1-pusher.sh`** (being deleted). Everything else resolves
its tool from a fixed source (`origin/main` ref, or self-contained) and is branch-
independent. **Severity: BOUNDED** — cnsUnltd is private-permanent; the product repos are
verified immune (prior finding); the one live latent issue is gated by the main clone
normally sitting on `main` and held 8× CLEAN.

## 4. Recommendations (EA owns the tooling — I surface + verify)

- **R1 — the hook:** land the branch-independent fix `4911768` (`.git/hooks/pre-commit`,
  `core.hooksPath` unset, scanner resolved from `main`'s object store). *[pending]*
- **R2 — `run_gates` (LOW-MED, the binding gate):** two one-liners —
  (a) `find_gate` miss → **`return 1` (fail CLOSED)**, not `return 0`;
  (b) resolve the scanner from a **fixed ref's object store**
  (`git cat-file -p origin/main:governance/board-hygiene/board-hygiene-scan.sh`) instead of
  `$MAIN`'s *working tree*, so the binding gate does not depend on the main clone sitting
  on `main`. Mirrors the hook fix.
- **R3 — `front1-pusher.sh`:** confirm the `research-mathsavant` deletion lands
  (commit + push); on landing its two defects are removed. **If mathSavant is ever
  revived, its pusher must use a self-contained / fixed-ref board-hygiene scan + ERE
  extraction** — do not resurrect the deleted version.
- **R4 — generalization (durable rule):** *a gate must resolve its tool from a fixed
  source (an origin ref / self-contained / absolute-pinned), never the checked-out tree
  or a relative `core.hooksPath`; and it must fail **CLOSED** if the tool can't be
  located.* Add this to `board-hygiene-guard.md` so a fourth instance isn't authored.

## 5. Post-install hook re-confirm (CEO's standing ask)

Pending the EA installing the branch-independent hook. On their signal I will re-confirm:
gating from `main` on a stale/scanner-less branch, fail-closed when `main` is unresolved,
and the scoped/audited override — same battery as `confirm-hook-failclosed.md`.
