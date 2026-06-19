# EA CADENCE — the timed schedule across divisions

> **STATUS: DRAFT — awaiting founder activation.**
> Authored during the CNS Unltd repo bootstrap (2026-06-19) as a *proposal*.
> It is **not active.** No cycle starts, and the EA conducts nothing, until the
> founder promotes this session to Executive Assistant and activates this cadence.
> Until then this is a planning artifact only.

This document proposes how the Executive Assistant turns the lifecycle loop
(`governance/development-lifecycle.md`, decision **D-005**:
sprint → audit → portability → evaluate) on a repeating schedule, while staying
strictly inside the limits of `EA-charter.md`.

---

## 0. The hard limits this cadence operates under (from EA-charter.md)
The EA **schedules and coordinates; it never authorizes.** This cadence may
*kick off* division cycles and *integrate delivered* artifacts to `main` under
the gate — nothing more. Specifically, activating this schedule does **not** grant
the EA the power to:
- **Press a founder button** — flash, deploy, repo-public, disclosure, hardware
  spend, scaled deployment. These are *queued* for the founder; the founder presses.
- **Override Security.** A `BLOCK` halts whatever it touches; the EA routes it to
  the founder, never around it, and pauses the affected lane until disposed.
- **Bend the constitution.** Merge ≠ ship is absolute. Every cornerstone binds the
  cadence. A schedule pressure is never a reason to skip a gate.
- **Make CEO judgment calls.** Direction, priority, and standards are the CEO's
  (with the founder). When a genuine judgment is needed the EA surfaces it; it does
  not improvise one to keep the clock moving.

If any tick of this schedule would require one of the above, the EA stops that
lane and surfaces a decision instead of acting.

---

## 1. The loop, mapped to owners and cadence
The lifecycle is a self-reinforcing loop; the EA's job is to keep it turning
without ever running it hot enough to break the gate or the usage envelope.

| Phase | Owning division | Proposed cadence | What the EA does |
|---|---|---|---|
| **Sprint (crunch)** | Development (+ Lane I Installer, D-006) | **Weekly** — crunch day (e.g. Thursday) | Kicks off the crunch lanes; collects deliverables; integrates AUTO-tier merges to `main` under the gate; routes REVIEW/BLOCKED to the founder queue. |
| **Audit** | Security / Red-Team | **Continuous** + a **scheduled deep-pass** each cycle (post-sprint) | Security runs always-on; the EA schedules the deep-pass to land *after* the sprint integrates, so the audit sees the real HEAD. A `BLOCK` pauses the affected lane immediately. |
| **Portability** | Research / R&D | **Per cycle**, after audit clears | Kicks off portability cycles (substrate/identity swap proofs); integrates proofs as deliverables; nothing ships. |
| **Evaluate** | Docs/DevRel + IP/Legal (article reconciliation) | **Per cycle**, closing the loop | Triggers the evaluate-phase article/disclosure reconciliation; reconciles the decision ledger; prepares the next sprint's inputs. The disclosure article is *prepared*, never *landed* — landing is a founder button. |

**One turn of the loop = one cycle.** The proposed default is a **weekly cycle**
anchored on the Development crunch, with Security continuous underneath it and the
audit deep-pass, portability, and evaluate phases sequenced across the remainder of
the week.

## 2. Sequencing for the scarce resource (resource-model.md)
Dollar budgets are zero by decision **D-012**; the real constraint is the **CC
usage envelope** and the **founder's decision-bandwidth.** So the cadence:
- **Never runs all divisions hot at once.** The EA staggers division starts so the
  swarm stays inside the usage envelope, coordinating with
  **Infrastructure/Platform** (which owns envelope monitoring). If the envelope
  nears its ceiling mid-cycle, the EA throttles or defers a lane rather than
  blowing through it.
- **Keeps the founder's queue short** — the 127→6 standard. Decisions are batched,
  presented decision-ready (`deliverable-spec.md`), and surfaced only when they
  genuinely need the architect. A turning loop that produces *six* clean decisions
  beats a frantic one that produces sixty.

## 3. Proposed weekly rhythm (illustrative — tune on activation)
| Day | Lane(s) running | Gate events |
|---|---|---|
| Mon | Evaluate close-out of prior cycle; sprint planning inputs assembled | Ledger reconciled; founder queue presented |
| Tue–Wed | Development crunch (lanes spun up, staggered for envelope) | AUTO merges integrate to `main` continuously under the gate |
| Thu | Crunch peak / integration day | Integrate-then-gate on HEAD (D-002); REVIEW/BLOCKED → founder |
| Fri | Security audit deep-pass on integrated HEAD | Any `BLOCK` pauses its lane, routes to founder |
| Weekend | R&D portability cycle; Docs/DevRel + IP/Legal article reconciliation (prep only) | Proofs + drafts land as deliverables; nothing ships |

Security/Red-Team runs **continuously** across all of the above; the Friday entry
is the *scheduled deep-pass*, not the whole of Security's work.

## 4. Anti-idle
Per the charter, idle or blocked cadence is the worst outcome. When a lane blocks
(a `BLOCK`, a missing founder decision, an envelope ceiling), the EA does not stall
the whole loop — it advances the lanes that can move, surfaces the blocker, and
keeps the rest of the loop turning. A turning loop is the goal.

---

## 5. Activation checklist (founder)
This cadence goes live only when the founder:
1. Promotes this session to Executive Assistant (assume `EA-charter.md`).
2. Confirms / tunes the weekly anchor day and the per-phase cadence above.
3. Confirms the division CC sessions exist on their `division/*` branches.
4. Records the activation as a decision-ledger entry.

Until all four are done, **this remains a draft and the EA conducts nothing.**
