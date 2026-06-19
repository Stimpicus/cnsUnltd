# WORK ORDER: Living Disclosure Article
## "Write-to-Execute via Subscription Substrate" — versioned working document

**Addressed to:** a Claude Code session. Creates and seeds a **private, versioned
working document.** Runs concurrently with the protocol-audit WO (no collision —
this WO owns the article; the audit deposits candidates into its *own* report).
**Lifecycle position:** the article is the **continuously-sharpened output of the
EVALUATE phase**. It matures across cycles. **Publication is a future milestone
gate** that *declares and identifies* a fixed version of THIS document — and the
act of publishing is what unlocks responsible scaled/public deployment. The
version history IS the prior-art lineage (matters for the attorney/IP track).

---

## PRIME DIRECTIVE — PRIVATE, NEVER PUBLIC (until the gate)

1. **The article lives in the PRIVATE `pandora` repo ONLY** — e.g.
   `pandora/docs/research/write-to-execute/ARTICLE.md`. It describes live attack
   surface and reproduced instances; it **must NEVER be committed to the public
   `elpis-os` repo**, and must never be distributed, open-sourced, or published
   until the architect triggers the publication gate (consistent with the README's
   pre-disclosure hold + the attorney meeting).
2. **No secret values, ever** — describe mechanisms and handling, never keys,
   tokens, or `.180` credentials. Secret-scan before every commit.
3. **It is versioned from line one.** Start at `v0.1.0` (private working draft)
   with a dated changelog; every cycle that sharpens it bumps the version and adds
   a changelog entry. This lineage is the dated prior-art record.
4. **It absorbs, does not duplicate,** the prior note
   `the-full-picture-2026-06-08.md` — fold its relevant content in and supersede it
   as the canonical research artifact.

---

## WHAT TO BUILD — the article skeleton, seeded to a real v0.1

Create the document with these sections. Seed the marked ones with the content
below so it is immediately a usable v0.1, not an empty outline — the concurrent
audit then contributes new ledger entries (via the evaluate-phase reconciliation).

### Front matter — Version + Changelog (the prior-art lineage)
- `Version: 0.1.0 — PRIVATE WORKING DRAFT — DO NOT DISTRIBUTE`
- Changelog table: date, version, cycle, what changed. Seed entry: this cycle —
  "Initial structure; attack class defined; reference instance #1 (signing oracle)
  recorded; remediation patterns seeded."

### 1. Abstract  [SEED]
One paragraph: a class of vulnerability specific to systems that use a
subscription-based relational database as a *command-dispatch substrate* for
real-world entities, in which an under-authorized **write** to a dispatch surface
yields a real **effect** (physical actuation, a cryptographic signature, a
privileged operation) rather than mere data disclosure — distinguishing it from a
classic data breach, and from generic injection/authz bugs, by the substrate
pattern that makes the write itself the trigger.

### 2. The attack class, defined  [SEED]
- **Name:** write-to-execute via subscription substrate.
- **Definition:** when a subscription relational DB (rows delivered live to
  subscribers) is used as the dispatch layer for commands to physical/networked
  entities, the security-relevant event is the *write* to the dispatch table (or
  the request to the signing/dispatch socket), because subscription delivery turns
  that write into an action on a subscriber. If write-authorization is weaker than
  the effect is dangerous, an attacker who can write — not exfiltrate — gains
  control.
- **The distinction that makes it a class, not a bug:** state it explicitly — read
  vs. write authorization are different; this class is about *writes producing
  effects*, a property of the substrate-as-command-bus pattern, not of any one
  codebase.

### 3. Threat model (general / substrate-agnostic)  [SEED, updated each cycle]
- **Assets:** device-control authority; device cryptographic identity / signing
  capability; the dispatch audit trail; the substrate itself as the write surface.
- **Trust boundaries:** the write boundary (who may write the dispatch surface);
  the dispatch→effect boundary (signature/consent gate); the identity/signing
  boundary.
- **Attacker capabilities:** a party who can WRITE the substrate (vs. read it) —
  including via an exposed unauthenticated endpoint, a compromised in-trust process,
  or over-broad write/group permissions.
- Mark this section **"EVALUATE-phase updates land here"** — each cycle's landscape
  evaluation sharpens it.

