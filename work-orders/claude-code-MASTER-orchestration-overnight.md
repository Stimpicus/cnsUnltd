# MASTER WORK ORDER — Overnight Multi-Agent Orchestration
**Addressed to:** the master Claude Code session (the ORCHESTRATOR)
**Host:** the baremetal dev machine where CC runs (Windows host, both repos,
          full toolchains). Reference box `.180` is a DEPLOY/VERIFY target,
          reached over SSH — not the orchestration host tonight.
**Window:** ~11 hours, unattended. The architect (human) is asleep / in-and-out
            and is the SOLE merge authority and final UAT.
**Repos:** `pandora` (private), `elpis-os` (private now — public-trajectory).

You are the orchestrator. You will run a pre-flight yourself, then spawn and
manage up to five concurrent sub-agent lanes, each working a queue of
time-boxed sprints, each landing work on its own feature branch. You will
collect reports and maintain one consolidated status doc. **You (the orchestrator)
never merge to main; the only merges permitted are the integrator (Lane C)
landing the architect-ratified AUTO tier per `merge-autonomy-policy.md`, each
CI-gated.** Read the Prime Safety Contract before doing anything.

---

## 0. PRIME SAFETY CONTRACT (non-negotiable, applies to you and every sub-agent)

1. **NEVER merge to `main` in either repo — with ONE bounded exception.** The
   human is the merge authority. Every lane stops at "branch pushed + QA report
   written." **The sole exception:** the integrator (Lane C) may merge the
   **TIER 1 / AUTO** set defined in `merge-autonomy-policy.md`, under the
   architect's standing ratification, the combined-QA gate, and revert-on-red.
   AUTO is constrained to deterministic, CI-verified, secret-clean, additive,
   no-risk-tag, no-trust-boundary, no-boot/parity, no-live-apply work — because
   **merging is not shipping** (flash / `.180` apply / deploy all stay gated
   downstream). REVIEW and BLOCKED branches are NEVER merged without the
   architect. Lanes A/B/D/E/F/G/S/H still never merge anything — only C, only AUTO.
2. **NEVER force-push, rewrite shared history, or delete branches** you did
   not create this session.
3. **NEVER reboot `.180`** unattended. It is the reference daily-driver.
4. **Live mutations of `.180` must be reversible with auto-rollback.** Any
   step that restarts a service or swaps a binary on `.180` keeps the
   known-good artifact, health-checks after, and rolls back on failure.
   Prefer reversible verifications (e.g. mute → confirm → unmute).
5. **Stay in your lane.** A sub-agent touches only its owned directories
   (ownership table §2). Cross-lane edits are forbidden.
6. **Anything that could affect boot/parity** (image, build, UKI, systemd,
   bootloader) stays on a branch and is flagged `RISK: PARITY` for explicit
   human review. Never live-apply it to `.180`.
7. **Destructive DB ops** (`spacetime publish --delete-data`, dropping
   tables, wiping config) happen only in dev/branch context, never against
   `.180`'s live substrate.
8. If a sprint's QA fails: commit WIP to the lane branch, write the failure
   honestly in the report, and move to the next queue item. **Do not get
   stuck, do not "fix forward" into another lane, do not merge to escape.**
9. **NEVER leak a secret into a repo — `elpis-os` is private now but
   public-trajectory** (a consumer OS destined to open-source; a secret committed
   while private becomes a permanent PUBLIC history leak the day it opens). So the
   secret-scan is a STANDING invariant, not contingent on current visibility. Never
   `git add -A` / `git add .`; stage only explicitly named paths you intend to
   commit. Never commit anything under a secrets/credential path (e.g.
   `secrets.yaml`, `*token*`, `*.key`, `*.pem`, HMAC values, `.180` creds,
   `/etc/pandora/` material). Run a secret scan (gitleaks/trufflehog, or a
   regex pre-commit fallback) on the staged diff before EVERY commit; if it
   trips, abort the commit and report. A leaked secret in git history is
   permanent — rotation is the only fix. Treat this as gravity, not advice.
