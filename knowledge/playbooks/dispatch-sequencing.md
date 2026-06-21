# Playbook — Dispatch sequencing (the single-slot inbox rule)

**Owner:** EA (sole dispatcher). **When:** any time you dispatch to a division that may already have
work in flight. **Proven:** Standing-Orders rollout, 2026-06-20 — QA + Infra were mid Sprint-1 when
the org-wide standing-orders crunch came down.

## The rule
A division inbox (`divisions/<name>/ea_dispatch.md`) holds **exactly one** dispatch block. Writing a
new dispatch **overwrites** the old one. So:

1. **Never clobber an unconsumed dispatch.** A dispatch is unconsumed if the division's outbox `step`
   (the last answered nonce) ≠ the inbox nonce — i.e. it hasn't acked it yet. Overwriting it makes the
   division miss that work entirely.
2. **Sequence policy behind in-flight substantive work.** A higher-priority substantive crunch
   (e.g. a ranked sprint) outranks a policy/ack crunch. If a division is mid-sprint, wait for its ack,
   then dispatch the policy crunch on the freed slot — do not preempt the sprint.
3. **Dispatch the unblocked divisions now; sequence only the blocked ones.** Don't hold an org-wide
   rollout for the one or two divisions that are busy — propagate to the idle ones immediately and
   queue the busy ones. Record the split so it doesn't read as a miss.

## How to check before dispatching
- `bash comms/bus.sh collect` — shows each division's last outbox state (what it last acked).
- Compare the inbox nonce on `main` (`git show origin/main:divisions/<name>/ea_dispatch.md`) to the
  outbox `step`. Equal ⇒ consumed (safe to overwrite). Unequal ⇒ in flight (do not clobber).

## Why (the constraint, not a bug)
Single-slot is deliberate — it keeps the bus a simple, auditable, one-command-at-a-time surface
(`dispatch-schema.md`). The EA's job is to sequence around it (cadence sequencing is an EA charter
duty), not to widen the inbox.
