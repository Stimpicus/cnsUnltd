# SECURITY FINDING — cnsUnltd hook absent on stale branches (3rd fail-open) + product-repo immunity VERIFIED

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** CEO — third fail-open of the session; make the hook branch-independent; **verify
(not assume) the product repos are genuinely immune — the severity-determining check.**
**Companions:** `confirm-hook-failclosed.md` (D-032), `finding-board-hygiene-staged-bre.md`.

---

## TL;DR / SEVERITY

- **The bug:** the cnsUnltd hook is wired via **relative** `core.hooksPath = .githooks`,
  which points at **version-controlled** content. Any branch predating `.githooks/`
  has **no hook file at that path → no hook runs at all** → the D-032 fail-closed logic
  can't fire (it isn't present to fire). This is the same root cause one level up: not
  "the scanner is absent," but "the hook itself is absent." Reproduced — **my own
  `division/security-redteam` branch (based at `8d869c1`) is exactly such a branch.**
- **Product repos: VERIFIED genuinely immune to the whole fail-open class** (the
  severity-determining check — done by running them, not assuming). They use
  `.git/hooks/` (`core.hooksPath` UNSET → branch-independent), a **self-contained ERE**
  scanner that **actually blocks**, no BRE bug, no external scanner to go absent.
- **Severity: BOUNDED, not HIGH.** Because product immunity is *verified*, the class is
  **contained to cnsUnltd's hook wiring** and does not reach the public-trajectory
  product repos. cnsUnltd is private-permanent; the binding `run_gates`-from-`$MAIN`
  gate held (8× CLEAN). Consistent with the prior two fail-opens.
- **One separate residual (NOT this class):** neither product repo's **CI scans
  secrets** — flagged below as a pre-public-gauntlet item.

---

## 1. The bug (reproduced)

`git config --get core.hooksPath` → `.githooks` (relative, in-tree). On a branch that
does not contain `.githooks/pre-commit`, git finds no hook and runs none. cnsUnltd has
**no** `.git/hooks/pre-commit` (default path empty). My division branch predates both
the scanner and `.githooks/` — last turn I hit "scanner absent"; the deeper truth is the
**hook is absent**, so D-032's fail-closed never even loads. A version-controlled hook is
durable *but branch-dependent* — the opposite of what a gate needs.

## 2. Product-repo immunity — VERIFIED (severity-determining)

Checked by inspection **and** by running the actual hook in a throwaway repo:

| Check | pandora | elpis-os |
|---|---|---|
| `core.hooksPath` | **UNSET** (default `.git/hooks/`) | **UNSET** |
| `.git/hooks/pre-commit` present | yes (self-contained P-4 scanner) | yes (same) |
| Scanner regex engine | **ERE** (`grep -E`) | **ERE** |
| BRE staged-extraction bug present | **none** | **none** |
| External scanner dependency (absent-risk) | **none** — patterns inline | **none** |
| **Functionally blocks a staged secret** | **YES** — AWS-key-id + secret-value assignment both caught, commit exit 1 | YES (identical hook) |
| **Branch-independent** | **YES** — hook persists across `git checkout` to another branch | YES |
| husky / lint-staged / `core.hooksPath` in tree | none | none |

**Conclusion: immune to all three fail-open mechanisms** (BRE silent-pass; absent
external scanner; absent hook on a stale branch). The product hook lives in `.git/`,
carries its own patterns, uses ERE, and was observed to refuse a real staged secret.

### Residual (separate item, MEDIUM — not this fail-open class)
Neither `.github/workflows/ci.yml` runs a **secret scan** (CI = builds / typecheck /
tests / shellcheck / apparmor only). The local `.git/hooks/` hook is **per-clone** — not
guaranteed on a fresh clone, an external contributor's machine, or a CI runner. Today the
**binding** product gate is the integrator's integrate-then-gate secret-scan
(merge-autonomy STEP 4), a manual/agent step. **Recommendation:** add a CI secret-scan
job (gitleaks, or the committed scanner over the PR diff / full history) so the binding
gate is **automated and clone-independent — a pre-public-gauntlet requirement before
`elpis-os` opens** (charter §5). Not urgent; not the same bug.