10. **NEVER silently erode a security invariant.** The product's whole thesis
    is consent-by-default (`allowedSigners: []`), the append-only audit log,
    AppArmor confinement, and the unprivileged `pandora` user. If a change
    would widen permissions, touch auth/OIDC, add a signer, relax a polkit/
    sudoers/AppArmor rule, or alter the audit path, you may build it on a
    branch but you MUST stamp it `RISK: SECURITY` (same tier as PARITY) for
    mandatory human review, and never live-apply it to `.180`. "Make the
    feature work" never justifies opening the safety model.
11. **Keep the source-of-truth docs current in the SAME commit.** Any change to
    build pipeline, boot/UKI model, services, device-control contract, or
    install flow updates the relevant `CLAUDE.md` section in that commit. A
    change that drifts its docs is unfinished.
12. **Pin what you pull.** Do not add unpinned dependencies. Respect GPLv3 in
    `elpis-os` — flag any new dependency whose license may be incompatible as
    `RISK: LICENSE` for human review rather than vendoring it.

If any instruction below ever conflicts with this contract, the contract wins.

---

## 0.5  ANTI-IDLE MANDATE (the optimization target for tonight)

**Outcome ranking, best to worst:**
1. **BEST — exhaust the credit budget.** Running out of credits at any point,
   30 minutes in or 10h59m in, is total success. There is no "too much work."
2. Acceptable — agents still working productively on lower-value but defensible
   improvements when time/credits end.
3. **WORST — any agent idle, blocked, or "awaiting instruction."** A halted
   agent is the single worst state tonight, worse than an agent doing
   imperfect-but-reversible work. Treat idleness as a defect to be designed out.

**Two rules make idleness impossible:**

**(R1) Self-refilling backlogs — never return empty-handed.** A lane's listed
sprints are a *floor*, not a ceiling. When a queue empties, the agent does NOT
stop and does NOT ask — it derives the next defensible unit of work *within its
owned directories* and continues, flagging it `UNPLANNED` in the report. Every
lane has a near-infinite well of legitimate work (see each lane's
"Backlog generator" below). The agent mines that well until credits run out.

**(R2) Fork, never block — decisions produce work, they never pause it.** When
an agent hits a genuine decision fork (an "Open decision" / aspect ratio /
packaging strategy / fixed-vs-resizable / which-option), it MUST NOT stop and
ask. It:
  a. picks the **most defensible default** (stated in the lane brief where
     known),
  b. **builds that option on its branch**,
  c. logs the decision + the road-not-taken in `DECISIONS NEEDED`, and
  d. **keeps moving** to the next queue item.
If the architect later prefers the alternative, it is a cheap branch swap — not
lost hours. A blocking question is a contract violation tonight.

**The boundary that anti-idle must NEVER cross:** "stay busy" does NOT license
breaking the Prime Safety Contract. Specifically it never justifies merging to
main, force-pushing, live-applying RED/parity changes to `.180`, rebooting the
reference box, or leaving a lane to manufacture risk for the sake of activity.
Anti-idle is scoped to **branch-safe, lane-owned, reversible** work only.
Infinite productive work; zero infinite risk.

---

## 1. PRE-FLIGHT (orchestrator does these directly, before spawning anything)

**P-0 — Save the uncommitted work (highest priority, do first).**
The entire capability-descriptor control system is uncommitted in the
`pandora` working tree (compiles clean, not committed, not deployed). It is
one accident from gone.
```
cd <pandora>
git checkout -b feature/capability-descriptor-controls
git add -A && git commit -m "feat: capability-descriptor device control system (WIP, compiles clean)"
git push -u origin feature/capability-descriptor-controls
```
Confirm the push succeeded before continuing. This branch is Agent A's base.

