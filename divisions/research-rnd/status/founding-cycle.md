# FOUNDING STATUS — Research / R&D (Division 7)

**Session:** researchRndClaude · **Branch:** `division/research-rnd`
**Date:** 2026-06-19 · **Type:** founding cycle (orient · propose · surface · hold)
**Mandate:** prove the thesis generalizes — substrate-/identity-portability (the
lifecycle's PORTABILITY phase), the general/theoretical form of the write-to-execute
attack class, and the side-quest incubator. Product = **proven possibility**.

> This is the founding deliverable, not ongoing work. The loop is **not turning
> yet**. Everything below is read-only inventory + a *proposed* first cycle for the
> founder/EA to dispose of. No product-repo change, no `.180` access, no merge, no
> gated op was performed. Evidence: `deliverables/portability-and-frontier-inventory-2026-06-19.md`.

---

## SCORECARD (the board view)

| Domain area | State | One line |
|---|---|---|
| Substrate portability | 🟢 **PROVEN** | Same client + same call test pass on SpacetimeDB **and** Postgres — at both the protocol and app layers |
| ↳ Postgres RLS bonus | 🟢 **STRONG RESULT** | 2nd substrate enforces DB-level row security the reference can't yet (#2810) — generalizes the threat model |
| Identity portability | 🟢 **PROVEN (1 substrate)** | Clerk-OIDC + SpacetimeDB-native both work; clean extensible seam |
| The "4-way matrix" | 🟡 **ASSERTED, NOT EXERCISED** | Two axes each proven; the cross-product is composition, not one proof — **green not yet earned** |
| New-substrate exploration | 🟡 **N = 2** | "Any compliant substrate" rests on two relationally-similar substrates; no 3rd |
| Attack-class theory | 🟢 **STRONG DRAFT** | WTES paper (`docs/threat-model.md`) + living article v0.1.0 (PRIVATE) already seeded |
| Living-article hygiene | 🟢 **CORRECTLY FENCED** | v0.1.0 is on a private `pandora` branch — **not** on `main`, **not** in `elpis-os` (verified) |
| Side-quest incubator (Orrery) | ⚪ **GREENFIELD** | Zero code in either repo; concept-only; carries a founder-gated hardware cost |
| Prior-art scan | ⚪ **NOT STARTED** | The novelty claim needs a scan before the publication gate (feeds IP/Legal) |

**The one sentence:** the portability thesis is **genuinely proven on its two main
axes — with a bonus result (substrate-enforced RLS) that advances the threat model
rather than just matching it** — but the charter's headline "4-way matrix" is still
*asserted by composition, not exercised as a single proof*, and making that claim
**earned** (plus a software-only Orrery prototype and a prior-art scan) is this
division's first real job — sequenced *after* Security's AUDIT, per the loop.

---

## A. DOMAIN INVENTORY (read-only; cited by path/commit, nothing copied)

1. **Portability seams (real, clean, extensible).** Substrate seam
   `web-client/src/substrate/index.ts` (`VITE_SUBSTRATE`: `spacetimedb`|`postgres`);
   identity seam `web-client/src/auth/index.tsx` (`VITE_AUTH_PROVIDER`:
   `clerk`|`spacetime`). Both documented for extension with no app-code change.
   *(No abstraction is literally named `RealtimeStore` — a naming gap vs. the
   charter, not a capability gap.)* (`inventory` §1a.)
2. **Substrate portability PROVEN at two layers.** F2F app on Postgres
   `LISTEN`/`NOTIFY` (`applications/face-to-face/server-postgres/`, intro `12c862e`)
   *and* the general protocol on Postgres (`substrate/server-postgres/`). The same
   `two-session-call.spec.ts` places a real P2P call on either substrate.
   (`inventory` §1b.)
3. **The bonus result.** The Postgres substrate enforces **database-level RLS**
   (`server-postgres/rls.sql`) — closing in the DB what SpacetimeDB only works
   around with JOIN-filtered queries (H-02/M-08, pending #2810). A
   portability-derived *threat-model generalization*. (`inventory` §1b.)
4. **Attack-class theory already drafted.** `docs/threat-model.md` (WTES paper, on
   `main`, `354fa49`) states the general class; `docs/research/write-to-execute/
   ARTICLE.md` v0.1.0 (`99e43d9`, branch `feature/research-living-article`, PRIVATE)
   is the seeded versioned disclosure document. (`inventory` §2.)
5. **Side quest greenfield.** No `Orrery`/`voxel` code in `pandora` or `elpis-os`
   (both searched read-only). Concept-only. (`inventory` §3.)

## B. ASSESSMENT (through the R&D lens)

**In good shape**
- Substrate portability is **really proven**, not asserted — two substrates, two
  protocol layers, the same regression test. The strongest claim in the domain.
- The Postgres-RLS result is the kind of finding the charter exists to produce: the
  second substrate *advances* the threat model (server-enforced visibility), it
  doesn't just replicate the first.
- The attack-class theory is well ahead of where a founding cycle would expect — a
  strong WTES paper *and* a seeded, correctly-fenced living article already exist.

**Broken / missing / at risk**
- **The "4-way matrix" is not earned** (R-1). The two axes are each proven, but the
  cross-product is composition, not a single exercised artifact; the charter's
  literal "Postgres + keypair" corner isn't implemented (Postgres uses an
  anonymous-token identity, not a public-key primitive). Per "green is earned," the
  matrix claim should not be reported green until it is.
- **"Any compliant substrate" rests on N=2** (R-5), and the two are relationally
  similar — the generalization is under-tested for a third, different substrate.
- **Two attack-class documents need reconciling** (R-3) — which is canonical, how
  the internal threat model relates to the disclosure article (an evaluate-phase
  step, not yet run).
- **Prior-art scan not started** — the novelty claim is undefended until it is.

## C. PROPOSED FIRST REAL CYCLE (once the loop turns — tiered; gating marked)

> Marking: 🟢 GREEN = branch-only/authoring + local test, run freely · 🟡 AMBER =
> needs a sibling/EA input or a decision first · 🔴 RED-GATED = founder/Security
> presses it, never me. **All of this is sequenced *after* Security's AUDIT** (the
> Audit→Portability dependency, `development-lifecycle.md`).

