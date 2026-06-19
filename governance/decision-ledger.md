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

## Open items awaiting the architect
- (none currently — REVIEW set from the 2026-06-19 sprint dispositioned)

## Carried-forward (owned by Security/Red-Team)
- `7ad628c` install polkit grant — verify post-merge what it permits + scope (audit item #6)
- H-9 §2 verifier sweep; H-4 / H-11 / H-15 hardening backlog
