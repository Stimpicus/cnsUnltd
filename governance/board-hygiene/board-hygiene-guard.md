# Board-Hygiene Guard — proposal for org-wide adoption

**From:** Infrastructure / Platform (Div 6) · **Status:** ready to adopt · 2026-06-19
**Artifact:** `board-hygiene-scan.sh` (in this directory) — tested, self-testing.

## The problem this closes
Division deliverables are hand-written, and the standing policy that keeps
**live-box identifiers** off the cnsUnltd board (full LAN IPs, MAC addresses,
private-key files — box *nicknames* like `.180` are fine) was enforced only by the
EA's eye. This cycle the Infra fleet deliverable carried real IPs and a key path;
the EA caught it by reading. That's a single point of failure that doesn't scale to
8 divisions × N cycles. The fix is to make the rule **mechanical** — the board
analogue of the product repos' secret-scan (orchestration WO P-4).

## What the guard does
Exit-code-driven (`0` clean / `1` block), two tiers so it stays credible:

- **BLOCK** (fails the scan): private/LAN IPv4 (RFC1918 + CGNAT + link-local),
  MAC addresses, `BEGIN … PRIVATE KEY` banners, private-key file references, SSH
  private-key filenames, and `secret/token/password/api_key =` assignments.
- **WARN** (prints, does not fail): `.pem` references and absolute home/SSH paths.

Deliberately **not** flagged: box nicknames (`.180`, `.196`, `dev VM`), hardware
capacity facts (core/RAM/disk counts), kernel versions, and public/RFC5737
documentation IPs (e.g. `203.0.113.x`) — none are live-box identifiers, so flagging
them would erode trust in the guard.

## Proof it works (run `--self-test`, or see the founding-cycle report)
- `--self-test`: a clean fixture passes; a synthetic fixture covering all BLOCK
  classes is blocked. Fixtures are assembled at runtime — no real identifier is
  committed.
- Run against the **pre-mask** Infra deliverable, it BLOCKs all three box IPs and
  the key path. Against the **masked** version, CLEAN. It would have caught this
  cycle's miss before commit.

## Recommended wiring (two enforcement points)
1. **EA integration gate (the chokepoint — highest leverage).** Before integrating
   any `division/<name>` branch, the EA runs `board-hygiene-scan.sh divisions/<name>/`
   and treats a BLOCK like a secret-scan hit: do not integrate; route back. This
   catches the miss regardless of which division forgot — exactly where this cycle's
   catch happened, now automated.
2. **Per-division pre-commit (shift-left, optional).** Divisions run
   `board-hygiene-scan.sh --staged` before committing (or install it as a
   `core.hooksPath` pre-commit hook). Cheaper to catch at authoring time.

## Promotion ask (founder / EA)
- **Move** `board-hygiene/` from this division's `deliverables/` to a shared path on
  `main` (suggest `governance/board-hygiene/`) so every division and the EA share one
  copy.
- **Ratify** a one-line addition to `governance/deliverable-spec.md` under "Format
  discipline": *"Deliverables reference live boxes by nickname only; full LAN IPs,
  MAC addresses, and private-key files never appear on the board. Enforced by
  `governance/board-hygiene/board-hygiene-scan.sh` at integration."*
- **Adopt** the EA integration gate (#1) as standing procedure.

Merge ≠ ship still holds: this is a board-content guard, not a live operation. The
"switch it on at integration" act is the EA's to make.

## Boundary note
The *policy* (what may appear on the board) is the founder/EA's to ratify; Infra
owns the *tooling* that enforces it — same split as Infra owning CI runners while QA
owns the gate logic. This guard is the tooling, offered for that ratification.

---

## EA addendum — switch-on + scope (2026-06-19, D-019)
**Switched on** by the EA at integration (cadence §0). Promoted here from Infra's
`deliverables/`. Two operating notes:
1. **Gate scope is `divisions/<name>/` (division content) + new governance/EA board
   content** — the chokepoint where this cycle's catch happened. The archival
   `work-orders/` (founder-ratified **verbatim** records) are **out of scope**: a
   full-board scan flags two bare software-key filename references there (H-13 finding
   context — a software-key *filename*, not a live-box identifier or secret), which
   are **accepted** under the verbatim-archival ruling and are NOT edited. Do not let
   those two known hits block an integration.
2. **The `--staged` mode self-trips only on the commit that adds/edits this script
   itself** (its synthetic fixtures contain pattern literals; `--staged` does not
   self-skip the way directory mode does). For all other commits — including every
   division's pre-commit use — `--staged` is correct. The commit that introduced this
   guard was therefore dogfooded in **directory mode** over the changed board dirs (CLEAN).
