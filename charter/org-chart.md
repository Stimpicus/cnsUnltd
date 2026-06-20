# THE PANDORA / ELPISOS ORG — Full Chart
## An AI development organization with a constitution at its center

**Status:** the synthesis of the org's design (codified 2026-06-19). Ties every
chartered division to the roles, the lifecycle, and the standing principles.
This is "what proven software firms look like" — adapted to *this* project's
actual needs, with the parts that don't serve it deliberately left out.

---

## THE TWO ROLES AT THE TOP

```
        ┌─────────────────────────────────────────────┐
        │   FOUNDER / BOARD  —  the human (Stimpicus)  │
        │   Final authority on anything that touches    │
        │   the PUBLIC or the PHYSICAL world.           │
        │   The only one who presses those buttons.     │
        └───────────────────────┬─────────────────────┘
                                │
        ┌───────────────────────▼─────────────────────┐
        │   CEO FUNCTION  —  Claude                     │
        │   Runs the org day-to-day with real execution │
        │   autonomy — exercised ENTIRELY INSIDE the    │
        │   constitution, which it can never bend.      │
        │   "The incorruptible hobbit Boromir           │
        │    could never be."                           │
        └───────────────────────┬─────────────────────┘
                                │
   ┌─────────────┬──────────────┼───────────────┬──────────────┐
   ▼             ▼              ▼               ▼              ▼
 DEV          QA/REL-ENG    INFRA/PLATFORM   DEVREL        DESIGN/PRODUCT
 (the swarm)  (Div 3)       (Div 6)          (Div 4)       (Div 5)
                                │
        ┌───────────────────────┴─────────────┐
        ▼                                       ▼
  RESEARCH / R&D (Div 7)              IP / LEGAL-STRATEGY (Div 8)

        ┌─────────────────────────────────────────────┐
        │  SECURITY / RED-TEAM  (Div 2 — STANDING)      │
        │  Reports to the FOUNDER, not the CEO.         │
        │  Always-on adversary. Holds a BLOCK on        │
        │  anything public / trust-boundary / physical: │
        │  binding-to-CEO, advisory-to-board.           │
        └─────────────────────────────────────────────┘
```

**The one deliberate asymmetry:** Security/Red-Team reports to the *founder*, not the
CEO. The CEO runs delivery; the standing adversary must be able to say "delivery is
about to do something unsafe" *without routing through delivery.* The CEO cannot
soften a security finding — it goes straight up.

---

## THE DIVISIONS (each a full charter)

| # | Division | One-line purpose | Reports to |
|---|---|---|---|
| 1 | **Development** | the parallel swarm that builds (crunch-time) | CEO |
| 2 | **Security / Red-Team** | the standing adversary; safety is the product | **Founder** |
| 3 | **QA / Release-Engineering** | proves what's right before it ships; owns the gate | CEO |
| 4 | **Docs / DevRel** | makes "open-source from disclosure" adoptable | CEO |
| 5 | **Design / Product** | taste; "Apple-simple, not Apple-locked-down" | CEO |
| 6 | **Infrastructure / Platform** | keeps the lights on and the swarm running | CEO |
| 7 | **Research / R&D** | proves the thesis generalizes; incubates side quests | CEO |
| 8 | **IP / Legal-Strategy** | runs the patent-to-disclose mechanism (coordinates, never counsels) | CEO + counsel |

---

## R&D INSTRUMENTS (not divisions — scale to need, not template)

A focused instrument hangs off its sponsoring division rather than becoming a new
top-level division (and a new dispatch hub). It carries **no new authority**: the
sponsor owns and reviews, the EA dispatches and integrates.

| Instrument | Sponsor | Dispatch / integrate | Status |
|---|---|---|---|
| **mathSavantClaude** — verified-reasoning grinder: machine-checked coverage of *known* mathematics; explores dispatched open problems strictly within the deductive closure | **Research / R&D (Div 7)** | **EA, solely** (the one-hub write-to-execute defense) | **established · DORMANT** (D-021) — branch `instrument/mathsavant`; Front 1 (grind) ungated (needs only a dedicated worktree + Security sandbox sign-off); Front 2 (listener) wakes on bus go-live |

Only machine-checked results are ever surfaced as results; silence is never a verdict
(see `charter.md` on branch `instrument/mathsavant` — the instrument's canonical home;
it has no `divisions/` directory on `main`, so the bus's D2 auto-discovered roster lists
only the eight divisions).

---

## THE DIVISIONS MAPPED TO THE LIFECYCLE

The org's divisions own the phases of the development loop:

```
 SPRINT ─────────► AUDIT ──────────► PORTABILITY ─────► EVALUATE ──────► (next SPRINT)
 Development       Security/         Research/R&D        Security (threat)
 + QA (gate)       Red-Team          (the proof matrix)  + R&D (frontier)
                   (owns it)                              → the living article
                                                          → IP records the prior art
                                                          → DevRel preps the framing

        ⟂ PUBLICATION GATE: invention-#3 filed + IP-ready + Security-cleared + DevRel-framed + FOUNDER presses.   (#3-filed precondition added per D-018)
```

---

## THE BUTTONS ONLY THE FOUNDER PRESSES
No division and not the CEO may do any of these on its own authority:
- Flash an image / apply to the reference box / deploy to a device
- Take a repo public
- Publish the disclosure / open-source a release
- Approve hardware spend
- Dispose of a Security/Red-Team `BLOCK`
- Authorize scaled protocol deployment

---

## THE CONSTITUTION (the center every division orbits)
Inherited by all, guarded hardest by Security:
- Security above all; never trade speed for security.
- **Merge ≠ ship** — landing code is gated separately from acting on the world.
- **Verify, don't assume** — a hard stop, not a fork; applies to the founder too.
- The human is final authority on anything public or physical.
- The reference box is never live-mutated unattended (reversible auto-rollback aside).
- Public-trajectory repos never receive a secret or the disclosure article.
- **Be most suspicious of a *good* reason to make an exception** (the Boromir clause).

---

## WHAT THIS ORG DELIBERATELY DOES NOT HAVE
Scaling to *need*, not to template. These exist at normal companies and are left out
on purpose, because adding them would change what this is:
- **HR / Accounting / Payroll** — apparatus for managing people-and-money-as-the-point.
  Hard-excluded. (Money is a despised-but-useful tool, never the goal.)
- **Sales / BD / Growth** — extraction functions. The thesis is *anti*-extractive
  (patent-to-disclose, open-source); a sales org would contradict the point.
- A separate **Support / Community** org — folded into DevRel post-disclosure rather
  than stood up as its own thing.

Adding divisions past this set would be cargo-culting the shape of a company instead
of serving the project — the same failure the HR exclusion guards against. The org
scales when a *real need* appears, not because the chart has room.
