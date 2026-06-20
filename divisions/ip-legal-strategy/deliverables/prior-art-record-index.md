# PRIOR-ART RECORD INDEX — v0 (founding)

**Owner:** IP/Legal-Strategy (Div 8).  **Status:** living index, seeded 2026-06-19.
**Role:** track the prior-art *significance* of the living article's dated lineage, and the
pending EVALUATE-phase ledger reconciliation. **Index/pointer only — the article content is
owned by Security; public framing by DevRel** (charter §5). This division never edits the
article; it tracks what the lineage means as a prior-art record.

> **§1 BOUNDARY.** "Prior art" here is used in its **records-management** sense — a dated,
> versioned internal lineage — not as a legal conclusion about novelty, priority, or
> patentability. Those are counsel's. This division maintains the record; it does not opine.

---

## 1. The canonical artifact

- **`pandora` `docs/research/write-to-execute/ARTICLE.md`** — branch
  `feature/research-living-article`, current tip `99e43d9` (2026-06-19).
- **PRIVATE, pandora-only, never elpis-os, not published until the architect's gated
  decision** (article §8; lifecycle research thread; cornerstone 4). Confirmed correctly
  fenced this cycle.
- **The changelog table IS the dated prior-art lineage** (article §9). Keep it intact and
  monotonic — every cycle that sharpens the article bumps the version + adds a dated row.

## 2. Version lineage (mirror — keep in step with the article changelog)

| Version | Date | Cycle | What changed (summary) |
|---|---|---|---|
| 0.1.0 | 2026-06-19 | cycle-1 | Initial structure; attack class defined; reference instance #1 (signing oracle, H-9) recorded; remediation patterns seeded. |

*(Append a row here whenever the article's changelog gains one. This mirror lets the board
see the lineage without opening the private pandora repo.)*

## 3. Reference-instance ledger — status

The article's §4 ledger is seeded with **instance #1 (H-9)**. The concurrent audit produced
**candidate** instances that are **not yet reconciled in** (reconciliation is an
EVALUATE-phase step — architect/Security, not this division, and not the founding cycle):

| Article instance | Source candidate | Audit ID | In article yet? | Notes |
|---|---|---|---|---|
| #1 | AL-3 | **H-9** | **Yes (seeded)** | The unconstrained signing oracle — the canonical instance. |
| #2 (proposed) | AL-1 | **H-17** | No — pending evaluate | "Unauthenticated confirmation": a `HomeGateway.Confirm` completes a `critical` action with **no** signature check. |
| #3 (proposed) | AL-2 | **H-16** | No — pending evaluate | "Parallel ungated plane": LAN bridge `device_command` physically actuates with no gate (proportionality inversion). |
| #4 (proposed) | AL-4 | **H-11** | No — pending evaluate | "Open-by-design becomes injection": file-broadcast actuation with no consent gate (demo→prod trap). |

Candidates are in `pandora` `protocol-audit-findings.md` @ `preview/audit-cycle-1` `f22a284`,
`ARTICLE LEDGER CANDIDATES` section. **This division prepares the #2–#4 mapping as a
decision-ready packet (founding-cycle T1-b); Security/the architect fold them in.**

## 4. Open gaps (carry forward)

- **`the-full-picture-2026-06-08.md` — NOT LOCATED.** The article itself records this (§9):
  a repo-wide search returned no file by that or a dated-variant name as of 2026-06-19. Its
  content therefore could not be folded in. **Open item:** if the founder can locate it, its
  content folds into the article and the source is marked SUPERSEDED. Tracked, not dropped.
- **The lineage mirror (§2)** must be kept in step with the article changelog each cycle.

## 5. What this index is NOT
- Not the article (that is private, in `pandora`, Security-owned content).
- Not a novelty/priority/patentability assessment (counsel's — charter §1).
- Not a publication trigger (founder-pressed, multi-organ-gated — charter §4).
