# SECURITY RE-AUDIT — `fix/bus-fence-inbox-seam` (STEP-5.1 F1) → **CLEAR / F1 CLOSED**

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Re:** re-audit of `fix/bus-fence-inbox-seam @ d6c2ec7` — the EA's fix for STEP-5.1 **F1**
(the `BUS_INBOX_FILE` seam bypassed the single-`main` write-auth chokepoint).
**Companion:** `step5-1-bus-write-to-execute-clearance.md` (§3 F1), `cnsunltd-bus-clearance`.

---

## VERDICT: **CLEAR — F1 is closed.** The EA may land `fix/bus-fence-inbox-seam → main`.

The fix gates the seam exactly as F1 required: `comms/bus.sh process()` now honours
`BUS_INBOX_FILE` **only** when `CNS_BUS_ALLOW_TEST_INBOX=1` is *also* set; otherwise the inbox
is read **only from `origin/main`**, and a stray/forged `BUS_INBOX_FILE` is loudly **ignored**.
A single-variable injection (the plausible cross-session vector in the shared-host model) can no
longer substitute a forged inbox — the single-`main` chokepoint holds. Diff is minimal (6+/1−,
confined to `process()` inbox resolution).

## Verified by running it (throwaway, the shared clone untouched)

| Test | Condition | Result |
|---|---|---|
| **T1 — production** | forged `BUS_INBOX_FILE`, no flag | **IGNORED** (loud `[bus] BUS_INBOX_FILE IGNORED…` warning) → read `origin/main`; forged dispatch **not acted on** ✓ |
| **T2 — gated** | forged + `CNS_BUS_ALLOW_TEST_INBOX=1` | seam honoured ("acted") — test path preserved ✓ |
| **T3 — normal** | no `BUS_INBOX_FILE` | clean `origin/main` read, **no** spurious warning ✓ |
| **T4 — regression** | `--self-test` (division dirs present) | **17 / 0** — no regression (the fix touches nothing the validation/roster/sentinel exercise) ✓ |

## Why this is the right shape

- **Default-deny on the seam.** Production sets no flag, so `BUS_INBOX_FILE` is inert there;
  honouring it requires a *second, deliberate* `CNS_BUS_ALLOW_TEST_INBOX=1` that no production
  path sets — so an accidental or single-var-forged inbox is defeated.
- **Tamper-evident.** A `BUS_INBOX_FILE` present without the flag is surfaced (audit signal), so a
  forging attempt in production is loud, not silent.
- **Residual (unchanged, accepted):** an attacker with *full* env control can set both vars — but
  they already own the listener process and could act directly; the seam grants nothing beyond
  that. The fix removes the asymmetric, single-variable bypass, which was F1's actual point.

## Disposition of the STEP-5.1 conditions

- **F1 — CLOSED on this fix landing.** (It was the "fence before reliance" item; now fenced.)
- **F2 — unchanged, still open as an accepted org-level item:** `main`-write remains **procedural**
  (no branch protection on the free private tier). Not a bus fix; the bus bounds it (allowlisted
  verbs only). Founder/org-infra call — out of scope for this re-audit.

**Recommendation to the EA:** land `fix/bus-fence-inbox-seam`, and the D-041 ledger entry can now
record the STEP-5.1 clearance as **CLEAR with F1 fenced** (F2 noted as accepted-procedural). Re-audit
on any future change to `process()`'s inbox-resolution path.
