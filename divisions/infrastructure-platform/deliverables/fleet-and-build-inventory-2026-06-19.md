# Fleet & Build-Environment Inventory — read-only snapshot

**Division:** Infrastructure / Platform (Div 6) · **Captured:** 2026-06-19, founding cycle
**Method:** read-only introspection only (ICMP reachability + read-only SSH + repo
reads). No state was mutated on any box. Supporting artifact for
`status/founding-cycle.md`.

---

## 1. The fleet (reachability + health)

| Box | Handle | Reachable | Notes |
|---|---|---|---|
| RTX 3090 reference box | `.180` | **YES** | healthy daily-driver; full read-only snapshot below |
| Intel 155H laptop | `.196` | **NO** | no ICMP response — powered off or off-network |
| Hyper-V dev VM (the mkosi build host) | dev VM | **NO** | no ICMP response — VM not running / unreachable from this host |

*Boxes are referenced by handle only. Full live-box network identifiers (LAN IPs)
are deliberately kept out of cnsUnltd per standing policy — connection details
live in box-local ops material, not on the org board.*

### `.180` read-only health snapshot
- **OS/kernel:** Ubuntu 24.04.4 LTS, `6.8.0-124-generic`, x86_64
- **Uptime/load:** 13h43m, load avg 0.44 / 0.54 / 0.54 — stable
- **Capacity:** 20 logical CPUs · 62 GiB RAM (60 GiB free) · root NVMe
  `/dev/nvme0n1p2` 916 G, **2% used, 856 G free**
- **Core `pandora-*` units (systemctl, read-only):** `pandora-desktop`,
  `pandora-dispatch`, `pandora-firewall`, `pandora-home-gateway`,
  `pandora-home-scanner`, `pandora-substrate-api`, `pandora-tpm-signer` =
  **active/running**; `pandora-substrate`, `pandora-growfs` = active (exited)
  [normal oneshot]. The capability-descriptor runtime is live and healthy.
- **Toolchains present:** `node`, `npm`, `git`
- **Toolchains ABSENT:** `mkosi`, `cargo`, `rustc`, `spacetime`, `claude`
  → `.180` is **not** provisioned as a dev/build host (consistent with the
  deploy model: only the node runtime is baked; the dev overlay is a separate,
  gated step).

## 2. The orchestration host (this Windows box — charter §2 "where the swarm runs")
- 24 logical CPUs · 63.3 GiB RAM (32.9 GiB free) · `C:` **504 GiB free / 1.84 TiB**
- Healthy headroom for the multi-lane crunch + a local image-build path.

## 3. The build environment (mkosi)
- **In-repo build path exists:** `elpis-os/build/mkosi/{mkosi.conf,
  mkosi.postinst.chroot,README.md}` + `elpis-os/build/build-mkosi.sh`
  (HEAD `2c614ce`). Migrated off the bit-rotted Ubuntu-noble live-build.
- **Status per repo:** `build/mkosi/README.md` §Status(Phase 2) — the image
  "builds, boots to userspace, and provisions the device identity on first boot."
- **Fragility (the catch):**
  - The build host is the Hyper-V **dev VM — currently unreachable** (§1).
    `mkosi` is **absent on `.180`**, so the VM is the *only* place it has run.
  - Runs **mkosi 20.x** (noble default) with an **uncommitted** stopgap
    `build/mkosi/mkosi.local.conf` supplying a matching initrd + explicit `root=`
    (the 20.x generated initrd can't mount the discoverable root and pulls a
    `t64`-broken `libtss2-mu0`). README: "clean fix is mkosi 22+."
  - **No CI builds the image** — neither workflow (below) does mkosi; the build
    is a manual, single-VM act.

## 4. CI substrate
- **`pandora/.github/workflows/ci.yml`** — 8 jobs: wasm32 workspace module build,
  demo-console typecheck, f2f web-client build, wasm-demo build+sha, software-/
  android-/windows-oracle smoke+tests. Conservative by design (no fmt/clippy; no
  live-substrate integration tests).
- **`elpis-os/.github/workflows/ci.yml`** — 5 jobs: dispatch / home-gateway /
  user-agent (tsc+build+test), shell `bash -n` (blocking) + shellcheck (advisory)
  + handler-JSON validate, apparmor profile parse.
- **Both** trigger on `push:[main]` + `pull_request` → a sprint feature-branch
  push gets **no CI until a PR is opened** (gap vs the orchestration WO P-5
  "CI-on-push" intent).
- **`ci-verify.sh` — ABSENT from both repos.** The merge-autonomy policy and the
  master orchestration WO both name it as the integrator's local combined-QA gate
  (TIER-1 AUTO criterion #2); it is referenced but not implemented anywhere.

## 5. Secret hygiene (incidental finding, routed to Security)
- The component-publisher private key under `elpis-os/build/components-dist/` is a
  local build artifact. It is **NOT git-tracked** and is **covered by
  `.gitignore:46` (`build/components-dist/`)** — verified un-committable. The
  matching public key beside it is content-addressed and ships in the image.
  **No leak.** Visibility flag only (the directory is gitignored as a whole; no
  key filename is named here by design).

## 6. Usage-envelope / credit monitoring
- Assigned to this division by `governance/resource-model.md` §2 ("Infrastructure/
  Platform owns watching this"). **No tooling exists yet** — greenfield.

---
*This is the **v0 fleet/build baseline** — a dated, immutable snapshot intended to
be diffed (not edited) by later cycles. Boxes are referenced by handle only; full
live-box identifiers (LAN IPs) and key filenames are deliberately kept off the org
board per standing policy. No key material, token, or credential is reproduced here.*
