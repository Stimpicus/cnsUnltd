# Development — Founding-Cycle Branch Inventory (read-only)

**Authored:** 2026-06-19 by devOpsClaude (Development, Div 1), founding cycle.
**Method:** read-only `git` introspection of the two product repos. Nothing
changed in either repo. Everything below is cited by branch + short commit so the
board can verify without this artifact copying any product code.
**Heads at time of read:** `pandora` `origin/main` @ `a34a427`; `elpis-os`
`origin/main` @ `6618608`.

This is the supporting detail behind `status/founding-cycle.md`. It catalogues
**what landed (AUTO)**, **what is approved-but-unlanded (REVIEW)**, and **what is
BLOCKED**, per `governance/merge-autonomy-policy.md` ("TONIGHT'S APPLICATION") and
the decision ledger (D-001…D-008).

---

## 1. pandora (private) — `origin/main` @ `a34a427`

### LANDED (AUTO tier, integrated by the EA/integrator)
The integrator merged exactly the two AUTO lanes the policy predicted, guards
aside. CI-green, additive, no trust-boundary or boot/parity touch.

| Lane / set | Representative tips | Tier | Notes |
|---|---|---|---|
| Lane S — substrate tests/docs (7 indep.) | `sprint/S/build-verify` `a64452f` … `sprint/S/verify-target` `050d564` | AUTO | reducer/client test harness, schema↔client consistency check, substrate-scoped `CLAUDE.md`, one-command host verify target. |
| Lane F — oracle robustness (linear tip) | `sprint/F/failpath-hardening` `b36f46e` → `sprint/F/retry-loop-coverage` `5b6036d` | AUTO | parser fuzz, bounded transient-only retry, structured secret-safe logging, 2 real bug fixes (`substrate-query-resilience`). |

### REVIEW — approved-process / awaits the **architect's** merge (NOT landed)
This is the high-value, trust-adjacent set. **The trunk is here, and everything
in Lane A rebases on it.**

| Branch | Commit | Why REVIEW (per policy) |
|---|---|---|
| `hotfix/bridge-bind-loopback` | `956fdf7` | **Foundational trunk tip.** Carries the H-1 bridge loopback-bind security fix + the large capability feature. Everything rebases on it → reviewed once. (The bind *deploy* is separately gated.) |
| `feature/capability-descriptor-controls` | `d2fa794` | The capability-descriptor device-control system (WIP, compiles clean). Base of the entire Lane A fan-out. Expands the device-actuation surface → trust-adjacent. |
| Lane A fan-out (`sprint/A/*`, ~20 branches) | e.g. `surface-contract` `d9b1df5`, `provider-set` `b335210`, `provider-encoder-tests` `7219ffd`, `paired-reconcile` `08ef5b9`, `cast-construct` `1e605bb` | One provider/dispatcher file per device family (WiZ, Kasa, AVR, Sonos, Chromecast, Roku, LG webOS, Apple TV, Fire TV, Hue, Xbox, Samsung 2nd TV), each honestly stamped `live\|partial\|template`, + encoder tests + surface-contract validation. Mechanical unions, but expands actuation surface → REVIEW; graduates to AUTO once trusted + the H-1 bind is deployed. |
| `feature/installer-ux` | `4780073` | Lane I (installer) — design doc + start-install watchdog. Installer-adjacent UI; split pure-UI (AUTO-eligible) from install-mechanics (REVIEW). |
| `preview/security-invariant-tests` | `f03abb6` | Additive guards (bridge-bind + secret-scan regression). Policy marked it AUTO-first, **but it did not land** — it is REVIEW-*coupled* to the bridge-bind fix that sits on the REVIEW trunk (correct per integrate-then-gate readiness analysis: a branch built on the REVIEW trunk is not AUTO). Consequence: pandora `main` currently carries **less** regression protection than elpis-os `main`. |
| `sprint/tierB/1A-bind-runbook` | `fafaa5e` | H-1 bridge bind deploy/rollback runbook (docs, tier-B). |

### ABANDON (superseded / subsumed / stale — per policy)
`feature/elpis-run-apk-desktop` `2de8420`, `restructure/pandora` `64b868e`,
`demo/command-dispatch-poc` `77a115a`, `sprint/A/bootstrap` `fbefec5`, and the
`preview/feature/*` mirrors of the above. Do not merge; let them age out.

