# What "green" now means — Sprint-1, QA/Release-Eng (Div 3, lead)

**WO:** `work-orders/claude-code-WO-sprint-1-green-means-green.md` (crunch nonce `478d4c58`)
**Section:** the QA/Release-Eng lens. Companion artifact:
[`ci-e2e-ephemeral-spacetimedb.yml`](./ci-e2e-ephemeral-spacetimedb.yml).
**Status of this deliverable:** the CI job is **authored and ready-to-run**; its first real
green must be produced by **CI**, not asserted here (see §4 — I do not have a SpacetimeDB +
browser environment in this authoring session, and *green is earned by the gate, never
reported by the division*). No overclaim: nothing below says "the suites pass" — it says
"here is what a pass will certify, and here is what it will not."

---

## 1. The gap this closes
Product CI today (`pandora/.github/workflows/ci.yml`) is **build-only**: it compiles the
workspace + a few typechecks/builds, runs **no integration tests**. So every "green is earned"
claim is, for the call path, *asserted not earned*. The proposed `f2f-e2e` job runs the three
real end-to-end suites against a live, ephemeral `face-to-face` SpacetimeDB module.

## 2. What a green `f2f-e2e` run CERTIFIES
A pass means, against a freshly-published module on a real SpacetimeDB instance, across
**Chromium and Firefox** (Edge where a runner provides it):

- The **1:1 call path** works end-to-end (`two-session-call.spec.ts`): two distinct
  identities connect, add each other as contacts, place a call, accept, and a **live remote
  video tile renders on each side** — i.e. the `RTCPeerConnection` actually reached
  `connected`, not merely that the UI rendered.
- The **group call path** works (`group-call.spec.ts`): a multi-party session negotiates
  pairwise and media flows.
- The path is **browser-engine-agnostic** (`webrtc-cross-browser.spec.ts`).
- Therefore these reducers + their delivery are exercised for real, not just compiled:
  `register_presence`, contact graph (`send_contact_request`/`accept_contact_request`),
  `initiate_session`, `accept_session`, `send_signal` relay, `confirm_connected`,
  `leave_session` — plus the `session` / `session_participant` / `signal` **subscriptions**
  that drive call setup.
- It also pins the **caller-side deadlock fix** (`KNOWN_ISSUES.md` I-01) as a standing
  regression guard.

**Net:** "green" graduates from *compiles* to *the call path is tested on a real module +
secret-clean* (secret-scan is Infra's companion section of this same sprint). That is the
trustworthy-green bar this division exists to hold.

## 3. What a green run does NOT certify (so it is never overread)
- **Not a security gate.** The job runs the module in `dev_mode=true` (OIDC issuer/audience
  checks skipped) so the native-identity provider can mint tokenlessly in CI. It proves
  *function*, not the auth/trust-boundary properties. Those are separate (the ElpisOS
  enforcement spec, Sprint-2) and must not be inferred from this green.
- **Not media quality.** It asserts a remote track *renders*, not its resolution/bitrate/latency.
- **Not scale / load / soak.** Single session(s), `workers:1`, serial.
- **Not substrate parity in this job.** The identical specs also pass on the **Postgres**
  substrate (per the web-client README); this job pins `VITE_SUBSTRATE=spacetimedb`. A green
  here is the SpacetimeDB leg only — see §5 for the cheap matrix extension that would make
  green mean *both substrates*.
- **Not the full cross-browser matrix on hosted CI.** Edge auto-**skips** on hosted Linux
  (`launchOrSkip`); a green from a hosted runner certifies Chromium+Firefox. Edge is certified
  only where a runner provides it (self-hosted / Windows).

## 4. Execution status — DEFERRED to CI (honest)
I authored and statically validated the job against the *real* repo wiring (verified by
reading `pandora@6b603a4`): the three spec files exist; `playwright.config.ts` has no
`webServer` (so the job starts the dev server itself), `retries:3`/`workers:1`; the dev server
is `https://localhost:5173` via `@vitejs/plugin-basic-ssl` with `/v1`→`:3000` proxy;
helpers default `APP_URL=https://localhost:5173`, are headless unless `HEADED=1`, and inject
synthetic media; the module declares `spacetimedb = "2.2"`. I **cannot run** SpacetimeDB +
browsers in this authoring session, so I do **not** claim a pass — the job *is* the
deliverable and CI is its execution environment. First green → surfaced to the EA over the bus
when it runs.

## 5. Fork-never-block — the real obstacles, both branches assessed (not an idle wait)
- **CLI/module version skew (most likely first-run break).** The module is `spacetimedb 2.2`;
  the CLI must publish that ABI. *Branch A:* pin `STDB_VERSION` to the team's known-good 2.2.x
  (the job's single knob) — recommended. *Branch B:* if no 2.2.x CLI publishes it cleanly,
  the surfaced blocker is a module/CLI version bump (a Development decision), not a CI defect.
  **Surface, don't stall.**
- **WebRTC timing flake on shared runners.** *Branch A:* rely on the config's `retries:3` +
  serial `workers:1` (already tuned for same-machine WebRTC) on hosted runners — recommended
  to try first. *Branch B:* if it proves persistently flaky on hosted CPU, move the job to a
  **self-hosted runner** (more CPU; also unlocks real Edge). Both are viable; this is a
  runner-capacity tradeoff for the founder/Infra, not a reason to abandon the e2e gate.
- **Substrate-matrix extension (optional, cheap).** Add a `strategy.matrix.substrate:
  [spacetimedb, postgres]` axis so green means *both* substrates — turns the portability claim
  into a tested one. Out of this sprint's minimal scope; flagged as the natural next increment.

## 6. The Sprint-3 seam — JOIN subscriptions still needing live-`onApplied` confirmation
A green `f2f-e2e` proves the call path *gets the rows it needs* — but it does **not** isolate,
per subscription, whether `onApplied` fires **natively** for a JOIN-filtered query versus the
client engaging `subscribeWithFallback` (full-table + client filter). That distinction is the
open item in `CLAUDE.md` ("retire the fallback once verified") and is the Sprint-3 seam:

- **Already resolved (do not re-litigate):** `session_participant` uses the **full-table**
  subscription on purpose — its self-join *applied* but did **not** deliver peer-row UPDATEs on
  SpacetimeDB 2.4.1, deadlocking the caller (`KNOWN_ISSUES.md` I-01). Not a JOIN to "confirm";
  it is deliberately not a JOIN.
- **Simple WHERE, fine:** `contact`, `contact_request`, and `signal` (Identity-direct / simple
  `:sender` predicates) — no JOIN risk.
- **JOIN-filtered, live `onApplied` NOT yet independently confirmed (the seam to close):**
  `session` (JOIN through `session_participant`), and the user-scoped JOINs (own / contacts' /
  session-participants' / context-sharing `user` records). The e2e green is *consistent with*
  these working (the call path completes), but Sprint-3 should add a **targeted per-JOIN probe**
  that asserts native `onApplied` fired (not the fallback), then retire the fallback path for
  each confirmed query — or, when SpacetimeDB issue **#2810** lands, move user-data tables to
  `client_visibility_filter` (RLS) and delete the JOIN-vs-fallback question entirely.

**Mark for Sprint-3:** one e2e assertion (or a thin harness) per JOIN-filtered subscription
that distinguishes *native onApplied* from *fallback engaged*. Until then, "green" includes an
honest asterisk: the JOIN subscriptions are proven *sufficient for the call path*, not proven
*native-delivering*.
