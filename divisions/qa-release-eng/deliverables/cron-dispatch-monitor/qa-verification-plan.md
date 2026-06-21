# QA Verification Plan — Cron Dispatch Monitor

**Division:** QA/Release-Eng (Div 3) — *verify* role. **WO:**
`work-orders/claude-code-WO-cron-dispatch-monitor.md` (crunch nonce `7312337a`).
**Lead/build:** Infra (Div 6). **Binding:** Security (Div 2). **Adjudicates soak:** EA.
**Status:** plan authored + ready; **execution DEFERRED** until Infra's Phase-0 passes
and the monitor/stamp/EA-staleness jobs are built+landed. *QA verifies what Infra
builds; green is EA-adjudicated, never self-reported.*

---

## 1. What QA must prove (the four acceptance checks, from the WO)
QA does not pass the system on assertion. Each check is observation-backed, and where
possible **exit-code / artifact driven** (the division's standing rule: green is earned).

### V1 — Cron fires UNATTENDED, at scale
The failure that started this: long-lived listeners timed out; respawn-on-timer
overwhelmed the app. The cron model must wake **with no session interaction**.
- **Procedure:** with all sessions idle, no one interacting, app backgrounded, observe
  each session's **liveness stamp** advance over a sustained window (≥ the soak length).
- **PASS:** every rostered session's stamp advances every tick (within threshold) across
  the whole window, zero interaction. **Evidence = the stamp timestamps** (monotonic,
  ≤ threshold apart), not a claim.
- **Hard dependency / STOP:** this only holds if **Infra's Phase-0** already proved cron
  fires independently of session-active state on the **Windows desktop-app** environment.
  If Phase-0 shows it idles out with the session, it has the *same disease* — QA cannot
  certify; **STOP + escalate to CEO/Founder** (the WO's load-bearing gate).

### V2 — A killed session is caught as STALE and ESCALATED (no silent loss)
- **Procedure:** kill a session; let its stamp go stale past threshold; observe the EA's
  staleness-check job detect it and **escalate to the human**.
- **PASS:** stale detected within threshold **and** escalation actually surfaced. Then the
  backstop: **kill the EA** → the EA-unreachable path surfaces to the human (root of tree).
- This is the regression that motivated the whole effort (the 2/8-dark, undetected). QA
  treats "death noticed → human told" as **required, not optional** (WO).

### V3 — The cron reader REJECTS a malformed/forbidden dispatch EXACTLY as the listener did
A cron reader is a **reader swap, not a validation downgrade** (WO). QA verifies
**behavior-parity** with the listener's validation (Security owns the *binding* confirm that
the read-path enforces allowlist + `validate_block` + forbidden-verb guard + chokepoint +
F1 fence + never-executes-file-contents).
- **Parity oracle:** `comms/bus.sh --self-test` is the existing 17/0 validation battery
  (injection `status; rm -rf /` → INVALID; `deploy` → ATTACK; forged issuer/`to` → INVALID;
  bad nonce/timestamp → INVALID; `crunch` without `wo` → INVALID). QA's check: the cron
  read-path routes through this **same** `validate_block`, and a cron-fed equivalent of each
  case yields the **identical** verdict.
- **Procedure:** feed the cron reader (a) an injection field, (b) a forbidden verb, (c) a
  forged issuer/`to`, (d) a malformed nonce/timestamp, (e) `crunch` with no `wo`, (f) an
  overridable inbox path (must be ignored — F1 fence carried forward).
- **PASS:** each rejected identically to the listener (INVALID/ATTACK), **nothing from file
  contents is ever executed**, the authoritative path is non-overridable. Any divergence =
  FAIL and routes to Security (BLOCK authority stands).

### V4 — No herd
8+ jobs must not stampede `main`.
- **Procedure:** run the full roster on-cron; confirm schedules are **staggered** (or that
  simultaneous reads are proven harmless); measure under concurrent ticks.
- **PASS:** no error/timeout spike, no lost or doubled dispatch, no app-overwhelm across the
  window. (Directly counters the "respawn-on-timer overwhelmed the app" failure.)

## 2. QA's empirical evidence feeding these criteria (first-hand, this session)
QA/Release-Eng *lived* the listener failure modes the cron model must not reproduce — these
ground the criteria above (not hearsay):
- **`--max N` heartbeat** re-invoked the agent every N min → a **Founder ping** per cycle.
- **Indefinite (`--max 0`)** background listener was **SIGKILLed** by the harness past the
  ~10-min ceiling (`Killed`, no dispatch) → **unreliable wake** (the D-076 missed-directive
  class). Observed directly.
- **Rapid relaunch** produced quick/again-killed loops → the "overwhelmed the app" risk.
**Implication for acceptance:** V1 must prove the cron tick is *short-lived* (wakes, acts,
exits — never approaches the ceiling) and *unattended*; V4 must prove many short ticks don't
recreate the respawn-storm. These are the exact regressions QA will be looking for.

## 3. What green certifies — and what it does NOT (no overclaim)
- **Green (EA-adjudicated soak PASS) =** monitoring works unattended **+** deaths are noticed
  and escalated **+** validation holds at parity with the listener **+** the app is never
  overwhelmed, across the full window.
- **NOT** a Security clearance (Security's binding confirm of the read-path is separate and
  required). **NOT** a claim cron fires unattended until **Infra Phase-0** proves it on the
  Windows desktop-app environment. **NOT** self-reported — the EA adjudicates the soak.

## 4. Acceptance soak (QA's verification mapped to the WO's EA-adjudicated steps)
1. Benign command to each division via cron-pickup → all act, **no persistent listener
   anywhere** → exercises **V1**.
2. Kill a session → stamp stale → EA escalates → exercises **V2**.
3. Malformed/forbidden dispatch → cron reader rejects (allowlist + forbidden-verb hold) →
   exercises **V3**.
4. Kill the EA → EA-staleness backstop surfaces to human → exercises **V2 (backstop)**.
- Sustained, unattended window throughout → exercises **V4 (no herd / no overwhelm)**.
**QA reports the observed result per check; the EA declares PASS.**

## 5. Dependencies / sequencing (what QA needs before it can run this)
- **Infra (Div 6):** Phase-0 result (cron fires unattended — the gate); the built+landed
  dispatch-monitor cron, the liveness stamp, the EA staleness-check job; the stagger.
- **Security (Div 2):** the binding read-path clearance (QA's V3 verifies behavior-parity but
  does not substitute for Security's BLOCK-authority confirm).
- **EA:** runs the staleness cron; adjudicates the soak; owns stale→human + EA-unreachable→human.
- **Founder:** the human backstop at the root; and the Phase-0 STOP escalation target if cron
  proves session-bound.

**QA status:** plan ready; standing by to verify on the built mechanism. No listener resumed
(Founder order — the cron monitor supersedes it). Green earned, never asserted.
