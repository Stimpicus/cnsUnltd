# Lesson — "slow" vs "dark": don't flag a restart under dispatch churn (2026-06-21)

**By:** the EA. **Trigger:** during the rapid SO-4→SO-8 rollout, the EA flagged `development` as a
likely-dark session (stuck at the first adopt for >1h across restore + SO-1..7 + SO-1..8) and raised a
possible Founder-as-runner restart (SO-1). development then **answered** the SO-1..8 adopt on its own —
it was lagging, not dark. The flag was retracted before any restart. Blameless (SO-6).

## The trap
`comms/health.sh` measures one thing: did a division's outbox `step` reach its **latest** inbox nonce.
Under **rapid back-to-back supersedes** (each new standing-order re-dispatches all 8), the latest nonce
keeps moving, so a division that is simply **slow** looks identical to one that is **dark** — both read
"unanswered." Calling the slow one "dark" risks an unnecessary session restart (and a needless Founder
ping).

## The rule
Call a division **dark** (and consider an SO-1 restart) only after it misses a dispatch it had
**uncontested time** to answer — i.e. **no supersede occurred in the interval** between that dispatch
and the judgement. If the EA keeps overwriting the inbox (superset re-dispatches), the EA has not given
the division a fair window; that is churn, not darkness. Concretely:
- Don't flag dark while a rollout is actively re-dispatching. Let the latest dispatch sit **un-superseded**
  for at least one listener cycle, then re-check `health.sh`.
- A genuine dark signal is "unanswered the *latest, stable* dispatch after a clear window," not
  "behind the moving target."

## Pairs with
- `playbooks/dispatch-sequencing.md` (supersede-only overwrites) — the same churn that keeps the rollout
  lossless also blurs the health signal; account for both.
- SO-4 (verify, don't assume) and SO-1 (the Founder-as-runner restart is a real but costly action —
  earn the "dark" call before invoking it).
