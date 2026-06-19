# WORK ORDER: `.180` Device-Identity Persistence — DETERMINE FIRST
## (+ Tier-1 security cuts, in parallel)

**Addressed to:** a Claude Code session. **Two parallel tracks.** Track A is the
**priority and must report the moment it has an answer** — do not wait for Track B.
**Repos:** `pandora` (private), `elpis-os` (private now — public-trajectory; secret-scan stays standing). Target box: `.180`.
**Source docs:** `security-review.md` (H-9, H-13), `H9-signer-design.md`,
`claude-code-work-order-security-remediation.md` (full Tier-1 detail).

---

## WHY THIS IS THE FIRST QUESTION

The device identity is `sha256(DER SPKI of the ED25519 public key)`. Whether that
identity is **stable across an SSD wipe + Elpis reinstall**, or **regenerated
fresh each reinstall**, determines whether any further security work is even
needed:

- **FRESH per reinstall** → `.180` has effectively rotated identity on every past
  wipe. Any external verifier holding its key would *already* be broken today — so
  there almost certainly is no long-lived off-box verifier, and the H-9 §2
  verifier-sweep collapses to a quick confirmation. Risk bounded down hard.
- **STABLE (hardware-bound)** → an external verifier could silently hold `.180`'s
  key across every reinstall, and the §2 pre-image change would break it. The
  sweep becomes mandatory and thorough.

So this single fact reshapes (or removes) all downstream security work. **Answer
it before STAGE 2/3 of the remediation WO runs.** The Tier-1 cuts, by contrast,
depend on it not at all — so they run in parallel, now.

---

## PRIME DIRECTIVE (condensed)
Security above all; verify, don't assume. **Track A is read-only.** Track B is
branch-only authoring; every `.180` apply is gated to the human, attended,
reversible. **No merges to `main`** (human is sole merge authority). Public repo:
stage by name, secret-scan before every commit, update CLAUDE.md in-commit.

---

## TRACK A — IDENTITY PERSISTENCE (PRIORITY · READ-ONLY · REPORT FIRST)

Determine, conclusively, the persistence model. The deciding factor is **WHERE the
key (or its sealed blob) physically lives**, and whether the installer wipes that
location — *not* whether the TPM is involved. (A TPM-sealed blob stored on the root
SSD is destroyed by a wipe just like a software key; only a key persisted in TPM
NVRAM survives.)

### A1 — Code-read the key lifecycle (should be conclusive on its own)
Locate and read, in `elpis-os` (identity provisioning) and the signer:
1. **Key generation / provisioning.** Find where the device ED25519 key is first
   created (firstboot / postinst / `pandora-identity`). Determine:
   - Is it generated **conditionally** (only when no key exists) or **unconditionally**?
   - **Where is the key / sealed blob written?** Capture the exact path.
2. **Storage location classification.** For that path, determine which case holds:
   - **(a) SOFTWARE key on disk** (`device.key`, H-13 fallback) on the root
     partition → **wiped on reinstall → FRESH identity.**
   - **(b) TPM-sealed blob stored on the root SSD** (TPM seals; blob is a file the
     unseal path reads) → wipe deletes the blob → **FRESH identity** (even though
     the TPM is intact).
   - **(c) Key in TPM NVRAM** (`tpm2_nvwrite`/`nvread`-style; not a root-partition
     file) → **survives wipe → STABLE / hardware-bound identity.**
3. **`pandora-tpm-signer` unseal path** (`packages/pandora-identity/.../tpm-signer.js`):
   confirm whether it reads the sealed blob from a **filesystem path** (which
   partition? wiped by the installer?) or from **TPM NVRAM**. This disambiguates
   (b) vs (c).
4. **Installer behavior.** Confirm whether the Elpis installer (the partition/
   rsync/systemd-boot flow) reformats or preserves the partition that holds the
   key/blob.

### A2 — Record the current identity hash (reinstall baseline)
Read-only on `.180`: compute/observe the current device identity
`sha256(DER SPKI)` and record it verbatim in the report. This is the ground-truth
baseline for the empirical check (A3).

### A3 — Empirical backstop (ground truth)
The definitive test is a before/after comparison across a real reinstall: the A2
hash now, vs. the hash after the next wipe-and-reinstall. **Same hash → STABLE;
different → FRESH.** Note this in the report as the confirmation step the human
runs at the next reinstall; A1's code-read is expected to settle it in advance,
A3 confirms it.

