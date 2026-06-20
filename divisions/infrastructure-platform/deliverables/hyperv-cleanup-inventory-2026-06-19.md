# Hyper-V Cleanup — Inventory + Removal Proposal (Phases 1–2)

**Owner:** Infrastructure / Platform (Div 6), via the EA · **Date:** 2026-06-19
**Scope:** `C:\Hyper-V\` + the Hyper-V VM registry. **Read-only.** Nothing deleted,
nothing quarantined — this stops at the **Phase-3 founder gate.** No disk contents were
read or are reproduced here (artifact metadata only; no IPs / internals).

## Two verifications first (confirm, don't assume)
- **"Staged savant VHDX" hint → does not exist.** No savant VM or VHDX was ever created;
  that VM build was retracted at the recon stage (D-024/D-025) *before* any artifact
  existed. There is nothing of that kind to remove.
- **`C:\Hyper-V\iso\` no longer exists.** Ubuntu ISOs were under it last session; they
  are gone now (moved/removed outside this WO). Only `elpis-dev\seed-cidata.iso` (~0 GB,
  part of the running elpis-dev VM) remains. Flagged, not acted on.

## VM registry (state · project · where its files live)
| VM | State | Serves | Files in `C:\Hyper-V\`? |
|---|---|---|---|
| **elpis-dev** | 🟢 RUNNING | **ElpisOS** (dev / mkosi build host) | Yes — `elpis-dev\` (~100 GB) |
| **Pandora** | 🟢 RUNNING | **Pandora** (and the F2F dev environment) | No — disks in ProgramData |
| **Claude** | ⚪ Off | **unknown** | No — disks in ProgramData (~100 GB) |
| **elpis-final-test** | ⚪ Off | **ElpisOS** (final-image test) | Yes — `elpis-final-test.vhdx` (4.21 GB) |
| **pandora-iso-test4** | ⚪ Off | **Pandora** (current ISO-test iteration, v4) | No — disk in `…\elpis-vm-setup\` |

> **Running VMs (`elpis-dev`, `Pandora`) are KEEP / never-touch** by definition. Note: no
> VM is literally named "F2F dev VM" — if that guardrail refers to one of these, it's the
> **Pandora** VM (F2F lives in the Pandora repo). Both running VMs are already protected;
> **no removal candidate below is running or is a dev VM.** Please confirm the F2F-VM mapping.

## `C:\Hyper-V\` artifacts — classification (total tree = 109.16 GB)

| Item | GB | Class | Reasoning |
|---|---|---|---|
| `elpis-dev\` (running VM + base disk + 5-checkpoint chain + saved state) | 100.28 | **KEEP** | RUNNING ElpisOS dev/build host; the checkpoints are the milestone history (post-install-clean → phase2-bootable-image-verified). Do not touch. |
| `pandora-iso-test\pandora-os.vhdx` | 2.32 | **REMOVE-CANDIDATE** | **Orphaned** — attached to no VM; an early Pandora ISO-test iteration superseded by `pandora-iso-test4` (v4). |
| `pandora-iso-test\pandora-os-v2.vhdx` | 2.35 | **REMOVE-CANDIDATE** | **Orphaned** — same; the v2 iteration, superseded by v4. |
| `elpis-final-test.vhdx` (VM `elpis-final-test`, **off**) | 4.21 | **UNCERTAIN** | Serves **ElpisOS** testing — per the WO, anything serving the three projects is not a candidate without your confirmation. Is the "final test" done, or kept as a reference? Removal would unregister the (off) VM first. |

**Reclaim (within `C:\Hyper-V\` scope):**
- Clear REMOVE-CANDIDATE (orphaned, superseded): **4.67 GB** (`pandora-iso-test\` v1 + v2).
- UNCERTAIN, pending your call: **+4.21 GB** (`elpis-final-test`).
- Maximum pending reclaim if both approved: **~8.88 GB.** (The 100 GB `elpis-dev\` is KEEP.)

## Out of this WO's scope (surfaced, not actioned)
The WO says "stay within `C:\Hyper-V\`." These have files **outside** that path, so they
are **not** removal candidates here — flagged for your awareness only:
- **`Claude` VM (off, ~100 GB in ProgramData) — UNKNOWN purpose.** Not ElpisOS/Pandora/F2F
  by name. The single largest reclaimable artifact on the box *if* it's disposable — but
  its disks are outside `C:\Hyper-V\` and its purpose is undetermined. **Needs your input**;
  would be a separate cleanup if you want it addressed.
- `pandora-iso-test4` (the active v4 iteration) and `Pandora`/`Pandora`'s base disk live in
  ProgramData / `elpis-vm-setup\` — out of scope, KEEP.

## Phase 3 — your gate (nothing happens until you approve, item by item)
1. **Approve REMOVE:** the two orphaned `pandora-iso-test\` disks (4.67 GB)? They own no VM
   and are superseded by v4.
2. **Disposition UNCERTAIN:** `elpis-final-test` (4.21 GB) — remove, or keep as reference?
3. **Out-of-scope note:** want the `Claude` VM (~100 GB, unknown) handled in a follow-up?
4. **Confirm** which VM is "the F2F dev VM" (so the guardrail is explicit).

On your approval, Phase 4 is **reversible-only**: VM OFF → unregister → **move files to
`C:\Hyper-V\_quarantine\`** (never `rm`). The permanent purge stays **your** keystroke
after a cooling-off. **Until you approve, I delete and quarantine nothing.**
