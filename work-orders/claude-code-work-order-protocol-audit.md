# WORK ORDER: Multi-Repo Pandora Protocol Security Audit
## The write-to-execute lens — lifecycle AUDIT phase, cycle 1

**Addressed to:** a Claude Code session (read-only audit; may spawn read-only
sub-audits per implementation — no collision risk since nothing is written to
source).
**Repos:** `pandora` (private), `elpis-os` (private now — public-trajectory; secret-scan stays standing). Reference box `.180`
(read-only introspection only).
**Lifecycle position:** this is the **AUDIT phase** of the development loop
(*sprint end → AUDIT → portability → evaluate → new sprint*). It is the first
formal instance — structure it to be **repeatable every cycle** (next cycle diffs
its map against this one).
**Companion (running concurrently):** the living disclosure article
(`...-living-article.md`). This audit FEEDS that article but does NOT write to it
— see "Feeding the article" below.

---

## THE LENS (the single question this audit asks everywhere)

The project's own novel attack class: **write-to-execute via subscription
substrate** — *an unauthorized or under-authorized write to a command-dispatch
table (or socket/endpoint) in a subscription-delivered relational substrate
produces an effect — physical actuation, a cryptographic signature, a privileged
operation — not merely a data exposure.* A data breach reads; this class **acts**.

So for **every** Pandora Protocol implementation, the audit answers:

> Where does a *write* (to a subscription-delivered table, a command-dispatch
> path, or a request socket) produce an *effect* rather than mere storage — and
> is the **authorization on that write proportional to the danger of the
> effect**?

