# R&D DOMAIN INVENTORY — Portability proof · attack-class frontier · side quests

**Division:** Research / R&D (Div 7) · **Session:** researchRndClaude
**Date:** 2026-06-19 · **Type:** founding-cycle supporting artifact (read-only)
**Method:** read-only introspection of the product repos (`pandora`, `elpis-os`)
— cited by path/commit, **nothing copied**. No source touched.

Inventory snapshot taken against `pandora` working tree at `d2fa794`
(`feature/capability-descriptor-controls`) and `origin/main`; `elpis-os` present
and searched read-only. This is the detailed evidence behind
`../status/founding-cycle.md` — that file is the board view; this is the receipts.

---

## 1. THE PORTABILITY PROOF (the lifecycle's PORTABILITY phase — R&D owns it)

The charter scopes this as the `RealtimeStore` / `Identity` abstractions and a
**4-way matrix** ({SpacetimeDB, Postgres} × {OIDC, keypair}), scoped to
communication payloads. What actually exists in code:

### 1a. The two abstraction seams (real, clean, extensible)
- **Substrate seam** — `applications/face-to-face/web-client/src/substrate/index.ts`.
  `connectF2FSubstrate()` selects on `VITE_SUBSTRATE`: `spacetimedb` (default) or
  `postgres`. Both paths hand the app a connection exposing the same surface
  (`db.<table>`, `reducers`, `identity`, `subscriptionBuilder`, `disconnect`), so
  the context + UI are substrate-agnostic. There is **no abstraction literally
  named `RealtimeStore`** — the seam is this connect-shim plus
  `substrate/postgresConnection.ts`. (Naming gap vs. the charter, not a capability
  gap.)
- **Identity seam** — `applications/face-to-face/web-client/src/auth/index.tsx`.
  Selects on `VITE_AUTH_PROVIDER`: `clerk` (OIDC, default) or `spacetime`
  (SpacetimeDB-native identity). Adapters: `auth/clerkAuth.tsx`,
  `auth/spacetimeAuth.tsx`. Documented for extension — "add an adapter exposing the
  same three exports … no app code changes" (X.509, DID wallet, another OIDC).
- The thesis these seams serve is stated in `ARCHITECTURE.md`: substrate = any
  real-time relational DB with subscriptions; identity = any persistent verifiable
  cryptographic identity. **The seams are the running-code claim; the question this
  division exists to answer is how much of that claim is *proven* vs. *asserted*.**

### 1b. Substrate portability — **PROVEN, at TWO layers**
- **F2F application layer:** the PostgreSQL substrate
  (`applications/face-to-face/server-postgres/` — `server.js`, `schema.sql`,
  `rls.sql`) runs the F2F **call path** on Postgres `LISTEN`/`NOTIFY` instead of
  SpacetimeDB. The same React client and the **same** regression test
  (`web-client/tests/two-session-call.spec.ts`) place a real P2P call on either
  substrate — the test is in fact *defaulted to Postgres* now. Intro commit
  `12c862e` ("feat: run Face to Face on PostgreSQL (substrate-agnostic call path)").
- **General-protocol layer:** `substrate/server-postgres/` (`server.js`,
  `schema.sql`, `setup.sql`) gives the `command-dispatch-demo` reference protocol a
  Postgres substrate too — so portability is demonstrated for the *protocol*, not
  only the *app*.
- **Bonus research result (matters for EVALUATE):** the Postgres substrate enforces
  **database-level Row-Level Security** (`server-postgres/rls.sql`, README "Row-Level
  Security") — per-row visibility decided by Postgres, unbypassable by any client.
  This *closes in the substrate* what SpacetimeDB can only work around with
  JOIN-filtered queries (findings H-02 / M-08), pending Clockwork Labs #2810. **The
  second substrate doesn't merely match the reference — it demonstrates a security
  property the reference can't yet enforce.** That is a direct "portability
  generalizes the threat model" data point (the lifecycle's Portability→Evaluate
  arrow).

### 1c. Identity portability — **PROVEN on the reference substrate**
- Two identity adapters work end-to-end on SpacetimeDB: Clerk OIDC (production) and
  SpacetimeDB-native (`spacetime` mode, dev). Clean, documented extension point.

### 1d. The "4-way matrix" — **asserted-by-composition, NOT exercised as one artifact**
- The two axes are each proven *independently*: substrate {SpacetimeDB, Postgres}
  via the call test; identity {OIDC, native} via the auth adapters. **There is no
  single artifact that exercises the cross-product** — substrate is chosen per-run
  by an env var (`VITE_SUBSTRATE` appears only in `substrate/index.ts`,
  `vite.config.ts`, the tests, and the READMEs; no matrix runner), and the Postgres
  server's identity model is its own "identity-per-token (anonymous, like
  SpacetimeDB)" (`server-postgres/README.md`) — it is **not** wired to the Clerk-OIDC
  adapter nor to a distinct public-key ("keypair") primitive.
