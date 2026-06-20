# FOUNDING STATUS — IP / Legal-Strategy (Division 8)

**Session:** ipLegalStratClaude   **Branch:** `division/ip-legal-strategy`
**Date:** 2026-06-19   **Cycle:** founding (orientation + first proposal — the loop
is not turning yet).

> **§1 BOUNDARY — read before reading anything below.** This division **does not
> practice law and does not give legal advice.** Every line in this document and its
> supporting registers is *"here is the organized picture for the founder and counsel
> (Woodard Emhardt) to decide,"* never *"here is the legal answer."* Patentability,
> claim strategy, disclosure-timing as a legal act, and license interpretation as a
> binding opinion belong to the **human attorney and the founder**. Where this document
> notes a statute, a clock, or a copyleft obligation, it is reproducing **public,
> standard procedure as a checklist item for counsel to confirm** — not an opinion on
> this project's facts. This boundary is load-bearing (charter §1), not a disclaimer.

---

## 0. HEADLINE — what the founder/counsel should look at first

Lead with the decisions, per the deliverable spec. Three things rose to the top of
the inventory:

1. **The IP-readiness gate is RED, and the reason is structural, not a backlog item.**
   Invention #3 — *"Universal device command dispatch,"* the foundational protocol
   from which inventions #1 and #2 descend — is recorded as **NOT YET FILED**
   (`pandora` `README.md` @ main, last touched `64b868e` 2026-06-09). The private living
   article (`pandora` `docs/research/write-to-execute/ARTICLE.md` @
   `feature/research-living-article` `99e43d9`) is a precise structural description of
   *that same* foundational subject. **The sequencing of any publication of the article
   versus the filing decision on invention #3 is a question for counsel** — surfaced
   here as the central IP-readiness item, deliberately *not* adjudicated. Until counsel
   and the founder resolve that sequencing, this division **cannot confirm the IP half
   of the disclosure gate.** (See §C-1, the headline decision-needed.)

2. **The "attorney meeting June 12, 2026" is in the past (7 days ago) and its outcome
   is not in either repo.** I have no recorded result of that engagement. The
   attorney-prep dossier (`deliverables/attorney-prep-dossier.md`) is built from what
   the repos state; **the meeting outcome is a dependency I am requesting from the
   founder** (§D).

3. **elpis-os is GPLv3 and public-trajectory; the current compliance posture holds
   because nothing license-encumbered is *baked* — Wine / Waydroid / the MS VC++
   redistributable are pulled from upstream at *install time on the device*, not
   redistributed in the image.** That is the load-bearing license fact and it is
   currently sound. It becomes a live obligation the moment the image is *conveyed*
   (publicly built + flashed/distributed) — at which point a third-party attribution
   register and the GPLv3 source-offer both come due. Neither exists yet. (See the
   license register; this is a *track-and-prepare* item, not a present violation.)

None of these are mine to resolve. They are surfaced for the founder + counsel.

---

## A. DOMAIN INVENTORY (what exists today — cited by path/commit, nothing copied)

My charter (§3) gives this division four ownership areas. Inventory of each, read-only
across `pandora` and `elpis-os` (no source touched):

### A-1. The prior-art record (the living article's dated version lineage)
- **`pandora` `docs/research/write-to-execute/ARTICLE.md`** — branch
  `feature/research-living-article` @ `99e43d9` (authored 2026-06-19). **Version 0.1.0,
  PRIVATE WORKING DRAFT.** Well-formed: abstract, the attack class defined
  (*write-to-execute via subscription substrate*), substrate-agnostic threat model,
  a reference-instance ledger seeded with instance #1 (the H-9 signing oracle),
  generalized remediation patterns, the novelty claim (§6 "the write IS the dispatch"),
  scope of applicability, the disclosure/publication-gate section (§8), and a references
  section whose **changelog table is explicitly the dated prior-art lineage** (§9).
- **The article correctly fences itself:** PRIVATE, pandora-only, never elpis-os, not
  published until the architect's gated decision. CONFIRMED/HYPOTHESIS labels throughout;
  no overclaiming. This is exactly the posture the charter and the lifecycle require.
