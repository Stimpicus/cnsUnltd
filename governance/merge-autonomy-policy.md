# MERGE-AUTONOMY POLICY — Pandora / ElpisOS
## A standing rule so the architect isn't the bottleneck on 127 branches/week

**Status:** for architect ratification. Once ratified, the crunch-time integrator
lane operates under it; future weeks the AUTO tier lands automatically and the
architect sees only the REVIEW set + a post-hoc digest.

---

## THE PRINCIPLE THAT MAKES THIS SAFE: merge ≠ ship

The reason "no agent merges to main" was a hard rule is the fear that an
auto-merge could silently break the precious things — parity, the trust boundary,
a working reference box. But notice **what merging actually does: it changes
`main`. It does not deploy anything.** Every dangerous operation lives *downstream*
of merge and stays independently gated:

- **Flashing a consumer image** — gated (and there's no build path yet anyway).
- **Applying anything to the reference box** — gated, attended, reversible.
- **Deploying the bridge / shell** — gated.
- **The security cuts** — gated.

So a Lane-G device handler merged to `main` ships to exactly nobody until someone
builds an image (gated) and flashes it (gated). That gap is the safety margin.
**Auto-merge is safe precisely for the tier of work that (a) can't break the build
and (b) has no live-apply component** — because the worst case of a bad auto-merge
is "main's CI goes red and we revert," not "the reference box is bricked."

This policy delegates a *constrained slice* of merge authority to the integrator,
under tight gates, while keeping the architect as the authority on everything that
touches the boundary. **The architect is not giving up control — they are
exercising it by setting policy once instead of 127 times,** and can revoke or
retune the tier definitions anytime.

---

## THE STANDING AUTHORIZATION

The integrator may merge a branch to `main` WITHOUT per-branch sign-off **iff ALL**
of these hold (TIER 1 / AUTO):

1. **Deterministic merge:** a linear tip that contains its stack, OR independent
   single-commit branches, OR a fan-out whose only conflicts are **mechanical
   unions** (a registry line, a test-glob, a doc row) — no semantic conflict
   requiring judgment.
2. **Independently CI-verified green** (build + full test suite via `ci-verify.sh`),
   not merely self-reported QA.
3. **Secret-scan CLEAN.**
4. **Docs updated in-commit** (relevant `CLAUDE.md` current).
5. **No risk tag** — NOT `RISK: SECURITY`, `RISK: PARITY`, or `RISK: LICENSE`.
6. **Does not touch the trust boundary** — no auth/OIDC, no signer/signing path,
   no polkit/sudoers/AppArmor, no consent/`allowedSigners` logic, no network
   bind/exposure.
7. **Does not touch boot/image/parity** — no change to install behavior, UKI,
   bootloader, or first-boot; no image-bake config altering the shipped image.
8. **Additive in nature** — new files, new tests, new device handlers/profiles
   *behind the unchanged authorizer*, new docs — not a rewrite of core dispatch,
   auth, or boot control flow.
9. **No live-apply/deploy component** — merging changes `main` only.

Fail ANY criterion → it is NOT auto-mergeable. It goes to TIER 2 or TIER 3.

---

## THE TIERS

**TIER 1 — AUTO** (integrator merges under the standing authorization above; the
architect reads a post-hoc digest, does not pre-approve). The high-volume,
low-stakes bulk: test suites, oracle/robustness hardening, device handlers behind
the unchanged gate, build/verify *tooling and docs*, window-rule config, dev-overlay
*scripts* (the merge; the apply stays gated).

**TIER 2 — REVIEW** (hands-on; the architect merges). Anything that:
- carries any `RISK:` tag; or
- touches the trust boundary (auth, signing, polkit/sudoers/AppArmor, consent,
  network exposure); or
- touches boot/image/parity (install behavior, UKI, bootloader, first-boot); or
- is the **foundational trunk merge** (reviewed once because everything rebases on
  it and it carries security-relevant changes); or
- is a fan-out whose conflicts aren't purely mechanical, or which expands the
  device-actuation surface in a trust-adjacent way (graduates to AUTO once the
  pattern is trusted and the relevant boundary fix is deployed).

**TIER 3 — BLOCKED** (cannot merge until a named precondition clears): a missing
environment (image build), an unmet review (a license decision), or a superseded
branch (abandon, don't merge).

---

## INTEGRATOR PROCEDURE (TIER 1 only)

**Canonical form — integrate-then-gate (ratified 2026-06-19 after the first run):**

1. **Validate the gate on a known-green `main` FIRST.** Before trusting `ci-verify.sh`
   for any merge, run it on the current `origin/main` and confirm GREEN. This
   catches gate bugs (e.g. a check that reads tool *stdout* instead of *exit codes*)
   before they can cause a false revert or a false pass. The gate must be a **real**
   build + full test suite (+ `cargo build --target wasm32` for the module) — never
   `bash -n` / partial `tsc`. (This step caught two false-RED gate bugs on the first
   run; it earns its keep.)
2. **Readiness analysis** — confirm each AUTO tip merges cleanly onto **`origin/main`**
   without dragging in a REVIEW/RED commit. A branch built on the REVIEW trunk or on
   an unpushed local-main that carries a RED commit (e.g. a polkit grant) is **not**
   AUTO — it is REVIEW-coupled. Drop it.
3. **Merge the guards FIRST** — the parity-regression harness and the
   security-invariant tests — onto an integration branch off `origin/main`, so they
   are present to check everything after them. Then merge the AUTO-tier lanes in
   dependency order, each as its collapsed tip, using a `union` driver **only** for
   doc files; any non-doc conflict is a semantic one → drop that branch to REVIEW
   (do not hand-edit code/JSON mid-merge).
4. **Gate the integrated HEAD, push only on GREEN.** Run the full real-build+test
   gate on the integrated HEAD (not after each individual merge). Green → secret-scan
   the entire integrated diff, then **fast-forward** push to `origin/main`. This is
   the efficient standing form: it never publishes a red `main`, and a green
   integrated HEAD is a *stronger* compositional guarantee than each merge passing in
   isolation.
   - **RED-case fallback (the one caveat):** if the integrated HEAD comes back RED,
     do NOT push. Fall back to **per-merge CI (or bisect)** to attribute the breakage
     to a specific merge, drop/fix that branch, and re-integrate. The granularity
     cost is paid only when red actually occurs.
5. Produce a **digest**: what auto-merged, the gate result, the final `main` HEAD per
   repo, any branches dropped to REVIEW, and any procedure notes. Post-hoc, not
   blocking.

The integrator never merges TIER 2/3. It may *prepare* them (rebased previews,
combined-QA reports) for the architect, exactly as Lane C does today.

### Standing conflict-resolution authorization (ratified 2026-06-19)
The integrator may auto-resolve **two** narrow, deterministic conflict classes
without dropping the branch to REVIEW:
1. **Doc-file unions** — the `union` driver on documentation files (already
   permitted).
2. **Additive, non-overlapping keys in a structured file** — e.g. two branches
   adding *different* `package.json` script keys (`check:schema` vs
   `verify:host`). The keys must not collide and no value may change; the result
   is mechanically determined. (This was the Lane-S `substrate/package.json` case.)

**This authorization is exhaustive and does not widen.** Overlapping keys, any
value change, reordering with semantic effect, or any conflict requiring judgment
→ still drops to REVIEW. And it grants nothing beyond conflict resolution: the
integrator **does not skip any other part of the SDLC** — the gate, the
secret-scan, the readiness analysis, and the merge-tier criteria all still apply
in full. After any auto-resolution, the gate on the integrated HEAD is the
backstop that proves it was correct.

---

## THE ARCHITECT'S RESIDUAL ROLE (what actually needs you)

- **Review + merge the TIER 2 set** — the genuinely-needs-judgment branches.
- **Apply the gated live operations** — security cuts to the reference box, image builds,
  flashes, deploys — unchanged by this policy.
- **Read the AUTO digest** — post-hoc; spot-check, don't gate.
- **Retune the tiers** whenever you want; this policy is yours to amend.

---

## TONIGHT'S APPLICATION (the 113 + ~14, bucketed)

### pandora
| Lane / branch | Tier | Why |
|---|---|---|
| Lane S — substrate tests/docs (7 indep.) | **AUTO** | Pure tests + docs; independent; CI-green; no boundary touch. |
| Lane F — oracle robustness (tip, contains 10) | **AUTO** | Linear tip; net-positive hardening + 2 real bug fixes; CI-green. |
| `preview/security-invariant-tests` | **AUTO (first)** | Additive guards; merge early so they protect the rest. |
| `hotfix/bridge-bind-loopback` (canonical trunk tip) | **REVIEW** | Foundational trunk; carries the bridge security fixes + the large capability feature. Eyeball once; everything rebases on it. (The *deploy* is separately gated.) |
| Lane A — providers/dispatch (12, fan-out) | **REVIEW** | Mechanical unions, but expands the device-actuation surface (trust-adjacent). Graduates to AUTO once trusted + the H-1 bind is deployed. |
| `preview/feature/installer-ux` | **REVIEW** | Installer-adjacent UI; confirm it's shell-UI-only (install mechanics live in the parity base). Likely graduates to AUTO. |
| `elpis-run-apk-desktop`, `capability-descriptor-controls`, `sprint/A/bootstrap`, `feat/clipboard-sync`, `demo/command-dispatch-poc`, `restructure/pandora` | **ABANDON** | Superseded / subsumed / already-on-main / stale ancestors. |

### elpis-os (private now — public-trajectory, so every AUTO merge is still secret-scanned)
| Lane / branch | Tier | Why |
|---|---|---|
| Lane G — device handlers (tip, contains 31) | **AUTO** | Textbook: registration-only behind the unchanged authorizer; clean-room; 292 tests; no trust surface. |
| Lane D — tooling/docs (13 of 16) | **AUTO** | Build/verify *scripts + docs*; several are net-positive security guards; CI-green. |
| Lane B — wayfire window rules (tip, contains 8) | **AUTO** | Additive config/rules + own validator; no privilege surface. |
| Lane E — dev-overlay (base + 3) | **AUTO** | The *merge* of overlay scripts + CLAUDE.md note is additive; applying to the reference box stays gated. |
| `preview/qa/parity-regression-harness` | **AUTO (first)** | Additive QA; merge first so the parity guard is live on `main`. |
| `preview/security-invariant-tests` | **AUTO (first)** | Additive invariant guards; merge early. |
| parity-fix base (`consumer-hardening` / `device-library-expansion`) | **REVIEW** | RED: SECURITY+PARITY — the polkit grant widens an install permission; not on origin/main. Review the grant + postinst. Reconcile device-library-expansion's 4 net-new YAMLs with Lane G. |
| `sprint/D/pandora-apps-extratrees` | **REVIEW** | Carries `RISK: PARITY` (image staging recipe) — review before any build. |
| `sprint/D/bake-firefox-wine`, `bake-waydroid-microg` | **BLOCKED** | `RISK: LICENSE` (libndk) + `RISK: PARITY`; need license review + a VM image build that doesn't exist yet. |
| Lane G `coverage-report-docs` / `library-coverage-expansion` / `library-test-hardening`; the 11 stale ancestor locals | **ABANDON** | Re-authored into the G tip / ancestors of origin/main. |

### The net effect
Of the ~127 branches, the **bulk auto-merge** (Lanes S, F, G, D-13, B, E, the three
test/guard previews), leaving the architect a **REVIEW set of ~5 decisions**: the
pandora trunk tip, Lane A, installer-ux, the parity-fix base + its polkit grant,
and the extratrees recipe — plus **2 BLOCKED** bakes waiting on the image env +
license call. 127 sign-offs → ~5 judgment calls.

---

## FOLDING INTO CRUNCH-TIME

Reference this policy from the master orchestration WO so the integrator (Lane C)
applies it every run: Lane C keeps producing `READY-TO-MERGE.md`, but now it also
**tags each branch AUTO / REVIEW / BLOCKED per the criteria above** and, with the
standing authorization, *executes the AUTO merges under the combined-QA gate*
instead of only preparing them. The architect's weekly load becomes: the REVIEW
set + the digest. The hard rules are unchanged — no merge of REVIEW/BLOCKED without
sign-off, combined-QA gate on every AUTO merge, revert-on-red, and nothing touches
the reference box or builds/flashes an image without the architect.
