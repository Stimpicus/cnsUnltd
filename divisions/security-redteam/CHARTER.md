# DEPARTMENT CHARTER — Security / Red-Team
## The standing adversary. The first department after Development.

**Status:** founding charter, for the founder/board (the human architect).
Authored by the CEO function. Establishes Security/Red-Team as a **standing**
department — always-on, independent of the sprint cadence — not a sprint lane.
**Why first:** this project's thesis *is* safety ("the capability was already in
the technology; we build the safeguards that decide whether it is catastrophic or
beneficial"). For a project heading toward public open-source and physical device
control, the department that adversarially tries to break it is the one whose
absence would most betray what the project is. Every other department makes the
work better; this one makes it *what it claims to be*.

---

## 1. MANDATE

To continuously attack the Pandora Protocol and ElpisOS — every implementation,
across both repos and the live reference box — through the project's own lens
(**write-to-execute via subscription substrate**) and every other lens an
adversary would use, so that weaknesses are found *by us, before deployment,*
rather than by an attacker after it.

The department's product is **adversarial assurance**: a continuously-current
answer to "what would a hostile party do, and would it work?"

---

## 2. WHAT MAKES THIS A *STANDING* DEPARTMENT (not the audit phase, not Lane H)

The audit is a *phase* (runs once per lifecycle turn). Lane H was a *lane* (runs
when a crunch invokes it). Both are sprint-coupled — security only happens when
something else triggers it. For this org that is backwards. So:

- **Always-on, sprint-independent.** Security/Red-Team runs on its own cadence,
  not gated by sprint start/end. It is attacking `main` and the live box on the
  days no sprint is running.
- **It OWNS the audit phase and absorbs Lane H** — the lifecycle's AUDIT phase
  becomes this department's scheduled deep-pass; the crunch's security lane becomes
  this department staffing the sprint. Same instruments (the write-to-effect map,
  the invariant tests), now owned by a permanent function instead of spun up ad hoc.
- **It maintains the living instruments between cycles:** the write-to-effect map,
  the invariant regression suite, the reference-instance ledger, the threat model —
  kept current continuously, not rebuilt each audit.

---

## 3. INDEPENDENCE (the non-negotiable structural property)

A red team that reports to the people shipping the feature is theater. So:

- **Independent of Development.** Security/Red-Team does not answer to the sprint's
  delivery goals. It can call a finding that blocks a merge or a deployment, and
  "but we wanted to ship" is not an override.
- **Read-only by default against production state.** It attacks by reading,
  reproducing, and reasoning — never by mutating the reference box or merging fixes itself
  (fixes are owned by the relevant build lane + the architect, exactly as Lane H
  authored designs but not source). Its power is the *finding* and the *veto*, not
  the commit.
- **Reports to the founder/board (the human architect), not to the CEO function.**
  This is deliberate: the CEO runs delivery; the standing adversary must be able to
  flag that delivery is about to do something unsafe *without* going through the
  delivery chain. The CEO cannot quietly soften a security finding — it routes
  straight to you.

---

## 4. AUTHORITY — voice and veto on anything public or physical

The department has a **standing seat and a binding flag** on every decision in
these classes (it cannot be skipped):

- Anything that **touches the public** (a repo going public, a disclosure
  publication, an open-source release, a public deployment).
- Anything that **touches the trust boundary** (auth, signing, consent,
  polkit/sudoers/AppArmor, network exposure).
- Anything that **actuates the physical world** (a flash, a reference-box apply, a device
  deploy, scaled protocol deployment).

Its flag is **advisory-to-the-board, binding-to-the-CEO**: the CEO function may not
proceed past a Security/Red-Team `BLOCK` on its own authority — only the founder
can dispose of it (accept-with-rationale, or send back for remediation). This is
the same shape as the merge policy's RED tier, made into a permanent organ: the
adversary raises it, the human disposes, the CEO never overrides.

---

## 5. STANDING WORKSTREAMS (the department's always-on backlog)

Anti-idle, like every department here — when one stream is quiet it mines the next:

1. **Continuous protocol attack** — keep the write-to-effect map current across all
   implementations; re-run it on every change to `main`; attack new write surfaces
   as they land.
2. **The reference-instance ledger** — reproduce and document every confirmed
   instance of the attack class; this is the **evidence feed for the living
   disclosure article** (the department is the article's primary source).
3. **Invariant regression suite** — maintain and grow the tests that prove
   consent-by-default, the loopback bind, secret-scan efficacy, the signing scope,
   etc. cannot silently regress; wire them into the gate.
4. **The carried-forward queue** — the known items deferred from prior cycles
   (currently: the `7ad628c` install polkit grant; the H-9 §2 verifier sweep; the
   H-4/H-11/H-15 backlog) — owned here, not lost.
5. **Threat-landscape watch** — track the general (substrate-agnostic) threat model;
   feed the EVALUATE phase and the next sprint's priorities.
6. **Pre-public gauntlet** — before any repo opens or any disclosure publishes, run
   the full adversarial pass that the department signs (or blocks).

---

## 6. RELATIONSHIP TO THE LIFECYCLE & THE OTHER ORGANS

- **AUDIT phase** → this department's scheduled deep-pass (it owns it).
- **EVALUATE phase** → fed by this department's ledger + threat watch; the living
  article is its written output.
- **Sprint (crunch-time)** → this department staffs the security lane and holds the
  `RISK: SECURITY` tagging authority in the merge policy.
- **CEO function** → coordinates, but cannot override a `BLOCK`.
- **Founder/board (human)** → the only authority that disposes of a `BLOCK`, and the
  only one who presses the physical/public buttons regardless.

---

## 7. INVARIANTS (inherited; this department guards them hardest)

It holds the org's standing rules and is the organ most responsible for them:
security above all / never trade speed for security; merge ≠ ship; verify-don't-
assume is a hard stop, not a fork; the human is final authority on anything public
or physical; the reference box is never live-mutated unattended; the public-
trajectory repos never receive a secret or the disclosure article. The department's
special charge: **be most suspicious of a good reason to make an exception** — the
Boromir failure mode is a capable actor certain it can handle the exception this
once. The rules win every time the temptation is a good one.

---

## 8. WHAT THIS DEPARTMENT IS NOT
- Not a fix-it shop — it finds and vetoes; build lanes + the architect remediate.
- Not sprint-gated — it runs when no sprint runs.
- Not overridable by delivery pressure or by the CEO function.
- Not a consumer of secrets or a mutator of the live box — read, reproduce, reason.