### Sibling-division work in this repo (NOT Development's — read-only awareness)
| Branch | Commit | Owner | Adds (by path) |
|---|---|---|---|
| `preview/audit-cycle-1` | `f22a284` | Security/Red-Team (Div 2) | `audit-inventory.md`, `protocol-audit-findings.md`, `write-to-effect-map.md` — new GAPs H-16/17/19 (write-to-execute lens). **This is the threat-informed input to Development's next sprint.** |
| `feature/research-living-article` | `99e43d9` | Research/R&D (Div 7) | `docs/research/write-to-execute/ARTICLE.md` v0.1.0 (PRIVATE — never leaves `pandora`). |

---

## 2. elpis-os (private now — public-trajectory) — `origin/main` @ `6618608`

### LANDED (AUTO tier — guards FIRST, then the lanes)
Textbook integrate-then-gate: the two guards merged first so they protect
everything after them.

| Lane / set | Tier | Notes |
|---|---|---|
| `preview/qa/parity-regression-harness` `0440708` | AUTO (first) | parity guard live on `main`. |
| `preview/security-invariant-tests` `bb4afc4` | AUTO (first) | security-invariant guards live on `main`. |
| Lane G — device handler library (tip `sprint/G/firetv-adb-auth-stream` `a0982b1`) | AUTO | registration-only **behind the unchanged authorizer**; clean-room handlers + per-handler AppArmor profiles (`apparmor/pandora-handler-*`); no trust surface. The library's consent posture (one confined profile per handler) is a genuine strength. |
| Lane B — wayfire window rules (`wayfire-duplicate-rule-detection` `ac23075`) | AUTO | additive rules + own validator. |
| Lane E — dev-overlay/repo-sync (`sprint/E/repo-sync` `96c845f`) | AUTO | overlay *scripts* (the apply to `.180` stays gated). |
| Lane D — productization tooling (13 merges, `android-smoke-harness` `94bcb7c` … `verify-image` `6618608`) | AUTO | build/verify **scripts + docs**: gap manifest, image-diff, flash-and-verify, firstboot self-test, consumer go/no-go gates, libndk license audit, build provenance, productization closeout. The *bakes* themselves are separate (below). |

### REVIEW / BLOCKED — awaits the **architect** (NOT landed)
| Branch / set | Commit | Disposition | Why |
|---|---|---|---|
| `preview/feature/consumer-hardening` + `preview/feature/device-library-expansion` | parity-fix base (`7ad628c` lineage) | **REVIEW — D-007 MERGE-APPROVED, not yet merged** | RED: SECURITY+PARITY — the install **polkit grant** widens a permission. D-007 approved the merge (code only; bind deploy gated); the human performs the REVIEW merge; **polkit-grant scope verification is DEFERRED to Security audit item #6** (carried-forward), not skipped. |
| `sprint/tierB/1B-sign-group` `d836300`, `1C-audit-append-only` `fd57a3a`, `1D-firewall-caps` `c503912` | — | REVIEW | Tier-B trust-boundary work (signing group, append-only audit, firewall caps) — `RISK: SECURITY`, mandatory human review. |
| `sprint/D/pandora-apps-extratrees` | — | REVIEW | `RISK: PARITY` — image-staging recipe; review before any build. |
| `sprint/D/bake-firefox-wine`, `bake-waydroid-microg` | — | **BLOCKED (D-008)** | `RISK: LICENSE` (libndk not redistributable) + no mkosi image-build path exists. Precondition unmet. |

---

## 3. The crunch-time template (Development's operating instrument)

`work-orders/claude-code-MASTER-orchestration-overnight.md` — the standing template.
- **Lanes:** A (control), B (windowed Android), C (integration/triage + AUTO merge),
  D (productization), E (dev overlay) standing; F/G/H/S added on the first run;
  **Lane I (installer) standing per D-006.**
- **Discipline:** Prime Safety Contract (merge ≠ ship, stay-in-lane, secret-scan,
  no `.180` reboot, RISK tags) + Anti-Idle mandate (self-refilling backlogs;
  fork-never-block).
- **Merge discipline:** `governance/merge-autonomy-policy.md` (D-001) +
  integrate-then-gate (D-002) + the exhaustive conflict-resolution authorization
  (D-003).
- **Run state:** executed **once** (the overnight crunch — the run that produced
  the ~127 branches above and that the policy's "TONIGHT'S APPLICATION" table
  bucketed). The AUTO tier is integrated in both repos. The **standing loop is not
  yet turning** (D-014: no division CC sessions, EA anchor day untuned).

---

## 4. One-line reconciliation

Of the post-crunch branch population: the **AUTO bulk has landed** (pandora S+F;
elpis-os G+B+D+E + both guard sets), exactly as the policy bucketed it. What
remains is a **coherent REVIEW set the architect has not yet disposed of** — and
in pandora that set is *the trunk plus the entire device-control product*. That is
the central fact of Development's current position (see `status/founding-cycle.md`).
