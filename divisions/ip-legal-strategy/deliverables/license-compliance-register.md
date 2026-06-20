# LICENSE-COMPLIANCE REGISTER — v0 (founding)

**Owner:** IP/Legal-Strategy (Div 8).  **Status:** living register, seeded 2026-06-19.
**Read-only inventory — cites by path/commit; copies nothing.**

> **§1 BOUNDARY.** This register **flags conflicts for decision; it does not adjudicate
> them** (charter §3/§7). Every "license" entry below is *the organized picture for the
> founder and counsel to decide.* License names are reproduced from upstream as factual
> labels, not as a legal opinion on compatibility. This division does not give legal advice.

---

## The load-bearing fact (read first)

**elpis-os is GPLv3** (`elpis-os` `LICENSE` @ `61f8588` 2026-06-12; `CONTRIBUTING.md`:
GPLv3 + DCO + `Signed-off-by`) and is **public-trajectory** (private now, destined to
open-source — decision D-004). The compliance posture is currently sound for **one
structural reason:** the license-encumbered runtime pieces (Wine, Waydroid, the MS VC++
redistributable) are **pulled from upstream at install time on the device — not baked into
/ redistributed in the shipped image.** elpis-os conveys *install recipes*, not the
upstream binaries.

This holds **until the image is publicly conveyed** (built + flashed/distributed). At that
transition the GPLv3 obligations on whatever *is* baked, plus a third-party attribution
register, come due. Tracked below as *latent-at-conveyance*, not present violations.

---

## Register

| # | Component / artifact | Path (elpis-os) @ commit | Upstream license (as labeled) | Distribution mode | Status / flag for counsel |
|---|---|---|---|---|---|
| L-1 | elpis-os itself | `LICENSE` @ `61f8588` | **GPL-3.0** | The product | Baseline. All baked, GPL-derived components must be GPLv3-compatible; §3/§6 **source-offer** is *latent-at-conveyance*. |
| L-2 | Wine (`wine-base`/`-dxvk`/`-vkd3d`) | `components/wine-base/…` | Wine = **LGPL-2.1+** (upstream) | **Runtime install** (`install.sh`, apt/upstream) | OK while not baked. If ever baked: confirm-with-counsel LGPL-in-GPLv3 conveyance + corresponding-source. |
| L-3 | MS VC++ 2015–2019 redistributable | `components/wine-msvcrt-2019/install.sh` | **Microsoft proprietary EULA** (redistributable) | **Runtime**, `winetricks -q vcrun2019` into a per-prefix | OK while not redistributed. **If ever baked: MS redistributable-EULA review + GPLv3 mere-aggregation question → counsel.** |
| L-4 | Waydroid runtime | `components/waydroid-runtime/manifest.json` @ `5f212d2` | Waydroid (GPL-family) + **LineageOS VANILLA** system image | **Runtime**, from upstream `waydro.id` repo | OK; installs from upstream. **VANILLA = no Google apps / no microG** — deliberately sidesteps Google proprietary libs. |
| L-5 | android-api-23 | `components/android-api-23/manifest.json` | n/a (`noop` marker) | none (satisfied by L-4) | No license surface. |
| L-6 | **microG / GApps path** (contemplated) | branch `bake-waydroid-microg` (merge-autonomy policy) | involves **libndk = Google proprietary, "not redistributable"** | would be baked | **TIER-3 BLOCKED, `RISK: LICENSE` (decision D-008).** libndk redistributability is the gate. **Counsel determination required** before this can ever leave BLOCKED. |
| L-7 | Third-party attribution (`NOTICE`) | **does not exist** | — | — | **Missing.** A GPLv3 conveyance needs third-party attribution + a written offer of corresponding source. Propose drafting now (founding-cycle T1-c) so the gate is cheap. |

---

## Pandora (private; not public-trajectory) — lighter touch

`pandora` is the private protocol repo (the disclosure article lives here and **never**
moves to elpis-os until the gate). Its npm dependency trees carry the usual permissive
licenses (`node_modules` LICENSE files: MIT/BSD/Apache/ISC across base64-js, prettier,
esbuild, spacetimedb SDK, etc.). Not redistributed as a product today; revisit if/when any
`pandora` artifact is conveyed publicly. **No flag at present.**

---

## Standing watch-items (carry forward each cycle)

1. **The bake boundary is the whole compliance story.** Re-check every cycle: *did anything
   move from runtime-install to baked-into-image?* If yes, that component's license review
   (L-2/L-3/L-4) goes live. Diff `build/mkosi/` + the package hooks against the prior cycle.
2. **libndk / microG (L-6)** stays BLOCKED until counsel rules on redistributability (D-008).
3. **The `NOTICE` / source-offer (L-7)** must exist before any public conveyance; draft early.
4. **Source for the Lane D dependency audits** — request via EA; reconcile into this register
   (founding-cycle T2-a).

*Nothing here is a present violation. The current runtime-install posture is compliant by
construction; these are prepare-for-the-gate items so the disclosure gate is not a scramble.*
