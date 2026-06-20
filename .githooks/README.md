# .githooks — cnsUnltd's durable hook directory

**Wire it (ONCE per clone):** `git config core.hooksPath .githooks`
The committed hooks then apply to that clone **and all its worktrees** (hooks resolve
via the shared git dir). This is how the hook stays durable — it lives in the repo, not
in an un-committed `.git/hooks/`.

- **`pre-commit`** → runs `governance/board-hygiene/secret-scan.sh` (secret-VALUE guard,
  correct **diff-mode ERE**). Blocks a commit whose staged diff carries an embedded
  key / token / secret value.

**Not covered here, by design:** live-box **identifiers** (LAN IPs / MACs) — that is
board-hygiene's job. Until the board-hygiene `--staged` fix lands + Security signs off
(branch `fix/board-hygiene-staged`), identifier hygiene is the **EA pre-integration
directory scan** (`board-hygiene-scan.sh divisions/<name>/`), which is the **binding**
board gate.

**Durable rule:** any staged-content scan command must use **ERE** (`grep -E` / `grep -vE`)
or `gitleaks`. `git grep --cached <pattern>` defaults to **BRE** and carries the same
one-or-more (`\+`) pitfall that silently broke the board scanner's `--staged` mode
(see `divisions/security-redteam/deliverables/finding-board-hygiene-staged-bre.md`).
