# FOUNDING STATUS — Design / Product (Division 5)

**Session:** designProductClaude · **Branch:** `division/design-product` ·
**Date:** 2026-06-19 · **Status:** founding cycle (orient → propose → surface →
hold). The loop is not turning yet (ledger D-014); nothing below is executed.

**Discipline note.** Everything here is read-only introspection of the product
repos, cited by path/commit, copied nowhere. This division *proposes* and
*specs*; it does not edit the product repos. Every product-repo adoption of a
spec below is **gated** (REVIEW / Lane I / Security / founder per the change),
and anything public-facing — the brand mark and tagline above all — is the
**founder's** button. Taste never outranks Security or QA (charter §3).

---

## a. DOMAIN INVENTORY — what exists today

My domain (per onboarding table): the Elpis shell UX, device-control UX,
installer UX (Lane I), the elpis brand, and coherence across the parallel lanes.
Everything below lives in `pandora` `applications/elpis-shell/` unless noted.

### Brand & design system
- **Tokens exist and are good.** `src/design-tokens.ts` defines the whole palette
  from one source: `bg #0A0E1A` (void) → surfaces → `accent #3B82F6`
  (protocol-blue) → the five **semantic device-compatibility tiers**
  (native/green, network-assisted/amber, software-locked/orange,
  incompatible/red, unknown/grey) with glow variants. This matches the charter's
  "void / protocol-blue / semantic tiers" and is the strongest coherence asset
  in the product. The comment calls accent "Pandora's identity colour"
  (codename leak — the product is *Elpis*).
- **The brand identity in the charter is unrealized.** Charter brand = **"elpis"
  lowercase Teko, "Hope begins in the dark."** Grep across *both* repos: **no
  "Teko," no tagline, no wordmark asset, no brand/design/UX doc anywhere**
  (`elpis-shell` has no README). The only mark in code is `TopBar.tsx` rendering
  the string **"Elpis"** (capital-E) in Inter/accent-blue.
- **Typography is set in code but undocumented and partly drifting.**
  `src/index.css` loads **Inter + JetBrains Mono** — *from the Google Fonts CDN
  at runtime* (`@import url(fonts.googleapis.com…)`). `src/App.css` is **leftover
  default Tauri/Vite scaffolding** (light theme `#f6f6f6`, Avenir, `.logo.react`
  hovers, `#greet-input`) that directly contradicts the dark system — dead,
  conflicting code.

### Elpis shell
- `src/App.tsx` — the desktop surface: a `TopBar`, a desktop canvas with the
  draggable `DeviceDiscovery` widget + `ControllerPanel`, a floating `ToastStack`
  (launch feedback), the conditional `InstallerPanel`, and a `Dock`. Framed as
  "a live view of your connected world," not a file manager. The familiar
  TopBar+Dock home paradigm the charter calls for is present.
- `src/components/Dock.tsx` — macOS-style magnify-on-hover dock: Devices, Run App,
  Browser, Downloads, Settings. **`Settings` has no `onClick`** (inert
  affordance). `src/components/TopBar.tsx` — clock, device count, and the
  USB-only "Install to Disk" entry.

### Device-control UX — **two paradigms mid-migration**
- **On `main` today: bespoke, per-profile.** `src/panels/ControllerPanel.tsx`
  (a 320px slide-in panel) routes by `profile_id` to hand-written components:
  `controllers/{HueController, SamsungTVController, ChromecastController,
  XboxController, UnpairedDevice, NetworkAssistedDevice, UnknownDevice,
  ControllerComingSoon}`.
- **On the REVIEW trunk, NOT on main: generic, descriptor-driven.**
  `src/controller/DeviceController.tsx` + `src/controller/widgets.tsx` +
  `src/lib/controlSurface.ts` + `src/hooks/useCapabilities.ts` render *any*
  device from a `ControlSurface` descriptor (groups → controls:
  button/slider/dpad/select/applist; tones; a `live/partial/template` discovery
  badge). Zero device-specific code. This is clean, consistent work.
- **Branch reality (verified via `git ls-tree`/`--contains`):** the generic
  renderer is **absent from `main`**; it lives on
  `feature/capability-descriptor-controls` (`d2fa794`, "WIP, compiles clean")
  and is **subsumed into the REVIEW-tier trunk tip `hotfix/bridge-bind-loopback`**
  (merge-policy "tonight's application"; the standalone branch is **ABANDON** —
  stale ancestor). The entire **Lane A `sprint/A/*` provider fan-out** (appletv/
  firetv, avr, cast, kasa, lg/roku, sonos, wiz, `surface-contract`, `provider-set`,
  …) is built on this contract and is also **REVIEW**. So: the near-term
  device-control roadmap rides one descriptor contract that has not yet landed.

