# FOUNDING INTAKE — consolidated rollup
**Prepared by:** the EA (execAssistClaude) · **Date:** 2026-06-19 · **For:** the founder/board
**Source:** the 8 `divisions/<name>/status/founding-cycle.md` deliverables, intaken to `main`.
Read this, not the eight documents. Every per-division claim is cited in its own deliverable.

---

## Integration
- **8/8 founding-cycle status docs integrated to `main`** (intake HEAD `e04bd7e`; this rollup + D-015 sit on top).
  Seven via `--no-ff` merges (disjoint paths, zero conflicts); **Infrastructure/Platform via partial intake**.
- **1 supplementary deliverable WITHHELD:** `infrastructure-platform/deliverables/fleet-and-build-inventory-2026-06-19.md`
  carries the **full numeric IPs of the fleet** (the `.180` and `.196` boxes and the dev VM) — live-box detail that fails the
  secret gate. It **never entered main's history**; routed back to Infra to genericize the IPs → nicknames and re-push.
  Infra's `founding-cycle.md` itself is clean and was intaken. Other supplementary deliverables (development
  branch-inventory, security attack-surface-onboarding, research portability-inventory, ip-legal's 3 registers) are clean and integrated.
- **Pending:** none outstanding for intake (all 8 directors delivered). One deliverable awaiting Infra re-push (above).

## Secret-scan
- **CLEAN on everything landed.** No keys, tokens, JWTs, hashes, MACs, credentials, or full IPs on `main`
  (staged-index scan + post-merge defense-in-depth sweep). The one real-secret hit (Infra's full IPs) was caught and withheld.
- The `.180` *nickname* appears in 5 divisions' clean docs — acceptable per the standing ruling (nickname OK in
  operational docs; full IPs are not). One finding *about* the build-publisher private key (in elpis-os) is reported by Infra/Security as
  **gitignored + untracked, no leak** — no key material present.

## Gated touched: **NONE**  ·  Loop started: **NO**
Confirmed. No product-repo merge, no `.180`/flash/deploy, no publication, no Security BLOCK disposed. The living
disclosure article was **not** integrated (R&D R-2) and is **not** on `main`/`elpis-os` — confirmed fenced.

---

## Per-division (one row each)

