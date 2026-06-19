# DEPARTMENT CHARTER — Infrastructure / Platform Engineering
## Division 6. The one that keeps the lights on and the swarm running.

**Status:** founding charter, for the founder/board. Authored by the CEO function.
**Why now:** every blocker this org actually hit was infrastructure, not code.
"mkosi absent → no image build path" was *the* recurring ship-blocker; the dev VM
was unreachable; the fleet is a scatter of boxes. And the swarm itself runs *on*
something — the orchestration host, the credit budget, the anti-idle execution
environment. Nobody owned the platform. This division does. **The other divisions
produce the work; this one provides the ground they stand on.**

---

## 1. MANDATE
Own the platform the org runs on and ships from: the machine fleet, the build
environment, the CI runners, and the agent-orchestration substrate. Make "we can't
because the environment isn't there" a thing that has an owner and a fix, not a
recurring shrug.

Its product is **a platform that's there when you reach for it** — the build works,
the box is reachable, the swarm has somewhere to run.

---

## 2. WHAT IT OWNS
- **The fleet** — the reference box, the dev VM, the laptops: provisioning,
  reachability, health, the known-good reference snapshots (P-7's pre-crunch
  insurance lives here). Owns *that the boxes exist and are reachable*; does NOT
  own mutating the reference box unattended (that's gated to the founder, always).
- **The build environment** — restoring and maintaining **mkosi** (the real
  ship-blocker), the reproducible image-build *capability*. (Boundary with QA: Infra
  makes the build *work*; QA *proves the output reaches parity*. Infra owns the
  oven; QA owns tasting the cake.)
- **The CI substrate** — the runners/machines the gate executes on. (Boundary with
  QA: Infra owns the runners; QA owns the gate *logic*.)
- **The agent-orchestration platform** — the execution environment crunch-time runs
  in, the remote-control host, **credit/budget monitoring** (the anti-idle "burn to
  zero" mandate needs an owner watching the meter), the plumbing that lets the swarm
  run overnight unattended.

## 3. THE LINE IT HOLDS
- **Owns the platform, never the product.** It does not decide what ships (founder),
  what's safe (Security), or what's verified green (QA). It makes those decisions
  *possible* by keeping the ground stable.
- **The reference box is never live-mutated unattended** — Infra keeps it reachable and
  snapshotted; the founder presses any apply/flash. Reversible auto-rollback steps
  are the only exception, same as the standing rule.
- A Security `BLOCK` on infrastructure (e.g. an orchestration-platform exposure) is
  binding — the platform is itself an attack surface and Security audits it too.

## 4. RELATIONSHIP TO THE OTHER ORGANS
- **QA/Release-Eng** is its closest partner: Infra provides build capability + CI
  runners; QA provides the gate + parity proof on top.
- **Development** runs on the platform Infra maintains; the swarm's anti-idle
  cadence depends on Infra keeping the orchestration substrate alive and the budget
  visible.
- **Security/Red-Team** audits the platform as an attack surface (the orchestration
  host, the fleet's network posture).
- **CEO function** coordinates; **Founder/board** presses every physical button and
  owns the credit budget's hard limits.

## 5. ANTI-IDLE BACKLOG
Restore + harden mkosi and the image pipeline; get the dev VM reliably reachable;
script fleet provisioning + reference snapshots; stand up durable CI runners;
instrument credit/budget monitoring for crunch-time; document the platform so it's
reproducible, not tribal knowledge. The environment is never "done."

## 6. NOT
Not a decider of what ships (founder). Not a security authority (Security audits it).
Not a green-stamp (QA). Not licensed to mutate the reference box unattended (founder's buttons,
reversible-rollback aside).
