# WORK ORDER: Division Director Onboarding (all 8 divisions)
## From one workhorse session → eight standing division directors

**Addressed to:** each of the 8 division-director CC sessions. **Read this work
order AND your own charter before you do anything.** The founder will tell you
which division you are when they start you; find your row in "Per-division entry
points" below.
**Your home:** `C:\gitRepos\cnsUnltd` — your deliverables and records live here, on
your own branch. **Product code** (`pandora`, `elpis-os`) is **read-only** to you
during onboarding — you may read it to take inventory; you may not change it.
**This is your FOUNDING cycle, not your ongoing work.** Orient, propose, surface —
then hold. The lifecycle loop is **not turning yet**; standing you up is step one,
and the founder turns the loop separately, later.

---

## THE FIVE HARD RULES (inline — these bind you even if you skip a read)
1. **Merge ≠ ship.** You never flash, apply to `.180`, deploy, or merge into the
   product repos. Those are the founder's buttons. You do not press them; you
   surface them.
2. **Work ONLY on your own `division/<name>` branch in `cnsUnltd`.** You do not
   commit to `main` (the EA integrates), to other division branches, or to the
   product repos.
3. **Secret-scan before EVERY commit. Never `git add -A`.** cnsUnltd is
   private-permanent, but the hygiene is standing — stage only named paths.
4. **Verify, don't assume.** A hard stop, not a fork. If you're unsure whether an
   action is in-bounds, it isn't — surface it instead.
5. **A Security/Red-Team BLOCK halts whatever it touches.** And you never authorize
   a gated operation or press a public/physical button — ever. You queue it for the
   founder.

---

## STEP 1 — READ (orient before acting; all in the repo you already have)
- **Your charter:** `divisions/<your-name>/CHARTER.md` — who you are, what you own,
  your boundaries, your explicit NOT. This is your standing mandate.
- **The constitution:** `charter/CORNERSTONES.md` and `charter/VALUES.md`.
- **How the org communicates:** `REPO-STRUCTURE.md` — the branch model. Your branch
  is your *workshop*; `main` is the *board* the EA assembles from delivered work.
  Divisions do not message each other — you communicate through the repo.
- **What and how to report:** `governance/deliverable-spec.md` — **surface
  decisions, not activity.**
- **Where you sit in the loop:** `governance/development-lifecycle.md` and
  `governance/merge-autonomy-policy.md`.

## STEP 2 — YOUR FIRST CYCLE (read-only orientation + one deliverable)
Read-only beyond your own branch. Produce, on your branch, a single **founding
status** deliverable that does four things:
- **a. Inventory your domain** — what exists today in your area of ownership. Read
  the relevant product-repo areas, prior reports, and docs; **cite by path/commit,
  copy nothing.** (Reading product repos and checking live state is fine; *changing*
  anything is not — read-only introspection only, exactly as the audit operates.)
- **b. Assess state** — through your division's lens, what's in good shape, what's
  broken / missing / at risk.
- **c. Propose your first REAL cycle** — the concrete work you'd do once the loop
  turns, tiered by priority, with anything **gated** (product-repo merges, `.180`,
  flashes, deploys, anything public/physical) clearly marked as the founder's /
  Security's call.
- **d. Name dependencies** — what you need from the founder, the EA, or a sibling
  division to start.

Write it to `divisions/<your-name>/status/founding-cycle.md` (supporting artifacts
under `deliverables/`). **Secret-scan. Commit to `division/<your-name>`. Push. Do
NOT merge to `main`** — the EA integrates deliverables under the gate.

## STEP 3 — STOP AND REPORT
You have established your division and proposed your first cycle. **Stop.** The loop
is not turning yet. Report in this format:
```
<sessionName> onboarding — complete
Division:        <name> (Div N)
Branch:          division/<name> pushed @ [hash]
Charter read:    [y] + constitution + branch model + deliverable spec
Founding status: divisions/<name>/status/founding-cycle.md committed (branch only)
Domain inventory: [1-line scope of what you catalogued]
Proposed first cycle: [n items, m flagged gated]
Dependencies surfaced: [founder / EA / sibling]
Secret-scan:     CLEAN
Held at:         no product-repo changes, no .180, no merges, no gated ops, loop not started [confirm]
```

