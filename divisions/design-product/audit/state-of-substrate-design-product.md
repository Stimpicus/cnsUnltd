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