- **So the charter's literal "Postgres + keypair" corner is not implemented**, and
  the full 4-cell matrix is true only by composition of the two axes, not by a
  single exercised proof. Per the charter ("R&D is where that gets tested before
  it's asserted") and the deliverable spec ("green is earned, never reported"),
  **the matrix claim is not yet earned.** This is the single highest-value gap in
  the portability domain and the #1 proposed cycle item.

### 1e. New-substrate exploration — **N = 2**
- Proven substrates: SpacetimeDB + PostgreSQL. `ARCHITECTURE.md` names Supabase /
  PlanetScale as "…" — aspirational, no adapter. "Any compliant substrate" currently
  rests on N=2 (and the two are relationally similar). A genuinely *different* third
  substrate would harden the generalization before it's asserted.

---

## 2. THE ATTACK-CLASS RESEARCH FRONTIER (general form; shared border with Security)

The charter splits this: **Security reproduces concrete instances on our system;
R&D explores the general/theoretical class.** Both feed the living article. Current
artifacts:

- **`docs/threat-model.md` — the WTES theory paper** (on `main`; authored `354fa49`).
  A substantial, already-written statement of the *general* attack class:
  "Write-to-Execute via Subscription Substrate (WTES)" — definition, the three
  preconditions (subscription substrate / registered surfaces / command semantics),
  the "authentication is not a precondition" claim, the scale characteristic, the
  three mandatory mitigations, and a disclosure plan. **This is the theory half my
  division co-owns, and it already exists at a strong draft level.**
- **`docs/research/write-to-execute/ARTICLE.md` — the living disclosure article
  v0.1.0** (commit `99e43d9`, branch `feature/research-living-article`; **PRIVATE**).
  382 lines. Seeded per `work-orders/claude-code-work-order-living-article.md`:
  abstract, class definition, threat model, reference-instance ledger #1 (the H-9
  signing oracle), remediation patterns, the novelty claim, scope, the publication
  gate. **Confirmed NOT on `origin/main` and NOT in `elpis-os`** — correctly fenced
  to a private `pandora` feature branch.
- **Relationship to reconcile:** there are now *two* attack-class documents — the
  `threat-model.md` note and the living `ARTICLE.md`. Which is canonical / how they
  relate (internal threat model vs. the versioned disclosure artifact) is an
  EVALUATE-phase reconciliation, not yet done (the loop hasn't turned).
- **R&D's theory contribution at evaluate time is already visible:** the portability
  result (§1b) *is* theory input — it shows the class is substrate-agnostic in both
  directions (the same write-to-execute surface reproduced as Postgres write
  handlers, AND a substrate-enforced mitigation the reference lacks). That is the
  generalization the article's threat-model section is built to absorb.

---

## 3. THE SIDE-QUEST INCUBATOR (Elpis Orrery / voxel display)

- **GREENFIELD — zero code.** Read-only search for `Orrery` / `voxel` / `orrery`
  found **no matches in `pandora` and none in `elpis-os`** (both repos confirmed
  present and searched). The side quest exists only as a named concept in this
  division's charter (§2) and org memory — there is nothing to inventory yet.
- It carries a **physical/cost dimension** (display hardware) that the charter (§3)
  explicitly flags: money-is-an-object for hardware, founder approves spend. So the
  honest founding posture is: software-prototype-able on existing hardware at zero
  spend; any physical display is a founder-gated cost decision.

---

## 4. PRIOR-ART SCAN (anti-idle backlog item; cross-division with IP/Legal + Security)

- **Not started.** The WTES novelty claim ("the write *is* the dispatch — there is
  no separate send-command step a gate can sit in front of", `threat-model.md` /
  article §6) is the thing that must survive a prior-art scan before publication.
  This feeds IP/Legal's prior-art record (the article's dated version lineage is the
  prior-art evidence) and is gated, at publication, by Security + founder.

---

## 5. WHERE R&D SITS IN THE LOOP (dependency that shapes the first real cycle)

The lifecycle order is *sprint → AUDIT → PORTABILITY → EVALUATE → sprint*
(`governance/development-lifecycle.md`). The Audit→Portability arrow is a **real
dependency**: you cannot responsibly deepen the substrate abstraction before the
audit tells you where the trust boundaries are, or you risk encoding a
substrate-specific assumption into the portability seam. **So R&D's first *real*
cycle is sequenced after Security's AUDIT phase completes** — which has not run yet
(loop not turning). This is a sequencing dependency to surface, not a blocker for
the founding cycle.

---

## CITATIONS (paths/commits referenced; read-only, nothing copied)
- `ARCHITECTURE.md` — substrate + identity thesis
- `applications/face-to-face/web-client/src/substrate/index.ts`, `substrate/postgresConnection.ts`
- `applications/face-to-face/web-client/src/auth/index.tsx`, `auth/clerkAuth.tsx`, `auth/spacetimeAuth.tsx`
- `applications/face-to-face/web-client/tests/two-session-call.spec.ts`
- `applications/face-to-face/server-postgres/` (`server.js`, `schema.sql`, `rls.sql`, `README.md`) — intro `12c862e`
- `substrate/server-postgres/` (`server.js`, `schema.sql`, `setup.sql`) — general-protocol substrate
- `docs/threat-model.md` (WTES paper, authored `354fa49`)
- `docs/research/write-to-execute/ARTICLE.md` @ `99e43d9` on `feature/research-living-article` (PRIVATE)
- Orrery/voxel: **absent** from `pandora` and `elpis-os` (verified negative)
