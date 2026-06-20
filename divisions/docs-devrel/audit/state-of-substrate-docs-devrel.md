## Div4 — Docs/DevRel · doc-versus-reality

*Accuracy, and framing that doesn't write a check the code can't cash. Tags: [VERIFIED];
[DOCUMENTED]; [ASSESSED].*

**The `vrcadia` caveat is stale-in-a-good-way.** [VERIFIED] CLAUDE.md devotes a "Note on history"
paragraph warning that avatar/level/VR-transform references are legacy artifacts. The code has
**0 such references** (whole f2f tree). Recommend demoting the defensive caveat to a single
historical sentence — keeping a warning about artifacts that don't exist invites readers to look
for ghosts and undercuts confidence. **Doc lagging behind a cleaner reality.**

**Currency of the API-discrepancy notes.** [ASSESSED] The "SpacetimeDB 2.x API Notes" block is
detailed and load-bearing (table-accessor syntax, enum tag unions, `onApplied`-seeding, the
`SurfaceType.Tv` normalisation). It reads as battle-earned and current; no contradiction found
against the module shape. Keep — this is the project's best doc asset.

**Maincloud deployment checklist.** [DOCUMENTED, not re-run] The checklist (rotate `hmac_secret_v1`,
set `allowed_issuer`, confirm `oidc_client_id` non-empty = the VECTOR-1a guard, `dev_mode=false`,
tighten rate limits) is internally consistent and security-anchored. **Not verifiable from docs
alone** — flag for Infra/QA to dry-run once against a Maincloud target; until then it is a
*procedure*, not a *verified* runbook.

**Public-framing / disclosure-article readiness — the honest read.** [ASSESSED] The framing claim
is "write-to-execute via subscription substrate," demonstrated by f2f + the `substrate/`
command-dispatch reference. **The claim is real and demonstrable.** The overclaim risk is in three
places the article must NOT paper over: (a) subscription privacy is client-query-trust until RLS
#2810 (don't imply server-enforced privacy today); (b) H-17 is open (don't imply the actuation
path is hardened); (c) invention #3 is **not yet filed** — publication is gated on it (IP lens).
**Framing that ships only if it ships these three caveats with it.**

**Open, ranked (Docs):** (1) retire the vrcadia caveat → history note; (2) add the three
disclosure caveats to the article skeleton so they can't be dropped under deadline; (3) dry-run +
date-stamp the Maincloud checklist; (4) confirm SECURITY.md's VECTOR table matches the code's
current ordering (coordinate with Security's line-level re-read).
