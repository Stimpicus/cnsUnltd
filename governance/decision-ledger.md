# DECISION LEDGER

Every decision that required the architect/founder, or that sets standing org
policy. Append-only — the record is the org's memory of *why*, not just *what*.
New entries at the bottom. Decider: FOUNDER (public/physical/direction), CEO
(operational, within constitution), or SECURITY (a raised BLOCK + its disposition).

| ID | Date | Decision | Rationale | Decider | Status |
|---|---|---|---|---|---|
| D-001 | 2026-06-19 | Merge-Autonomy Policy ratified (AUTO/REVIEW/BLOCKED tiers) | Merge ≠ ship makes auto-merge safe for a constrained tier; dangerous ops stay gated. Human is merge authority for REVIEW/BLOCKED. | FOUNDER | ADOPTED |
| D-002 | 2026-06-19 | Integrate-then-gate as canonical integrator procedure | Validate gate on known-green main first (caught 2 false-RED gate bugs); gate the integrated HEAD, push only on green; RED-case fallback = per-merge/bisect. Stronger compositional check than per-merge; never publishes a red main. | FOUNDER | ADOPTED |
| D-003 | 2026-06-19 | Integrator standing conflict-resolution authorization (exhaustive) | Only two classes auto-resolvable: doc-file unions, and additive non-overlapping structured-file keys. Everything else → REVIEW. Grants nothing beyond conflict resolution; no SDLC step skipped. | FOUNDER | ADOPTED |
| D-004 | 2026-06-19 | elpis-os reframed: private now, public-trajectory | Secret-scan is a STANDING invariant (a secret committed while private becomes a permanent public-history leak on open-source); the disclosure article never lands in elpis-os regardless of visibility. | FOUNDER | ADOPTED |
| D-005 | 2026-06-19 | Development lifecycle (SDLC) codified | Self-reinforcing loop: sprint → audit → portability → evaluate → sprint. Dependency-ordered; security is the bookend; write-to-execute is the lens. | FOUNDER | ADOPTED |
| D-006 | 2026-06-19 | Lane I (Installer) added as standing crunch lane (app + ux) | Installer is a permanent parallel workstream; install-mechanics land REVIEW (trust/boot-adjacent), pure UI is AUTO-eligible; coordinates with Lane D. | FOUNDER | ADOPTED |
| D-007 | 2026-06-19 | Parity-fix base `7ad628c` → approved to merge | Lower-risk direction under uncertainty: merging preserves a closed bug class; deleting was the only path that could silently regress. Merge = code only; bind deploy gated; polkit-grant verification DEFERRED to next audit cycle (audit item #6), not skipped. | FOUNDER | MERGE-APPROVED |
| D-008 | 2026-06-19 | BLOCKED bakes stay blocked | libndk not redistributable + no image-build path (mkosi absent). Precondition unmet. | FOUNDER | BLOCKED |
| D-009 | 2026-06-19 | Org defined as an AI dev ORG: founder/CEO roles | Founder = final authority on public/physical + the only button-presser. CEO (Claude) = day-to-day autonomy strictly inside the constitution. Boromir framing. NO HR/Accounting/Payroll; NO Sales/BD/Growth (anti-extractive thesis). | FOUNDER | ADOPTED |
| D-010 | 2026-06-19 | Eight divisions chartered | Dev, Security/Red-Team (reports to founder), QA/Release-Eng, Docs/DevRel, Design/Product, Infrastructure/Platform, Research/R&D, IP/Legal-Strategy. Org declared right-sized; further divisions only on real need. | FOUNDER | ADOPTED |
| D-011 | 2026-06-19 | CNS Unltd infrastructure: org-as-repo | Division = branch (workshop) + directory on main (display case); EA acts as org-scale integrator; cnsUnltd private-permanent. | FOUNDER | ADOPTED |
| D-012 | 2026-06-19 | Resource model: no dollar budgets | Operating cost is a flat-rate plan (nothing to allocate); dollar budgets would be useless overhead. Track: service/supply as ACTUAL dollars; CC throughput within plan envelope; founder decision-bandwidth. | CEO (cost-benefit), FOUNDER (ratify) | ADOPTED |
| D-013 | 2026-06-19 | CNS Unltd repo bootstrapped; division branches cut; EA cadence drafted | repo instantiated per D-011 | CEO/EA-pending | DONE |
| D-014 | 2026-06-19 | EA promoted + activated; Development CHARTER authored (8/8 set complete); division branches fast-forwarded to main; cadence ACTIVE | Founder promotion + "authorize and complete all work"; EA completed the in-scope setup/integration. Loop not yet turning (no division CC sessions; anchor day untuned) — surfaced, not improvised. | FOUNDER (promote), EA (complete) | ACTIVE |
| D-015 | 2026-06-19 | Founding intake: 8/8 division founding-cycle status docs integrated to main; 1 supplementary deliverable (infra fleet-inventory) WITHHELD (full fleet IPs) + routed back; consolidated rollup authored | First real turn of the coordination machine. Disjoint-path merges under the secret+sanity gate; gate caught Infra's full IPs. No gated op; no BLOCK disposed; loop not started. | EA (intake) | DONE |

## Open items awaiting the architect
*(Full decision-ready detail batched in `executive-assistant/founding-intake-rollup.md`.)*
- **Turn the loop? + cadence anchor day** (cadence §5) — EA default: weekly Thursday-anchored crunch until tuned. **Prerequisite below.**
- **PREREQUISITE — fix session isolation before standing up sessions** (Infra R-5 / Security FLAG-3): the 8 sessions share one working clone; HEAD races landed a commit on the wrong branch this cycle. Recommended: per-session `git worktree`. Turning the loop onto the shared clone reproduces the defect at 8× concurrency.
- **Security FLAG-1 — recommended standing BLOCK** (routed by the EA, only the founder disposes): do not ship `dispatchToOwners`-over-substrate / enable a `critical` capability whose nonce reaches an unauthenticated writer until the H-17 fix (N1) lands.
- **pandora REVIEW-set disposition** — ≥ authorize Development to prepare the single collapsed `preview/trunk-capability` for one-decision review (the keystone the highest-value work sits on).
- **Codename → public name** (Docs DR7 + Design D-1, one decision); **pandora LICENSE choice** (Docs D-2 + IP/Legal).
- **Durable build/dev host** — `.180` vs revive dev VM vs dedicated builder (Infra #1).
- **IP sequencing** — invention-#3 filing vs article publication (counsel + founder); + June-12 attorney-meeting outcome; + what "SpaceChatDB" is (IP/Legal).
- **Permanent home for the unversioned security KB** (`C:\GitRepos\overnight\` is a SPOF — Security FLAG-4).
- **Reconcile ledger D-008** ("mkosi absent" is stale vs repo reality — record-only; bakes stay BLOCKED on libndk).
- **Ratify the EA-authored `divisions/development/CHARTER.md`** if desired (the other seven are FOUNDER-adopted, D-010).
- **Re-push: Infra fleet-inventory deliverable** with full IPs genericized to nicknames (withheld this intake).

## Carried-forward (owned by Security/Red-Team)
- `7ad628c` install polkit grant — verify post-merge what it permits + scope (audit item #6)
- H-9 §2 verifier sweep; H-4 / H-11 / H-15 hardening backlog
