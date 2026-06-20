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
