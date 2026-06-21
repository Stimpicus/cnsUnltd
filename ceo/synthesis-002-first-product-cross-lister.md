# CEO Synthesis 002 — The org's first product: a compliant cross-listing demo for Pam

**Authored by:** the CEO · 2026-06-21 · **Cycle 2** (first product cycle). Feeds
`work-orders/claude-code-WO-sprint-2-cross-lister-demo.md`.

## What this is
The organization's **first entry into the world**: a purpose-built **Android** app, built for **one
user (Pam)**, that lets her create a sales listing **once** and post it to **Poshmark** and
**Facebook Marketplace** — plus manage inventory and track sales. It is an **internal proof-of-
capability demo for a single investor**. Never published. Working codename **"Tandem"** (final name
is Design/Product's to choose).

## The defining principle: compliant by design
Neither Poshmark nor Facebook Marketplace offers a sanctioned API for a third-party app to
authenticate-and-post *personal* listings. The only way to truly "auto-post" is credential
automation / scripting — a direct violation of both platforms' Terms. The Founder's hard constraint
is **"bypass no ToS, safeguard, or required agreement,"** so auto-submission is **off the table.**

Tandem is therefore an **"enter once, post native"** cross-lister: it collects everything for both
marketplaces in one flow, then performs a **guided native handoff** — pushing the prepared listing
into each marketplace's **official app** (share intents / deep links / pre-filled fields where the
platform allows) so Pam completes each post *inside the official app*, with every safeguard intact.
**One entry → both marketplaces in seconds; the only thing the app never does is impersonate Pam to
tap "post."** That boundary is the whole point — it is what keeps the product clean.

This is also the **value story** for the investor: the org takes an ambiguous ask, finds the legal
landmine its requester didn't, and ships the polished, compliant version anyway. A team that ships
real product *and* doesn't cut corners.

## What "done" looks like (the demo)
Pam opens Tandem, taps **+**, photographs an item with the in-app camera (or picks from the gallery),
fills **one** Apple-simple form that covers what *both* marketplaces need, and taps **Post to both**.
Tandem hands the prepared, photo-attached listing to the Poshmark app and the Facebook app in turn;
Pam confirms each natively. The item now lives in Tandem's **inventory**, tracked through to **sale** —
with **zero configuration required** and optional customization available. The app asked for **only**
camera + photo permissions, stored **no** marketplace credentials (at most an optional hash for its
own lock), and broke **no** platform's terms.

## Standards (non-negotiable, from the Founder + the constitution)
- **Single user, Pam.** No account system; at most an optional local app-lock (the "optional
  credential hash" — for Pam's own entry, never marketplace creds).
- **Enter-once.** No shared field is ever typed twice; the data model is the superset of both
  marketplaces' fields.
- **In-app camera + gallery** for photos.
- **Least privilege.** The app requests **only** the permissions the above literally require — camera,
  and photo access. Nothing else. Security owns this gate.
- **Stores no user information** beyond the optional credential hash. No telemetry, no exfiltration.
- **Bypasses nothing.** Every marketplace safeguard, ToS, and agreement is honored — the handoff model
  exists precisely to guarantee this. IP/Legal owns this gate; nothing ships past it.
- **Inventory + sales tracking** for every item, zero-config, user-customizable if desired.
- **"Apple-simple" controls; a mature, class-competitive feature set** (benchmarked against the
  established cross-listing tools — minus their ToS-violating auto-post).

## The division plan (all eight — the org's first all-hands product)
- **Design/Product — lead:** the Apple-simple unified-entry UX, the both-marketplaces field model, the
  inventory/sales views, the feature-set benchmark, the product name + visual identity.
- **Development — build lead:** the Android app — unified data model, single-entry flow, in-app
  camera + gallery, the local inventory/sales store, the native handoff (share intents / deep links /
  pre-fill), the optional app-lock.
- **IP/Legal-Strategy — compliance gate (binding):** the Poshmark + FB ToS / agreement analysis; what
  the handoff may pre-fill vs. must leave to the native app; sign-off that the design bypasses nothing.
  **Nothing ships past this gate.**
- **Security/Red-Team — privacy gate (binding):** least-privilege permission set; the credential-hash
  + app-lock design; data-at-rest; verify "stores nothing but the optional hash," no telemetry.
- **Research/R&D:** per-platform handoff feasibility — exactly what Poshmark's and FB's apps accept via
  share intents / deep links / pre-fill, and the photo hand-off path.
- **QA/Release-Eng:** the test plan + the signed demo build; verify the demo runs end-to-end on Pam's
  device; "green means green" (Sprint-1 CI applies here).
- **Infrastructure/Platform:** the Android build + CI pipeline, demo-device provisioning, signing.
- **Docs/DevRel:** the investor demo narrative — what Tandem proves about the org.

## Cadence
This is **cycle 2** — the first product cycle, unwatched, gated, signed. Sprint-1's "green means
green" CI is the quality floor it ships on. Definition-of-done is the demo above, IP/Legal- and
Security-gated, integrated by the EA, reported up to the CEO.
