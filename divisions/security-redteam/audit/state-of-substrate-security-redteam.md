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
