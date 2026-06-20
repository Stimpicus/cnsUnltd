# SECURITY FINDING + BLOCK — `board-hygiene-scan.sh --staged` silently passes (BRE bug)

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-20
**Source:** CEO board-hygiene priority; repro `task_adcd3517`; bug on `main`
`governance/board-hygiene/board-hygiene-scan.sh:70`.
**Severity:** **control defect HIGH** (a secret gate that reports CLEAN
unconditionally) · **realized data exposure LOW + contained + already mitigated.**
**Status:** **BLOCK** on reliance on `--staged` (scope + lift conditions below).
The EA holds the fix for this sign-off — conditions are in §6.

---

## 1. The defect (reproduced)

`board-hygiene-scan.sh:70` (`--staged` mode) extracts staged additions:

```sh
git diff --cached -U0 | grep -E '^\+' | grep -v '^\+\+\+' | sed 's/^\+//' > "$tmp/staged.txt"
```

The second filter `grep -v '^\+\+\+'` runs in **BRE** (no `-E`). In GNU grep BRE,
`\+` is the *one-or-more* operator, not a literal `+`. So `^\+\+\+` does **not**
match the diff header `+++ b/file`; it collapses to "a line starting with one-or-more
`+`" — i.e. it matches **every added line**. `grep -v` then **deletes every added
line**, so `staged.txt` is **empty on every run** and the downstream (correct, ERE)
`scan_file` finds nothing → the scanner prints `CLEAN` and exits 0 unconditionally.

This is not a *weakened* gate; in `--staged` mode it scans an empty file every time —
**zero coverage, full green light.** Reproduced directly:

| extraction | result on a staged diff containing a private IP + `token=<value>` |
|---|---|
| buggy `grep -v '^\+\+\+'` (BRE) | `staged.txt` **empty** → secret **dropped** → **silent CLEAN** |
| fixed `grep -vE '^\+\+\+'` (ERE) | added lines retained → secret present → **BLOCK** |

Root cause that let it ship: the script's `--self-test` exercises `scan_file`
(directory mode, which is correct) but **never exercises the `--staged` extraction
pipeline** — the broken path had no test.

---

## 2. Blast radius — does it guard the product repos? (CEO Q1)

**No — and the product repos have a working backstop.**

- `board-hygiene-scan.sh` exists **only in `cnsUnltd`** (`governance/board-hygiene/`).
  It is absent from `pandora` and `elpis-os` (confirmed: `git grep` for it returns
  nothing in either). It guards the **org board**, not the product code.
- `pandora` and `elpis-os` each carry `.git/hooks/pre-commit` = the overnight
  **`secret-scan.sh`**, a **diff-mode** scanner using correct **`grep -E`** (ERE) —
  it does not use the buggy `--staged` BRE path. So the public-trajectory repo
  (`elpis-os`) and `pandora` were **never gated by this bug.**
- Caveat (noted, not a finding): the product-repo scanner targets secret *values*,
  not live-box *identifiers* (IPs/MACs). Identifier-hygiene is the board scanner's
  job by design; for `elpis-os` the permanent-leak risk is secret values, which the
  correct scanner covers.
- Separately: `cnsUnltd` itself has **no installed pre-commit hook** — `--staged`
  was run **manually** by each session and was the board's *only* automated gate.
  So the board's automated protection was 100% dependent on a scanner that passes
  unconditionally. The control that actually worked was the **EA's pre-integration
  directory scan** (`board-hygiene-scan.sh <dir>` — correct ERE path) **+ the EA's
  eye** (see §4).

---

## 3. Corrected-grep history scan (CEO Q2)

Re-ran the BLOCK patterns with **correct ERE** (`git grep -nEiI` and a full
`git log --all -p` added-line sweep) across **all `cnsUnltd` refs and full history**,
excluding the scanner's own pattern definitions:

- **All current branch tips: CLEAN** (no live-box identifier or secret value present
  on any tip).
- **No secret-value assignment anywhere in history** (empty result for the
  `token|secret|password|api_key|bearer|hmac_secret = <value>` pattern).
- **One real BLOCK-class event in history** — see §4.
- Two false-positive classes confirmed harmless: the scanner's `--self-test`
  synthetic private-key-banner fixture (a pattern literal, no key material), and a
  prose note *describing* a build-artifact `*.key` path (reference-by-path, no key
  material).

---

## 4. The one realized exposure — contained, already mitigated

The Infrastructure/Platform founding-cycle commit **`c247450`** added a fleet/build
inventory table containing **full RFC1918 LAN IP addresses** for three hosts (the
reference box `.180`, the `.196` laptop, and the dev VM) — exactly the live-box
identifiers board-hygiene exists to BLOCK. The broken `--staged` gate let the commit
through (it should have blocked it). Containment:

