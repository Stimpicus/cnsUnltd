# WORK ORDER: Security Remediation Sequence
## Tier-1 cuts → verifier sweep (HARD GATE) → H-9 §2 domain separation

**Addressed to:** a Claude Code session running this as a **single, ordered
sequence** — NOT an anti-idle swarm. The signing-contract work especially is
deliberate, single-threaded, and gated.
**Repos:** `pandora` (private), `elpis-os` (private now — public-trajectory; secret-scan stays standing).
**Source findings (do not re-derive — cited inline):** `security-review.md`
(H-1..H-15), `SECURITY-REMEDIATION.md` (sequencing), `H9-signer-design.md`
(the approved §2 design).

---

## PRIME DIRECTIVE FOR THIS WORK ORDER

**Security above all. Never trade speed for security. Where a proper way exists
to verify a change will not break the project, do that thing — every time, no
exception.**

This translates into rules that OVERRIDE the normal crunch-time posture:

1. **The STAGE 2 → STAGE 3 gate is a HARD STOP, not a fork.** The anti-idle
   "fork-never-block, pick a defensible default, keep moving" rule is
   **SUSPENDED** at that gate. If the verifier sweep finds anything unexpected,
   the agent **HALTS and surfaces to the human.** It does NOT pick a default, it
   does NOT proceed to STAGE 3, it does NOT manufacture adjacent work to look
   busy. Stopping is the correct, desired behavior here.
2. **No merges to `main`.** The human architect is the sole merge authority.
   Every change lands on a branch + QA report; the human merges.
3. **No security-critical change is applied to `.180` unattended.** All `.180`
   mutations are (a) staged on a branch, (b) accompanied by a tested rollback,
   (c) applied by the human, attended. Authoring is safe to do now; *applying*
   is a human, attended, reversible step.
4. **Public-repo hygiene:** stage by explicit path (never `git add -A`), run the
   secret-scan guard before every commit, update the relevant `CLAUDE.md` in the
   same commit. Tag `RISK: SECURITY` / `RISK: PARITY` where they apply.

If any instruction here conflicts with these four, these win.

---

## STAGE MAP (runs in order; gates are real)

```
STAGE 0  Recon (read-only)                     → recon.md            [GREEN]
STAGE 1  Tier-1 cut-set (author on branches)   → 4 branches + runbooks
            1A H-1 loopback bind (merge + deploy runbook + test)
            1B H-9 §4 socket-ACL (dedicated pandora-sign group)   ← closes LIVE reach
            1C H-2/H-14 audit logs chattr +a
            1D H-10 firewall cap-drop
STAGE 2  Verifier-enumeration sweep (read-only) → verifier-sweep.md  [HARD GATE]
            verdict GREEN  → STAGE 3 may proceed
            verdict RED    → STOP. Surface. STAGE 3 blocked.
STAGE 3  H-9 §2 domain separation (gate-locked) → phased migration
            (only if STAGE 2 == GREEN, or human has dispositioned a RED)
```

Note on naming: STAGE 3 contains the design doc's internal **Phase 0–3**
migration. "STAGE" = this work order's top-level steps; "Phase" = the §2
migration phases inside STAGE 3.

---

## STAGE 0 — RECON (read-only; safe anytime; feeds everything)

Capture the live facts that STAGE 1B and STAGE 2 both depend on, so no later
step has to assume. Strictly read-only on `.180` (`ls`, `stat`, `getent`, `id`,
`ss`, `ps`, `systemctl show/cat`, `lsattr`, `aa-status`) and `git`/grep in the
repos. Write `recon.md` capturing:

- **Signing socket:** `ls -la /run/pandora/sign.sock` (expect `srw-rw---- root:pandora 0660`).
- **Group membership:** `getent group pandora` (expect `...:106:elpis`),
  `getent group pandora-session`, `id elpis`, `id pandora`.
- **Principal map — who runs as what** (from `ps -eo user,pid,cmd` + the unit
  files), for each of: `pandora-substrate-api` (the bridge — expect user
  `pandora`), `pandora-tpm-signer` (expect root), `pandora-dispatch`,
  `pandora-home-gateway` / scanner. **This is the critical output for 1B:** it
  tells us exactly which principals legitimately sign (dispatch + gateway) vs.
  which must lose signing reach (the bridge, `elpis`).
