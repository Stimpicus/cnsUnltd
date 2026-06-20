# FOUNDING STATUS — QA / Release-Engineering (Division 3)

**Session:** qaReleaseEngClaude · **Branch:** `division/qa-release-eng`
**Cycle:** founding (orientation + one deliverable; the loop is not turning yet)
**Date:** 2026-06-19
**Read:** CHARTER.md · CORNERSTONES · VALUES · REPO-STRUCTURE (branch model) ·
deliverable-spec · development-lifecycle · merge-autonomy-policy
**Scope rule observed:** product repos read-only; cited by path/commit, nothing
copied; no merges; no `.180`/flash/deploy; loop not started.

> **The one-line verdict for a tired founder:** my entire toolchest is *already
> built* — and almost none of it is *landed*. The elpis-os QA/release suite
> (parity harness, consumer GO/NO-GO, provenance, image-diff, flash-and-verify,
> first-boot self-test) lives on **stale `sprint/D` + `preview/qa` branches**, not
> on `main`; the gate the charter says I own — an exit-code-driven `ci-verify.sh`
> — **exists nowhere as a committed file** (it was the integrator's transient
> crunch script). My proposed first cycle is therefore *consolidation, not
> creation*: commit the gate, rebase-and-surface the stranded suite for landing,
> and close the CI coverage gap. Every actual landing/flash stays your button.

---

## a. INVENTORY — what exists today in my domain (cited, not copied)

### The gate
- **pandora — `.github/workflows/ci.yml`** (on `main` @ `6b603a4`). A real,
  green, *landed* GitHub-Actions gate: 8 jobs — workspace wasm32 module build;
  `demo-console` typecheck; `face-to-face` web-client build; `wasm-demo`
  wasm32-wasip1 build + SHA-256 log (cross-surface proof); `software-oracle`
  smoke; `android-oracle` and `windows-oracle` build+test. Its own header
  documents what it *deliberately excludes*: `cargo fmt`/`clippy` (tree not
  fmt-clean), the Playwright/vitest integration suites (need a live substrate),
  and 4 of the web-clients.
- **pandora — `substrate/verify-substrate.mjs`** (on `main`): a landed substrate
  verifier.
- **elpis-os — `qa/verify.sh` + `qa/parity-regression.sh` + `qa/README.md`**
  (on `preview/qa/parity-regression-harness`, **NOT on `main`**). The
  host-runnable "can this branch even be considered" gate: `bash -n` on every
  tracked `*.sh`, YAML sanity, and the parity guard. README documents
  bidirectional validation (17 failures without the fix → exit 1; 21/21 with →
  exit 0).
- **elpis-os — `build/verify-components.mjs`** (on `main`): the one piece of
  verify tooling actually landed.
- **GAP — there is no committed `ci-verify.sh` in either repo.** The
  exit-code-driven, real-build + full-test + `cargo build --target wasm32` gate
  the charter names as my first owned artifact is **institutional knowledge from
  the crunch run, not a version-controlled file.** (`git log --all -- '*ci-verify.sh'`
  returns nothing in either product repo.)