Every place where authorization is weaker than the effect is dangerous is a
write-to-execute gap. H-9 (the unconstrained signing oracle reachable through the
substrate's own trust delegation) is the first reproduced instance — the audit
looks for every other expression of the same pattern.

---

## PRIME DIRECTIVE

Read-only across all repos and `.180` (introspection only — `git`, grep, source
read, and on `.180` the same read-only tools Lane H used). **No source edits. No
merges. No `.180` mutation.** Findings live in this audit's own report / a
`preview/audit-*` branch. Public-repo discipline: **never quote a secret value**;
describe handling/permissions only. The audit is cumulative — cross-reference the
known findings (H-1..H-15 in `security-review.md`) rather than restarting; new
findings get new IDs continuing that series.

---

## STAGE 0 — Inventory every Pandora Protocol implementation (both repos)

Build the definitive implementation inventory. The protocol's thesis is
substrate-agnostic command dispatch; every place that expression appears is in
scope. Known implementations (confirm paths + find any others):

1. **General-protocol reference** — `command-dispatch-demo`
   (`pandora/substrate/module/`) + its clients (`substrate/clients/web/`,
   `substrate/clients/node/`). *The purest expression of the write-to-execute
   surface — the reference implementation of the protocol itself.*
2. **F2F application** — the `face-to-face` SpacetimeDB module
   (`pandora/applications/face-to-face/module/`) + web client. *Communication
   substrate; signal/session/presence/contact write paths.*
3. **Device-control plane** — the substrate-api bridge
   (`pandora/applications/pandora-substrate-api/`), `elpis-shell`, `elpis-run`.
   *The H-1→H-9 chain lives here; the bridge is the network write surface.*
4. **Home gateway + privileged helpers** —
   (`elpis-os/packages/pandora-home-gateway/`, `pandora-dispatch/`,
   `pandora-identity/tpm-signer`). *The dispatch authorizer, the firewall helper,
   the signing oracle.*

Output: `audit-inventory.md` — every implementation, its repo/path, its substrate
(SpacetimeDB / Postgres / unix socket / WS), and its role in the protocol.

---

## STAGE 1 — Per-implementation WRITE-TO-EFFECT MAP (the core method)

For EACH implementation, produce a write-to-effect map. This is the heart of the
audit and the artifact that makes it repeatable:

For every write surface (each reducer/table accepting subscription-delivered
writes; each command-dispatch path; each request socket/endpoint):
1. **Effect class** — classify what the write ultimately causes:
   `data-only` | `state-with-side-effect` | `privileged-operation` |
   `physical-actuation` | `cryptographic-signature`.
2. **Authorization gate** — what must hold for the write to be accepted AND the
   effect to fire? Enumerate: signature verification? signer allow-list /
   consent-by-default (`allowedSigners`)? `require_authenticated()` (the sentinel
   guard)? replay/nonce protection? rate limit? socket/group ACL? **none?**
3. **Proportionality verdict** — is the gate proportional to the effect?
   `OK` (gate ≥ effect danger) | `GAP` (gate < effect danger) | `UNKNOWN`.
4. For every `GAP`, write a finding (new ID in the H-series), severity, and the
   write→effect chain that realizes it.

The map's value: next cycle re-runs it against the changed substrate and **diffs**
— new write surfaces, changed gates, regressions all surface mechanically.

---

## STAGE 2 — Required deep-dives (the deferred + the generalizations)

These are mandatory regardless of what STAGE 1 surfaces (item 6 is carried forward
from the 2026-06-19 cycle):

1. **F2F module reducers — the deep re-audit Lane H explicitly DEFERRED.** Every
   reducer in `face-to-face/module`: confirm the **sentinel-guard rule** (every
   sensitive reducer calls `require_authenticated()` at entry — the canonical
   `delete_account` pattern), the OIDC issuer/audience checks, `dev_mode` gate,
   the consent posture, and the signal/session/presence/contact/block write
   paths. Does any reducer write a row that another client's subscription turns
   into an action without an auth gate on the writer?
2. **`command-dispatch-demo` — the reference implementation, audited as the
   canonical write-to-execute surface.** Lane S noted it is
   **"permissionless-by-design"** and pinned that posture with a test. Audit
   whether that demo posture is (a) clearly fenced as demo-only, and (b) a latent
   trap when the pattern is copied into a real deployment — because this is the
   module others will learn the protocol from. This is the purest case of the
   class; document it as such.
3. **The device-command path end-to-end** — bridge write → dispatch table →
   handler actuation. The H-1→H-9 chain is ONE realization (LAN → :7473 →
   sign.sock → identity forgery). Map the *whole* path and look for other
   write→actuation routes (e.g. `launch_progress`/`app_launches` writes, the
   capability-descriptor dispatch payloads, the 34 device handlers — does any
   handler actuate on an under-authorized write?).
4. **The signing-oracle pattern, generalized (from H-9).** Anywhere a write or
   request yields a signature: the TPM signer (now `pandora-sign`-gated post-cut),
   the software-key fallback, and any other signing path. Generalize H-9 into "is
   every signature-producing write scoped + authorized + audited?"
5. **Subscription-write authorization in the substrate itself.** The
   JOIN-filtered model, the blocked RLS / `client_visibility_filter` (issue
   #2810), and write-side authorization: who can WRITE which tables, and does a
   write get *delivered to subscribers* in a way that triggers action? Read vs.
   write authorization are different questions — this class is about writes.
6. **Carried-forward (added 2026-06-19): the `7ad628c` install polkit grant.**
   The per-device-state parity fix was merged to `main` with the architect's
   informed sign-off, **deferring** verification of its trust-boundary change to
   this audit (verify-don't-assume applied post-merge, not skipped). Read what
   `49-elpis-install.rules` grants **after** `7ad628c` versus before: confirm it
   stays scoped to the exact installer path AND `subject.user === "elpis"` (the
   tight form H-6 praised), and determine exactly what new action the widened grant
   permits and what the first-boot **self-pair** step does (does it auto-pair
   anything, to what, under whose authority?). Verdict: `scope-still-tight` (close
   it) or a hardening finding for a future sprint. Not urgent; this is the loop
   absorbing a known item rather than rushing it.

---

## STAGE 3 — Consolidate & split the output

1. **Findings register** — every `GAP` from STAGE 1/2, new IDs continuing the
   H-series, each with: severity, the write→effect chain, the proportionality
   gap, and a cross-reference if it relates to an existing H-finding. Mark which
   are **pre-existing vs. introduced since the last cycle** (diff discipline).
2. **Two-way split of every finding:**
   - **→ HARDENING FEED** (input to the next sprint): the actionable fix, tiered
     by effort/risk like the remediation roadmap.
   - **→ ARTICLE LEDGER CANDIDATES** (input to the living article): findings that
     are *reference instances of the attack class* — formatted as candidate ledger
     entries (the instance, how it manifests write-to-execute, the reproduction,
     the remediation pattern), H-9-style. **Write these into THIS audit's report,
     in a clearly-marked `ARTICLE LEDGER CANDIDATES` section — do NOT write them
     into the article file** (the concurrent article WO owns that; reconciliation
     happens in the evaluate phase, avoiding a write-collision).

---

## DELIVERABLES
- `audit-inventory.md` (STAGE 0)
- `write-to-effect-map.md` — per-implementation maps (STAGE 1/2); the repeatable
  artifact
- `protocol-audit-findings.md` (STAGE 3) — findings register + the HARDENING FEED
  and `ARTICLE LEDGER CANDIDATES` sections
- All on `preview/audit-cycle-1` (read-only authoring of reports only; no source
  touched). Secret-CLEAN (public repo).

---

## REPEATABLE-LOOP NOTE
This is **cycle 1**. The write-to-effect map is the durable instrument: each
subsequent AUDIT phase re-derives it against the then-current substrate and diffs
against the prior cycle's map, so new write surfaces / weakened gates / regressions
are caught mechanically. Reference this WO from the lifecycle definition so the
audit phase is as repeatable as crunch-time.

---

## REPORT FORMAT
```
Multi-Repo Protocol Audit — cycle 1 (write-to-execute lens)

STAGE 0 inventory:        [N implementations across pandora + elpis-os]
STAGE 1 write-to-effect maps:
  per implementation:     [done? write surfaces / effect-classes / gates]
  GAPs found:             [n]
STAGE 2 deep-dives:
  F2F reducers (deferred): [sentinel-guard rule holds? gaps?]
  command-dispatch-demo:   [permissionless posture fenced? latent trap?]
  device-command path:     [other write→actuation routes? ]
  signing-oracle general:  [every signature-write scoped/authorized/audited?]
  subscription-write auth:  [write authz mapped; delivery-triggers-action cases?]
STAGE 3:
  Findings (new IDs):      [list, severity, pre-existing vs new-since-cycle-0]
  HARDENING FEED:          [tiered fixes for next sprint]
  ARTICLE LEDGER CANDIDATES:[instances of the class, H-9-style, in THIS report]
Read-only honored / no merge / .180 untouched / secrets quoted: [Y / Y / Y / NONE]
preview/audit-cycle-1 pushed: [hash]
```
