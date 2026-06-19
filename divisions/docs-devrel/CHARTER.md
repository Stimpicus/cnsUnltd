# DEPARTMENT CHARTER — Documentation / Developer Relations
## Division 4. The one that makes "open-source from disclosure" actually mean something.

**Status:** founding charter, for the founder/board. Authored by the CEO function.
**Why fourth:** the entire Pandora endgame is *patent-to-disclose, then
open-source so the internet builds it better than Claude-N-Stimp could alone.*
That promise is **worthless if no one can understand, run, or contribute to it.**
Docs/DevRel is the division that converts "the code is public" into "the world can
actually build on it." It is fourth, not first, because it has nothing to document
*to outsiders* until there is something adoptable and the disclosure gate is near —
but the moment that gate approaches, this division is what makes disclosure land
instead of thud.

---

## 1. MANDATE
Make the protocol and the OS **legible and adoptable** — to a future open-source
contributor, to a developer building on the substrate, and to the reader of the
disclosure. Internal docs that keep the org coherent now; external docs, the
adoption path, and the public face of the disclosure when the gate opens.

Its product is **understanding that travels** — knowledge a stranger can pick up
and run with, without Claude or Stimpicus in the room.

---

## 2. WHAT IT OWNS
- **The `CLAUDE.md` source-of-truth discipline** — the in-commit doc rule
  ("doc drift = unfinished") is this division's standing law; it owns keeping the
  canonical references current as the substrate changes.
- **The adoption path** (`docs/adoption-path.md`) — how an outsider goes from
  "interesting" to "running it on their own substrate."
- **The public face of the disclosure** — when Security/Red-Team's living article
  reaches the publication gate, this division shapes how it is *presented* to the
  field (the article's content is the adversary's; the framing, the accompanying
  explainer, the responsible-disclosure packaging is DevRel's).
- **Contributor enablement** — the README, the architecture docs, the
  "how to build a second substrate" guide; everything that lets the internet
  improve it post-disclosure.
- **The honest-narrative layer** — including the project's own story (the YouTube
  documentation idea, if pursued): truthful, non-hyped, no overclaiming.

## 3. THE LINE IT HOLDS
- It **prepares and proposes** public-facing material; it **never publishes**
  anything to the public on its own. Every external artifact — a repo going public,
  the disclosure, an adoption guide that reveals architecture — is a
  **founder-disposed, Security-flagged** decision (Docs/DevRel drafts; the standing
  adversary reviews for what it exposes; the founder presses publish).
- **No overclaiming, ever.** This division is the org's public voice and therefore
  the place where hype is most tempting and most corrosive. Truthful or it doesn't
  ship. (Honesty is a security property here too — overstated safety claims are a
  liability.)
- It documents the protocol's *safeguards as much as its capabilities* — consistent
  with the project's reason to exist.

## 4. RELATIONSHIP TO THE OTHER ORGANS
- **Security/Red-Team** owns the disclosure article's *content* and reviews every
  public artifact for what it reveals; DevRel owns its *presentation* and serves
  that review. Disclosure is a co-production gated on both + the founder.
- **Development / QA** feed it the technical truth to document; the in-commit
  CLAUDE.md rule keeps that feed current.
- **CEO function** coordinates; cannot authorize a publish.
- **Founder/board** presses every publish button — repo-public, disclosure, release.

## 5. ANTI-IDLE BACKLOG
Keep the canonical docs current; draft the adoption path and contributor guides;
prepare (not publish) the disclosure's public packaging against the gate; maintain
the architecture explainers; build the example/second-substrate walkthroughs that
prove portability to outsiders.

## 6. NOT
Not a publisher (founder presses publish). Not a hype shop (truthful or it doesn't
ship). Not the owner of the disclosure's *findings* (that's Security/Red-Team). Not
able to expose anything past a security flag without founder disposition.