- The EA flagged it and **masked the identifiers** in follow-up commit **`3417624`**
  ("mask live-box identifiers from fleet/build inventory (EA flag)"). The working
  directory-mode scan + the EA's eye were the backstop that held.
- **`c247450` is reachable only from `origin/division/infrastructure-platform` —
  NOT from `origin/main`.** The integrated board was **never exposed**; the residue
  is in **one division branch's history only**, masked at every current tip.
- Repo is **`cnsUnltd` = private-permanent** (never going public) and the values are
  **non-routable RFC1918** LAN IPs. Residual risk: **LOW.**

(Identifiers are referenced here by nickname only — this finding is itself
board-hygiene-clean.)

---

## 5. Severity call

- **Control defect: HIGH.** A pre-commit secret/identifier gate that returns CLEAN
  unconditionally is the worst failure class — *false assurance*. Every session that
  ran `--staged` received a meaningless green light, and it **demonstrably failed
  open on a real event** (§4). Only a human/EA backstop prevented integration.
- **Realized data exposure: LOW, contained, already mitigated.** Confined to one
  division branch's private history, never reached `main`, masked at all tips,
  RFC1918 values in a private-permanent repo. Product repos unaffected.

No fire-drill. But the gate cannot be trusted or cited until fixed + tested.

---

## 6. The fix review (CEO Q3) + sign-off conditions

**Reviewed one-line fix — CORRECT (verified by reproduction):**

```diff
-    git diff --cached -U0 | grep -E '^\+' | grep -v '^\+\+\+' | sed 's/^\+//' > "$tmp/staged.txt"
+    git diff --cached -U0 | grep -E '^\+' | grep -vE '^\+\+\+' | sed 's/^\+//' > "$tmp/staged.txt"
```

Adding `-E` makes `\+` literal, so `^\+\+\+` matches the `+++` header and only it.
(`grep -vF '+++'` / `grep -v '^+++'` are equivalent; `-E` is minimal.) The rest of
the pipeline is sound: `grep -E '^\+'` is already ERE; `sed 's/^\+//'` correctly
strips the leading `+`.

**Security sign-off requires ALL of the following (EA lands them; I re-verify):**
1. The `-E` fix on line 70 (above).
2. **A `--staged`-path regression test** added to `--self-test`: feed a synthetic
   dirty diff through the *actual* extraction pipeline (lines `grep -E '^\+' |
   grep -vE '^\+\+\+' | sed ...`) into `scan_file` and assert `FOUND_BLOCK=1`. This
   closes the exact gap that let the bug ship (the self-test covered only the
   working mode). Without this test the fix is unverified against regression.
3. I re-run `--self-test` + the §1 reproduction against the patched script and
   confirm a dirty staged set now **BLOCKs**. Then I sign off; EA integrates.

**Strongly recommended (not blocking sign-off):**
4. Install `board-hygiene-scan.sh` as an actual `.git/hooks/pre-commit` in `cnsUnltd`
   (currently absent) **or** formally designate the **EA pre-integration directory
   scan as the binding gate** (it works; it's what caught §4) and treat `--staged`
   as advisory. Do not let an opt-in manual command be the board's only gate.
5. Any shared doc/memory that tells a session to scan staged content must specify a
   **verified-ERE** command (or `gitleaks`/`grep -P`) — note the identical BRE
   pitfall in the loose `git grep --cached <pattern>` advice (`git grep` also
   defaults to BRE). The EA's standing hold ("no shared doc tells a session to use
   `--staged` until Security confirms") should extend to this.

---

## 7. BLOCK — scope and lift

**BLOCK:** do not rely on `board-hygiene-scan.sh --staged` as a secret/identifier
gate, and do not represent any commit as "board-hygiene-scanned via `--staged`,"
until conditions 1–3 in §6 are met and I have re-verified.

- **What it gates:** the EA's landing of the `--staged` fix is held for this sign-off
  (already the EA's posture). Until lifted, the **binding board gate is the EA
  directory-mode scan** (`board-hygiene-scan.sh divisions/<name>/`), which is correct.
- **What it does NOT gate:** product-repo commits (separate, working scanner); the
  Infra `feature/session-isolation-provisioner` branch (out of scope here — not
  adjudicated, per the CEO).
- **Lift:** I re-run the patched scanner's self-test + the §1 repro → green on clean,
  BLOCK on dirty staged → I sign off → EA integrates the fix and may re-enable
  `--staged` guidance.
- **Disposition for the founder (I surface, you dispose):** the masked-at-tip fleet
  IPs remain in `division/infrastructure-platform` **history** (never on `main`).
  Given private-permanent + RFC1918, my recommendation is **ACCEPT-with-rationale**
  (a history rewrite of a private-permanent branch is high-cost / low-benefit); your
  call.