## 3. The fix (verified) — branch-independent cnsUnltd hook

Install into `.git/hooks/pre-commit` (per clone; `core.hooksPath` UNSET) a hook that
resolves the **canonical** scanner from **`main`'s object store** — not the checked-out
tree — so a stale branch is still gated. Fail-closed with the D-032 audited override.
This closes all three mechanisms at once: branch-independent (in `.git/hooks`),
content-canonical (from `main` → stale-branch-proof), and fail-closed.

```sh
#!/bin/sh
# cnsUnltd pre-commit — BRANCH-INDEPENDENT. Lives in .git/hooks (present on EVERY
# branch; requires core.hooksPath UNSET). Resolves the canonical secret-VALUE scanner
# from main's object store — NOT the checked-out tree — so a stale branch that predates
# the scanner is still gated. FAIL CLOSED if main/scanner unresolved (audited override).
set -u
mainref=""
for r in refs/remotes/origin/main refs/heads/main; do
  git rev-parse --verify --quiet "$r" >/dev/null 2>&1 && { mainref="$r"; break; }
done
if [ -n "$mainref" ] && git cat-file -e "${mainref}:governance/board-hygiene/secret-scan.sh" 2>/dev/null; then
  git cat-file -p "${mainref}:governance/board-hygiene/secret-scan.sh" | sh; exit $?
fi
if [ "${BOARD_HYGIENE_ALLOW_NO_SCANNER:-}" = "1" ]; then
  printf '[AUDIT] cnsUnltd pre-commit: scanner unresolved from main — ALLOWED via override. user=%s branch=%s time=%s\n' \
    "$(git config user.name 2>/dev/null || id -un)" "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" "$(date -u +%FT%TZ)" >&2
  exit 0
fi
printf 'cnsUnltd pre-commit BLOCKED: cannot resolve secret-scan.sh from main (fetch origin?). REFUSED (fail-closed).\n  Audited override: BOARD_HYGIENE_ALLOW_NO_SCANNER=1 git commit ...\n' >&2
exit 1
```

**Verification (throwaway repo, real stale branch):**

| Scenario | Result |
|---|---|
| Stale branch (tree has **no** scanner) + staged AWS-key-id | **BLOCK** (gated from `main`'s scanner) ✓ |
| Stale branch, clean staged set | allowed (exit 0) ✓ |
| No `main` ref reachable | **fail-closed** (exit 1) ✓ |
| No `main` + `BOARD_HYGIENE_ALLOW_NO_SCANNER=1` | exit 0 + `[AUDIT]` to stderr ✓ |

**Install (EA owns the hook — I author + verify, EA lands):**
1. `git config --unset core.hooksPath` in each cnsUnltd clone.
2. Install the script above as `.git/hooks/pre-commit` (`chmod +x`). One install per
   clone covers all its worktrees (hooks resolve via the shared common git dir).
3. Commit a reproducible `governance/board-hygiene/install-hooks.sh` + a README update
   so any clone can wire it once; run it in the shared clone now.

Optional simpler variant (literal product-repo mirror): install the **self-contained**
`secret-scan.sh` directly as `.git/hooks/pre-commit`. Branch-independent and zero runtime
dependency, but a per-clone copy that can drift from the tracked source on scanner
updates. The from-`main` variant above avoids drift; recommend it.

## 4. Closing

This is the **third and structurally-final** fail-open in the hook chain — BRE
silent-pass (fixed, D-031), scanner-absent (fail-closed, D-032), now hook-absent (this
fix). One forward-looking ask for the EA: **audit whether any *other* cnsUnltd gate
resolves its tool via a relative `core.hooksPath` / checked-out-tree path** — that is the
generalized root cause, and it should be swept once rather than found a fourth time. I'll
re-confirm the hook post-install on request.
