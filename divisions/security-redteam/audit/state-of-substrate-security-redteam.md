## Div2 — Security/Red-Team · the adversarial truth

*The section the disclosure evidence leans on. Tags: [VERIFIED] live-tree this turn;
[DOCUMENTED] SECURITY.md/CLAUDE.md; [ASSESSED] red-team judgement.*

**f2f as a write-to-execute instance.** The attack surface IS the reducer set; a "command" is a
row-write whose handler is selected by validated enum, never by an evaluated field. The security
question is therefore: *can a write select an action, or reveal state, it should not?*

**VECTOR findings — closed-in-code vs documented-only:**
- **VECTOR-O (call-permission probing oracle)** — [VERIFIED @ d2fa794] line-level source re-read
  done this turn: the permission check runs **first** in `initiate_session` (`sessions.rs:210`)
  and `add_participant` (`:413`), before any online/blocked/Invisible/DND check, and all three
  unavailable causes collapse to one identical `"User unavailable"` (`:223-231`). Oracle closed
  in source. *Residual (LOW):* a theoretical branch-timing side-channel (each unavailable cause
  scans a different table) — strings identical, far weaker than the closed content oracle.
- **VECTOR-B/C (context-token harvesting)** — [VERIFIED @ d2fa794] raw tokens hashed at ingestion
  (`register_presence:51` / `initiate_session:256` → `helpers::hash_context_token`,
  `helpers.rs:59-65`: a domain-separated **keyed** HMAC per NIST SP 800-108), never stored —
  source-confirmed this turn. Closes harvesting/precomputation from the public presence/session
  tables. *Residual (LOW):* the opaque hash in the public `presence` table allows context
  *correlation* (same-hash surfaces), not token recovery.
- **VECTOR-4 (per-sender signal cap)** — [VERIFIED @ d2fa794] 500 rows/sender/session
  (`sessions.rs:559`) + 8192-byte payload (`:526`) + 200/60s rate (`:549`), behind both-ends
  participant checks — source-confirmed this turn. A DoS-bound, not a confidentiality control.
- **Sentinel guard (the f2f analogue of H-17)** — [VERIFIED @ d2fa794] every sensitive reducer
  opens with `require_authenticated`/`require_admin` (28 guards / 30 `#[reducer]`; the ungated
  remainder are connection-lifecycle + scheduler reducers, gated by their own mechanism). No f2f
  write becomes another client's action without a writer auth gate.
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
(4) VECTOR-O / -B/C / -4 + sentinel guard — **VERIFIED closed in source this turn** (@ `d2fa794`);
the only residual is runtime-only (a live pass to exploit-prove M-08 and measure VECTOR-O branch
timing) — owed to QA's live-`onApplied` verification, not to a source re-read.

**Disclosure-evidence read:** the VECTOR catalogue + safeguards *are* the prior-art record. It is
strong on the closed items; the honest gaps to disclose are M-08 (RLS-pending) and H-17 (open).