### Track A output — `identity-persistence.md`, REPORTED THE MOMENT A1 RESOLVES
A one-line verdict, plain-language (answers "set at hardware level, or reset every
wipe?"):
- **`FRESH-PER-REINSTALL` (software key)** — reset on every wipe.
- **`FRESH-PER-REINSTALL` (TPM-sealed blob on wiped partition)** — reset on every
  wipe despite the TPM.
- **`STABLE` (TPM NVRAM / preserved partition)** — survives wipe; hardware-bound.
- **`UNCERTAIN`** — code-read inconclusive; state exactly what's ambiguous and what
  A3 will settle. (Treat UNCERTAIN as STABLE for risk purposes until proven
  otherwise — the conservative assumption.)
Plus: the exact key/blob path, conditional-vs-unconditional generation, the
installer's treatment of that path, and the A2 hash. **Then state the
implication:** FRESH → §2 verifier risk bounded low; STABLE/UNCERTAIN → sweep
mandatory before §2.

**Do not block on Track B to report this. The verdict is the gate the human is
waiting on.**

---

## TRACK B — TIER-1 CUTS (PARALLEL · INDEPENDENT · branch-only, applies gated)

Execute **STAGE 1 (1A–1D) of `claude-code-work-order-security-remediation.md`**
exactly as specified there. Summary so this is self-contained:

- **1A — H-1 loopback bind.** Already staged on `hotfix/bridge-bind-loopback`;
  confirm `index.ts:24` defaults `SUBSTRATE_API_HOST` to `127.0.0.1`, confirm/extend
  the loopback regression test, write the deploy runbook. Deploy = AMBER, gated.
- **1B — H-9 §4 dedicated `pandora-sign` group** (the live-reach closer). Create
  `pandora-sign` with ONLY the legitimate signers (dispatch + gateway — confirm
  the users from `.180`); re-chown `sign.sock` to `root:pandora-sign` in
  `tpm-signer.js:117-124`. **Leave `elpis` in group `pandora`** (it needs that for
  `/etc/pandora` config-read — do NOT remove it). Bridge stays user `pandora` but
  loses signing reach (not in `pandora-sign`). Runbook must verify post-apply:
  desktop up + shell reads config; dispatch+gateway still sign; bridge+`elpis`
  reach CLOSED; full Pair→command works. Tested rollback. `RISK: SECURITY/PARITY`,
  apply gated/attended.
- **1C — H-2/H-14** `chattr +a` on both audit logs from a root firstboot/postinst
  step; handle logrotate (`-a`→rotate→`+a`) or document no-rotation. `RISK: PARITY`.
- **1D — H-10** firewall unit → `CapabilityBoundingSet=CAP_NET_ADMIN` + mirror the
  `pandora-tpm-signer` hardening. `RISK: PARITY`.

All four: authoring GREEN (branches), each secret-CLEAN, CLAUDE.md updated, each
with a tested apply+rollback runbook. **None applied to `.180`** — that's the
human's attended step.

**Track coordination:** Track A is read-only and cannot conflict with Track B's
authoring. Both touch the signer area (A reads key persistence; B 1B edits the
socket-chown group) — different concerns, but if one agent runs both, do A1's
read before editing `tpm-signer.js` so the read reflects the current tree.

---

## WHAT THE ANSWER GATES (for the human, after Track A reports)
- **FRESH** → STAGE 2 sweep is a quick confirmation; H-9 §2 likely safe to schedule.
- **STABLE / UNCERTAIN** → STAGE 2 sweep is mandatory and thorough (enumerate every
  off-box verifier; classify owned-lockstep / owned-separate / not-controlled);
  H-9 §2 gated on a clean sweep.
- Either way → Tier-1 cuts (Track B) proceed to the human for attended apply.

---

## REPORT FORMAT
```
Identity Persistence + Tier-1 Cuts

TRACK A — IDENTITY (report the instant A1 resolves):
  Key/blob path:           <path>
  Storage class:           [software-on-disk | tpm-blob-on-disk | tpm-nvram | preserved-partition]
  Generation:              [conditional (only if absent) | unconditional]
  Installer wipes it?:     [yes/no]
  Current identity hash:   sha256(DER SPKI) = <hex>   (A2 baseline)
  VERDICT:                 [FRESH-PER-REINSTALL | STABLE | UNCERTAIN]
  Implication for §2:      [verifier risk bounded low | sweep mandatory]
  A3 empirical check:      [baseline recorded; compare after next reinstall]

TRACK B — TIER-1 CUTS (branch-only; applies gated):
  1A H-1:   branch [..]  test [ref/added]  runbook [y]  CLEAN [y]
  1B §4:    branch [..]  dedicated-group + elpis KEPT in pandora [y]  rollback runbook [y]  CLEAN [y]
  1C H-2/14:branch [..]  logrotate handled [y]  CLEAN [y]
  1D H-10:  branch [..]  CLEAN [y]
  Applied to .180:  [NONE — gated]   Merges to main: [ZERO]   Secrets leaked: [ZERO]
```