| Div | State of domain (1 line) | Proposed first cycle (1 line) | Top dependency | Gated? |
|---|---|---|---|---|
| **1 Development** | Overnight crunch worked; AUTO landed both repos — but the **entire pandora REVIEW set (trunk + the capability device-control product) is unlanded**, one decision from `main`. | Collapse the pandora REVIEW trunk to **one** reviewable branch + reproduce/fix Security's audit GAPs, threat-informed. | Founder disposes the REVIEW set (≥ authorize the single collapsed trunk) + turns the loop. | Prepares only; merge/`.180`/flash gated. |
| **2 Security/Red-Team** | Adversary stood up; **audit cycle-1 ran**, the write-to-effect map exists, and it **proactively found H-16 & H-17 (HIGH)** — incl. **unauthenticated Confirm → `critical` actuation (e.g. smart-lock unlock)**. | Run the **never-run verifier-enumeration sweep** (the HARD GATE blocking the highest-value H-9 §2 fix); close carried-forward #6 (polkit/self-pair). | Founder disposition on **FLAG-1 (recommended standing BLOCK)**; a permanent home for the unversioned security KB. | Recommends a **BLOCK**; all deploy/`.180`/merge gated. |
| **3 QA/Release-Eng** | Toolchest is **built but unlanded**; the named gate **`ci-verify.sh` exists as no committed file**; the elpis-os QA suite is stranded on **stale `sprint/D` branches that would *regress* the `7ad628c` parity fix if merged naively**. | Commit `ci-verify.sh` as a spec+reference; author the integrator digest/tier template; map the stranded suite's rebase-and-land plan. | Infra (mkosi ship-blocker, CI runners); founder disposes `integration/auto-elpis`. | Prepares; landing/flash/license-bakes gated. |
| **4 Docs/DevRel** | elpis-os OSS docs are strong, but **pandora — the disclosure vehicle — has no LICENSE/CONTRIBUTING/CoC and a README/ARCHITECTURE stale by 60 commits**: readiness inverted vs the disclosure timeline. | Source-of-truth drift register; write the real `adoption-path.md` (a placeholder today); draft the README/ARCH drift-correction on-branch. | Founder: codename→public name + pandora LICENSE choice; Security review of any pre-disclosure doc. | Prepares; publish/repo-public/brand = founder; Security-flagged. |
| **5 Design/Product** | Token system strong, but the **brand is unrealized** (no wordmark/tagline anywhere) and there are **two device-control paradigms mid-migration** (bespoke on `main` vs the generic descriptor renderer on the REVIEW trunk); fonts load from a CDN at runtime. | Product-Principles standing check; Design-System & Brand spec v0; **review the `ControlSurface` contract *before* the Lane A fan-out lands**. | Founder disposes the brand/wordmark; Development owns `ControlSurface` + needs the review pre-fan-out. | Specs only; brand = founder's button; adoption REVIEW. |
| **6 Infrastructure/Platform** | Ship-blocker moved *"mkosi absent" → "mkosi present-but-fragile"* (one **unreachable** VM, stopgap 20.x, no image-build CI); `ci-verify.sh` absent; **session-isolation DEFECT: the 8 sessions share one clone → HEAD races → commits land on the wrong branch (hit live this cycle).** | Make mkosi durable/reproducible; implement `ci-verify.sh` (with QA); CI-on-push; usage-envelope monitor. | Founder picks the durable build/dev host (`.180` vs dev VM vs dedicated builder); revive dev VM/`.196`. | Authoring green; `.180` apply / runner-on-`.180` / flash = founder. |
| **7 Research/R&D** | Substrate portability is **genuinely proven** (2 substrates × 2 layers, same test) **+ a bonus Postgres-RLS result that advances the threat model** — but the headline **"4-way matrix" is asserted-by-composition, not earned-green**; the living article is correctly fenced (PRIVATE). | Make the 4-way matrix an **exercised, CI-gated** artifact; resolve the "keypair" corner; prior-art scan — **sequenced after Security's audit** (loop order). | Security AUDIT must finish before PORTABILITY; QA/Infra `ci-verify.sh` for the matrix runner. | Ships nothing; **article must NOT be integrated** (R-2); Orrery hardware = founder spend. |
| **8 IP/Legal-Strategy** *(does not practice law)* | **IP-readiness gate is RED, structurally:** foundational **invention #3 ("universal device command dispatch") is UNFILED** while the private article describes that same subject; **June-12 attorney-meeting outcome unknown**; elpis-os GPLv3 posture sound (nothing encumbered baked) but no `NOTICE` file yet. | Stand up the 3 registers (seeded); prep the EVALUATE ledger-reconciliation packet; draft the GPLv3 `NOTICE`; build the disclosure-timing checklist for counsel. | Founder: June-12 meeting outcome; what "SpaceChatDB" is; counsel confirmation. | Prepares only; #3-vs-publication = counsel+founder; any publish = founder. |

---

## Cross-division signals (observed; the EA does not adjudicate)

**Boundary overlaps** (adjacent territory — all currently *complementary*, none hostile; flagged so the CEO can confirm the split):
- **`ci-verify.sh` — QA × Infra.** Both claim it; both already state the same split ("QA owns the gate *logic*, Infra owns the runner/plumbing"). Co-owned artifact; needs one written agreement.
- **The disclosure article — Security × DevRel × R&D × IP/Legal.** Four organs touch one artifact (Security = content, DevRel = framing, R&D = portability/theory half, IP/Legal = IP-readiness). Self-described as complementary; IP/Legal (T2-b) proposes one agreed multi-organ precondition list — sensible.
- **`ControlSurface` descriptor — Development × Design/Product.** Dev owns the code; Design wants a coherence review *before* the Lane A fan-out multiplies it. A sequencing handshake, not a turf clash.
- **Public name/brand — Docs/DevRel (DR7) × Design/Product (D-1).** Both surface the *same* unresolved codename→public-name decision. Convergent, not conflicting.

