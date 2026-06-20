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
