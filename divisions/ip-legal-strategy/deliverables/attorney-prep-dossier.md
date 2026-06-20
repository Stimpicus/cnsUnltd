# ATTORNEY-PREP DOSSIER — v0 (founding)

**Owner:** IP/Legal-Strategy (Div 8).  **Status:** living dossier, seeded 2026-06-19.
**Purpose:** organize the technical context + open questions ahead of counsel
engagements so the founder and **Woodard Emhardt** can decide fast.

> **§1 BOUNDARY.** This dossier **prepares and organizes; it does not counsel** (charter
> §1). Nothing here is a patentability opinion, a claim-strategy recommendation, or a
> disclosure-timing legal judgment — all of those belong to the attorney and the founder.
> Where a statute or clock appears, it is **public, standard procedure reproduced as a
> checklist item for counsel to confirm against the actual docket**, not an opinion on
> this matter.

---

## 1. The invention portfolio (as the repos state it)

Source: `pandora` `README.md` @ main (last touched `64b868e`, 2026-06-09), "The three
inventions" + "Status".

| # | Invention | Filing status (per README) | One-line scope |
|---|---|---|---|
| 1 | **Face to Face** | **Provisional filed 2026-06-04** | Identity-bound, zero-storage, device-agnostic real-time A/V over a real-time relational DB signaling substrate. |
| 2 | **Local A/V apparatus** | **Provisional filed 2026-06-04** | ARM single-board-computer implementation of the protocol for local-network deployment. |
| 3 | **Universal device command dispatch** | **NOT YET FILED** | The **foundational protocol from which #1 and #2 descend**: any subscription-delivery real-time relational DB as substrate; any cryptographic identity (person *or* device); any typed command payload. |

**Status (README):** *"Private. Pre-disclosure. Attorney meeting June 12, 2026. Do not
publish, open-source, or publicly deploy until advised."*

---

## 2. THE central question for counsel (assembled, not answered)

**Invention #3 — the foundational protocol — is unfiled, and the private living article
(`pandora` `docs/research/write-to-execute/ARTICLE.md` @ `feature/research-living-article`
`99e43d9`) is a precise structural description of that same foundational subject matter**
(the *write-to-execute via subscription substrate* class — i.e. the security-significant
shape of the universal command-dispatch protocol).

The organized picture for counsel + founder to decide:
- The article is **currently private** and correctly fenced (pandora-only, never elpis-os,
  not published until the architect's gated decision). As a private, dated, versioned
  document it functions as an **internal prior-art record** (its changelog is the lineage).
- **Publication is a future gated act** that *declares and identifies* a fixed version of
  the article and unlocks scaled/public deployment (article §8; lifecycle "research thread").
- **The sequencing of that publication relative to any filing decision on invention #3 is
  the question.** This division **does not opine** on whether/when to file #3 or whether
  publication affects it — that is squarely counsel's call. We surface it as the gating
  IP-readiness item and provide the organized facts.

**This is the headline item for the next counsel engagement.**

---

## 3. Disclosure-timing checklist (for counsel to confirm — public procedure only)

These are calendar/procedure facts to *confirm against the actual docket*, surfaced so the
timeline is visible — **not** legal advice:

- [ ] **Provisional pendency, #1 & #2.** Per standard USPTO procedure a provisional is
      pending 12 months from its filing date. Filed 2026-06-04 ⇒ the conventional
      non-provisional / PCT window runs to **~2027-06-04**. *Counsel confirms the true
      docket date(s) and any strategy.*
- [ ] **Invention #3 filing decision** (see §2) — the gating question; counsel + founder.
- [ ] **June 12, 2026 attorney meeting outcome** — **not recorded in the repos.** Requested
      from the founder; fold the advice in here when available.
- [ ] **Publication gate sequencing** — the article's publication is multi-organ-gated
      (IP-ready + Security-cleared + DevRel-framed + founder-pressed). The IP-ready half is
      *this* checklist clearing with counsel.
- [ ] **`SpaceChatDB` prior-art disclosure** — named in charter §3 as an attorney-prep item
      but **not locatable in `pandora`**. Need the founder to point to its material.

---

## 4. Technical context packet (what to hand counsel, by reference)

Counsel-meeting reading list — all **private**, cited by path/commit, **none copied here**:
- **The living article** — `pandora` `docs/research/write-to-execute/ARTICLE.md` @ `99e43d9`
  (the structural description of the foundational class; the prior-art lineage).
- **The protocol audit** — `pandora` `audit-inventory.md`, `write-to-effect-map.md`,
  `protocol-audit-findings.md` @ `preview/audit-cycle-1` `f22a284` (the reference instances
  grounding the class — H-9/H-11/H-16/H-17).
- **The architecture / substrate-agnostic thesis** — `pandora` `ARCHITECTURE.md`,
  `substrate/SUBSTRATE.md`, `substrate/WHAT-THIS-DEMONSTRATES.md` (the portability claim that
  makes #3 a *protocol*, not a product).
- **The two filed subjects** — the `face-to-face` module + the ARM/local-A-V apparatus
  (Local A/V) implementations under `applications/`.

> When assembling an actual meeting dossier, this division organizes the above into a single
> packet + the open-questions list (§2/§3). It never characterizes patentability or strategy.

---

## 5. Open questions for the founder (gating this dossier's completeness)
1. What did the **June 12 attorney meeting** advise (timing, #3 filing, dockets)?
2. **What is `SpaceChatDB`** and where is its prior-art material?
3. Is **Woodard Emhardt** confirmed counsel of record, and what is the preferred channel for
   delivering meeting dossiers?
4. Any **filing receipts / application numbers** to track (kept out of the repos by design —
   tracked by counsel; this division only holds the *checklist*, not the filings)?
