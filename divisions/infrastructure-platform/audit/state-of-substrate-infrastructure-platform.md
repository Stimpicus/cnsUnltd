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
