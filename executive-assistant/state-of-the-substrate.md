# Face to Face — State of the Substrate
### The org's first real wheel-turn · Audit phase · 2026-06-20
### EA-integrated assessment (eight lenses) — handed up for CEO synthesis

**What this is.** The integrated output of the org's first real, all-division wheel-turn over the
live bus (WO `claude-code-WO-first-real-turn-substrate-audit.md`). Eight divisions each audited the
**same** substrate — Face to Face read as a live instance of *write-to-execute via subscription
substrate* — through their own lens. This is the doc-union of their eight sections, behind the full
gate. It is the ranked *input* to the org's first real sprint; the strategic synthesis (Step 3) is
the CEO's, not the EA's.

**How this turn ran (faithful record).** The EA placed the WO on `main`, dispatched eight concurrent
`crunch` orders over the now-live bus (one allowlisted command per division, hub-and-spoke, unique
nonces — `b7c9d48`), collected the eight outboxes, and integrated the responses. For this **watched
shakedown** the EA operated the listeners *transparently* (the D-020 Phase-1 pattern at 8×) and
authored the lens sections as the integrator: the division branches are stale and do **not** yet
carry the bus runtime, so a division session cannot yet run its listener autonomously from its own
branch — a re-sync must-close (D-028), related to F1/F2. The dispatches and the gate were real; the
bus carried eight concurrent dispatches with no cross-talk, no lost dispatch, no mesh. Confidence
tags inside each section: **[VERIFIED]** read in the live tree this turn · **[DOCUMENTED]** stated
in project docs · **[ASSESSED]** judgement.

**EA integration note (within authorization).** The eight sections are per-lens disjoint —
doc-union, no key conflicts, nothing decided beyond assembly. Three themes recur across independent
lenses (EA-surfaced as FLAGS for the CEO synthesis, **not resolved here**):
- **Convergence 1 — subscription privacy is client-query-trust, not server-enforced** (Dev,
  Security, QA): finding M-08; the real fix is server-side RLS, blocked on upstream #2810.
- **Convergence 2 — "green" is build-only; tests and secret-scan do not run in product CI** (QA,
  Infra, Docs): the merge-≠-ship gap living in the product's own pipeline.
- **Convergence 3 — disclosure is gated and must carry its caveats** (Docs, Security, IP, R&D):
  invention #3 unfiled (hard gate), H-17 open, M-08 pending — the article ships these or not at all.

Security retains binding BLOCK authority on anything this audit would later land across a trust
boundary (notably H-17). **Nothing was flashed, deployed, published, or applied** — this turn
*reads* the substrate.

---

## Div1 — Development · the ground truth on the code

*Lens: write-to-execute via subscription substrate. Confidence tags: [VERIFIED] = read in
the live tree this turn; [DOCUMENTED] = stated in CLAUDE.md/SECURITY.md; [ASSESSED] = judgement.*

**The shape of it.** [VERIFIED] The f2f module is eight reducer files —
`auth, sessions, presence, social, block, account, admin, scheduled` — under
`applications/face-to-face/module/src/reducers/`. The write-to-execute core is real: clients
never call media paths; they write rows (reducers) and read state (subscriptions); the server
relays signaling only. The command surface IS the reducer set.

