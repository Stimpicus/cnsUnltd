# DELIVERABLE SPEC — what divisions report so the CEO can decide

A division's deliverables are whatever the CEO of an org like this would need to
make decisions. Each division surfaces, into its `divisions/<name>/` directory on
`main` (via the EA integrator), the following — kept current each cycle.

## Every division, every cycle
1. **STATUS** (`status/latest.md`) — what shipped this cycle, what's in flight, what
   landed on `main`, what's blocked and on what. The board view.
2. **DECISIONS-NEEDED** — anything requiring the architect/founder, decision-ready:
   the question, the options, the recommendation, the trade-offs, what each choice
   forecloses. (This is what feeds the decision ledger and the founder's queue.)
3. **RISKS / FLAGS** — anything trust-boundary, public-facing, physical, or
   cost-bearing. Security flags are mandatory and route per its charter.
4. **DELIVERABLES** (`deliverables/`) — the actual artifacts: reports, proofs,
   findings, designs, drafts. *Product code stays in the product repos and is
   referenced by commit, not copied here.*
5. **NEXT** — what the division will do next cycle, and what it needs from other
   divisions to do it.

## The principle
A deliverable exists to let a decision happen. If it doesn't inform a choice the
CEO or founder has to make, it's noise — keep it in the division's working branch,
not the board. **Surface decisions, not activity.**

## Format discipline
- Decision-ready means: a tired founder at the end of a long day can read it and
  choose. Lead with the recommendation; make the trade-off explicit; never bury the
  ask. (See the merge-digest as the canonical example: scorecard first, decisions
  isolated, everything else available but not in the way.)
- No overclaiming. Green is earned, never reported. Blocked is stated plainly.
- No live-box identifiers on the board: deliverables reference live boxes by nickname
  only (`.180`, `.196`, "dev VM"); full LAN IPs, MAC addresses, key-file references,
  and secrets never appear. Enforced by `governance/board-hygiene/board-hygiene-scan.sh`
  at integration (a BLOCK finding stops integration, like a secret-scan hit).
