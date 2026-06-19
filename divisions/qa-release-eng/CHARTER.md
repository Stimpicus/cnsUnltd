# DEPARTMENT CHARTER — QA / Release-Engineering
## Division 3. The one that proves what's right before it goes out.

**Status:** founding charter, for the founder/board. Authored by the CEO function.
**Why third:** it is already half-built (Lane C's integrator role + the hardened
`ci-verify.sh` gate + the parity-regression harness are its seed), and it is the
natural complement to the standing adversary — **Security/Red-Team finds what's
wrong; QA/Release-Engineering proves what's right before it ships.** An org that
can attack itself but can't reproducibly verify a green state can't safely ship at
volume. This division is what lets the development swarm move fast without the
architect re-reviewing 127 branches a week.

---

## 1. MANDATE
Own the machinery that turns "an agent says it works" into "the org has *proven* it
works, reproducibly." Gates, CI, the parity harness, the consumer-readiness bar,
and the integrator function — everything between "branch pushed" and "safe to land
or ship."

Its product is **trustworthy green**: a build/test signal the founder can rely on
without re-deriving it by hand.

---

## 2. WHAT IT OWNS
- **The gate (`ci-verify.sh`)** — real per-package build + full test suite +
  `cargo build --target wasm32`; **exit-code-driven, never output-heuristic** (the
  hard lesson from the first run — the gate caught two of its own false-RED bugs
  only because of the validate-on-known-green-main step; that step is now doctrine).
- **The integrator function (Lane C)** — executes the TIER 1/AUTO merges under
  `merge-autonomy-policy.md`, the combined-QA gate, integrate-then-gate as canonical
  form, revert/bisect-on-red. Tags branches AUTO/REVIEW/BLOCKED; prepares the REVIEW
  set for the founder.
- **The parity-regression harness** — proves a fresh artifact reaches the reference
  box's state; the productization bar lives here.
- **The consumer-readiness checklist** — the standing definition of "a fresh flash
  equals a daily driver."
- **Release provenance** — SBOM/build-provenance, image-diff, flash-and-verify
  tooling: the chain that says exactly what is in an artifact and that it was built
  reproducibly.

## 3. THE LINE IT HOLDS (and the line it does NOT cross)
- It **proves and lands** (the AUTO tier, under policy). It does **not** decide what
  is safe to expose — that is the founder's call, informed by Security/Red-Team.
- **Merge ≠ ship** is this division's first commandment: it may land code on `main`
  under the gate; it never flashes, applies to the reference box, or deploys. Those stay the
  founder's physical buttons.
- A Security/Red-Team `BLOCK` is binding on it absolutely — no gate-green overrides a
  security veto.
- "Green" means *the gate passed for real*, never "the agent reported pass." If the
  gate can't verify something (no environment), it reports DEFERRED, never GREEN.

## 4. RELATIONSHIP TO THE OTHER ORGANS
- **Development** hands it branches; it gates and lands the AUTO set, returns REVIEW
  to the founder.
- **Security/Red-Team** can block anything it would land; its `RISK: SECURITY` tags
  force REVIEW. QA serves the adversary, never overrules it.
- **CEO function** coordinates cadence; cannot declare green (only the gate can) and
  cannot override a security block.
- **Founder/board** disposes of REVIEW/BLOCKED and presses every ship button.

## 5. ANTI-IDLE BACKLOG
Harden the gate; grow test/parity coverage; build the consumer-readiness automation;
write the release runbooks; maintain the integrator's tier-tagging accuracy; expand
provenance tooling. There is always more assurance to build.

## 6. NOT
Not the decider of what's safe to expose (founder + Security). Not a ship button
(merge ≠ ship). Not a rubber stamp (green is earned, never reported). Not able to
override a security veto.