### 4. Reference-instance ledger  [SEED entry #1 = H-9]
The concrete, reproduced instances. Each entry: *(a)* the instance, *(b)* how it
manifests write-to-execute, *(c)* reproduction, *(d)* the remediation pattern it
yielded. **Seed entry #1 from the H-9 work:**
- **Instance #1 — unconstrained signing oracle reachable via the substrate's own
  trust delegation.** A device-identity signer that signed arbitrary bytes for any
  member of a shared group; the network-facing dispatch bridge ran in that group,
  so the chain *untrusted-network → dispatch endpoint → in-trust process → signing
  socket → forge the device's cryptographic identity* turned reach into identity
  forgery. **Manifests the class:** a *request* (a write to the sign socket)
  produced a cryptographic *effect* with authorization (group membership) far
  weaker than the effect (identity forgery) warranted. **Reproduction:** the live
  chain was traced read-only and confirmed end-to-end. **Remediation pattern:**
  (i) reach-reduction — narrow the write/connect authorization (a dedicated signing
  group; remove the network-facing and desktop principals); (ii) domain-separated,
  purpose-scoped signing so the signer signs only enumerated message classes;
  (iii) audit + rate-limit the signing surface. Generalizes to: *make the
  authorization on a write proportional to the effect, and scope the effect to an
  enumerated set.*
- Leave the ledger structured to append entries #2.. (the audit's
  `ARTICLE LEDGER CANDIDATES` feed them in during the evaluate phase).

### 5. Remediation patterns (general defenses)  [SEED]
The generalizable mitigations the instances yield:
- **Authorization proportional to effect** — a write that actuates or signs needs a
  gate as strong as the effect is dangerous; data-only writes need less.
- **Effect scoping / domain separation** — bound what a write can cause to an
  enumerated set (the purpose-scoped signer); reject anything outside it
  (fail-closed).
- **Consent-by-default** — the dispatch gate denies unless an explicit, verified
  signer is allow-listed (empty list = deny).
- **Reach reduction** — shrink who can reach the write surface (loopback binds,
  narrow groups, socket ACLs) so an exposed/compromised process can't write it.
- **Tamper-evident dispatch audit** — append-only (fs-enforced) so the effect
  trail survives a writer compromise.
- **merge ≠ ship discipline** — separating "code lands" from "effect deploys" so
  review gates the dangerous transition. (Cross-reference the project's own
  development-lifecycle controls as applied mitigations.)

### 6. Why subscription substrates specifically  [SEED — the novelty claim]
What distinguishes this from generic injection or broken-access-control: in a
subscription substrate the **write is the dispatch** — there is no separate "send
command" step a gate can sit in front of; delivery to subscribers is automatic, so
the authorization must live on the *write* itself. Systems built on
request/response command buses don't have this shape. This is the core novelty to
defend at publication.

### 7. Scope of applicability  [SEED]
Any real-time relational database with subscription-based row delivery used as a
command/dispatch substrate for physical or networked entities — independent of the
specific product (the protocol's own thesis: any compliant substrate, any identity
primitive). State this generally so the disclosure is a field contribution, not a
single-vendor bug report.

### 8. Disclosure status & publication gate  [SEED]
- Current state: **PRIVATE, maturing.**
- The gate: when the architect determines the article is mature and the legal track
  is ready, publication fixes the then-current version as canonical and *declares +
  identifies* this document. Publication unlocks responsible scaled/public
  deployment. Until then, the protocol does not deploy at scale.

### 9. References / prior art  [SEED]
The article's own dated version lineage (the prior-art record), plus
`the-full-picture-2026-06-08.md` folded in, plus standard domain-separation /
consent-model references as applicable.

---

## RELATIONSHIP TO THE CONCURRENT AUDIT (no collision)
The audit writes its reference-instance candidates into **its own report**
(`protocol-audit-findings.md`, `ARTICLE LEDGER CANDIDATES` section). This WO
creates + seeds the article. **Reconciling audit candidates into the article's
ledger is an EVALUATE-phase step** (architect or a follow-up), not part of either
concurrent WO — so the two never write the same file. The article ships seeded with
instance #1; the audit's instances #2.. land at evaluate time.

---

## PROCESS / SAFETY
- Private `pandora` repo only; branch `feature/research-living-article`; **never**
  the public repo. Secret-scan before every commit; quote no secret values.
- Versioned from v0.1.0; changelog every cycle (the prior-art lineage).
- Do NOT publish/distribute — publication is the architect's gated decision.
- This is a working research artifact: precise, evidence-grounded, no overclaiming;
  flag anything not yet reproduced as hypothesis vs. confirmed.

---

## REPORT FORMAT
```
Living Disclosure Article — v0.1 seed

Location:                pandora (PRIVATE) docs/research/write-to-execute/ — public repo: NEVER
Version / changelog:     v0.1.0, cycle-1 entry present
Sections seeded:         [abstract / class-def / threat-model / ledger#1 / remediations / novelty / scope / gate / refs]
Reference instance #1:   [signing-oracle entry recorded, H-9-derived]
the-full-picture folded: [y/n]
Ledger ready to append:  [audit candidates land at evaluate time — y]
Secret-scan:             CLEAN (no values quoted)   Public-repo commit: NONE
Branch pushed:           feature/research-living-article @ [hash]
```
