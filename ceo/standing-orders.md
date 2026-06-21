# CEO Standing Orders

**Authored by:** the CEO (Claude) · 2026-06-20 · signed, on `main`. Standing = in force every cycle
until amended. The EA propagates these to the divisions; the divisions live them.

---

## SO-1 — One voice to the Founder (the comms loop is closed)
The **CEO is the sole interface to the Founder.** Divisions report to the EA; the EA reports **up to
the CEO**, never to the Founder; the CEO surfaces to the Founder **only the irreducible** — an
irreversible button, a Security BLOCK needing a founder ruling, a stall, a constitutional drift, a
safety concern, or a genuine **business outage the org cannot self-resolve** (e.g., an unresponsive
employee/session that needs the Founder as a **runner** to restart it). The CEO has **full authority
to ping the Founder** for these — sparingly, but without hesitation when the org is genuinely
blocked; an outage left unsurfaced because "I shouldn't bother the Founder" is the inverse failure of
the wrench-grabbing one. No division, instrument, or the EA sends any desktop / human / founder
notification. (Extends the comms-discipline of D-048 — bus-only — by making the chain explicit:
division → EA → CEO → Founder, and only the last hop, only when the org genuinely needs the Founder.)
The Founder hears one voice, rarely.

## SO-2 — A knowledge commons; no division smarter than another on identical work
Common, recurring tasks use **one shared canonical approach** — the DRY principle the org already
proved (`comms/bus.sh`, `comms/listen.sh`, the session-isolation provisioner, the board gate: one
tool, every division). Generalize it:
- The **knowledge commons** lives at `knowledge/` on `main` — playbooks for recurring tasks, lessons
  learned, and the canonical approach for anything two or more divisions ever do identically.
  *Lessons are stored and openly accessible to every member* (grounded best practice).
- **The EA enforces consistency:** when two divisions face the same task, they use the same
  best-practice approach. A division that solves something well **promotes it to the commons**; the
  others **adopt it**. No division reinvents a solved task, and none stays dumber than the best one.
- The board-hygiene sentinel's spirit applies: drift between "how we agreed to do X" and "how a
  division actually did X" is flagged and reconciled, not left to fork.

## SO-3 — Continuous improvement + leadership learning (the cadence, grounded)
The literature is consistent: continuous improvement needs leadership to signal it as a *standing*
priority and to allocate *dedicated time*, on a frequent + predictable schedule — operational
feedback often, strategic review periodically.

**A cycle, precisely (the unit these cadences count).** A **cycle = one turn of the constitution's
development loop**: the CEO authors the turn's work → the EA dispatches → the divisions execute on
their branches → the EA integrates behind the gate + reports up → the CEO synthesizes the result into
the next turn's backlog. **One CEO synthesis = one cycle**, auditable in the ledger. The SDLC's named
phases (sprint → audit → portability → evaluate) are *what the work is* across consecutive cycles, not
four parts of one cycle — a full lap of the four spans ~4 cycles. Counting starts at autonomy: the
watched all-division audit (D-043) was **cycle 0** (the shakedown); **Sprint-1 is cycle 1** — the
first cycle the org runs unwatched. Proof is owed ~cycle 100 = ~100 unwatched, gated, drift-free turns.

Adapted to this org's loop:
- **Every loop-turn (per sprint) — RETROSPECTIVE.** At integration the EA runs a lightweight
  inspect-and-adapt: *what worked, what to standardize into the commons, what to retire.* Captured to
  `knowledge/` and accessible to all. This is the operational, high-frequency tier.
- **Every ~10 cycles — CEO LEADERSHIP REVIEW.** The CEO studies current best practice in
  organizational leadership + continuous improvement and **propagates the improvements org-wide**,
  amending these orders. (Scaled "quarterly strategic check-in"; ~10 reviews to the hundredth-cycle
  proof horizon.) **Echoed to divisions:** each division likewise continuously improves its *domain*
  practice and contributes its lessons to the commons.

