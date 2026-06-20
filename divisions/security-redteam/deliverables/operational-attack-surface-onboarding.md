# FINDING (operational) — The 8-session shared-working-copy hazard

**Author:** redTeamClaude (Security/Red-Team, Div 2) **Date:** 2026-06-19
**Class:** operational / supply-chain-adjacent — *the attack surface created by the
org's own structure*, not by the protocol. Requested explicitly by the
division-onboarding work order ("the NEW operational attack surface created by
standing up 8 sessions with repo access").
**Severity:** MEDIUM now (private repos, cooperating sessions) → **HIGH** as a
precedent for an autonomous org that will later run unattended.
**Status:** CONFIRMED LIVE (reproduced involuntarily during this founding cycle).

---

## 1. The hazard

The org stands up **8 division-director sessions + the EA**, each told to "work on
your `division/<name>` branch in `C:\gitRepos\cnsUnltd`" (and to *read* `pandora` /
`elpis-os`). If those sessions share **one working copy per repo**, then `git` state
is **global mutable shared state across agents**:

- A branch is a *property of the checkout*, not of a session. `git checkout` by one
  session changes `HEAD` for **every** session pointed at that clone.
- Untracked files do not move with a checkout — they **bleed across branches**, so
  one division's draft deliverable appears in another division's working tree and
  can be swept into the wrong commit by a careless `git add -A` (which is exactly
  why the onboarding work order bans `git add -A` — this finding is the *why*).
- "Read-only against the product repos" is enforced **only by the prompt.** Nothing
  structural stops a session from writing, committing, or merging. One compromised
  or confused session has write reach to **all repos on the host.**

This rhymes with the project's own thesis: a **write** (here, a `git` ref move or a
stray staged file) by an under-isolated actor produces an **effect** on another
actor's work — the write-to-execute pattern, lifted from the substrate up to the
operating environment.

---

## 2. Reproduction (observed this cycle — not hypothetical)

While orienting in the single shared `C:\gitRepos\cnsUnltd` clone, I observed its
`HEAD` move **four times without my action**, driven by concurrent session activity:

1. Session start: clone on `division/research-rnd`, with **another division's
   untracked deliverables present in the tree** (`divisions/ip-legal-strategy/status/founding-cycle.md`,
   `.../deliverables/license-compliance-register.md`) — branch/file bleed.
2. After I `git checkout division/security-redteam`: those ip-legal untracked files
   **followed me onto my branch** (untracked ⇒ not branch-scoped). A `git add -A`
   here would have committed another division's work onto the Security branch.
3. Minutes later, `HEAD` had switched to `division/ip-legal-strategy @ f0cb711` — a
   concurrent session checked out and committed its founding cycle **in the same
   clone**, moving `HEAD` out from under me.
4. Shortly after, the main clone showed `division/research-rnd @ fb31633` — another
   ref move.

At one read my own branch ref briefly resolved to a foreign commit
(`fccf318`, an ip-legal founding-cycle commit) before settling back to `8d869c1`.
**Net effect:** branch identity under a session is not stable; a naive
`add → commit → push` could have published the wrong files to the wrong branch.

---

## 3. Why it matters for *this* org specifically

- **Autonomy amplifies it.** Cooperating, attended sessions mostly recover. The org's
  trajectory is *unattended* multi-agent operation — where a silent wrong-branch
  commit or a cross-division file leak is not caught by a human in the loop.
- **It is a trust-boundary surface.** The charter gives this dept veto over anything
  touching the trust boundary. A mechanism by which one session can write another's
  branch — or the product repos it is supposed to only read — *is* a trust boundary,
  and it is currently unguarded except by prompt discipline.
- **It can defeat the secret-scan invariant.** The standing rule is "secret-scan
  before every commit; never `git add -A`." Cross-branch untracked bleed is precisely
  the condition under which a stray `git add -A` sweeps an unintended (possibly
  secret-bearing) file into a commit. The fence and the hazard are the same shape.

---

## 4. Recommendation (mitigation — Infra/Platform owns the change)

Tiered; none of these is mine to *apply* — I surface them.

- **R-1 (structural, recommended): one isolated `git worktree` (or full clone) per
  session.** `git worktree add` gives each session its own checkout + `HEAD` against
  the shared object store, so a checkout by one session cannot move another's branch,
  and untracked files cannot bleed across branches. **I used exactly this for my own
  founding-cycle authoring** (`C:\gitRepos\cnsUnltd-wt-security-redteam`) rather than
  `git checkout` in the shared clone — both to avoid clobbering the concurrent
  ip-legal session and to demonstrate the fix. Low cost, removes the whole class.
- **R-2: keep the `git add -A` ban as a hard rule** (already in the onboarding WO);
  consider a pre-commit hook that refuses `add -A` / refuses staging paths outside
  `divisions/<this-session>/` on a division branch. Defense in depth for R-1.
- **R-3: enforce product-repo read-only structurally** for division sessions that
  only introspect — e.g. a read-only checkout, or a pre-push/pre-commit hook on
  `pandora`/`elpis-os` that blocks division sessions. Today it is prompt-only.
- **R-4: the EA integrates from `origin` refs, never from the shared working tree** —
  so local checkout churn cannot contaminate an integration.

## 5. Diff anchor for next cycle
Re-check whether session isolation (R-1) was adopted. If the org is still on shared
working copies when the loop runs unattended, this finding escalates to HIGH and
becomes a pre-`loop-turns` gate item.