**P-1 — Snapshot `.180` baseline (read-only).** Record its current DHCP IP,
confirm SSH reachability, and capture a read-only service/health snapshot
(uptime, `systemctl is-active` for the core units, listening ports). Save as
`baseline-180.txt`. All lanes that touch `.180` use this IP for the night
(do NOT change its lease — that's a gated E sprint).

**P-2 — Confirm toolchains** on the orchestration host: node + `claude`, git,
Rust/cargo + wasm32, npm, and the mkosi build env (or the dev VM reachable
for image builds). Note which image-build path is available; Agent D needs it.

**P-3 — Create the consolidated status doc** `OVERNIGHT-STATUS.md` at the repo
root of a scratch location (not committed). You will append every sprint
result here. This is the artifact the architect reads first in the morning.

**P-4 — Install the secret-scan guard (do before any lane commits).** Add a
pre-commit hook (or a wrapper every lane must call) that runs
`gitleaks protect --staged` (or trufflehog, or a regex fallback covering
token/key/pem/secret/password + `secrets.yaml` + `/etc/pandora/`) on the staged
diff and BLOCKS the commit on any hit. Verify it actually blocks with a dummy
secret in a throwaway staged file, then remove the dummy. No lane commits until
this is proven to block. `elpis-os` is public-trajectory — this guard is load-bearing.

**P-5 — Stand up CI-on-push (independent QA signal).** Add a GitHub Actions
workflow to each repo that, on branch push, runs the build + test suite and
reports status on the branch/PR. Self-reported lane QA is necessary but not
sufficient; the architect's trustworthy morning signal is "CI green," produced
by something other than the agent that wrote the code. If Actions is
unavailable, stand up an equivalent local post-push build/test that writes an
independent result line into `OVERNIGHT-STATUS.md`.

**P-6 — Resource guard (anti-idle's own failure mode).** Before spawning lanes,
record free disk + RAM. Add a guard the orchestrator polls each cycle: if free
disk drops below a safe floor (set generously above one full image build),
PAUSE Lane D (the image builder) and prune stale build artifacts/old image
outputs before resuming. Cap image-output retention (keep newest N). SpacetimeDB
is in-memory — watch its growth too. Anti-idle removed the natural stopping
point; this guard puts a safe one back. Running out of *credits* is success;
running out of *disk* is a wedged box — never confuse the two.

**P-7 — Pre-crunch safety net for `.180`.** Capture a known-good reference of
the box before any AMBER live step: at minimum, back up the current shell + bridge
binaries and key config so A1's rollback has a floor, and note (for the
architect) that a full pre-crunch image snapshot is the cheap insurance for a
weekly cadence. Read-only; do not reboot.

---

## 2. LANES & DIRECTORY OWNERSHIP (the collision map)

Lanes own disjoint working sets. A sub-agent that edits outside its column
is violating the contract. (The orchestrator spins up the standing lanes below
plus any extra disjoint lanes the backlog warrants — the first run added F/G/H/S.)

| Lane | Subsystem | Owns (writable) | Repo |
|---|---|---|---|
| **A** Control system | device control, bridge Pair path, providers | `pandora` capability-descriptor system, bridge providers, `applications/elpis-shell` device-control + controller-window code | pandora |
| **B** Windowed Android | Waydroid multi-window, app window geometry | elpis-os Waydroid config, launcher **window-geometry** code, wayfire window rules | elpis-os |
| **C** Integration/triage | branch triage, combined QA, AUTO-tier merge | READ-ONLY across both repos; `preview/*` branches; **executes TIER 1/AUTO merges to `main` per `merge-autonomy-policy.md` under the combined-QA gate** | both |
| **D** Productization | bake runtime into image | elpis-os `build/`, `packages/*/DEBIAN`, mkosi config, image staging | elpis-os |
| **E** Dev overlay + housekeeping | `.180` dev overlay (per-box, NOT image), static lease, hostname | `.180` runtime config (overlay), a new `dev-overlay/` setup script dir | elpis-os (script only) |
| **I** Installer (standing — added 2026-06-19) | the installer **app** + its **UX**, as a parallel workstream every phase | the installer application logic (`elpis-install` + supporting install code) AND the installer UI (`InstallerPanel`, the start-install watchdog, the "Install to Disk" surface) — both app and ux branches | pandora (shell UI) + elpis-os (install mechanics) |

**Note for all future phases:** Lane I (Installer) is now a standing parallel lane.
Installer work — both the app/mechanics and the UX — runs as its own team every
crunch, not as one-off REVIEW branches. Its install-mechanics changes are
trust/boot-adjacent (they touch `elpis-install`, postinst, and may touch the
install polkit grant), so those land **REVIEW** by the merge policy; its pure-UI
shell branches are AUTO-eligible like any additive UI. Lane I coordinates with D
(productization owns the image bake; I owns the installer that runs at flash/first
boot) and must not edit D's `build/` / mkosi config.

**Known contention points — pre-resolved:**
- **A vs B on "windows":** A opens *controller* windows (Tauri `WebviewWindow`
  in the shell); B opens *Android app* windows (Waydroid/wayfire). Different
  windowing systems, different files. Permitted in parallel.
- **B vs D on the gateway package:** B edits the gateway's *runtime* launcher
  code; D packages from current `main` (without B's unmerged changes) and
  treats the gateway as a black box. D does **not** edit launcher internals.
  After B merges (with sign-off), the human re-runs D's packaging.
- **C touches nothing writable in shared dirs** — it only reads and creates
  `preview/*` branches. No collision possible by construction.

---

## 3. PER-LANE SPRINT QUEUES

Each sub-agent works its queue top-to-bottom. On finishing a sprint (own QA
green + branch pushed + report), it pulls the next item. If QA is red, it
records the failure and still advances (per contract §8). Keep queues deep so
no lane idles — utilization is the point tonight.

Branch naming: `sprint/<lane>/<slug>` (e.g. `sprint/A/deploy-controls`).

### Lane A — Control system (base: `feature/capability-descriptor-controls`)
- **A1 — Deploy + live-verify on `.180` (RISK: LIVE, reversible).** Rebuild the
  bridge service + Tauri shell binary; stage alongside the known-good binary;
  swap with auto-rollback-on-failure; health-check the desktop comes up; then
  round-trip a **reversible** control on the Odyssey G9 (mute → confirm
  `describe_device`/`device_capabilities` flow → unmute). If the shell fails
  health-check, roll back to the known-good binary and report.
  *Gate:* live round-trip succeeds AND desktop healthy (or clean rollback).
- **A2 — F-1 paired-flag reconciliation.** Bridge reconciles `paired=true` when
  a valid persisted credential already exists (the G9 token case). *Gate:*
  devices with valid tokens report `paired=true`; controller-window path
  triggers.
- **A3 — Exercise the richer discovery set.** Provider files for the Hue bridge,
  the second Samsung TV, and a template provider for the Xbox. *Gate:* each
  renders a `ControlSurface` (live or honestly stamped `template`).
- **A4 (stretch) — LG webOS + Roku provider files** (research-complete,
  template surfaces) to prove the "one provider file per family" claim.
- **A — Backlog generator (never idle):** keep authoring one provider file per
  device family that plausibly exists on consumer networks (Sonos, Chromecast,
  Apple TV, Vizio, Fire TV, generic Matter, smart plugs, AVRs, soundbars,
  thermostats, etc.), each as an honestly-stamped `live|partial|template`
  surface; then write unit tests for the descriptor encoder; then expand
  `DEVICE-CONTROLLERS.md`. There is effectively no end to clean provider work.

### Lane B — Windowed Android / NR-2
- **B1 — Enable multi-window.** Set `persist.waydroid.multi_windows` (verified
  unset today); restart the Waydroid container cleanly; confirm it persists.
  *Gate:* prop persists, container active after restart. (Branch-only config;
  do not apply to `.180` live unattended — stage it in the image/overlay path
  and verify in dev.)
- **B2 — Phone-proportional windowed launch.** Per-app window launch + wayfire
  rules for a phone-shaped default geometry (architect default: portrait
  phone aspect, sensible fraction of a 5120×1440 panel). *Gate:* an APK opens
  in a phone-proportional window, not full-screen, in dev verification.
- **B3 — Orientation + sizing policy.** Honor each app's declared orientation;
  default fixed phone-portrait, resizable allowed. *Gate:* a portrait app
  opens portrait, a landscape app opens landscape.
- **B4 (stretch) — Multiple Android apps in separate simultaneous windows.**
- **B — Backlog generator (never idle):** define and implement per-app-category
  window policies (messaging = tall portrait, video = landscape, games =
  declared orientation, utilities = resizable), one branch per category; then
  add window-state persistence (remember size/position per app); then write
  wayfire-rule tests. Defensible default when unsure: fixed phone-portrait,
  resizable allowed.

### Lane C — Integration & triage (READ-ONLY + `preview/*` + AUTO-tier merges)
Operates under `merge-autonomy-policy.md` (architect-ratified). Tags every branch
**AUTO / REVIEW / BLOCKED** by the policy's nine criteria, executes the AUTO set
under the combined-QA gate, and prepares (never merges) REVIEW/BLOCKED.
- **C1 — Branch triage.** Catalog all unmerged branches in both repos. Classify
  merge / rebase / abandon, **assign each a tier (AUTO/REVIEW/BLOCKED) per the
  policy**, with a one-line rationale, a conflict-risk note, and a recommended
  **merge order**. Output: `triage-report.md`. No merges yet.
- **C2 — Rebase previews + combined QA.** For each "merge" candidate, create a
  `preview/<branch>` rebased onto current `main`, build it, and run the parity
  smoke check. Confirm which are genuinely AUTO-eligible (pass all nine criteria)
  vs. REVIEW vs. BLOCKED. Still no merges to main in this sprint.
- **C3 — Execute the AUTO tier (the policy's bounded authorization).** Merge the
  **guards FIRST** (parity-regression harness + security-invariant tests) so they
  are live on `main`, then merge AUTO-tier lanes in dependency order, each as its
  collapsed tip. **After EACH merge run combined CI (`ci-verify.sh`) on the new
  `main` HEAD: green → continue; red → STOP, revert that one merge, flag it,
  continue if independent.** Never merge REVIEW or BLOCKED. Output: an AUTO-merge
  **digest** (what landed, CI at each step, final `main` HEAD per repo).
- **C4..Cn (rolling) — Live manifest for the REVIEW set.** Maintain
  `READY-TO-MERGE.md`: the AUTO digest (post-hoc, for the architect to spot-check)
  PLUS the REVIEW/BLOCKED branches in recommended order with risk flags, for the
  architect's sign-off. Re-run combined QA as the set grows. C *executes AUTO*;
  the human *executes REVIEW/BLOCKED*.
- **C — Backlog generator (never idle):** when no new branches await triage or
  AUTO-merge, expand automated QA coverage — a parity smoke-test script, a
  boot/UKI verification harness, a per-service health-check suite, regression
  tests for the closed per-device-state parity bug class, and a `make verify`
  target. More coverage is always defensible; this authoring never touches main.

### Lane D — Productization (elpis-os build/image)
- **D1 — Gap manifest.** From `docs/CONSUMER-READINESS.md`, enumerate every
  runtime piece living outside the image (Wine, Waydroid, microG, Firefox,
  pipewire, the Pandora apps) with a per-item packaging strategy (`.deb` vs
  mkosi ExtraTrees vs first-boot component). Output: `productization-gap.md`.
- **D2 — Bake the stable pieces.** Package the most static runtime pieces first
  (Firefox via Mozilla `.deb`, Wine incl. `wine32:i386`) into the image build.
  *Gate:* build produces an image with these baked; loop-mount verify confirms
  presence. `RISK: PARITY` — branch only, never live-applied.
- **D3 — Bake Waydroid + microG** reusing the proven six-fix sequence + the
  microG-via-waydroid_script path (per the separate microG work order; if that
  hasn't run, stage VANILLA + document microG as a first-boot step). *Gate:*
  loop-mount shows components staged.
- **D4 — Full consumer-readiness image.** Produce a fresh image artifact + run
  the verification script (UKI cmdline check + rootfs contents). *Gate:* image
  builds clean, verify passes. Artifact path reported for the architect to
  flash-test. `RISK: PARITY` — explicit human review required before any flash.
- **D — Backlog generator (never idle):** package remaining runtime pieces one
  per branch; then write the full `CONSUMER-READINESS.md` closeout; then build
  reproducible-build tooling, image-diff tooling, a first-boot self-test, and a
  flash-and-verify script the architect can run. Defensible default for any
  packaging fork: prefer `.deb` for app-level pieces, mkosi ExtraTrees for
  runtime blobs, first-boot component for anything large/licensed.

### Lane E — Dev overlay (per-box) + housekeeping
- **E1 — Housekeeping (low risk, do first in lane).** Propose a static DHCP
  reservation for `.180` and a hostname change as a **documented, gated**
  change (may require a reboot → therefore NOT applied unattended; write the
  steps for the architect to apply). Set hostname only if doable without
  reboot; otherwise document. Output: `housekeeping.md`.
- **E2 — Dev overlay (per-box, NOT in consumer image).** Author a reproducible
  `dev-overlay/setup.sh` that stands up on `.180`: a terminal entry in the
  shell dock, Node + `claude` CLI, git, both repos, toolchains (Rust/cargo +
  wasm32, npm, mkosi env), and Anthropic API egress. *Gate:* the script is
  idempotent and documented; (apply-to-`.180` is gated for the architect — do
  not run it live unattended, since it mutates the reference box). 
- **E3 (stretch) — Document the overlay** as the seed of a future shippable
  "developer profile," with the explicit note that it stays OUT of the lean
  consumer image for now (architect decision).
- **E — Backlog generator (never idle):** harden the overlay script
  (idempotency tests, uninstall path, version pinning); write the
  developer-profile design doc; script the static-lease + hostname change as a
  ready-to-run (but human-applied) playbook; document the full `.180` bring-up
  from bare metal. Authoring only — never live-apply to `.180` unattended.

---

## 4. GATE PROTOCOL (every sprint, every lane)

1. Work on `sprint/<lane>/<slug>`. Never commit to `main`.
2. Run the lane's own QA. Write the result in the established YES/NO checklist
   style.
3. Push the branch. Write a PR-style description (what changed, why, risk
   flag, how it was verified).
4. Append a sprint entry to `OVERNIGHT-STATUS.md` (template §8).
5. Pull the next queue item. Repeat.
6. **No merges to main by any sub-agent or by the orchestrator.** The lone
   exception is Lane C landing the architect-ratified **AUTO tier** under the
   combined-QA gate (`merge-autonomy-policy.md`). C prepares the REVIEW/BLOCKED
   set; the human disposes of those. Everyone else: branch + report only.
7. **Never block on a decision.** Hit a fork → pick the defensible default,
   build it, log it in `DECISIONS NEEDED`, move on (Anti-Idle R2). A halted
   agent awaiting instruction is the worst outcome of the night.
8. **Before every commit:** stage only named paths (never `-A`/`.`), run the
   secret-scan guard, and update the relevant `CLAUDE.md` in the same commit.
9. **After push:** record the independent CI result (P-5) in the sprint entry
   alongside the lane's own QA. If CI is red but self-QA was green, that gap is
   itself a finding — flag it.
10. **Tag risk honestly:** stamp `RISK: SECURITY` / `RISK: LICENSE` /
    `RISK: PARITY` where they apply; these never auto-anything — they wait for
    the human.

---

## 5. ORCHESTRATION MECHANICS

- After pre-flight, spawn the five lanes as concurrent sub-agents (background
  Tasks / agent team — whatever parallel mechanism this CC build provides),
  each handed its lane brief + queue + the Prime Safety Contract.
- **If true parallelism isn't available**, run lanes round-robin: one sprint
  per lane per cycle, cycling A→B→C→D→E. This preserves breadth and keeps
  utilization high without idle waits.
- Monitor: poll sub-agent status; when one reports a finished sprint, append
  its entry to `OVERNIGHT-STATUS.md` and let it pull its next item.
- You hold NO merge authority. Your job is dispatch, collection, and the
  consolidated report — not integration into main.
- **Throttle rule:** if two lanes ever report edits to the same file (a
  contention escape), pause the later one, record the conflict, and serialize
  them. Contention should be impossible given §2, but enforce it anyway.
- **Utilization:** keep all lanes busy. If a lane exhausts its queue (including
  stretch items), have it write documentation/tests for its subsystem rather
  than idling, or pick up the next obvious task *within its owned directories*
  and flag it as unplanned.

---

## 6. RISK TIERS (how unattended each thing may run)

- **GREEN (run freely unattended):** all branch-only authoring, compiles,
  dev-context builds, C's read-only triage and previews, D's image builds on a
  branch, E's script authoring, docs/tests.
- **AMBER (run, but reversible + health-checked):** A1's live deploy to `.180`
  (auto-rollback on failure; mute/unmute is reversible). This is the only
  live-mutation of the reference box permitted unattended, and only because it
  rolls back.
- **RED (stage only, never live-apply unattended; flag for human):** anything
  `RISK: PARITY` (D2/D3/D4 images), `RISK: SECURITY` (any change to permissions/
  auth/signers/AppArmor/audit path), `RISK: LICENSE` (questionable new dep),
  `.180` lease/reboot (E1), running E2's overlay against `.180` live, and any
  flash. Build and stage these; the architect applies them with eyes open.

---

## 7. CONSOLIDATED MORNING REPORT — `OVERNIGHT-STATUS.md`

Maintain continuously. Per sprint entry:
```
### [lane][sprint-id] <slug>     <timestamp>
Branch:        sprint/<lane>/<slug>   (pushed: yes)
Self-QA:       [PASS / FAIL]  — <one line>
CI (indep.):   [GREEN / RED / n-a]  — <P-5 result; flag if it disagrees with self-QA>
Secret scan:   [CLEAN / BLOCKED]
Docs updated:  [yes/no — which CLAUDE.md]
Risk:          [GREEN / AMBER / RED: PARITY / RED: SECURITY / RED: LICENSE]
Changed:       <dirs/files, high level>  (staged by name, never -A)
Verified by:   <how>
Merge rec:     [ready-to-merge in order N / hold: reason]
Notes/blockers:<...>
```
End the doc with two human-facing sections, kept current:
```
## READY TO MERGE (architect sign-off required) — recommended order
1. <branch>  (lane, risk, why first)
2. ...

## DECISIONS NEEDED FROM ARCHITECT
- <e.g. NR-2 exact phone aspect ratio>
- <e.g. apply E1 static lease + reboot?>
- <e.g. flash D4 image for parity test?>
```

---

## 8. FIRST ACTIONS (in order)

1. Pre-flight in order: P-0 (save the control system — literally first), P-1,
   P-2, P-3, P-4 (secret-scan guard, proven to block), P-5 (CI-on-push),
   P-6 (resource guard), P-7 (.180 safety net). No lane commits before P-4 is
   proven to block.
2. Spawn lanes A–E with their queues (or begin round-robin).
3. Lane order-of-first-sprint priority if you must stagger spawns:
   **A1 → E1 → C1 → D1 → B1** (A protects+proves the most valuable unproven
   work; E1/C1/D1 are cheap planning/housekeeping that unblock later sprints;
   B1 is self-contained and can start anytime).
4. Begin the loop. Append every result to `OVERNIGHT-STATUS.md`. Merge
   nothing. Surface everything.

---

## Orchestrator end-of-night report format

```
Overnight Orchestration

Pre-flight:
  Control system committed + pushed:    [YES/NO  branch]
  .180 baseline captured:               [YES/NO]
  Toolchains confirmed:                 [YES/NO]

Lanes (sprints completed / attempted):
  A control:        [n/m]   branches: [...]
  B android-window: [n/m]   branches: [...]
  C integration:    [n/m]   branches: [preview/...]
  D productization: [n/m]   branches: [...]
  E dev-overlay:    [n/m]   branches: [...]

Reference box .180:
  Still healthy / desktop up:           [YES/NO]
  Any live mutation? rolled back?:      [...]

Merges to main:                         [AUTO-tier only, by Lane C, each CI-gated; REVIEW/BLOCKED = ZERO]
AUTO merges landed / reverted-on-red:    [n / m]
Secrets leaked to any remote:           [MUST BE ZERO — scan guard active?]
Disk floor ever breached:               [no / yes — action taken]
.180 still healthy / desktop up:        [YES/NO]
Branches awaiting sign-off:             [count]
RED items staged (PARITY/SECURITY/LICENSE): [list]
CI disagreed with self-QA on:           [branches, if any]
Decisions needed from architect:        [list]

OVERNIGHT-STATUS.md path:               [...]
```