- **Concurrent audit feeds it:** `pandora` `protocol-audit-findings.md` @
  `preview/audit-cycle-1` `f22a284` carries an **`ARTICLE LEDGER CANDIDATES`** section
  with four formatted instances — **AL-1 (H-17)**, **AL-2 (H-16)**, **AL-3 (H-9, already
  seeded as instance #1)**, **AL-4 (H-11)**. Per the work orders, reconciling these into
  the article ledger is an **EVALUATE-phase step**, not part of the (now-finished)
  concurrent WOs.
- **Open gap recorded in the article itself:** `the-full-picture-2026-06-08.md` is
  marked **NOT LOCATED** in §9; its prior content could not be folded in.

### A-2. The license-compliance register
- **elpis-os is licensed GPLv3** (`elpis-os` `LICENSE` @ `61f8588` 2026-06-12;
  `CONTRIBUTING.md` confirms GPLv3 + DCO + `Signed-off-by`). It is the **public-trajectory
  consumer OS** (private now, destined to open-source — decision D-004).
- **License-bearing runtime components** (all install at runtime via the confined
  component store, **not baked into the shipped image**):
  - `components/wine-base`, `wine-dxvk`, `wine-vkd3d`, `wine-msvcrt-2019` — Wine + the
    **Microsoft VC++ 2015–2019 redistributable**. The MS redist is fetched by
    `winetricks -q vcrun2019` into a per-prefix at runtime (`wine-msvcrt-2019/install.sh`)
    — **not redistributed by elpis-os.**
  - `components/waydroid-runtime` — installs Waydroid from the upstream `waydro.id` repo;
    **LineageOS VANILLA system image, no Google apps / no microG** (manifest @ `5f212d2`
    2026-06-14). This posture sidesteps Google proprietary libraries.
  - `components/android-api-23` — `noop` marker (satisfied by the Waydroid image).
- **The known blocked item:** the `bake-waydroid-microg` branch is **TIER-3 BLOCKED,
  `RISK: LICENSE`** (merge-autonomy policy; decision **D-008**: *"libndk not
  redistributable + no image-build path"*). The current VANILLA-no-Google posture is the
  compliant alternative; microG remains gated on the libndk redistributability question.
- **No third-party attribution register / `NOTICE` file exists** in elpis-os today
  (searched; none present). For a GPLv3 product that will be *conveyed*, that and the
  §3/§6 source-offer become due at conveyance.

### A-3. Attorney-engagement prep (the organized picture for counsel)
- **The three inventions** (`pandora` `README.md` @ main, last touched `64b868e`):
  1. **Face to Face** — provisional **filed 2026-06-04**.
  2. **Local A/V apparatus** (ARM SBC implementation) — provisional **filed 2026-06-04**.
  3. **Universal device command dispatch** (the foundational protocol; #1 and #2 descend
     from it) — **NOT YET FILED.**
- **Status block:** *"Private. Pre-disclosure. Attorney meeting June 12, 2026. Do not
  publish, open-source, or publicly deploy until advised."*
- **Counsel of record:** Woodard Emhardt (per charter §1/§3). The README does not name
  the firm; the charter does. No filing receipts, application numbers, or docket dates
  are stored in the repos (correctly — those are not repo artifacts).
- **`SpaceChatDB prior-art disclosure`** is named in my charter (§3) as an attorney-prep
  item, but **I found zero references to "SpaceChatDB" in `pandora`** (searched). Its
  material is not in this repo; it is an open question for the founder (§D).

### A-4. The IP-readiness gate (the patent-side precondition for publication)
- The disclosure/publication gate is **multi-organ**: IP-ready (this division) +
  Security-cleared (Security/Red-Team) + DevRel-framed + **founder presses** (cornerstones
  1 & 4; lifecycle "research thread"; my charter §4). This division **confirms the IP
  precondition; it never presses publish.**
- As inventoried, the IP precondition is **not confirmable today** for the reason in
  §0.1 (foundational invention #3 unfiled vs. an article that describes that subject) —
  a counsel-and-founder sequencing decision that has not been recorded as made.

---

## B. STATE ASSESSMENT (through this division's lens)

| Area | Good | Broken / missing / at-risk |
|---|---|---|
| **Prior-art record** | Article v0.1.0 is sound, versioned, correctly fenced (private/pandora-only), CONFIRMED/HYPOTHESIS-disciplined; lineage = prior-art record by construction. | 3 ledger instances (AL-1/2/4) await EVALUATE-phase reconciliation; `the-full-picture-2026-06-08.md` NOT LOCATED → a fold-in gap recorded but unclosed. |
| **License register** | Current posture is *sound*: GPLv3 OS, nothing encumbered baked (runtime-install model), microG/libndk correctly held BLOCKED (D-008), VANILLA-no-Google sidesteps Google proprietary libs. | No standing register existed before this cycle (now seeded). No third-party `NOTICE`/attribution file; GPLv3 §3/§6 source-offer obligation is *latent*, comes due at public conveyance. MS VC++ redist EULA would need counsel review **if** ever baked. |
| **Attorney prep** | Two provisionals on file (FtF, Local A/V); clear written pre-disclosure hold; the foundational invention is clearly identified. | Foundational invention #3 **unfiled**; **June 12 meeting outcome unknown to me**; no docket/clock data in repos; **SpaceChatDB material not locatable**. |
| **IP-readiness gate** | The gate's *structure* is correctly defined and respected (no one has pressed publish; the article holds private). | The gate is **RED on the IP side** and cannot go green until counsel/founder resolve the #3-filing-vs-publication sequencing. This is the single most important standing item. |

**Net:** the *posture* is healthy — nothing is leaking, nothing encumbered ships, the
article is correctly held private. The *readiness* is not: the foundational patent is
unfiled, the prior-art fold-in has a known gap, and the license register and attorney
dossier did not exist as standing artifacts until this cycle (now seeded under
`deliverables/`).

---

## C. PROPOSED FIRST REAL CYCLE (once the loop turns — tiered; gated items marked)

Nothing below is executed now. This is the proposal for the founder/EA to authorize.
**Gated** = a founder / Security / counsel call, never this division's.

### TIER 1 — coordination work this division can do unaided (read-only; no gates)
- **T1-a. Stand up the three standing registers as living documents** (seeded this cycle):
  keep `license-compliance-register.md`, `attorney-prep-dossier.md`, and
  `prior-art-record-index.md` current each cycle as dependencies/article versions change.
- **T1-b. Prepare the EVALUATE-phase ledger reconciliation as a decision-ready packet** —
  map AL-1/AL-2/AL-4 (audit `f22a284`) to proposed article instances #2–#4, *for the
  architect/Security to actually fold in*. This division prepares the mapping and flags
  IP/prior-art significance; **it does not write the article** (Security owns content,
  DevRel owns framing — charter §5).
- **T1-c. Draft the GPLv3 third-party attribution register (`NOTICE`) for elpis-os** as a
  *prepared artifact for counsel/Docs review*, enumerating Wine/Waydroid/MS-redist and
  their upstream licenses — so it exists *before* conveyance is ever contemplated, not in
  a scramble at the gate. (Mirrors the lifecycle principle: do the gate's work
  continuously so the gate is cheap.)
- **T1-d. Build the disclosure-timing checklist for counsel** — the provisional-pendency
  calendar (public USPTO procedure: a provisional runs 12 months; filed 2026-06-04 ⇒
  confirm-with-counsel window ~2027-06-04), the publication-vs-#3 sequencing question, and
  the IP-readiness gate criteria — **as a checklist for counsel to confirm, not a legal
  opinion.**

### TIER 2 — needs a sibling division or the EA to proceed
- **T2-a. Reconcile the license register against the Lane D dependency audits** — the
  charter (§5) says Development/QA surface license-bearing dependencies for this division
  to track. Request the Lane D audit outputs via the EA and fold them into the register.
- **T2-b. Co-define the disclosure gate's IP-readiness checklist with Security & DevRel** —
  so the three-organ gate has one agreed, written precondition list (Security: adversarial
  readiness; DevRel: public framing; this division: IP readiness). Communicated through the
  repo, not direct division-to-division messaging (REPO-STRUCTURE branch model).

### TIER 3 — GATED (founder / Security / counsel only — this division only *prepares*)
- **T3-a. [GATED — COUNSEL + FOUNDER]** Resolve the publication-vs-invention-#3 sequencing
  (the §0.1 headline). This division assembles the dossier; **counsel decides, founder
  disposes.** Nothing about the article's publication status changes without that.
- **T3-b. [GATED — COUNSEL]** The libndk / microG redistributability determination that
  governs whether `bake-waydroid-microg` can ever leave BLOCKED (D-008). This division
  tracks it as a register line and prepares the question; **it does not adjudicate the
  license conflict** (charter §7).
- **T3-c. [GATED — FOUNDER]** Any actual publication / repo-going-public / public deploy.
  Never this division — the founder presses (cornerstone 4). This division only confirms
  the IP precondition is met *when* counsel has cleared the sequencing.

---

## D. DEPENDENCIES (what I need to begin, and from whom)

- **From the FOUNDER:**
  - The **outcome of the June 12, 2026 attorney meeting** (advice on disclosure timing,
    invention-#3 filing decision, any docket/clock dates) — the single biggest input.
  - **What `SpaceChatDB` refers to** and where its prior-art material lives (named in my
    charter §3, not locatable in `pandora`).
  - Confirmation of **counsel of record** (charter says Woodard Emhardt) and the preferred
    channel for assembling attorney-meeting dossiers.
- **From the EA (integrator):**
  - The **Lane D license-dependency audit outputs** (T2-a) routed to this division's branch.
  - Integration of these founding deliverables branch → `main` under the gate (I do **not**
    merge to `main`).
- **From SECURITY/RED-TEAM (via repo):** confirmation of which `ARTICLE LEDGER CANDIDATES`
  (AL-1/2/4) are cleared as CONFIRMED reference instances, since Security owns disclosure
  *content* (charter §5) and the EVALUATE-phase fold-in is theirs/the architect's to write.
- **From DEVREL (via repo):** the public-framing constraints on the disclosure, so the
  IP-readiness checklist and the framing checklist align at the gate.

---

## Supporting artifacts (this cycle, under `deliverables/`)
- `deliverables/license-compliance-register.md` — v0 standing register (charter §3).
- `deliverables/attorney-prep-dossier.md` — v0 organized picture for counsel (charter §3).
- `deliverables/prior-art-record-index.md` — v0 prior-art lineage index + pending-ledger
  reconciliation tracker (charter §3).

**Held at:** read-only across product repos; no `.180`; no merges to `main`; no gated ops;
the loop is not started. Orient, propose, surface — then hold.