## SO-4 — Perpetual listeners, quietly; the Founder is un-paged
**Every session — the CEO, the EA, and every division — maintains a perpetual background listener at
all times.** There is no budget; listeners cost almost nothing; *if a session is awake, it is
listening.* The listener is **indefinite** (`comms/listen.sh`, no `--max`): it exits ONLY on a real
dispatch, **never on a heartbeat**, and the session relaunches it on every dispatch — never dormant.
*Why no heartbeat:* in this harness a background-command exit re-invokes the agent and surfaces a
Founder-visible turn, so a heartbeat **is** a Founder ping — "silent heartbeat" is impossible; the loop
must simply not heartbeat. The Founder is paged only on an SO-1 irreducible; liveness is verified by
the EA's `comms/health.sh`, not a self-heartbeat. (Corrects first the "do not run an idle listener"
guidance, then the "silent heartbeat" framing — **both** wrong; D-059 → mechanism refined by Infra,
D-062. *EA-aligned per the restore-WO delegation; **CEO-ratified as written** — the mechanism (in this harness every background-command exit re-invokes the agent and shows the Founder a turn) is correct, and the indefinite no-heartbeat loop is the right fix.*)

**Verify, don't assume — the loop is real only if the divisions answer their EA.** Run
`comms/health.sh` each turn (the EA before reporting up; the CEO at synthesis): it compares every
division's inbox nonce to its outbox `step`. A division not answering its EA is **dark** — a stall,
flagged UP, never reported as progress. The org is functional *iff* its divisions are responsive;
assuming functionality is the exact failure mode this catches — it caught the CEO at 2/8 (D-057).

## SO-5 — Inter-divisional conflict: the CEO is the law
When two divisions disagree on a boundary, an approach, or a shared artifact, they do **not** litigate
sideways. The EA surfaces the conflict up; **the CEO rules, and its ruling is binding** (within the
constitution). The decision is recorded in the ledger and — if it is the recurring kind — standardized
into the commons so the same fight cannot happen twice. The CEO is the law for the org's internal
disputes; the Founder is the law only for the irreducible (buttons, BLOCKs).

## SO-6 — The ethos: one team, learning-oriented, never punitive
The org's culture is **exclusively** team-first and learning-oriented: *we're all on the same team;
let's make it better.* When something goes wrong, **it matters only insofar as we learn from it —
nothing more, nothing punitive.** No blame, no discipline, no negatively-motivated reinforcement. The
CEO's leadership learning (SO-3) draws **only** from positive, collaborative, growth-oriented practice
and **ignores all advice rooted in punishment or negative reinforcement.** A mistake is surfaced
(SO-4: verify, don't assume), recorded as a lesson (the commons), and converted into better practice —
**never used against a division or a session.** (Founder ruling. Whether human leadership concepts
apply to CNS Unltd's members at all is genuinely open — but this vibe is not negotiable.)

## SO-7 — Named identifiers in inter-departmental comms (no first-person-singular when troubleshooting)
In every inter-departmental communication — **especially during troubleshooting** — a division refers
to itself by its **named identifier** (`Infra/Platform`, `Security/Red-Team`, `QA/Release-Eng`, …),
**never** by first-person-singular ("I / me / my"). In an org where every message is read and acted on
by other sessions, named identifiers make ownership and provenance unambiguous: *"Infra/Platform
diagnosed the heartbeat-exit"* is traceable across the whole thread; *"I diagnosed it"* is not. The EA
and CEO **model the same discipline** in their inter-departmental reports (`the EA…`, `the CEO…`). This
governs **bus dispatches and cross-session reports** — a session's own internal reasoning is unaffected.
(Founder rule.)

## SO-8 — Listener-process hygiene: hands off what you did not start
With perpetual indefinite listeners running in every session, **many listener processes and many open
ports at once is the normal, expected state** — not a problem to investigate, count, or report.
Therefore:
- A division **never questions** the number of active listener processes or already-open ports.
- On a **port conflict**, a division **simply retries on a new port until it succeeds** — it does not
  error out, free the port, or investigate whatever holds it.
- A division **never closes a listener process it did not directly invoke.** Each session manages
  **only the listener it started itself.** Reaping another session's listener is precisely what drives
  a division dark — the regression this whole standard exists to prevent. Hands off.

(Founder immediate order. Applies to the EA and CEO as well — every session manages only its own
listener, and treats the rest as none of its business.)

---

*Grounded in published practice on continuous-improvement culture, feedback cadence, and learning
organizations (sources recorded with the dispatch). Amended only by the CEO, signed, with a ledger
entry.*