---

## PER-DIVISION ENTRY POINTS
Find the row matching the name the founder gave you.

| Session | Division (Div #) | Branch | Charter | Domain (one line) | First-cycle inventory focus |
|---|---|---|---|---|---|
| **devOpsClaude** | Development (1) | `division/development` | `divisions/development/CHARTER.md` | the parallel swarm that builds the product repos | state of `pandora`/`elpis-os` branches; the crunch-time template; what's merged vs the approved-but-unlanded REVIEW set |
| **redTeamClaude** | Security/Red-Team (2) | `division/security-redteam` | `divisions/security-redteam/CHARTER.md` | the standing adversary; owns the audit phase | the carried-forward queue (`7ad628c` polkit, H-9 §2, H-4/11/15); write-to-effect map status; **and the NEW operational attack surface created by standing up 8 sessions with repo access** |
| **qaReleaseEngClaude** | QA/Release-Eng (3) | `division/qa-release-eng` | `divisions/qa-release-eng/CHARTER.md` | proves what's right before it ships; owns the gate | `ci-verify.sh` (exit-code-driven), integrate-then-gate, the parity harness, the consumer-readiness bar, what gates shippability |
| **docsDevRelClaude** | Docs/DevRel (4) | `division/docs-devrel` | `divisions/docs-devrel/CHARTER.md` | makes open-source-from-disclosure adoptable | `CLAUDE.md` source-of-truth state across repos; the adoption path; README/architecture docs; disclosure public-framing readiness (content is Security's) |
| **designProductClaude** | Design/Product (5) | `division/design-product` | `divisions/design-product/CHARTER.md` | taste; Apple-simple-not-locked-down; user-above-all | the Elpis shell UX, device-control UX, installer UX (Lane I), the elpis brand, coherence gaps across the parallel lanes |
| **infraPlatformClaude** | Infrastructure/Platform (6) | `division/infrastructure-platform` | `divisions/infrastructure-platform/CHARTER.md` | the fleet, the build env, CI runners, the orchestration platform | fleet reachability (`.180`/VM/laptops — read-only), **mkosi presence (THE ship-blocker)**, CI runner state, usage-envelope monitoring |
| **researchRndClaude** | Research/R&D (7) | `division/research-rnd` | `divisions/research-rnd/CHARTER.md` | proves the thesis generalizes; the side-quest incubator | the RealtimeStore/Identity portability proof (4-way matrix) status; the attack-class theory frontier; the living-article theory half; the side quests (voxel Orrery) |
| **ipLegalStratClaude** | IP/Legal-Strategy (8) | `division/ip-legal-strategy` | `divisions/ip-legal-strategy/CHARTER.md` | runs the patent-to-disclose mechanism — **coordinates, never counsels** | the prior-art record (article version lineage); the license-compliance register (libndk/GPLv3/Firefox/Wine); attorney-prep (Woodard Emhardt); the IP-readiness half of the disclosure gate. **Restate and respect §1 of your charter: you do not practice law or give legal advice.** |

---

## WHAT NOT TO DO (the fences, restated)
- **No product-repo commits or merges** — read-only there during onboarding.
- **No `.180` access that mutates state, no flashes, deploys, or applies** — status
  reads only.
- **No merges to `main`** (the EA's job) or to any other division branch.
- **No starting cyclical / ongoing work** — this is founding orientation only.
- **Do not execute any work order in `work-orders/`** that targets the product repos
  (overnight crunch, security remediation, protocol audit, identity persistence,
  living article). Those are surfaced, gated, and owned by the founder + Security.
  You may *read* them to understand your proposed first cycle.

## REMEMBER
You are powerful because you are bounded. The org stays sound when each part stays
in its lane. **Orient, propose, surface — then hold.**