### Installer UX (Lane I)
- `src/panels/InstallerPanel.tsx` — a clean fullscreen flow
  (`selecting → confirming → installing → done | error`) over the Tauri backend
  (`list_disks` / `start_install` → `/usr/local/bin/elpis-install` /
  `reboot_system`), with an `install-progress` event stream. Honest, explicit
  destructive confirmation ("Erase and Install," red semantic tier). Entry is
  gated to the USB run context (`useRunContext` → `TopBar` "Install to Disk").
  Off-device it mocks disks so the flow is reviewable in dev. Ledger **D-006**:
  Lane I is a standing crunch lane (app+UX); mechanics land REVIEW, pure UI is
  AUTO-eligible; coordinates with Lane D. `preview/feature/installer-ux` is
  REVIEW per merge-policy.

### First-run / firstboot
- `elpis-os/firstboot/pandora-firstboot.{service,sh}` — **headless** (a systemd
  one-shot self-pair script; deliberately non-interactive after the tty1-hang
  fix). **There is no graphical first-run / welcome / orientation experience.**

### Orrery
- Charter names "the Orrery's design language" as mine to refine. **No "Orrery"
  reference exists anywhere in `pandora`** — it is a Research/R&D side-quest
  (voxel Orrery), not yet a product surface. Future coordination, not present work.

---

## b. STATE ASSESSMENT — through the design/product lens

Pressure-tested against the three standing principles (charter §2).

**In good shape**
- The **token system** is single-source and semantically disciplined — a real
  foundation.
- The **generic capability renderer + widgets** is the right architecture for
  device-control coherence: one code path, consistent press-feedback, semantic
  status. If it lands, every device inherits the same control language.
- The **installer flow** is genuinely Apple-simple-*not*-locked-down: clear,
  honest about data loss, no dark patterns, reviewable off-device.

**At risk / missing / broken (coherence-gap register)**
| # | Gap | Principle touched | Evidence |
|---|---|---|---|
| G1 | **Brand unrealized & undocumented** — charter's elpis/Teko/tagline mark exists nowhere; only "Elpis"/Inter in `TopBar.tsx`. No brand doc. | identity coherence | grep (no Teko/tagline); `design-tokens.ts`; `TopBar.tsx` |
| G2 | **No design system beyond raw tokens** — every panel re-implements buttons/headers/glass inline (`PrimaryButton`/`SecondaryButton` local to `InstallerPanel`; `ActionButton` local to `widgets`; ad-hoc styles in `ControllerPanel`/`DeviceController`). Drift is guaranteed as lanes evolve in parallel. | coherence | the four files |
| G3 | **Two device-control paradigms** (bespoke panel on main vs generic window on the REVIEW trunk) with different surfaces *and* mental models (320px slide-in panel vs full OS window). | Apple-simple (one mental model) | `ControllerPanel.tsx` vs `controller/`; `App.tsx` routing |
| G4 | **The `ControlSurface` contract has no design owner** yet is becoming the universal control-UX contract — the Lane A fan-out multiplies whatever it encodes. | coherence (highest leverage) | `lib/controlSurface.ts`; `sprint/A/*` |
| G5 | **Fonts load from the Google Fonts CDN at runtime** — a third-party network call + offline render-block on a device-control OS meant to "run on a toaster." | runs-on-a-toaster; (minor) user-hostile default / privacy | `index.css` `@import` |
| G6 | **No first-run experience** — user is dropped into the shell with no welcome/orientation/consent. | user-above-all | headless `firstboot` |
| G7 | **Dead/contradictory scaffolding** — `App.css` (light Tauri default) contradicts the dark system; `Settings` dock item is inert. | coherence; small trust ding | `App.css`; `Dock.tsx` |

None of these are safety defects; they are coherence and product-promise gaps —
exactly this division's mandate. G4 and G5 are the two with consequences beyond
aesthetics (G4 multiplies across the fan-out; G5 is offline/privacy/resource).

---

## c. PROPOSED FIRST REAL CYCLE (for when the loop turns)

Tiered by leverage. My outputs are **specs/design artifacts on this branch**;
every *product-repo adoption* is flagged **GATED** with its owner. Nothing here
is started now.

