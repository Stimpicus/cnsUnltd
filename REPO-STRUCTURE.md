# REPO STRUCTURE & MIGRATION MAP

How `cnsUnltd` is laid out, and where the documents already authored migrate to.

## Layout
```
cnsUnltd/                         (PRIVATE, permanent — the org's operating system)
  README.md                       what this repo is
  REPO-STRUCTURE.md               this file
  charter/
    MISSION.md  VISION.md  VALUES.md  CORNERSTONES.md  LORE.md
    org-chart.md                  ← migrate: org-chart-overview.md
  governance/
    decision-ledger.md            append-only; the org's memory of WHY
    resource-model.md             no dollar budgets; track actuals + throughput + attention
    deliverable-spec.md           what divisions report so the CEO can decide
    development-lifecycle.md      ← migrate: pandora-development-lifecycle.md
    merge-autonomy-policy.md      ← migrate: merge-autonomy-policy.md
  divisions/
    development/        CHARTER.md  status/  deliverables/   (product code → pandora, elpis-os)
    security-redteam/   CHARTER.md ← org-security-redteam-charter.md ; status/ deliverables/
    qa-release-eng/     CHARTER.md ← org-qa-release-engineering-charter.md
    docs-devrel/        CHARTER.md ← org-docs-devrel-charter.md
    design-product/     CHARTER.md ← org-design-product-charter.md
    infrastructure-platform/  CHARTER.md ← org-infrastructure-platform-charter.md
    research-rnd/       CHARTER.md ← org-research-rnd-charter.md
    ip-legal-strategy/  CHARTER.md ← org-ip-legal-strategy-charter.md
  executive-assistant/
    EA-charter.md
    cadence.md                    the timed schedule across divisions (author next)
  work-orders/                    CEO directives to divisions (e.g. crunch master, audit, article)
```

## Branch model (decision D-011)
- `main` — the org's live board. Everyone reads it. Articles, ledger, division
  *delivered* artifacts, charters. Always coherent.
- `division/<name>` — each division's workshop. Its CC session works here.
- The **EA integrates** division deliverables from branch → `main` under the gate
  and the merge-autonomy policy (org-scale Lane C). Branch = workshop; directory on
  main = display case.

## What migrates in (already authored, in /mnt/user-data/outputs/)
- `org-chart-overview.md` → `charter/org-chart.md`
- `pandora-development-lifecycle.md` → `governance/development-lifecycle.md`
- `merge-autonomy-policy.md` → `governance/merge-autonomy-policy.md`
- the 8 `org-*-charter.md` → `divisions/<name>/CHARTER.md`
- `claude-code-MASTER-orchestration-overnight.md`, `claude-code-work-order-*.md`
  → `work-orders/` (or per issuing division)

## Setup (a CC session does this — the CEO can't touch the host)
1. `git init C:\gitRepos\cnsUnltd`; create private remote; push `main`.
2. Lift this scaffold from /mnt/user-data/outputs/cnsUnltd/ onto `main`.
3. Migrate the documents above into place.
4. Create the `division/<name>` branches.
5. Stand up the per-division CC sessions + the EA session.
6. Secret-scan before the first commit (standing hygiene, even private).