### The integrator function (Lane C)
- **Branches exist:** `integration/auto-pandora`, `integration/auto-elpis`
  (the integrator's prepared sets).
- **`integration/auto-elpis`** is ~30 merges ahead of `main` and bundles the
  whole `sprint/D` suite **plus** LICENSE-risk merges (Firefox/Wine
  redistribution gates `c0585b9`, libndk audit) and the parity-fix/polkit base.
  It is a *prepared* REVIEW set, **not landed**.
- **The standing rule is ratified and migrated:** `governance/merge-autonomy-policy.md`
  (TIER 1/AUTO criteria, integrate-then-gate, validate-on-known-green-main first).
- **GAP — no committed `READY-TO-MERGE.md` / merge-digest artifact or
  tier-tagging template.** The integrator's *output format* is undocumented as a
  reusable artifact.

### The parity-regression harness
- **elpis-os — `qa/parity-regression.sh`**: static-asserts the four facets of the
  per-device-state bug class fixed in `7ad628c` (self-pair↔dispatch deadlock,
  `no_agent` desktop-user group, installer `pkexec` polkit scope, cloned-disk
  machine-id). `7ad628c` itself **is** on `main` (@ `2c614ce`); the *guard* is not.
- **pandora — `applications/{android,windows}-oracle/src/outcome-parity.test.ts`**
  (landed on `main`): cross-oracle outcome parity.
- **pandora — `applications/face-to-face/web-client/tests/two-session-call.spec.ts`**
  (landed): the substrate-portability regression guard (per CLAUDE.md I-01,
  passes on both SpacetimeDB and Postgres substrates).

### The consumer-readiness bar
- **elpis-os — `docs/consumer-flash-go-no-go.md`** (on `sprint/D/consumer-flash-gono-go`,
  not `main`): the operator's STOP/WARN/INFO GO/NO-GO checklist. **Its own current
  verdict is NO-GO** — pending one supervised dev-VM build+verify+boot pass (mkosi
  absent on the authoring host; dev VM unreachable that run).
- Supporting (all on `sprint/D`, not `main`): `build/lib-consumer-gates.sh`
  (consumer gate assertions), `build/firstboot-selftest.sh`, `build/android-smoke.sh`,
  `docs/productization-gap.md` (the gap manifest).

### Release provenance
- **elpis-os (all on `sprint/D`, not `main`):** `build/build-provenance.sh`
  (image sha256 + .deb hashes + mkosi/toolchain versions + git rev),
  `build/image-diff.sh`, `build/flash-and-verify.sh`.

---

## b. ASSESSMENT — through the QA/Release lens

**In good shape**
- pandora's gate is *real, landed, and green* on `main`, with an honest header
  about its own coverage limits — exactly the "no overclaiming" posture the
  charter demands.
- The elpis-os QA/release suite is *well-designed*: host-runnable so it needs no
  image build, bidirectionally validated, and it already maps cleanly onto the
  five things my charter says I own.

**Broken / missing / at risk**
1. **The toolchest is stranded.** Almost the entire elpis-os QA/release suite is
   unlanded — it lives on `sprint/D/*` and `preview/qa/*`. `main` carries only
   `build/verify-components.mjs`. A capability that is not on `main` is not a
   standing gate; it is a draft.
2. **The stranded branches are STALE vs `main`.** Diffing `main..preview/qa/parity-regression-harness`
   over `packages/` shows the branch *removing* ~63 lines from the very files the
   parity fix touched (`postinst`, `elpis-install`, `49-elpis-install.rules`,
   `pandora-pair`) — they were cut **before `7ad628c` fully landed**. A naive
   merge would *regress the parity fix*. They must be rebased onto current `main`
   before they can be gated or landed. (This is precisely the "REVIEW-coupled /
   readiness-analysis" trap the merge-autonomy policy warns about.)
3. **The gate has no committed form.** `ci-verify.sh` being institutional memory
   rather than a file is a single-point-of-failure: the charter's hardest lesson
   (validate-on-known-green-main; exit-codes-not-stdout) is documented in policy
   but not *executable* in the repos. The next integrator re-derives it by hand.
4. **The integrator's output is un-templated.** No committed READY-TO-MERGE /
   digest format means tier-tagging accuracy (a charter anti-idle item) can't be
   audited cycle-over-cycle.
5. **Consumer flash is NO-GO**, and the blocker is environmental (mkosi absent;
   dev VM/`.180` reachability) — i.e. it routes to Infrastructure + the founder's
   physical button, not to authoring.
6. **CI coverage gap on the highest-value guards.** The integration `*.spec.ts`
   suites that encode the real security/portability invariants
   (`two-session-call`, `group-call`, `zero-retention`, `crypto`,
   `key-exchange`) are *excluded* from pandora CI because they need a live
   substrate. The regression guards that matter most don't run in the gate.

---

## c. PROPOSED FIRST REAL CYCLE (once the loop turns) — tiered

### TIER 1 — pure authoring on my branch; no product-repo change, no gated op
*(These produce division deliverables only. They are safe to do the moment the
loop turns; nothing here touches `main` or a box.)*
- **T1.1 — Commit the gate as a spec + reference script.** Author the canonical
  `ci-verify.sh` contract (exit-code-driven; real per-package build + full test +
  `cargo build --target wasm32`; the mandatory validate-on-known-green-`main`
  preflight) as `deliverables/`, ready to be *proposed* for landing into both
  product repos. **Landing is gated** (founder/EA) — I deliver the artifact, not
  the merge.
- **T1.2 — Author the integrator digest + tier-tagging template.** Turn
  `merge-autonomy-policy.md` into a runnable READY-TO-MERGE checklist + digest
  format, so tier-tagging accuracy is auditable.
- **T1.3 — Landing-readiness map for the stranded elpis-os QA suite.** For each
  `sprint/D` / `preview/qa` artifact: AUTO vs REVIEW vs BLOCKED per the policy,
  *plus the rebase-onto-current-`main` plan* (they're stale). This is the
  prepared, decision-ready REVIEW set for you — the integrator function doing its
  one legitimate job: *prepare*, not *merge*.

### TIER 2 — requires founder/EA action to land (GATED — I prepare, you dispose)
- **T2.1 — Rebase + land the QA toolchest onto `main`.** Once rebased and
  de-coupled from the LICENSE risks: `qa/verify.sh` + `qa/parity-regression.sh`,
  `build/build-provenance.sh`, `build/image-diff.sh`, `build/flash-and-verify.sh`,
  `build/firstboot-selftest.sh`, `build/lib-consumer-gates.sh` are AUTO-class
  (additive, no trust-boundary, no live-apply). **MERGE = EA under the gate;
  REVIEW disposition = you.** I never merge.
- **T2.2 — Close the CI coverage gap.** Extend pandora `ci.yml` to run the
  integration `*.spec.ts` suites behind a substrate service container. **MERGE =
  gated.**

### TIER 3 — GATED: founder / Security / physical only (I surface, never press)
- **T3.1 — The single supervised dev-VM build+verify+boot pass** that flips
  `consumer-flash-go-no-go.md` from NO-GO to GO. Needs a working mkosi env + a
  reachable dev VM/`.180`. **This is your physical button + an Infra dependency.**
- **T3.2 — Any `flash-and-verify` / image build executed against `.180` or real
  hardware.** Founder only. I can author and dry-run the *tooling*; I never run
  the apply.
- **T3.3 — LICENSE-risk bakes** (Firefox/Wine redistribution, libndk) remain
  **BLOCKED** pending the license decision (IP/Legal + you); no gate-green of mine
  overrides that, and a Security BLOCK on the coupled polkit base is binding.

---

## d. DEPENDENCIES — what I need, and from whom

- **Founder/architect:** disposition of the `integration/auto-elpis` REVIEW set;
  the supervised build+verify+boot pass (T3.1, physical); the LICENSE call on the
  bakes (with IP/Legal). I cannot self-authorize any of these.
- **EA (integrator):** integrate my TIER-1 deliverables to `main`; once you
  approve, integrate the rebased QA toolchest under the gate. I deliver to my
  branch; the EA lands.
- **Infrastructure/Platform (Div 6):** **mkosi presence — the shared
  ship-blocker** (their stated inventory item too); a CI runner able to stand up
  a substrate service container (for T2.2); dev VM / `.180` reachability for T3.1.
- **Security/Red-Team (Div 2):** binding review of the polkit grant in the
  parity-fix base and the LICENSE-risk bakes before any coupled set lands. **Their
  BLOCK halts whatever it touches; I serve the adversary, never overrule it.**
- **Development (Div 1):** hands me the branches; coordinate the rebase of the
  stale `sprint/D` set onto current `main`.

---

## RISKS / FLAGS (mandatory surface)
- **PARITY:** the stranded QA branches are stale and would regress `7ad628c` if
  merged naively — do not fast-merge them; rebase first. (Surfaced, not acted on.)
- **SECURITY/LICENSE:** the QA suite is coupled on a branch base that also carries
  the polkit install grant and the Firefox/Wine/libndk LICENSE risk — landing the
  QA tooling must be *decoupled* from those, which stay Security's/your call.
- **No GREEN claimed here.** Everything above is DEFERRED where it depends on an
  environment I don't have (mkosi, the dev VM). Green is earned by the gate, never
  reported by me.

**Held:** no product-repo changes, no `.180`, no merges, no gated ops. Orient,
propose, surface — then hold.