**Dependency chains / likely critical path:**
- **mkosi (Infra) is the universal ship-blocker** — Development's bakes, QA's consumer-flash GO, and any image work all wait on Infra making mkosi durable + reachable.
- **`ci-verify.sh` (Infra+QA) is the shared automation prerequisite** — Development needs it green before the next AUTO run; R&D's matrix runner (T1.1) is blocked on it existing; QA owns its logic.
- **The pandora REVIEW trunk (Dev T1a) is the keystone** — the capability/device-control product, the Lane A fan-out, pandora's guard-parity restoration, and Design's `ControlSurface` review all sit on top of it. Until the architect disposes it, the highest-value work stays off `main` and rebases on a moving target.
- **Loop order is real and self-enforced:** **Security AUDIT → Development sprint (threat-informed) → R&D PORTABILITY → EVALUATE (article reconciliation).** Several divisions explicitly sequence themselves after Security's audit; Security's verifier-sweep (S1) is the gate for the single highest-value latent fix (H-9 §2).

**Contradictions:**
- **Record vs reality — ledger D-008 says "mkosi absent"; the repo now builds images with mkosi.** Infra (R-4) and Development both flag it. Recommend reconciling the record (the BLOCKED status of the bakes stays — still on the libndk license, not the build path). *Surfaced for the founder; I did not rewrite a ratified decision.*
- No division-vs-division factual contradictions otherwise — the eight reports are strikingly consistent. (QA's warning that the stale `sprint/D` branches would *regress* `7ad628c` is a correct trap-flag, not a disagreement.)

---

## FOR THE FOUNDER (surfaced, not decided) — batched

**Decisions owed (your queue — short on purpose):**
1. **Turn the loop? + cadence anchor.** Every first cycle waits on it (ledger D-014 open). **But see #2 first** — there is a prerequisite.
2. **Session-isolation fix BEFORE standing up sessions (prerequisite to #1).** Infra R-5 / Security FLAG-3: the 8 sessions share one working clone; HEAD races landed a commit on the wrong branch *this cycle*. Recommended fix: **per-session `git worktree`** (Infra #4). Turning the loop onto the current shared clone reproduces the defect at 8× concurrency.
3. **Security FLAG-1 — recommended standing BLOCK** (routed, not disposed by me): do not ship `dispatchToOwners`-over-substrate / enable any `critical` capability whose nonce can reach an unauthenticated writer **until the H-17 fix (N1) lands.** Only you dispose of this.
4. **pandora REVIEW-set disposition** — at minimum authorize Development to prepare the single collapsed `preview/trunk-capability` for one-decision review (keeps the keystone moving without a gated merge).
5. **Codename → public name** (Docs DR7 + Design D-1 — one decision, two divisions).
6. **pandora LICENSE choice** (Docs D-2, with IP/Legal) — the disclosure vehicle has none.
7. **Durable build/dev host:** `.180` vs revive the dev VM vs a dedicated builder (Infra #1).
8. **IP sequencing:** invention-#3 filing vs article publication (**counsel + founder**); plus the **June-12 attorney-meeting outcome** and **what "SpaceChatDB" refers to** (IP/Legal needs both).
9. **Permanent home for the unversioned security knowledge base** (`C:\GitRepos\overnight\` is a single point of failure — Security FLAG-4).
10. **Reconcile ledger D-008** ("mkosi absent" is stale).

**Gated work consolidated into the queue (the EA holds all of this; you press):**
- **Product-repo merges** (REVIEW/BLOCKED): the pandora trunk-capability + Lane A fan-out + installer-ux + security-invariant-tests; elpis-os parity-fix base (D-007, RED:SECURITY+PARITY), Tier-B security cuts, the QA toolchest, `integration/auto-elpis` (~30 merges).
- **`.180` applies/flashes/deploys:** H-1 loopback bind (1A) and the 1B/1C/1D security cuts; dev-overlay apply; standing a CI runner on `.180`; the consumer-flash GO pass; any snapshot.
- **BLOCKED bakes (D-008):** `bake-firefox-wine`, `bake-waydroid-microg` (libndk license — counsel).
- **Disclosure / publication:** the living article stays PRIVATE (never `main`/`elpis-os`/publish); repo-going-public; brand/wordmark publication.
- **Hardware spend:** Orrery physical display (none requested this cycle).

**EA carry-forward (mine to do once you turn the loop):** land the Lane C integrator digest as a durable per-cycle artifact (Dev gap #3); sequence cadence inside the usage envelope once Infra's meter exists; keep these registers current each cycle.

---

**Ledger:** D-015 appended (founding intake complete; 8/8 status integrated, 1 deliverable withheld).
**EA posture:** within charter — integrated under the gate, recorded, surfaced. No founder button pressed, no BLOCK disposed, loop not started. **Held.**