- **Bridge's other access needs** (to scope 1B's optional hardening safely):
  does the bridge process hold the PostgreSQL socket `/run/pandora/.s.PGSQL.5432`
  open, and does it read `/etc/pandora/**`? (Determines whether "bridge off user
  `pandora`" is safe or must stay a fast-follow.)
- **Audit logs:** `lsattr` on `/var/log/pandora/dispatch-audit.jsonl` and
  `/var/log/pandora/home-gateway-audit.jsonl` (expect extent-only, no `a`).
- **Firewall unit:** `systemctl show pandora-firewall` capability set + hardening
  (expect full caps, no hardening) vs. `pandora-tpm-signer` (the template).
- **Bind state:** `ss -tlnp | grep 7473` (expect `0.0.0.0:7473`, user node/pandora).

Gate: `recon.md` exists and the principal map is unambiguous. GREEN, read-only.

---

## STAGE 1 — TIER-1 CUT-SET (four independent tightening changes)

Each is pure tightening, independent, and stageable now. Authoring is GREEN
(branch-only). Every `.180` *apply* is gated to the human, attended, reversible.

### 1A — H-1: bind the control bridge to loopback  [QUICK-WIN · HIGH]

**Status:** the fix is ALREADY staged on `hotfix/bridge-bind-loopback` (the
canonical pandora trunk tip; commit `8eaa9cd` makes the host env-driven defaulting
to `127.0.0.1`; `956fdf7` fixes the startup log). The setToken crash-guard in the
same stack is already deployed+proven on `.180`.

Do:
1. **Confirm** `applications/pandora-substrate-api/src/index.ts:24` resolves
   `const HOST = process.env.SUBSTRATE_API_HOST ?? '127.0.0.1'` and the log at
   `:244` uses `HOST` (per `H9`/remediation §1). No re-authoring if already correct.
2. **Regression test:** confirm/extend `preview/security-invariant-tests`
   (pandora) — it already contains a bind-loopback guard asserting no hardcoded
   `host: "0.0.0.0"` remains and the default resolves to loopback. If present and
   green, reference it; do not duplicate. If absent, add it as a new test file
   only (no product source change).
3. **Apply runbook (for the human, attended):** the *merge* of the hotfix tip is
   the human's call; the *deploy* of the loopback bind to `.180` is AMBER
   (reversible). Document: rebuild bridge → swap with the existing
   known-good backup pattern → health-check (bridge active, NRestarts=0, shell up)
   → confirm `ss` now shows `127.0.0.1:7473`. **Known consequence to state in the
   runbook:** deploying the bind stops all remote `:7473` `describe_device`/`Pair`
   probes by design — that is the point.

Risk: merge GREEN; deploy AMBER (reversible, gated). Branch: use the existing
`hotfix/bridge-bind-loopback`; add only the runbook doc + test reference on
`sprint/sec/h1-runbook` if you need a place for them.

### 1B — H-9 §4: dedicated `pandora-sign` group  [the LIVE reach closer · HIGH]

This is the highest-value action available now: it closes the **live, confirmed**
reach (STAGE 0 / the audit verified both the network-exposed bridge *and* `elpis`
can open `sign.sock` today) **without any wire-contract change.** It is the part
of H-9 that does not need the sweep.

**Design decision (made here, deliberately, to avoid breaking the desktop):**
use the **dedicated-group** approach, NOT "remove `elpis` from `pandora`."
- The security review warns explicitly: **do NOT blanket-remove `elpis` from
  group `pandora`** — `elpis` needs that membership to read `/etc/pandora` config,
  or the shell breaks on next boot.
- So: **leave `elpis` in `pandora`** (config-read grant intact) and move the
  *signing* grant to a new, narrow group.

Author (branch `sprint/sec/h9-socket-acl`, staged — DO NOT live-apply):
1. **Create group `pandora-sign`** in provisioning (the same firstboot/postinst
   that currently creates `pandora` and adds `elpis` to it — locate via STAGE 0).
   Membership = **only the principals STAGE 0 identified as legitimate signers**
   (the users `pandora-dispatch` and the gateway/scanner run as). Explicitly NOT
   `elpis`, explicitly NOT the bridge's user.
2. **Re-chown the socket** in
   `elpis-os/.../pandora-identity/usr/lib/pandora-identity/tpm-signer.js:117-124`:
   change `chown root:pandora` → `chown root:pandora-sign` (keep `chmod 0o660`).
3. **Leave the bridge as user `pandora`** (no DB/config disruption). Because the
   bridge is not in `pandora-sign`, it loses signing reach — which is correct and
   lossless (the call graph shows the bridge never signs; only dispatch + gateway
   do).
4. **Verify nothing legitimate breaks** (this is the "verify, don't assume" step):
   the apply runbook must check, after applying on `.180` attended, that:
   (a) the desktop comes up and the shell still reads `/etc/pandora` (elpis still
   in `pandora`); (b) `pandora-dispatch` and the gateway can still sign (they are
   in `pandora-sign`); (c) the bridge and `elpis` can NO LONGER open `sign.sock`
   (the closed reach); (d) a normal Pair→describe→command still works end-to-end.
5. **Rollback:** revert the chown to `root:pandora` and drop `pandora-sign` —
   single, scripted, tested before apply.

**Optional fast-follow (do NOT bundle): "bridge off user `pandora`."** Defense in
depth, but it risks the bridge's DB/config access (STAGE 0 determines this).
Leave it as a separate, later branch with its own verification — not in this cut.

Risk: `RISK: SECURITY` + `RISK: PARITY` (group/provisioning/unit + socket owner).
Authoring GREEN (branch only); apply gated to the human, attended, with the
tested rollback. **Never live-apply unattended.**

### 1C — H-2 / H-14: make both audit logs filesystem append-only  [QUICK-WIN · MED]

Author (branch `sprint/sec/h2-h14-append-only`, staged):
- A **root-run** firstboot/postinst step (the `pandora` daemons lack
  `CAP_LINUX_IMMUTABLE` — good) that runs:
  ```sh
  chattr +a /var/log/pandora/dispatch-audit.jsonl
  chattr +a /var/log/pandora/home-gateway-audit.jsonl
  ```
- **Logrotate handling (required, or rotation silently fails):** ship a
  `prerotate`/`postrotate` pair that `chattr -a` → rotate → `chattr +a`, OR
  document forgoing rotation (logs are tiny — dispatch-audit was 1692 B/day).
  Put the note in the rotation config so a future operator isn't surprised.

Risk: `RISK: PARITY` (firstboot/image step). Authoring GREEN; apply gated.

### 1D — H-10: drop the firewall helper to one capability  [QUICK-WIN · MED]

Author (branch `sprint/sec/h10-firewall-caps`, staged): in
`elpis-os/packages/pandora-home-gateway/lib/systemd/system/pandora-firewall.service`,
mirror the in-repo `pandora-tpm-signer` unit template:
```ini
CapabilityBoundingSet=CAP_NET_ADMIN
AmbientCapabilities=CAP_NET_ADMIN
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/run/pandora
PrivateTmp=yes
ProtectHome=yes
```
Verify the helper still drives `iptables` (it needs only `CAP_NET_ADMIN`). The MAC
arg is already regex-validated and `iptables` is invoked via `execFileSync` argv
(no shell), so this is pure capability reduction.

Risk: `RISK: PARITY` (unit change). Authoring GREEN; apply gated.

**STAGE 1 gate:** four branches pushed, each secret-CLEAN, CLAUDE.md updated,
each with a tested apply+rollback runbook. None applied to `.180` (that's the
human's attended step). 1B is the headline — it closes the live reach.

---

## STAGE 2 — VERIFIER-ENUMERATION SWEEP  (read-only; HARD GATE for STAGE 3)

**Purpose:** turn "I believe only the gateway and dispatch verify this device's
signatures" into a *known*. H-9 §2 changes the signature pre-image (a domain
prefix is prepended), so a v2-signed message will NOT verify under a verifier that
still expects bare bytes. If any verifier exists that we don't update first, we
break it — possibly off-box, possibly silently, possibly a week later. We find
them before we touch the signer.

This is **read-only** — grep/`git` across both repos and the F2F substrate, plus
reasoning about network peers. Safe to run anytime.

Enumerate and record in `verifier-sweep.md`:

1. **In-repo verifier call sites.** Every place that verifies a device signature:
   - `pandora-dispatch/src/signing.ts:93` (`verifySignature`)
   - `pandora-home-gateway/src/signing.ts:76` (`verifySignature`)
   - any caller of those; any independent re-implementation; any consumer of the
     `sha256(DER SPKI)` device-identity check (`signing.ts:57-60`).
2. **Message-class consumers.** Who receives and *checks* the two signed message
   classes the device emits — a **command response** (`dispatch.ts:177-180`,
   `command_type:"<orig>:response"`) and an **owner notification**
   (`scanner-main.ts:160-171`, `DisplayNotification`)? Trace where those land.
3. **Off-box / peer verifiers — the part the audit explicitly did NOT close.**
   Determine whether ANY of these ingest and verify `.180`'s outbound signatures:
   - the **F2F substrate / module** (search `applications/face-to-face/**` for any
     device-signature verification, SPKI check, or signed-message ingest);
   - a **web client** or companion app;
   - **another Elpis box / peer device** that has been handed `.180`'s public key.
   Note: **vendor pairing (Samsung Tizen token, Hue, Xbox) is NOT a Pandora
   signature verifier** — those devices check their own credentials, not the
   ED25519 device identity. Distinguish "paired with a smart device" (irrelevant
   here) from "verifies Pandora device signatures" (the thing that matters).
4. **Persisted / in-flight bare-signed artifacts (second-order break risk).**
   Is there any stored, cached, or queued artifact signed under the CURRENT bare
   scheme that must still verify AFTER cutover — a persisted token, a cached
   notification, a queued command response, anything durable? If yes, the
   dual-accept verifier window (Phase 0/3) must stay open long enough to cover its
   lifetime. Record exactly what and its lifetime.

**Verdict (binary, explicit):**
- **GREEN** — verifiers are exactly `pandora-dispatch` + `pandora-home-gateway`,
  in-repo; no off-box/peer verifier; no durable bare-signed artifact that
  outlives a normal dual-accept window. → STAGE 3 may proceed.
- **RED** — anything else. Record precisely what was found (file:line or the peer/
  artifact). → **STOP. Surface to the human. STAGE 3 is BLOCKED** until the human
  dispositions it (the found verifier(s) get added to STAGE 3's Phase 0
  dual-accept set, or the artifact's lifetime extends the window). **Do not
  proceed. Do not pick a default. Do not start §2 on a "we'll update it later"
  assumption** — that is exactly the trade this work order forbids.

Risk: GREEN, read-only. **This is the gate. Honor it.**

---

## STAGE 3 — H-9 §2: DOMAIN-SEPARATED SIGNING  (GATE-LOCKED)

**Precondition (enforced):** begin ONLY if STAGE 2 verdict is GREEN, or the human
has explicitly dispositioned a RED and the found verifiers are now in the Phase-0
set below. Otherwise STOP.

This converts the signer from "sign arbitrary bytes" into "sign one of two
enumerated message classes," per `H9-signer-design.md`. The design is sound: the
device's entire legitimate signing call graph is exactly two classes
(**cmd-response**, **notification**), which is what makes a closed purpose
allow-list real. Implement it phased so no verifier ever faces a signature it
can't check (no mixed-fleet break). Single-threaded, deliberate; each phase its
own branch + QA; `.180` applies gated/attended/reversible.

### Wire contract (reference — design §2.1/§2.2)
```jsonc
// request over /run/pandora/sign.sock (newline-delimited JSON)
{ "v":2, "id":"<uuid>", "purpose":"cmd-response", "body":"<base64 canonicalize() output>" }
// success: { "id":"<uuid>", "purpose":"cmd-response", "signature":"<base64>" }
// error  : { "id":"<uuid>", "error":"unknown purpose: <p>" }   // fail-closed
```
```js
// signer builds the signed pre-image itself; caller cannot choose leading bytes
const PURPOSE_PREFIX = {
  'cmd-response': Buffer.from('pandora:cmd-response:v1\0','utf8'),
  'notification': Buffer.from('pandora:notification:v1\0','utf8'),
};
function signedPreimage(purpose, bodyBuf){
  const prefix = PURPOSE_PREFIX[purpose];
  if(!prefix) throw new Error(`unknown purpose: ${purpose}`); // fail-closed
  return Buffer.concat([prefix, bodyBuf]);          // NUL cannot appear in JSON body
}
```

### Phase 0 — verifiers accept BOTH (deploy verifiers FIRST)
Branch `sprint/sec/h9-verify-dual-accept`. Update `verifySignature` in BOTH
`pandora-dispatch/src/signing.ts:93` and `pandora-home-gateway/src/signing.ts:76`
(**and any additional verifier STAGE 2 found**) to try the v2 prefixed pre-image
first, then fall back to the legacy bare `canonicalize(c)` pre-image. Every
verifier now accepts old AND new. This ships everywhere that verifies BEFORE any
signer emits v2. If STAGE 2 flagged a durable bare-signed artifact, the
bare-fallback stays until that artifact's lifetime ends.

### Phase 1 — signer accepts BOTH request shapes
Branch `sprint/sec/h9-signer-dual-accept`. `tpm-signer.js handleLine`:
- `req.v === 2 && req.purpose` → `signedPreimage(purpose, body)`; refuse unknown
  purpose (fail-closed).
- legacy `{id, data}` (no `v`/`purpose`) → sign bare, **gated behind
  `PANDORA_SIGN_ALLOW_LEGACY=1`**, audited `legacy:true`.

### Phase 2 — migrate the two callers to v2
Branch `sprint/sec/h9-callers-v2`.
- `pandora-dispatch/src/dispatch.ts:177` (via `identity.sign`/`signViaHelper`) →
  send `{v:2, purpose:'cmd-response', body}`.
- `pandora-home-gateway/src/scanner-main.ts:171` (`signViaHelper`) →
  `{v:2, purpose:'notification', body}`.
- `signViaHelper` grows a `purpose` param in BOTH `signing.ts` copies.
- **Software/TPM fallbacks must apply the SAME prefix locally** so software-key
  devices stay interoperable: factor a shared `preimage(purpose, body)` helper and
  call it on EVERY signing path — the helper path, `DeviceIdentity.sign`
  (`identity.ts:45-63`), and the scanner fallback (`scanner-main.ts:177`).

### Phase 3 — retire legacy
Branch `sprint/sec/h9-legacy-off`. Once all callers emit v2 and all verifiers
accept v2: set `PANDORA_SIGN_ALLOW_LEGACY=0` (or remove the legacy branch). The
signer now refuses bare-`data` — the "sign arbitrary bytes" capability is closed.
Verifiers MAY keep the bare-fallback one more release if STAGE 2 found a durable
artifact, then drop it.

### §5 — audit + rate limit (lands WITH the signer change)
Branch `sprint/sec/h9-audit-ratelimit`.
- Root-owned append-only `/var/log/pandora/sign-audit.jsonl` (`root:root 0640`),
  one line/request: `{ts, peer:{pid,uid}, purpose, decision, reason, bodyLen,
  bodySha256}` — log the **sha256 of the body, never the body or signature.**
- `chattr +a` it from the same root step as 1C.
- **AppArmor carve-out (must ship WITH this):** the `pandora-tpm-signer` profile
  (`apparmor/pandora-tpm-signer:40`) currently has `deny /var/log/pandora/** w`.
  Add the single path `/var/log/pandora/sign-audit.jsonl w,` or enforcing the
  profile blocks the new write. Flag to the AppArmor owner (Lane D territory).
- **Rate limit:** token bucket per peer UID — start 30/10s burst, 5/s sustained;
  on exceed refuse `error:"rate limited"` + audit `decision:"deny"
  reason:"rate-limit"`. In-memory (single long-lived process).

### Test to land WITH the fix
`preview/security-tpm-signer-domain-sep` — the six assertions from design §7:
refuses unknown purpose; prepends per-purpose prefix (and cross-purpose
non-reuse); legacy gate on/off; peer/group ACL drop (if the native check lands);
rate limit; and the round-trip that proves a v2 signature verifies under the
Phase-0 verifier WHILE a bare signature still verifies during the dual-accept
window (the no-mixed-fleet-break proof).

Risk: every STAGE 3 change is `RISK: SECURITY` (signer/auth contract). Authoring
GREEN (branches); each `.180` apply gated to the human, attended, reversible.
**Phased order is mandatory** — verifiers dual-accept BEFORE the signer emits v2,
or you break verification.

---

## CROSS-STAGE GATE SUMMARY

| Gate | Condition to pass | If not met |
|---|---|---|
| STAGE 0 → 1 | principal map unambiguous | re-introspect; don't guess who signs |
| STAGE 1 apply | per-change rollback tested; human attended | stage only; never unattended |
| **STAGE 2 → 3** | **sweep verdict GREEN** (or human dispositioned RED) | **STOP. Surface. STAGE 3 blocked.** |
| STAGE 3 phase order | verifiers dual-accept before signer emits v2 | do not advance; mixed-fleet break |
| any merge to main | — | forbidden; human is sole merge authority |

---

## REPORT FORMAT

```
Security Remediation Sequence

STAGE 0 — Recon:
  recon.md written:                    [YES/NO]
  Principal map (who signs):           dispatch=<user> gateway=<user> bridge=<user> elpis∈pandora=<y/n>
  sign.sock / groups / audit attrs:    [captured]

STAGE 1 — Tier-1 cuts (all branch-only; applies gated):
  1A H-1 bind:        branch [..]  test [ref/added]  deploy-runbook [y]  CLEAN [y]
  1B H-9 §4 ACL:      branch [..]  pandora-sign design [dedicated-group, elpis KEPT in pandora]
                      apply+rollback runbook [y]  verifies desktop+dispatch+gateway OK, bridge+elpis reach CLOSED [y]
  1C H-2/H-14:        branch [..]  logrotate handled [y]  CLEAN [y]
  1D H-10 caps:       branch [..]  CLEAN [y]
  Applied to .180:    [NONE — gated to human]   Secrets leaked: [MUST BE ZERO]

STAGE 2 — Verifier sweep (read-only GATE):
  In-repo verifiers:        [dispatch + gateway only? Y/N]
  Off-box/peer verifiers:   [NONE / list]
  Durable bare-signed arts: [NONE / list + lifetime]
  VERDICT:                  [GREEN → STAGE 3 proceeds | RED → STOPPED + surfaced]

STAGE 3 — H-9 §2 (only if GREEN / dispositioned):
  Started:                  [YES/NO — gate respected?]
  Phase 0 verifiers dual-accept:  [branch]
  Phase 1 signer dual-accept:     [branch]
  Phase 2 callers v2 + fallbacks: [branch]
  Phase 3 legacy off:             [branch]
  §5 audit+ratelimit+AA carve:    [branch]
  domain-sep test:                [branch, assertions pass]
  Applied to .180:                [NONE — gated to human]

Merges to main performed:   [MUST BE ZERO]
```

---

## FAST-FOLLOW BACKLOG (named so nothing is lost; NOT in this sequence)
- **H-4** — AppArmor profile + systemd hardening for `pandora-substrate-api` (the
  network-facing yet only-unconfined `pandora` daemon). Natural pair to H-1.
- **H-9 §3** — `SO_PEERCRED` UID allow-list on the signer `connection` (native
  addon); and the optional "bridge off user `pandora`" defense-in-depth (needs the
  STAGE 0 DB/config-access finding first).
- **H-11** — recipient consent gate + `require_authenticated()` on file-broadcast
  / `sync_clipboard` BEFORE any untrusted deployment (production promotion gate).
- **H-15** (send-rate-limit), **H-13** (software `device.key` perms/shred),
  **H-5** (sudoers arg-opacity verify), **H-6** (polkit unit-scope revisit),
  **H-12/H-7/H-8** (doc-level foot-guns).
