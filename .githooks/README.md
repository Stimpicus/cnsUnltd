# .githooks — cnsUnltd's durable hook directory

**Wire it (ONCE per clone) — use an ABSOLUTE path (rule R4):**
`git config core.hooksPath "$(git rev-parse --show-toplevel)/.githooks"`
A *relative* `.githooks` resolves per-worktree-top, so a worktree on a stale branch whose
tree lacks `.githooks/` gets **no hook at all** — the gap the 8× wheel-turn surfaced
(`D-035`, finding 2). An **absolute** path makes every worktree/branch find THIS hook file.
The hook stays durable — it lives in the repo, not an un-committed `.git/hooks/`.

- **`pre-commit`** → **branch-independent** (R4): resolves
  `governance/board-hygiene/secret-scan.sh` from a fixed canonical source (`origin/main`,
  else local `main`) — **never the per-branch tree** — and runs it (secret-VALUE guard,
  correct **diff-mode ERE**) on the staged diff. So it gates even on a stale branch/worktree
  whose own tree lacks the scanner. **Fails closed** if the canonical scanner is
  unresolvable, with one scoped, audited `BOARD_HYGIENE_ALLOW_NO_SCANNER=1` override.

**Not covered here, by design:** live-box **identifiers** (LAN IPs / MACs) — that is
board-hygiene's job. Until the board-hygiene `--staged` fix lands + Security signs off
(branch `fix/board-hygiene-staged`), identifier hygiene is the **EA pre-integration
directory scan** (`board-hygiene-scan.sh divisions/<name>/`), which is the **binding**
board gate.

**Durable rule:** any staged-content scan command must use **ERE** (`grep -E` / `grep -vE`)
or `gitleaks`. `git grep --cached <pattern>` defaults to **BRE** and carries the same
one-or-more (`\+`) pitfall that silently broke the board scanner's `--staged` mode
(see `divisions/security-redteam/deliverables/finding-board-hygiene-staged-bre.md`).