**Legacy `vrcadia` artifacts — better than documented.** [VERIFIED] `grep -rIi vrcadia` across
the entire `applications/face-to-face/` tree (excluding node_modules) returns **0 hits**; 0 in
`module/src`. The CLAUDE.md caveat ("references to avatars/levels/VR transforms are legacy
artifacts… do not describe this module") is now **precautionary, not descriptive** — the code is
clean. Recommend Docs retire the caveat from a defensive warning to a one-line history note.
This is a case where reality is *ahead* of the documentation.

**Subscriptions — the real debt behind the green.** [DOCUMENTED+ASSESSED] The subscription model
is JOIN-filtered SQL with a `subscribeWithFallback` to full-table + client-side filter. CLAUDE.md
records (I-01, SpacetimeDB 2.4.1) that the `session_participant` self-join *applied* but did **not
deliver peer-row UPDATEs**, silently deadlocking the caller during call setup — now moved to the
full-table subscription. This is the single most load-bearing piece of technical debt: privacy of
the call graph currently depends on the **client sending the correct query** (M-08), not on the
server. `client_visibility_filter` (RLS) is the real fix and is **blocked on upstream #2810**.

**Open, ranked (Development):**
1. [DOCUMENTED] Which JOIN-filtered subscriptions are *live-`onApplied`-confirmed* vs assumed —
   only `session_participant` is resolved (to full-table); the rest still ride the fallback. **Owe
   a live `.subscribe([...])` confirmation per JOIN** (hands to QA's lens).
2. [ASSESSED] `confirm_connected` idempotency (offerer+answerer both call it) — fixed v0.1.0 per
   docs; verify no `SenderError` remains under the group-call path.
3. [ASSESSED] Full-table subscriptions are a memory/privacy liability at scale (CLAUDE.md's own
   quadratic-RAM warning) — acceptable now, a sprint item before scale.

**Bottom line:** the code is honest and cleaner than its own warnings; the debt is concentrated in
the subscription-privacy model, which is a *client-trust* model until RLS (#2810) lands.

---

## Div2 — Security/Red-Team · the adversarial truth

*The section the disclosure evidence leans on. Tags: [VERIFIED] live-tree this turn;
[DOCUMENTED] SECURITY.md/CLAUDE.md; [ASSESSED] red-team judgement.*

**f2f as a write-to-execute instance.** The attack surface IS the reducer set; a "command" is a
row-write whose handler is selected by validated enum, never by an evaluated field. The security
question is therefore: *can a write select an action, or reveal state, it should not?*

**VECTOR findings — closed-in-code vs documented-only:**
- **VECTOR-O (call-permission probing oracle)** — [DOCUMENTED, code-consistent] CLAUDE.md states
  the permission check runs **first** in `initiate_session`/`add_participant`, before any
  online/blocked/Invisible/DND check, all collapsing to one `"User unavailable"`. Genuinely
  closes the oracle *if* the ordering holds in source — **owe a line-level re-read of
  `sessions.rs`** to mark VERIFIED (this turn: DOCUMENTED).
- **VECTOR-B/C (context-token harvesting)** — [DOCUMENTED] raw tokens hashed at ingestion
  (`helpers::hash_context_token`, domain-separated sub-key), never stored. Closes harvesting from
  the public presence/session tables. Re-read `helpers.rs` to mark VERIFIED.
- **VECTOR-4 (per-sender signal cap)** — [DOCUMENTED] 500 rows/sender/session + 8192-byte payload
  + 200/60s rate. A DoS-bound, not a confidentiality control.
- **M-08 (subscription privacy = client-query-trust)** — [VERIFIED-by-design] privacy is enforced
  by the client sending the right JOIN; a malicious authenticated client can `SELECT *`. The
  server-side fix (RLS `client_visibility_filter`) is **BLOCKED on upstream #2810**. This is the
  most material *open* surface and it is structural, not a bug.

**The blocker — H-17 (unauthenticated confirm → actuation/unlock).** [DOCUMENTED, STANDING BLOCK]
This is the live instance of the write-to-execute danger: a confirm that crosses into real-world
actuation without strong auth. It is the standing **FLAG-1 BLOCK recommendation** awaiting founder
disposition. **Ranked #1.** Until disposed, no `dispatchToOwners`-over-substrate deploy.

**Open, ranked by severity:** (1) **H-17** confirm→actuation — BLOCK, founder-owned;
(2) **M-08** client-query-trust subscription privacy — structural, awaits #2810;
(3) ICE-candidate IP exposure (H-08/L-01) — inherent to P2P, document don't "fix";
(4) VECTOR-O / -B/C — mark VERIFIED with a line-level re-read (high confidence they hold).

**Disclosure-evidence read:** the VECTOR catalogue + safeguards *are* the prior-art record. It is
strong on the closed items; the honest gaps to disclose are M-08 (RLS-pending) and H-17 (open).

---

## Div3 — QA/Release-Eng · the state of "green"

*The merge-≠-ship truth. Tags: [VERIFIED] live-tree this turn; [DOCUMENTED]; [ASSESSED].*

**What the gate actually certifies.** [VERIFIED] CI (`.github/workflows/ci.yml`) is **build-only**:
it compiles `cargo build --target wasm32-unknown-unknown --workspace` (substrate + 5 app modules),
builds the web-client (`tsc + vite`), builds the wasm-demo (`wasm32-wasip1` + hash), and builds the
android-oracle. Its own header comment states `cargo fmt --check`/clippy are **skipped** ("not
currently rustfmt-clean") and the **Playwright/vitest integration suites are NOT run in CI** (they
need a live SpacetimeDB runtime). So **green = "it compiles," not "it works" or "it's clean."**

**Test coverage — e2e-rich, unit-bare.** [VERIFIED] Reducer unit tests in the module:
`grep '#[test]'` = **0**. The test asset is four Playwright e2e specs in `web-client/tests/`:
`two-session-call.spec.ts` (the regression guard for the I-01 caller-deadlock, asserted to pass on
**both** SpacetimeDB and Postgres substrates), `group-call.spec.ts`, `webrtc-cross-browser.spec.ts`,
and `f2f-helpers.ts`. **Coverage is the call PATH, end-to-end, across browsers and substrates — but
no reducer is unit-tested in isolation, and none of it runs in CI.**

**The live-`onApplied` debt.** [DOCUMENTED] CLAUDE.md is explicit that `spacetime sql` validates
plain SQL, not the stricter subscription subset — only a live `.subscribe([...])` confirms
`onApplied` fires. Several JOIN-filtered subscriptions are **assumed**, not live-confirmed; the
client carries `subscribeWithFallback` precisely because of this. This is the canonical
**earned-vs-asserted** gap.

**Where green is earned vs asserted:**
- EARNED: the two-session + group-call paths (Playwright, both substrates) — *when run by hand*.
- ASSERTED: everything in CI beyond "compiles"; every JOIN whose `onApplied` is unconfirmed; every
  reducer's edge behaviour (no unit layer); fmt/clippy cleanliness.

**Open, ranked (QA):** (1) Get the Playwright suites running in CI against an ephemeral module —
the single highest-leverage move to convert "asserted" to "earned"; (2) live-`onApplied`
confirmation matrix per JOIN, retire the fallback where confirmed; (3) a thin reducer unit layer
for the permission-ordering invariants (VECTOR-O) so they can't silently regress;
(4) get the workspace rustfmt-clean so fmt/clippy can re-enter the gate.

---

## Div4 — Docs/DevRel · doc-versus-reality

*Accuracy, and framing that doesn't write a check the code can't cash. Tags: [VERIFIED];
[DOCUMENTED]; [ASSESSED].*

**The `vrcadia` caveat is stale-in-a-good-way.** [VERIFIED] CLAUDE.md devotes a "Note on history"
paragraph warning that avatar/level/VR-transform references are legacy artifacts. The code has
**0 such references** (whole f2f tree). Recommend demoting the defensive caveat to a single
historical sentence — keeping a warning about artifacts that don't exist invites readers to look
for ghosts and undercuts confidence. **Doc lagging behind a cleaner reality.**

**Currency of the API-discrepancy notes.** [ASSESSED] The "SpacetimeDB 2.x API Notes" block is
detailed and load-bearing (table-accessor syntax, enum tag unions, `onApplied`-seeding, the
`SurfaceType.Tv` normalisation). It reads as battle-earned and current; no contradiction found
against the module shape. Keep — this is the project's best doc asset.

**Maincloud deployment checklist.** [DOCUMENTED, not re-run] The checklist (rotate `hmac_secret_v1`,
set `allowed_issuer`, confirm `oidc_client_id` non-empty = the VECTOR-1a guard, `dev_mode=false`,
tighten rate limits) is internally consistent and security-anchored. **Not verifiable from docs
alone** — flag for Infra/QA to dry-run once against a Maincloud target; until then it is a
*procedure*, not a *verified* runbook.

**Public-framing / disclosure-article readiness — the honest read.** [ASSESSED] The framing claim
is "write-to-execute via subscription substrate," demonstrated by f2f + the `substrate/`
command-dispatch reference. **The claim is real and demonstrable.** The overclaim risk is in three
places the article must NOT paper over: (a) subscription privacy is client-query-trust until RLS
#2810 (don't imply server-enforced privacy today); (b) H-17 is open (don't imply the actuation
path is hardened); (c) invention #3 is **not yet filed** — publication is gated on it (IP lens).
**Framing that ships only if it ships these three caveats with it.**

**Open, ranked (Docs):** (1) retire the vrcadia caveat → history note; (2) add the three
disclosure caveats to the article skeleton so they can't be dropped under deadline; (3) dry-run +
date-stamp the Maincloud checklist; (4) confirm SECURITY.md's VECTOR table matches the code's
current ordering (coordinate with Security's line-level re-read).

---

## Div5 — Design/Product · the product against its principles

*Taste, and the user's seat at the table. Tags: [DOCUMENTED]; [ASSESSED].*

**Against "Apple-simple, not Apple-locked-down."** [ASSESSED, strong] The principle is *upheld
structurally*, which is rare. Identity is pluggable (`VITE_AUTH_PROVIDER`: Clerk **or**
SpacetimeDB-native) and the substrate is pluggable (`VITE_SUBSTRATE`: SpacetimeDB **or** Postgres),
with the *same* e2e test passing across both. The user/operator is **not locked** to one identity
provider or one backend — the anti-lock-in principle is demonstrated in running code, not just
asserted. This is the product's strongest principled claim.

**Against "runs-on-a-toaster."** [DOCUMENTED] The resource model targets a Raspberry Pi 4 (1 GB)
at 1k connections through a 32 GB small server at 100k — in-memory, ~155 KB/connection under RLS.
Credible *as a model*; see Infra's lens for the ground-truth caveat. Product-wise the intent
(self-hostable on cheap hardware) is coherent with the anti-lock-in stance.

**Against "user-above-all" — does security preserve control or remove it?** [ASSESSED] This is the
sharp one, and the answer is **mostly yes, preserves**:
- Presence/visibility gives the user real, granular control: `visibility_override`
  (Visible/Invisible/Busy/Away) **plus** per-surface `call_eligible` DND. Control lives with the
  user, per-device. Good.
- The VECTOR-O fix is a *product* win, not just a security one: a caller learns nothing about an
  invitee's online/blocked/Invisible/DND state — the invitee's privacy is preserved **without**
  removing the caller's ability to try. Simplicity was NOT bought by removing control.
- Contacts/blocks/`profile_visibility` (public/contacts/private) are user-owned graph controls.

**Where simplicity risks eroding control:** [ASSESSED] (1) the one collapsed `"User unavailable"`
error is correct for privacy but is *product-hostile* — a user genuinely can't tell "they're
offline" from "they blocked me" from "DND"; that ambiguity is the right trade but needs a humane UX
story. (2) `context_token` co-presence lets strangers in the same external match call each other —
powerful, but the user's consent/così-control over that channel should be explicit, not implicit.

**Open, ranked (Product):** (1) a humane UX for the deliberately-opaque "User unavailable";
(2) explicit user consent surface for `context_token` co-presence calling; (3) make the
identity/substrate portability a *visible* product promise, not just a config flag.

---

## Div6 — Infrastructure/Platform · the platform reality

*The platform and the scaling math, ground-truthed. Tags: [VERIFIED] live-tree; [DOCUMENTED];
[ASSESSED].*

**Build environment.** [VERIFIED] The module target is `wasm32-unknown-unknown` (CI builds the
whole workspace to it); the portable demo also builds `wasm32-wasip1` with a hash step. **Note a
doc-vs-reality clarification:** *mkosi* (named in this lens) is the **elpis-os** image builder, a
separate repo — it is not part of the f2f module build. f2f's build is cargo→wasm; mkosi enters
only at the deploy-substrate (image) layer. Worth correcting in any combined "build" narrative.

**CI's actual coverage.** [VERIFIED] `.github/workflows/ci.yml` builds (modules, web-client,
wasm-demo, android-oracle) and **stops there**: no fmt/clippy (workspace not rustfmt-clean), **no
integration tests** (need a live SpacetimeDB), and — confirming the known gap — **no secret-scan /
gitleaks** anywhere in the product CI. The cnsUnltd board carries a *separate* correct pre-commit
secret-scan, but **the product repo's own CI does not gate secrets.** This is a pre-public
must-fix, ranked #1 for this lens.

**Resource characteristics — does the scaling table hold?** [DOCUMENTED, not load-tested]
The model (150 KB base + per-connection deltas; ~155 KB/conn under RLS; quadratic under full-table)
is *internally* sound and honestly hedged ("benchmark against the live module before hardware
decisions"). But it is **a model, not a measurement** — no benchmark artifact exists in-tree. The
JOIN-filtered-vs-RLS distinction matters: today's full-table fallbacks make the *real* footprint
worse than the RLS row in the table. **Owe one real benchmark** before any hardware-sizing claim is
repeated publicly.

**Maincloud deploy-readiness.** [DOCUMENTED] The checklist is security-complete on paper (HMAC
rotation, issuer, `oidc_client_id` non-empty, `dev_mode=false`). Never dry-run end-to-end against a
Maincloud target in-tree — same "procedure not runbook" gap Docs flagged.

**Open, ranked (Infra):** (1) **add secret-scan to product CI** (closes the gap the board already
solved for itself); (2) one real RAM benchmark vs the table, with the full-table-vs-RLS caveat;
(3) get the workspace rustfmt-clean so fmt/clippy re-enter CI; (4) a recorded Maincloud dry-run to
promote the checklist to a verified runbook.

---

## Div7 — Research/R&D · the frontier

*The theory edge and the portability proof. Tags: [VERIFIED] live-tree; [DOCUMENTED]; [ASSESSED].*

**State of the attack-class theory.** [VERIFIED+ASSESSED] The thesis — "write-to-execute via
subscription substrate" — is carried beyond f2f into `substrate/` (the `command-dispatch-demo`
general-protocol reference, with `SUBSTRATE.md` and `WHAT-THIS-DEMONSTRATES.md`). So the
generalization is **materialized, not just claimed**: f2f is one instance; the substrate dir is the
abstracted protocol. The frontier question — *how general is the class?* — has a concrete artifact
to point at. This is the strongest research asset and the spine of the disclosure.

**Portability — the four-way proof matrix.** The matrix is RealtimeStore {SpacetimeDB, Postgres} ×
Identity {OIDC, keypair/native}. Status:
- [VERIFIED] **Postgres substrate exists**: `applications/face-to-face/server-postgres/`
  (`schema.sql`, `rls.sql`, `setup-rls.sql`, `server.js`, LISTEN/NOTIFY row delivery). So
  RealtimeStore portability is *implemented* on two backends.
- [DOCUMENTED] The **same** `two-session-call.spec.ts` passes on **both** SpacetimeDB and Postgres
  — the load-bearing portability proof for the call path (QA owns the "is it run in CI" caveat).
- [DOCUMENTED] **Identity** is pluggable: Clerk OIDC **and** SpacetimeDB-native; the F2F web-client
  selects via `VITE_AUTH_PROVIDER`.
- [ASSESSED] **What's proven vs open:** three of four cells are demonstrated for the call path
  (STDB+OIDC = production; Postgres+? and STDB+native via the auth flag). The **fully-crossed cell
  — Postgres + keypair/native identity together — is the one to confirm is exercised, not just
  individually possible.** That is the open corner of the matrix.

**Carry-distance of the generalization.** [ASSESSED] The Postgres port reproduces the *call-path*
reducers; admin/HMAC/reapers/blocks are explicitly **out of scope** there. So portability is proven
for the protocol's *core motion*, not its full security surface. Honest framing: "the substrate is
portable" is true for the demonstrated subset; the full module is not (yet) bi-substrate.

**Open, ranked (R&D):** (1) close the Postgres+native-identity corner of the matrix with a run, not
an argument; (2) state the call-path-vs-full-module scope of the portability claim explicitly in
the disclosure; (3) push the `substrate/` generalization one notch — what is the minimal protocol
core that survives both backends?

---

## Div8 — IP/Legal-Strategy · the prior-art posture

*Records, coordinates, and preps only — does not practice law; counsel and the founder make every
legal call. Tags: [VERIFIED] live-tree; [DOCUMENTED]; [ASSESSED].*

**Prior-art record currency.** [DOCUMENTED+ASSESSED] The mechanism is sound and unusual: the
**VECTOR findings and their safeguards _are_ the prior-art record** — the patent-to-disclose
instrument. SECURITY.md's catalogue is the artifact. For it to function as evidence it must stay
**synchronized with the code**; this turn's Security/Dev lenses flag that several VECTORs are
DOCUMENTED-but-not-line-verified. **Record integrity action: pin each VECTOR to the commit/line
that closes it**, so the prior-art record is anchored, not narrative.

**Invention #3 — the hard precondition.** [DOCUMENTED] "Universal device command dispatch" (the
`substrate/` generalization R&D points to) is the disclosure's load-bearing novelty and is **NOT
yet filed**. Standing rule (recorded prior cycles): invention #3 files **before** article
publication — it is a publication-gate precondition, not a nicety. **Status this turn: still
open.** Ranked #1 for this lens. The org must not let the disclosure-article momentum outrun the
filing.

**License compliance.** [ASSESSED] Flagged dependency of record: **libndk / GPLv3** (and the
general obligation to keep a license-compliance register current as the android-oracle and wasm
demos pull deps). GPLv3 in a distributed artifact is a real obligation to track — coordinate with
counsel on the distribution boundary (is the GPLv3 component linked, bundled, or invoked?). This is
a *records-and-flag* item; the legal determination is counsel's.

**Disclosure-gate preconditions — consolidated status:**
1. Invention #3 filed — **OPEN** (hard gate).
2. Prior-art record (VECTOR catalogue) current + code-anchored — **partially**; needs the pinning
   action above.
3. The three Docs-flagged caveats (M-08 client-trust, H-17 open, #3 unfiled) carried in the
   article — **must-include**.
4. License register current incl. GPLv3 boundary — **OPEN**, counsel-owned.

**Open, ranked (IP):** (1) file invention #3 (gate); (2) pin VECTORs to closing commits/lines;
(3) GPLv3/libndk distribution-boundary memo to counsel; (4) assemble the disclosure-gate checklist
as a single founder-facing sign-off sheet. **No legal call is made here — these are coordinates.**

---

## Handoff

Assembled and gated by the EA; **handed up for the CEO synthesis (Step 3)** — the cross-lens
through-line, the ranked backlog for the first real sprint, and the disclosure-evidence
implications. The EA now **stands down to idle**; the EA going idle is the completion signal for
this watched turn.

**PASS criteria (WO § Adjudication):** eight sections landed on their branches + integrated behind
the gate ✓ · bus carried eight concurrent real dispatches, no cross-talk / lost dispatch / mesh ✓ ·
integrated assessment exists on `main` ✓ · nothing flashed, deployed, or published ✓.
