# FOUNDING STATUS — Infrastructure / Platform (Division 6)

**Session:** infraPlatformClaude · **Branch:** `division/infrastructure-platform`
**Date:** 2026-06-19 · **Type:** founding cycle (orient · propose · surface · hold)
**Mandate:** the platform the org runs on and ships from — the fleet, the build
environment, the CI substrate, the agent-orchestration platform + usage envelope.

> This is the founding deliverable, not ongoing work. The loop is **not turning
> yet**. Everything below is read-only inventory + a *proposed* first cycle for the
> founder/EA to dispose of. No product-repo change, no `.180` mutation, no merge,
> no gated op was performed. Supporting data: `deliverables/fleet-and-build-inventory-2026-06-19.md`.

---

## SCORECARD (the board view)

| Domain area | State | One line |
|---|---|---|
| Reference box `.180` | 🟢 **GOOD** | reachable, healthy, all `pandora-*` units up; 20c/62G/856G free |
| Dev VM (mkosi build host) | 🔴 **AT RISK** | **unreachable now**; the *only* host that runs mkosi |
| `.196` laptop | 🟡 **DOWN** | no ICMP — off or off-network (status unknown, not confirmed-bad) |
| mkosi build path | 🟡 **PRESENT-BUT-FRAGILE** | builds on one VM, mkosi 20.x + uncommitted stopgap, no CI, SPOF |
| CI substrate | 🟡 **PARTIAL** | both repos have Actions CI; **no image-build CI**; `ci-verify.sh` absent |
| Orchestration host | 🟢 **GOOD** | 24c/63G, 504 GiB free — headroom for the swarm + a local build |
| Session isolation | 🔴 **DEFECT** | division sessions share ONE git clone → `HEAD` races → commits land on the wrong branch (hit live this cycle) |
| Usage-envelope monitor | ⚪ **GREENFIELD** | assigned to Infra by resource-model §2; **no tooling exists yet** |
| Secret hygiene (build keys) | 🟢 **CLEAN** | `_publisher.key` is gitignored + untracked — no leak (Security visibility flag) |

**The one sentence:** the historical ship-blocker has moved from *"mkosi absent"*
to *"mkosi present but fragile and non-durable"* — it lives entirely on a single,
currently-unreachable VM, on a stopgap version, wired into no CI; making that
capability **durable, reproducible, and reachable** is this division's #1 job.

---

## A. DOMAIN INVENTORY (read-only; cited by path/commit, nothing copied)

1. **Fleet.** `.180` reachable + healthy (Ubuntu 24.04.4, 20c/62 GiB/856 G free,
   all core `pandora-*` units active). `.196` and the Hyper-V dev VM both
   unreachable by ICMP. `.180` lacks `mkosi`/`cargo`/`rustc`/`spacetime`/`claude`
   — it is **not** yet a dev/build host. (`deliverables/…inventory…` §1.)
2. **Build environment.** mkosi config + `build-mkosi.sh` committed at
   `elpis-os/build/mkosi/*` (HEAD `2c614ce`); README §Status(Phase 2) records the
   image builds/boots/provisions identity. But it runs only on the dev VM, on
   mkosi **20.x** with an uncommitted `mkosi.local.conf` stopgap (initrd + `root=`;
   the clean fix is mkosi 22+). (`inventory` §3.)
