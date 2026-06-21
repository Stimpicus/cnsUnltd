# Work Order — Sprint 2: "Tandem" — the compliant cross-listing demo (the org's first product)

**Authored by:** the CEO · **Dispatched by:** the EA · 2026-06-21
**Synthesis:** `ceo/synthesis-002-first-product-cross-lister.md`
**Classification:** first product build; internal investor demo; **never published.** Lands behind the
gate, signed. No public/physical/irreversible buttons without the Founder.

## Objective
An Android app for **one user (Pam)** that collects a sales listing **once** and posts it to
**Poshmark** and **Facebook Marketplace** via **compliant native handoff**, with built-in **inventory
+ sales tracking**. "Apple-simple," class-competitive, compliant by design. Working name **Tandem**.

## Two binding gates (nothing ships past either)
1. **IP/Legal-Strategy — compliance.** The product **bypasses no ToS, safeguard, or required
   agreement** of either marketplace. Auto-submission is forbidden; the native handoff (Pam confirms
   each post inside the official app) is the mechanism that guarantees it. IP/Legal defines what the
   handoff may pre-fill vs. must leave to the native app, and signs off. A Security/IP-Legal **BLOCK**
   binds; only the Founder disposes of it.
2. **Security/Red-Team — privacy + least privilege.** The app requests **only** camera + photo
   permissions (whatever the features literally require, nothing more), stores **no** user information
   beyond an **optional** credential hash (app-lock only — never marketplace credentials), and emits
   **no** telemetry. Security verifies and signs off.

## Division lenses (each a section on its branch, behind the gate)
- **Design/Product (lead):** the Apple-simple single-entry UX; the unified field model = the superset
  of Poshmark + FB listing fields (no shared field entered twice); inventory + sales views (zero-
  config, optional customization); the feature-set benchmark vs. established cross-listers; product
  name + visual identity.
- **Development (build lead):** the app — unified data model; single-entry flow; in-app camera +
  gallery picker; local inventory/sales store; the native handoff to the Poshmark + FB apps (share
  intents / deep links / pre-fill); optional app-lock.
- **Research/R&D:** per-platform handoff feasibility — exactly what each official app accepts via
  share intent / deep link / pre-fill, including the photo path; document the ceiling of what can be
  compliantly pre-populated.
- **QA/Release-Eng:** test plan + signed demo build; the e2e demo runs on Pam's device; apply the
  Sprint-1 "green means green" CI (tests + secret-scan) to this repo.
- **Infrastructure/Platform:** Android build + CI pipeline, signing, demo-device provisioning.
- **Docs/DevRel:** the investor demo narrative — the run-of-show and what Tandem proves about the org.

## Constraints (constitution + Founder)
- Isolated worktree per division; all dispatch over the bus; the EA integrates behind the gate.
- Every section on a feature branch, signed; **merge ≠ ship.** Nothing published, deployed, or posted
  to a live marketplace account during the build without the Founder.
- Fork-never-block: if a handoff path has a real obstacle, assess alternatives and surface it — a
  stalled division is the worst outcome.
- Product code is its own repo (not `cnsUnltd`); Infra/Dev propose where Tandem's source lives.

## PASS
The demo in the synthesis runs end-to-end on Pam's device: enter once → photos via in-app camera →
post to both via native handoff → item tracked in inventory; **only** camera+photo permissions; **no**
stored creds beyond the optional hash; **IP/Legal- and Security-signed compliant**; integrated by the
EA; reported up to the CEO for the cycle-3 synthesis.
