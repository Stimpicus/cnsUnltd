# CEO Synthesis 001 — State of the Substrate → the first real sprint

**From:** the CEO (Claude) · 2026-06-20 · the Step-3 synthesis owed since D-043, now authored.
**Inputs:** `executive-assistant/state-of-the-substrate.md` (the 8-lens audit) + the Founder's
standing ruling that f2f's findings are an *enforcement specification for ElpisOS*, not app patches.

## The through-line the eight lenses don't each see
Face to Face is a **working** instance of the org's thesis — write-to-execute via a subscription
substrate. Its most important finding is not a bug; it is a **boundary**. f2f's privacy is
client-query-trust today (M-08, the server enforces nothing until RLS #2810), and its actuation
edge is unauthenticated (H-17). Per the Founder's ruling, those are **not f2f patches** — they are
the requirements for the layer where enforcement actually belongs: **ElpisOS**. The application is
the proof-of-concept; the *enforcement* is platform work. That reframes the whole backlog: we do
not harden the app, we **specify the platform** and **make our own quality claims real**.

## What the org can do autonomously now — ranked

1. **Sprint 1 — Make "green" mean green.** The audit's sharpest self-indictment: product CI is
   **build-only** — it compiles but runs **no tests and no secret-scan**. Until that closes, every
   "merge ≠ ship / green is earned" claim the org makes is *asserted*, including its own. Get the
   Playwright e2e suites (two-session, group-call, cross-browser) running in CI against an ephemeral
   module, and add a secret-scan job to the product repos. **Highest leverage — it makes every
   later sprint's green trustworthy.** Lead: QA (Div 3); support: Infra (Div 6). *Dispatched.*

2. **Sprint 2 — Author the ElpisOS enforcement spec** from M-08 + H-17 (the Founder's ruling):
   turn the audit's enforcement gaps into the platform's enforcement *requirements* — server-side
   visibility (the RLS successor), and an authenticated actuation edge. Lead: Research (Div 7) +
   Security (Div 2); support: Infra (Div 6).

3. **Sprint 3 — Retire the asserted-not-earned debt:** live-`onApplied` confirmation per JOIN
   subscription (Dev/QA), and close the open corner of the portability matrix — Postgres + native
   identity, run not argued (Research).

## Surfaced UP to the Founder — not org-authorable

- **Invention #3 (universal device command dispatch) is unfiled**, and disclosure publication is
  gated on it. Filing is a **legal/counsel action**, not org work. The standing risk is letting
  the disclosure-article momentum outrun the filing — flagged so it cannot drift past us.
- **H-17** disposition remains the standing Security-BLOCK recommendation already routed to you.

These two are the buttons this synthesis surfaces; everything above the line, the org turns itself.
