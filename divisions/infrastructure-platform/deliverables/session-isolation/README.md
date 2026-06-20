# Session Isolation — per-session/per-lane worktree provisioning

**Owner:** Infrastructure / Platform (Div 6). **Closes:** R-5 (shared-clone `HEAD`
race). **Status:** feature-complete on `feature/session-isolation-provisioner`,
handed to the EA. The 8× concurrent wheel-turn validation is **founder-gated** (per
`work-orders/claude-code-WO-infra-crunch-session-isolation.md`) — not self-adjudicated here.

## The defect
The 8 division sessions + the EA + instrument sessions share **one** working clone.
`HEAD` is global, so concurrent checkouts race and a commit can land on the wrong
branch (observed live: a founding commit briefly landed on another division's branch).
The manual `git worktree` per session was the stopgap. This is the systematic fix.

## The mechanism
One **git worktree per session** over the shared object store: each session gets its
own `HEAD`/index/working-tree; the race is gone by construction. `worktrees.sh`
provisions them deterministically and guards commits.

## Usage
```
worktrees.sh provision infrastructure-platform        # idempotent; prints the worktree path
worktrees.sh provision A sprint/A/foo --from origin/main   # ad-hoc crunch lane
worktrees.sh assert  infrastructure-platform          # verify HEAD == the right branch
worktrees.sh commit  infrastructure-platform -m "msg" --push -- path/one path/two
worktrees.sh doctor                                   # health + anti-pattern detection
worktrees.sh list | remove <name> | --self-test
```
- **`provision`** is idempotent + locked (a shared lock under the common `.git` so 8
  concurrent calls can't race), and **refuses** when a branch is checked out in the
  MAIN clone — that *is* the R-5 anti-pattern.
- **`commit`** is the guarded entry point: it asserts the worktree is on the expected
  branch, stages **named paths only** (never `-A`), and runs the canonical
  **board-hygiene** gate (live-box identifiers AND secrets) before it will land. A
  session never has to remember the hygiene rules — the tool enforces them.
- **`doctor`** flags the anti-pattern (a session branch occupying the shared clone),
  stale locks, and unregistered live worktrees (instruments/lanes).

## Config knobs (env-overridable; defaults are PROVISIONAL — see Decisions)
| Knob | Default | Effect |
|---|---|---|
| `CNS_WT_ROOT` | unset → flat sibling `<parent>/<repo>-<name>` | worktree location/layout |
| `CNS_EA_BRANCH` | `main` | the branch the EA's integration worktree checks out |
| `CNS_LANE_BASE` | `origin/main` | base for a brand-new ad-hoc lane branch |
| `CNS_SESSION_REGISTRY` | `./sessions.tsv` | the session→branch map |

---

## DECISIONS — runtime-model knobs (founder/EA's to set; surfaced, not guessed)

Each ships with a provisional default so the tool is runnable now; none is a silent
choice. Setting these is a config change, not a rewrite.

**D1 — Host for the worktree fleet.** *Where do the worktrees physically live?*
- **(a) Windows orchestration host** (current reality — all sessions run here today). Recommended *for now*: zero new dependencies, matches the existing `cnsUnltd-*` siblings.
- **(b) `.180`** — per the standing self-hosted-dev-on-`.180` requirement. Cleaner long-term, but couples to the dev-overlay (T2.3, gated) and to `.180` being the dev host.
- *Forecloses:* picking (b) before the dev-overlay lands strands sessions on an unprovisioned box. **Recommend (a) now, (b) once the overlay is applied.**

**D2 — Layout (`CNS_WT_ROOT`).** *Flat siblings vs a dedicated parent dir?*
- **(a) Flat sibling** `<parent>/cnsUnltd-<name>` (default) — matches the three worktrees already in use; nothing to migrate.
- **(b) Dedicated `cnsUnltd-worktrees/<name>`** — tidier, one folder to prune, but orphans/renames the existing three. *Forecloses:* (b) means a one-time move of live worktrees. **Recommend (a).**

**D3 — EA isolation (`CNS_EA_BRANCH`).** *How does the integrator avoid racing division checkouts?*
- **(a) EA worktree on `main`** (default) — the integrator merges in its own `main` worktree; the shared MAIN clone is then free/detached. Simple, one model for all.
- **(b) Dedicated integration clone** — strongest isolation for the merge driver, at the cost of a second object store. *Forecloses:* (a) keeps the EA inside the shared object store (one gc/lock domain). **Recommend (a); revisit if integration contends.**

**D4 — Lifecycle.** *Persistent vs ephemeral worktrees?*
- **Recommended hybrid:** division + EA worktrees are **persistent** (one per session, long-lived); crunch lanes / instruments are **ephemeral** (`provision … --from …` then `remove` at sprint end). *Open:* should the tool auto-reap ephemeral lanes on a clean tree, or leave teardown explicit? **Recommend explicit `remove` first; add auto-reap only if sprawl appears.**

**D5 — Provisioning authority.** *Who calls `provision`?*
- **Recommended:** **self-serve** for standing sessions (each session provisions itself on startup via its name); **orchestrator-assigned** for crunch lanes (the crunch master provisions `A/B/C/…` before dispatch). *Forecloses:* a purely-central model bottlenecks on the orchestrator; a purely-self-serve model has no one provisioning spawned lanes. The hybrid matches how sessions actually start.

**D6 — Mechanism (informational, not a knob here).** git worktree (shared object
store) was chosen over per-session full clones: far less disk, instant ref sharing,
and it fully removes the `HEAD` race. Trade-off: one shared gc/lock domain. Separate
clones remain the fallback if the shared object store ever becomes a contention point.