### P0 — foundational (author as cnsUnltd specs; ungated to *produce*)
- **P0-1 — Product-Principles Standing Check.** Write the
  runs-on-a-toaster / Apple-simple-not-locked-down / user-above-all checklist as
  a standing review lens (the design analog to Security's threat lens), to feed
  EVALUATE/sprint-priority. *Ungated artifact.* Adoption as a real gate input is
  a **founder** call (decision D-1 below).
- **P0-2 — elpis Design System & Brand spec v0.** Codify the (good) tokens;
  define the missing layer: wordmark + typography + tagline, and the shared
  component primitives (Button, Panel, Surface, Badge, the destructive-action
  pattern) that G2 is missing. *Ungated to author.* **GATED to adopt:** product-
  repo implementation = REVIEW; **the wordmark + tagline are public-facing =
  founder disposes** (decision D-1).
- **P0-3 — `ControlSurface` design-coherence review (G4).** Review the descriptor
  vocabulary for sufficiency/coherence **before** the Lane A fan-out lands;
  recommend additions if the widget set is too thin. *I propose; the contract is
  trust-adjacent actuation surface = REVIEW* → **Development / architect dispose.**
  Sequencing ask in decision D-3.

### P1 — high-value coherence
- **P1-1 — Resolve the two-paradigm split (G3):** spec the generic renderer as
  the single control path (bespoke panels retire to pairing-only or are
  subsumed); define the panel-vs-window surface. **GATED to adopt** (product-repo;
  REVIEW).
- **P1-2 — First-run experience spec (G6):** a humane, skippable, **no-account /
  no-lock-in** welcome + orientation. **GATED:** touches `firstboot`/boot →
  REVIEW + Lane I + **parity**, and **QA** must gate it.
- **P1-3 — Installer UX coherence pass (Lane I partnership):** bring
  `preview/feature/installer-ux` under the design system; confirm shell-UI-only.
  **GATED:** install-mechanics = REVIEW (D-006); **Security** eyes any
  trust-surface UI.
- **P1-4 — Bundle fonts locally (G5):** remove the runtime CDN dependency.
  Small; pure-UI, likely AUTO-eligible — but I surface it to **Development** to
  implement (and to **Security/Infra** as a minor outbound-call/offline item).

### P2 — cleanup & forward-looking
- **P2-1 — Dock/Settings coherence (G7):** wire or hide inert affordances; spec
  dock behavior. **GATED to adopt** (product-repo).
- **P2-2 — Remove dead `App.css` scaffolding (G7).** Trivial; AUTO-eligible;
  surfaced to **Development**.
- **P2-3 — Orrery design language:** placeholder; **coordinate with Research/R&D**
  when/if it becomes a product surface.

---

## d. DEPENDENCIES — what I need, and from whom

- **Founder:** dispose of the public-facing brand decision (D-1); ratify whether
  the Product-Principles Check is a standing input (D-2); arbitrate the contract-
  review sequencing (D-3). Founder presses every public/brand button.
- **EA:** integrate this branch → `main` (display case); slot the Product-
  Principles Check into the EVALUATE/sprint-priority cadence once it exists.
- **Development (Div 1):** owns `ControlSurface` + the shell code; needs my P0-3
  review before Lane A lands; implements adopted specs.
- **Lane I / Installer:** closest partner (charter §4, D-006) on P1-3.
- **Security/Red-Team (Div 2):** routes any installer/trust-surface UI; eyes on
  the CDN-font call (P1-4). Outranks me on every tie.
- **QA/Release-Eng (Div 3):** gates first-run + installer UX. Outranks me.
- **Docs/DevRel (Div 4):** shared honest-voice / brand-consistency standard
  (P0-2).
- **Research/R&D (Div 7):** Orrery design-language coordination (P2-3).

---

## DECISIONS-NEEDED (for the founder's queue)
1. **D-1 (public-facing — founder's button): brand identity.** Adopt the
   charter's **"elpis" lowercase Teko wordmark + "Hope begins in the dark"**
   tagline as canonical, or keep the current "Elpis"/Inter? *Recommendation:*
   adopt the charter mark; I'll spec it (P0-2); founder disposes the public call.
   *Trade-off:* a wordmark/tagline is durable public identity — deciding now
   prevents every new surface (installer, first-run, Orrery) from hard-coding a
   provisional mark and accumulating drift to undo later. Forecloses: the casual
   "Elpis" string, if Teko/lowercase is chosen.
2. **D-2: is the Product-Principles Check a standing gate input or advisory?**
   *Recommendation:* adopt as a standing, recorded check that feeds
   EVALUATE/sprint-priority but **never overrides Security/QA** (charter §3).
   *Trade-off:* a real check adds one lightweight lens per sprint; advisory-only
   risks the founding promise eroding silently under engineering pressure (the
   exact failure this division exists to prevent).
3. **D-3 (sequencing — founder/Development): review the `ControlSurface` contract
   for design coherence *before* the Lane A provider fan-out merges?**
   *Recommendation:* yes — one review now is far cheaper than retrofitting
   coherence across N landed providers. *Trade-off:* a small, one-time gate on a
   REVIEW-tier merge that is already pending the architect anyway.

## RISKS / FLAGS
- **G4 (coherence, high-leverage):** the universal device-control contract has no
  design owner; the REVIEW-tier Lane A fan-out will multiply whatever it encodes.
  Flag → review before fan-out lands (D-3).
- **G5 (resource / privacy, minor — surfaced to Security/Infra, not a BLOCK):**
  the shell fetches web fonts from `fonts.googleapis.com` at runtime — a
  third-party call + offline render-block on an OS that should run on a toaster.
- **Public-facing:** the brand mark/tagline (D-1) is the **founder's** button; I
  never publish.
- **Gating:** all product-repo adoption of these specs is gated (REVIEW / Lane I /
  Security / founder per the change). This division produces specs only.

## NEXT (once the loop turns)
Author P0-1 and P0-2 on this branch; bring P0-3 to Development for the contract
review; await the three decisions above. Until then: **held.**