3. **CI substrate.** `pandora/.github/workflows/ci.yml` (8 jobs) and
   `elpis-os/.github/workflows/ci.yml` (5 jobs) both run on push-to-main + PR. No
   workflow builds the image. **`ci-verify.sh`** — the merge-autonomy policy's
   named local combined-QA gate (TIER-1 criterion #2) — **exists in neither repo.**
   (`inventory` §4.)
4. **Orchestration platform.** This Windows host: 24c/63 GiB/504 GiB-free — the
   substrate the crunch runs on. Resource guard / disk-floor tooling (orchestration
   WO P-6) not yet implemented. (`inventory` §2.)
5. **Usage envelope.** `governance/resource-model.md` §2 assigns "watching the CC
   throughput envelope" to this division. No meter/tooling exists. (`inventory` §6.)

## B. ASSESSMENT (through the Infra lens)

**In good shape**
- The reference box is reachable, healthy, and running the live capability runtime.
- The orchestration host has ample headroom (CPU/RAM/disk) for the swarm.
- Build-key secret hygiene is correct (gitignored, untracked, public key separate).
- CI exists in both repos and is honestly scoped (the comments name what's excluded
  and why) — a real, if conservative, independent signal.

**Broken / missing / at risk**
- **mkosi is a single point of failure** (R-1 below). The build host is down now;
  it's the only box with mkosi; it's on a stopgap version; no CI exercises it. The
  ship-blocker is *de-risked but not resolved.*
- **`ci-verify.sh` is referenced-but-absent** (R-2). The AUTO-tier merge mechanism
  the whole org leans on names a local gate that does not exist.
- **No durable CI runner** can do a privileged image build — image build is a
  manual, single-VM act, not a verifiable gate.
- **Usage-envelope monitoring is unowned-in-practice** — assigned here, zero tooling.
- **Ledger drift:** `decision-ledger.md` D-008 still records "no image-build path
  (mkosi absent)"; the repo shows mkosi present and building (R-4).

## C. PROPOSED FIRST REAL CYCLE (once the loop turns — tiered; gating marked)

> Marking: 🟢 GREEN = branch-only/authoring, run freely · 🟡 AMBER = reversible +
> health-checked · 🔴 RED-GATED = founder/Security presses it, never me.

**TIER 1 — foundational (unblocks the rest)**
- **T1.1 — Make the mkosi build durable + reproducible.** Confirm/restore dev-VM
  reachability; write the exact build-host bring-up so it's reproducible, not
  tribal; pin the mkosi version; plan the move to **mkosi 22+** to retire the
  uncommitted 20.x stopgap. 🟢 (authoring/build on a branch; **any flash of the
  output is 🔴 founder's**).
- **T1.2 — Implement `ci-verify.sh`** (the policy's local combined-QA gate: real
  build + full test suite + `cargo build --target wasm32`). **Cross-division:** QA
  owns the gate *logic*, Infra owns the runner/plumbing it executes on. 🟢
- **T1.3 — CI on feature-branch push** in both repos (close the P-5 gap so sprint
  branches get an independent signal before a PR exists). 🟢

**TIER 2 — durable platform**
- **T2.1 — A durable CI runner that can build the image.** Stand up a self-hosted
  runner able to do the privileged mkosi build so image build becomes a gate, not a
  one-VM act. 🟡/🔴 — **if the runner lives on `.180`, provisioning it mutates the
  reference box → founder presses; Security audits the runner as an attack surface.**
- **T2.2 — Usage-envelope monitor** (resource-model §2): instrument how many
  divisions run hot vs the plan envelope; surface to the EA for cadence sequencing. 🟢
- **T2.3 — `.180` dev-overlay authoring** (orchestration WO Lane E2 / the
  self-hosted-dev-on-.180 requirement): idempotent `dev-overlay/setup.sh` adding the
  absent Rust+wasm32 / `spacetime` / `claude` / mkosi env / repos. 🟢 to author;
  **🔴 applying it to `.180` is the founder's button (mutates the reference box).**
- **T2.4 — Orchestration resource guard** (WO P-6): disk/RAM floor watchdog that
  pauses the image-builder before a wedged box. 🟢

**TIER 3 — hardening / insurance**
- **T3.1 — Pre-crunch reference snapshot playbook** (WO P-7) for `.180`. 🟢 to
  script; **🔴 the actual full-box snapshot/capture is attended/founder.**
- **T3.2 — Fleet provisioning scripts + platform docs** (bring `.196` / dev VM back
  to reproducible reachability; document the platform end-to-end). 🟢 authoring.

## D. DEPENDENCIES (what I need, and from whom)

- **From the FOUNDER:** (a) decide the durable build/dev host — `.180` vs the dev VM
  vs a dedicated builder; (b) power/confirm the dev VM + `.196` (down now) — or
  confirm they're meant to be off; (c) press every gated button (apply dev-overlay
  to `.180`, stand a runner on `.180`, any flash/snapshot).
- **From the EA:** (a) integrate this branch → `main` under the gate; (b) reconcile
  ledger **D-008** (the "mkosi absent" half is stale — see R-4); (c) sequence
  Infra's cadence inside the usage envelope once T2.2 produces a meter.
- **From QA/Release-Eng (sibling):** co-own **`ci-verify.sh`** — QA the gate logic,
  Infra the runner. "Infra owns the oven; QA tastes the cake" (charter §2).
- **From Security/Red-Team (sibling):** audit any self-hosted CI runner + the
  orchestration host as attack surfaces *before* they go live; note the
  build-key visibility flag (no action needed — gitignored-clean).
- **From IP/Legal-Strategy (sibling):** the BLOCKED bakes (D-008) stay blocked on
  the **libndk license** question regardless of mkosi — that half is their call,
  not an Infra build-path problem.

---

## DECISIONS NEEDED FROM ARCHITECT (isolated, decision-ready)

1. **Durable build/dev host — which box?** Options: **(a) `.180`** [recommended —
   20c/62G/856G-free, already reachable; but provisioning + running a builder on the
   reference box is 🔴-gated and Security-audited], (b) **revive the dev VM** [keeps
   builds off the reference box; but it's the current SPOF and was down at snapshot],
   (c) **a dedicated builder** [cleanest isolation; needs hardware — cost-bearing].
   *Forecloses:* picking (a) couples build-capability to the daily-driver's health.
2. **mkosi 20.x stopgap → 22+ ?** Recommend yes (retires the uncommitted
   `mkosi.local.conf` initrd/`root=` hack). *Trade-off:* a build-host change to
   verify before the next image; pure upside once green.
3. **Reconcile ledger D-008** (EA/founder write): "mkosi absent" is contradicted by
   the repo. Reconciling corrects the record only — it does **not** unblock the
   bakes (still blocked on libndk license).
4. **Isolate division sessions (urgent platform fix — see R-5).** The sessions share
   one `cnsUnltd` working clone; `HEAD` is global, so under concurrency a commit
   lands on whichever branch another session just checked out. **This happened this
   cycle** — my founding commit briefly landed on `division/ip-legal-strategy`
   (contained, local-only, reverted; nothing reached origin). Options: **(a)
   per-session `git worktree`** [recommended — one command per division, isolated
   `HEAD`/index/working-tree, shared object store; I used it to land this very
   commit safely], (b) **a separate clone per session** [heavier; full duplication],
   (c) **serialize commits org-wide** [kills the parallelism the swarm exists for].
   *Forecloses:* leaving it unfixed means every division's Rule-2/Rule-3 hygiene is
   one race away from silent cross-branch contamination.

## RISKS / FLAGS

- **R-1 (HIGH, PLATFORM):** mkosi build is a single point of failure — one
  unreachable VM, stopgap version, no CI. The ship-blocker is de-risked, not gone.
- **R-2 (MED, PLATFORM/QA):** `ci-verify.sh` referenced by the merge-autonomy policy
  but absent → the AUTO-tier gate leans on GH Actions, not the named local gate.
- **R-3 (LOW, SECURITY — visibility only):** component-publisher private key exists
  in dev working trees; **verified gitignored + untracked** in `elpis-os`. No leak;
  routed to Security for awareness, no action requested.
- **R-4 (LOW, RECORD):** ledger D-008 "mkosi absent" is stale vs repo reality.
- **R-5 (HIGH, PLATFORM/PROCESS):** division sessions share one `cnsUnltd` working
  clone → global `HEAD` race → commits can land on the wrong branch. **Observed
  live this cycle** (my commit briefly on `division/ip-legal-strategy`; contained,
  local-only, reverted; origin never touched). Threatens Rule-2/Rule-3 hygiene
  org-wide. Fix in decision #4 (per-session worktrees). I adopted a worktree to land
  this update safely.

---

## HELD AT
No product-repo change · no `.180` mutation (read-only SSH only) · no merge to
`main` · no gated op authorized · loop not started. Orient · propose · surface —
**held.**
