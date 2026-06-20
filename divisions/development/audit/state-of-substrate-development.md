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
