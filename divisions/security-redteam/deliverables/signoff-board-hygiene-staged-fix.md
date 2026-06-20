# SECURITY SIGN-OFF — board-hygiene `--staged` fix + pre-commit hook fail-open finding

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** CEO request — verify/sign off `fix/board-hygiene-staged @ aa37a54`; audit the
EA `.githooks/pre-commit` fail-closed behavior.
**Companion:** `finding-board-hygiene-staged-bre.md` (the original finding + BLOCK).

---

## 1. SIGN-OFF — `fix/board-hygiene-staged @ aa37a54` → **APPROVED**

All three §6 sign-off conditions are met and independently verified (read-only, in a
throwaway repo — the shared clone untouched):

1. **ERE fix.** The extraction is factored into `extract_staged()` using
   `grep -vE '^\+\+\+'`; the `--staged` case calls `git diff --cached -U0 |
   extract_staged`. The buggy BRE `grep -v '^\+\+\+'` is gone. ✓
2. **`--staged` regression test.** `--self-test` now feeds a synthetic unified diff
   (private IP + `token=<value>`) through the **same** `extract_staged` helper into
   `scan_file` and asserts a dirty diff BLOCKs and a clean diff passes. Reusing the
   production helper means test and production path cannot drift. ✓
3. **Proven load-bearing (negative control).** The buggy BRE helper yields **0 lines**
   on the test's own synthetic diff → `FOUND_BLOCK=0` → the assertion **FAILS**; the
   ERE helper yields the 2 secret lines → BLOCK → PASS. The test actually catches the
   bug it guards (not a vacuous green). ✓
4. **End-to-end.** Real `git diff --cached | extract_staged` in a throwaway repo:
   dirty staged set → **BLOCK (exit 1)**; clean staged set → **CLEAN (exit 0)**. ✓
5. **Scope.** Only `board-hygiene-scan.sh` changed (25+/4−); minimal, no collateral. ✓

**Verdict: SIGN OFF.** The EA may land `aa37a54` to `main` and re-enable `--staged`
per-division guidance. **The BLOCK in `finding-board-hygiene-staged-bre.md §7 is
LIFTED on this merge.**

---

## 2. FINDING — `.githooks/pre-commit` **fails OPEN when the scanner is absent** (MED)

The CEO asked me to confirm the refixed hook "fails closed when the scanner's absent."
Verified empirically:

- **Exec-bit flap: FIXED.** The hook gates on existence (`[ -f "$scanner" ]`) and runs
  via `sh "$scanner"` — independent of the `+x` bit. Verified: a **non-executable**
  scanner still BLOCKs a staged AWS key (exit 1). On Windows `chmod -x` was a no-op
  (`-rwxr-xr-x` persisted) — which is exactly why keying on the exec bit was wrong;
  the fix correctly keys on existence + `sh`. ✓
- **Scanner-absent: still FAIL-OPEN.** When the scanner file is absent the hook prints
  a warning and `exit 0`. Verified: scanner removed → staged AWS key → **hook exits 0,
  commit allowed.** ✗

This is *deliberate* ("degrade gracefully rather than hard-fail on a stale branch that
predates the scanner; the binding gate is the EA directory scan regardless"). But it is
fail-open in a secret gate, and it is the **same class** as the incident that prompted
the refix: a condition under which the scanner does not run results in *allow*, not
*block*. It is also trivially reachable — any branch predating the scanner, or a deleted
/ renamed scanner, opens the window.

**Severity: MEDIUM.** Bounded by: `cnsUnltd` is private-permanent; the **EA
pre-integration directory scan is the binding gate** and catches before `main`; and
the actually-reported exec-bit flap is fixed. Not an emergency, not a BLOCK.

**Recommendation (EA owns the hook — I surface, EA lands):** make the absent path
**fail closed** — `exit 1` with an actionable message ("secret-scan.sh absent — re-sync
to `main` or run the EA directory scan; commit blocked for safety"), **with an explicit,
loudly-printed, audited override** for the legitimate stale-branch case (e.g.
`BOARD_HYGIENE_ALLOW_NO_SCANNER=1`). Default-deny + a deliberate escape hatch beats a
silent allow. One-line change plus message.

**Why I don't wave it through:** "fail-open by design because there's a backstop
elsewhere" is exactly the good-reason-for-an-exception the charter says to distrust.
The backstop protects `main`; it does not protect a branch's history or an unattended
future. Fail-closed-with-override costs nothing and removes the class.
