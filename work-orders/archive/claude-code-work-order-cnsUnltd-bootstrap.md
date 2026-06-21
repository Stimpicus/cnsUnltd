# WORK ORDER: CNS Unltd repo bootstrap + EA promotion
## For a fresh Claude Code session → to be promoted to Executive Assistant on completion

**Addressed to:** a fresh CC session on the Windows host (PowerShell, `C:\gitRepos`).
**Repo:** `C:\gitRepos\cnsUnltd` — already `git init`'d with a private remote
configured (the founder did this). This is the **org's operating system**, PRIVATE
and permanent. It is NOT product code (that's `pandora` / `elpis-os`).
**Your job tonight:** lift the prepared scaffold onto `main`, migrate the existing
org documents into place, cut the division branches, and prepare the repo so the
founder can promote you to **Executive Assistant** afterward. The founder is asleep
— this runs unattended, so it is **branch-and-commit work only, no destructive
operations, secret-scan before every commit.**

---

## PRIME DIRECTIVE (unattended-run safety)
- **Additive only.** You are creating files, committing, and pushing to a fresh
  repo. Do not delete or rewrite history. Do not touch `pandora` or `elpis-os`.
- **Secret-scan before EVERY commit** (gitleaks/trufflehog or a regex fallback).
  cnsUnltd is private, but secret-scan is standing hygiene — and several source
  documents reference live-box details (`.180`, identity hashes): **none of those
  belong in this repo.** If a doc you're migrating contains a secret or a live
  credential, STOP and leave it out, noting it in your report.
- **Never `git add -A`.** Stage explicitly named paths.
- **Verify, don't assume.** After each phase, confirm the tree is what you intended
  before committing (the host shell is `dash`-like in some tools and PowerShell in
  others — brace expansion and path quoting bite silently; check your work).
- **No authority beyond setup.** You are not yet the EA. Do not start any division
  cycle, do not merge anything in `pandora`/`elpis-os`, do not press any
  gated/physical button. Build the repo, then stop and report.

---

## SOURCE MATERIAL
The founder has a prepared scaffold and a set of already-authored org documents
(delivered via the chat session, in the founder's `outputs` — they will place them
where you can reach them, or paste them). Treat these as the canonical content:

**Scaffold (already written — lift verbatim onto `main`):**
- `README.md`, `REPO-STRUCTURE.md`
- `charter/MISSION.md`, `VISION.md`, `VALUES.md`, `CORNERSTONES.md`, `LORE.md`
- `governance/decision-ledger.md`, `resource-model.md`, `deliverable-spec.md`
- `executive-assistant/EA-charter.md`

**Documents to MIGRATE into the structure (already authored separately):**
- `org-chart-overview.md`            → `charter/org-chart.md`
- `pandora-development-lifecycle.md` → `governance/development-lifecycle.md`
- `merge-autonomy-policy.md`         → `governance/merge-autonomy-policy.md`
- the 8 `org-*-charter.md` files     → `divisions/<name>/CHARTER.md` (map below)
- `claude-code-MASTER-orchestration-overnight.md` + the
  `claude-code-work-order-*.md` files → `work-orders/`

If any source document is not available to you, **create the directory and a
`PLACEHOLDER.md` noting what belongs there**, and list it in your report as
"awaiting content" — do not invent the content.

---

## DIVISION NAME MAP
```
org-security-redteam-charter.md        → divisions/security-redteam/CHARTER.md
org-qa-release-engineering-charter.md  → divisions/qa-release-eng/CHARTER.md
org-docs-devrel-charter.md             → divisions/docs-devrel/CHARTER.md
org-design-product-charter.md          → divisions/design-product/CHARTER.md
org-infrastructure-platform-charter.md → divisions/infrastructure-platform/CHARTER.md
org-research-rnd-charter.md            → divisions/research-rnd/CHARTER.md
org-ip-legal-strategy-charter.md       → divisions/ip-legal-strategy/CHARTER.md
(Development has no separate charter file yet)  → divisions/development/CHARTER.md = PLACEHOLDER
```

---

## PHASE 0 — Recon (read-only)
1. Confirm `C:\gitRepos\cnsUnltd` is a git repo with a remote (`git remote -v`) and
   that `main` exists (or create it: `git switch -c main` if the repo is empty).
2. Confirm it is otherwise empty / fresh. Report the starting state.
3. Locate the source documents. Report which are available and which are missing.

## PHASE 1 — Lay down `main` (the live board)
1. Create the directory tree (PowerShell — avoid brace expansion; make dirs
   explicitly):
   ```
   charter\  governance\  executive-assistant\  work-orders\
   divisions\development\  divisions\security-redteam\  divisions\qa-release-eng\
   divisions\docs-devrel\  divisions\design-product\
   divisions\infrastructure-platform\  divisions\research-rnd\
   divisions\ip-legal-strategy\
   ```
   In each `divisions\<name>\`, also create `status\` and `deliverables\` (each with
   a `.gitkeep`).
2. Place the scaffold files (verbatim) and migrate the authored documents per the
   maps above. For any missing source, drop the `PLACEHOLDER.md`.
3. **Verify the tree** matches `REPO-STRUCTURE.md`. Fix discrepancies before committing.
4. Secret-scan the staged set. If clean, commit:
   `chore: establish CNS Unltd operating system — charter, governance, divisions, EA`
   Push `main`.

## PHASE 2 — Cut the division branches (the workshops)
For each of the 8 divisions, create a branch off `main`:
```
division/development            division/security-redteam
division/qa-release-eng         division/docs-devrel
division/design-product         division/infrastructure-platform
division/research-rnd           division/ip-legal-strategy
```
Push all branches. (They start identical to `main`; each division's CC session will
work on its own branch, and the EA will integrate deliverables back to `main`.)
Do NOT put any work on them yet — that's the divisions' job, under the EA's cadence,
once the founder promotes you.

## PHASE 3 — Prepare for EA promotion (do not act as EA yet)
1. Author `executive-assistant/cadence.md` as a **DRAFT proposal** (not active):
   a proposed timed schedule across divisions that turns the lifecycle loop
   (Development crunch on a weekly cadence; Security continuous + a scheduled audit
   deep-pass; R&D portability cycles; the evaluate-phase article reconciliation).
   Mark it clearly `STATUS: DRAFT — awaiting founder activation`. Reference the
   EA-charter's hard limits (schedules/coordinates, never authorizes; cannot press
   founder buttons or override a Security BLOCK).
2. Append one entry to `governance/decision-ledger.md`:
   `D-013 | <date> | CNS Unltd repo bootstrapped; division branches cut; EA cadence drafted | repo instantiated per D-011 | CEO/EA-pending | DONE`
   Secret-scan, commit to `main` (`docs: add draft EA cadence + ledger D-013`), push.
3. **STOP.** Do not start any cycle. Report and await promotion.

---

## REPORT FORMAT
```
CNS Unltd bootstrap — complete

Repo state:        main pushed @ [hash]; [N] division branches pushed
Scaffold placed:   [11/11 files? ]
Migrated:          [which docs landed; which → PLACEHOLDER (awaiting content)]
Tree matches REPO-STRUCTURE.md:  [Y/N]
Secret-scan:       CLEAN on every commit  (any doc withheld for secrets? [list])
EA cadence:        drafted, STATUS: DRAFT — awaiting activation
Ledger:            D-013 appended
Branches:          [list]
Stopped before:    acting as EA / starting any cycle / touching pandora|elpis-os  [confirm]
Awaiting:          founder promotion to Executive Assistant
```

---

## AFTER YOU REPORT (the founder's action, not yours)
The founder will review and **promote this session to Executive Assistant.** Only
then do you assume the EA charter: turning the loop, integrating division
deliverables to `main` under the gate, keeping the records, guarding the scarce
resources, and surfacing decisions — always within the limits in
`executive-assistant/EA-charter.md`. Until promoted, you are a setup session and
nothing more.