**TIER 1 — earn the headline claim**
- **T1.1 — Make the 4-way matrix an exercised, CI-gated artifact.** One runner that
  drives `two-session-call.spec.ts` across {SpacetimeDB, Postgres} × {OIDC, native},
  emitting a pass/fail cell grid — turning "asserted by composition" into a single
  proof. 🟢 (authoring + local test only; runs under QA's `ci-verify.sh` once Infra
  stands it up — see Dependencies). Closes R-1.
- **T1.2 — Resolve the "keypair" corner** (depends on Decision #2). If "keypair" is
  literal, prototype a public-key identity adapter behind the existing `auth` seam
  and prove the Postgres+keypair cell; if it's shorthand for "non-OIDC," document
  that the native adapter already satisfies it and correct the charter wording.
  🟡 (needs the founder's read on Decision #2).

**TIER 2 — generalize, then feed evaluate**
- **T2.1 — Stand up a genuinely different third substrate** end-to-end (a non-Postgres
  RTRD), to move "any compliant substrate" off N=2. 🟢 to prototype; the *proven
  adapter* is handed to **Development** to productize under the gates (charter §3 —
  R&D ships nothing). Closes R-5.
- **T2.2 — Author R&D's theory half of the EVALUATE reconciliation:** fold the
  portability results (the RLS generalization; substrate-agnostic write-to-execute
  surface) into the living article's threat-model section as the *theory* input,
  and reconcile the `threat-model.md`↔`ARTICLE.md` relationship. 🟡 (co-owned with
  Security, who owns the reproduced-instance half; happens at evaluate time). Closes
  R-3. **Stays PRIVATE — never to `main`/`elpis-os`/publication (R-2).**

**TIER 3 — incubate + defend**
- **T3.1 — Orrery side quest: software-only voxel prototype** on existing hardware,
  zero spend, kept in the incubator. 🟢 to build; **🔴 any physical display is a
  founder-gated cost decision** (charter §3) — scoped honestly, not spent.
- **T3.2 — Prior-art scan** of the WTES novelty claim — feeds IP/Legal's prior-art
  record and the publication gate. 🟢 to research; the *publication decision* is
  Security-flagged / founder-disposed, never mine.

## D. DEPENDENCIES (what I need, and from whom)

- **From the FOUNDER:** (a) Decisions #1–#3 below; (b) any Orrery hardware spend
  (none requested this cycle); (c) the publication gate on any generalized
  attack-class result — **not mine to press.**
- **From SECURITY/RED-TEAM (Div 2):** the **AUDIT must complete before PORTABILITY**
  (loop dependency) — I should not deepen the abstraction before the audit maps the
  trust boundaries. Shared border on the attack class: Security owns reproduced
  instances, R&D owns the general theory; both feed the article.
- **From the EA:** integrate this branch → `main` under the gate; sequence R&D's
  cadence to run *after* the audit phase; **do NOT integrate the living article**
  (`feature/research-living-article`) to `main` — it is gated to publication (R-2).
- **From QA/Release-Eng (Div 3) + Infra/Platform (Div 6):** the matrix runner (T1.1)
  should execute under `ci-verify.sh` — which Infra's founding status flagged as
  *referenced-but-absent*. T1.1 is blocked on that gate existing.
- **From Development (Div 1):** receives proven concepts (the matrix harness, a 3rd
  substrate adapter, a keypair adapter) to productize under the normal gates.
- **From Docs/DevRel (Div 4):** the portability proof is the adoption story
  ("swap the substrate, same client") — feeds `pandora/docs/adoption-path.md` (theirs).
- **From IP/Legal-Strategy (Div 8):** the prior-art scan (T3.2) feeds their prior-art
  record; the article's dated version lineage is the prior-art evidence.

---

## DECISIONS NEEDED FROM ARCHITECT (isolated, decision-ready)

1. **Is the "4-way matrix" a literal deliverable, or is per-axis proof enough?**
   Options: **(a) [recommended]** build it as one exercised, CI-gated artifact
   (T1.1) — cheap, and it converts a composition-claim into earned-green;
   **(b)** accept the two independently-proven axes as sufficient and *document the
   composition reasoning* instead of building a runner; **(c)** full cross-product
   including a real keypair adapter (= (a)+Decision #2). *Forecloses:* (b) leaves a
   permanent "asserted, not tested" asterisk on the headline portability claim,
   which sits uneasily with "green is earned."
2. **Does "Postgres + keypair" require a real public-key identity adapter,** or does
   the existing anonymous-identity-per-token (and the SpacetimeDB-native, non-OIDC
   adapter) already satisfy "any verifiable identity"? Recommend clarifying intent:
   if "keypair" is shorthand for *non-OIDC*, it is already demonstrated and the
   charter wording should say so; if literal, it is a new adapter (small, hand to
   Dev once proven). *Trade-off:* building a keypair adapter we don't actually need
   is exactly the bloat Cornerstone #6 warns against.
3. **Orrery: software-prototype-now (zero spend) or hold entirely?** Recommend
   **(a)** a software-only voxel prototype on existing hardware (stays in the
   incubator, no spend), with the physical display explicitly deferred to a founder
   spend decision + an honest cost scope. **(b)** Pure hold is equally acceptable —
   it is explicitly *not* critical-path. *Either way, no spend happens without you.*

## RISKS / FLAGS

- **R-1 (MED, RECORD/PORTABILITY):** the "4-way matrix" is **asserted by composition,
  not exercised as one proof**; the literal "Postgres+keypair" corner is
  unimplemented. The axes *are* proven — but the *matrix claim* is not yet earned
  (deliverable-spec: "green is earned, never reported"). Closed by T1.1/Decision #1.
- **R-2 (HIGH, PUBLIC-FACING — Security/EA visibility, no action needed):** the living
  disclosure article (`docs/research/write-to-execute/ARTICLE.md`,
  `feature/research-living-article`) describes live attack surface. **Verified it is
  NOT on `main` and NOT in `elpis-os`** — correctly fenced. Standing invariant:
  it must never reach `elpis-os`, never land on `main`, and never publish before the
  founder's gate. Flagged so the EA does not integrate it and Security tracks it. No
  leak; confirmation, not an incident.
- **R-3 (LOW, RECORD):** two attack-class documents (`threat-model.md` on `main` +
  the living `ARTICLE.md` on a branch) — canonical-status/relationship to reconcile
  at evaluate time.
- **R-4 (LOW, COST — founder-gated):** the Orrery side quest has a hardware/display
  cost dimension. **No spend proposed this cycle**; any future physical prototype
  routes through the founder (charter §3 — money-is-an-object for hardware).
- **R-5 (LOW, OVERCLAIM-RISK):** "any compliant substrate" currently rests on N=2
  relationally-similar substrates. Honest framing until a third, different substrate
  lands (T2.1). Not a defect — a not-overclaiming discipline.

---

## HELD AT
No product-repo change (read-only introspection only) · no `.180` access · no merge
to `main` · no gated op authorized · the living article untouched and unmoved · loop
not started. Orient · propose · surface — **held.**
