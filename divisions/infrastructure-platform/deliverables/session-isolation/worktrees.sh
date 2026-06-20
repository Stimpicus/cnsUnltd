#!/usr/bin/env bash
# worktrees.sh — scalable per-session/per-lane git-worktree provisioning for cnsUnltd.
#
# THE DEFECT IT CLOSES (R-5): division / EA / instrument sessions share one working
# clone, so concurrent checkouts race the global HEAD and a commit can land on the
# wrong branch. This gives each session its OWN HEAD/index/working-tree over the
# shared object store — the systematic replacement for the manual single-worktree
# stopgap. Idempotent, locked, registry-driven, with a guarded `commit` that asserts
# the branch and runs the canonical board-hygiene gate (live-box identifiers AND
# secrets) before it will land.
#
# CONFIG KNOBS are env-overridable; defaults are PROVISIONAL pending the runtime-model
# decisions surfaced in README.md §Decisions. Nothing here is a silent guess.
set -uo pipefail

# ───────────────────────── CONFIG KNOBS ─────────────────────────
# K1 (layout) — where worktrees live. Default: flat sibling of the main clone,
#    `<parent>/<repo>-<name>` (matches the convention already in use:
#    cnsUnltd-development, cnsUnltd-mathsavant-grind). Override CNS_WT_ROOT to use
#    a dedicated parent dir: `<CNS_WT_ROOT>/<name>`.
CNS_WT_ROOT="${CNS_WT_ROOT:-}"
# K4 (EA model) — the branch the EA integrator session checks out in its own
#    worktree (so its merges don't race division checkouts). Default: main.
CNS_EA_BRANCH="${CNS_EA_BRANCH:-main}"
# K-lane (ad-hoc base) — base a brand-new lane/instrument branch is cut from.
CNS_LANE_BASE="${CNS_LANE_BASE:-origin/main}"
# Registry: session-name -> branch.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="${CNS_SESSION_REGISTRY:-$SCRIPT_DIR/sessions.tsv}"
# ─────────────────────────────────────────────────────────────────

COMMON="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" \
  || { echo "[wt] not inside a git repo" >&2; exit 2; }
# Derive MAIN from git's OWN worktree list (the first entry is always the primary
# working tree) so it matches the path format used in wt_for_branch comparisons.
# (Bash `pwd` returns MSYS `/c/...` while git returns `C:/...` on Windows — never
# mix the two, or is_primary silently mis-compares.)
MAIN="$(git worktree list --porcelain | awk '/^worktree /{print substr($0,10); exit}')"
REPO="$(basename "$MAIN")"
LOCK="$COMMON/cns-wt.lock"

log() { echo "[wt] $*" >&2; }

branch_for() { awk -v n="$1" '$0!~/^#/ && $1==n {print $2; exit}' "$REGISTRY" 2>/dev/null; }
ea_branch_for() { [ "$1" = ea ] && { echo "$CNS_EA_BRANCH"; return; }; branch_for "$1"; }

std_path() { if [ -n "$CNS_WT_ROOT" ]; then echo "$CNS_WT_ROOT/$1"; else echo "$(dirname "$MAIN")/${REPO}-$1"; fi; }

# branch -> attached worktree path (""=none, the MAIN clone path if it's primary)
wt_for_branch() {
  git worktree list --porcelain | awk -v b="refs/heads/$1" '
    /^worktree /{wt=substr($0,10)} /^branch /{if(substr($0,8)==b){print wt; exit}}'
}
is_primary() { [ "$1" = "$MAIN" ]; }

lock()   { local i=0; while ! mkdir "$LOCK" 2>/dev/null; do i=$((i+1)); [ "$i" -gt 30 ] && { log "lock busy"; return 1; }; sleep 1; done; }
unlock() { rmdir "$LOCK" 2>/dev/null || true; }

resolve_branch() { # name [explicit-branch] -> branch (stdout) or fail
  local name="$1" b="${2:-}"; [ -n "$b" ] || b="$(ea_branch_for "$name")"
  [ -n "$b" ] || { log "unknown session '$name' (not in registry); pass an explicit branch"; return 2; }
  echo "$b"
}

cmd_provision() {
  local name="" branch="" from=""
  while [ $# -gt 0 ]; do case "$1" in
    --from) from="$2"; shift 2;;
    --*) log "unknown flag $1"; return 2;;
    *) if [ -z "$name" ]; then name="$1"; elif [ -z "$branch" ]; then branch="$1"; fi; shift;;
  esac; done
  [ -n "$name" ] || { log "usage: provision <name> [branch] [--from <base>]"; return 2; }
  branch="$(resolve_branch "$name" "$branch")" || return $?
  lock || return 1; trap unlock RETURN

  local existing; existing="$(wt_for_branch "$branch")"
  if [ -n "$existing" ]; then
    if is_primary "$existing"; then
      log "ANTI-PATTERN: '$branch' is checked out in the MAIN clone ($MAIN), not a worktree."
      log "Fix: git -C \"$MAIN\" checkout --detach   (then re-provision)"; return 3
    fi
    echo "$existing"; return 0                      # idempotent attach
  fi
  local target; target="$(std_path "$name")"
  [ -e "$target" ] && { log "path exists, not a worktree for '$branch': $target"; return 4; }

  if git show-ref --verify -q "refs/heads/$branch"; then
    git worktree add "$target" "$branch" >&2 || return 5
  elif git show-ref --verify -q "refs/remotes/origin/$branch"; then
    git worktree add --track -b "$branch" "$target" "origin/$branch" >&2 || return 5
  elif [ -n "$from" ]; then
    git worktree add -b "$branch" "$target" "$from" >&2 || return 5
  else
    log "branch '$branch' does not exist (local or origin); pass --from <base> to create it"; return 6
  fi
  [ "$(git -C "$target" rev-parse --abbrev-ref HEAD)" = "$branch" ] || { log "post-create HEAD mismatch"; return 7; }
  echo "$target"
}

attached_path() { # name -> isolated worktree path or fail
  local name="$1" branch p; branch="$(ea_branch_for "$name")" || return 2
  p="$(wt_for_branch "$branch")"
  [ -n "$p" ] && ! is_primary "$p" || { log "$name: no isolated worktree on $branch (run provision)"; return 1; }
  echo "$p"
}

cmd_assert() {
  local name="$1" branch p; branch="$(ea_branch_for "$name")"
  p="$(attached_path "$name")" || return 1
  local h; h="$(git -C "$p" rev-parse --abbrev-ref HEAD)"
  [ "$h" = "$branch" ] || { log "$name: worktree on '$h' not '$branch'"; return 1; }
  log "$name OK: $p on $branch"
}

# Locate the board-hygiene gate (post-promotion path first, then deliverables).
find_gate() {
  for c in "$MAIN/governance/board-hygiene/board-hygiene-scan.sh" \
           "$SCRIPT_DIR/../board-hygiene/board-hygiene-scan.sh" \
           "$MAIN/divisions/infrastructure-platform/deliverables/board-hygiene/board-hygiene-scan.sh"; do
    [ -f "$c" ] && { echo "$c"; return; }
  done
}

run_gates() { # worktree-path -> 0 clean / 1 blocked
  # Extract the staged ADDED lines via `git -C` (Windows-path safe) and scan them in
  # the gate's FILE mode. Do NOT `cd` into the worktree and use the gate's own
  # `git diff` — a Windows-style worktree path (C:/...) does not `cd` to where
  # `git -C` points, so the scan would silently see an empty diff.
  # The canonical board-hygiene gate covers BOTH live-box identifiers AND secrets
  # (private-key banners, token/secret assignments), so it is the single source of
  # truth — no duplicate inline secret regex (which would self-trip the gate on its
  # own pattern literals, and drift from the canonical rules).
  local p="$1" gate tmp; gate="$(find_gate)"
  [ -n "$gate" ] || { log "WARN: board-hygiene gate not found; board scan skipped"; return 0; }
  tmp="$(mktemp)"
  # NB: stage-2 MUST be `grep -Ev` (ERE). In BRE, GNU grep reads `\+` as the
  # one-or-more quantifier, so `grep -v '^\+\+\+'` strips EVERY `+` line, not just
  # the `+++` diff header — silently emptying the diff and passing dirty content.
  git -C "$p" diff --cached -U0 | grep -E '^\+' | grep -Ev '^\+\+\+' | sed 's/^+//' > "$tmp"
  if ! bash "$gate" "$tmp"; then rm -f "$tmp"; return 1; fi
  rm -f "$tmp"
}

cmd_commit() {
  local name="$1"; shift
  local msg="" push=0; local -a paths=()
  while [ $# -gt 0 ]; do case "$1" in
    -m) msg="$2"; shift 2;;
    --push) push=1; shift;;
    --) shift; paths=("$@"); break;;
    *) log "unexpected arg '$1' (named paths go after --)"; return 2;;
  esac; done
  [ -n "$msg" ] && [ "${#paths[@]}" -gt 0 ] || { log "usage: commit <name> -m <msg> [--push] -- <paths...>"; return 2; }
  local branch p; branch="$(ea_branch_for "$name")"; p="$(attached_path "$name")" || return 1
  [ "$(git -C "$p" rev-parse --abbrev-ref HEAD)" = "$branch" ] || { log "refuse: $p not on $branch"; return 1; }
  git -C "$p" add -- "${paths[@]}" || return 1            # named paths only, never -A
  if ! run_gates "$p"; then log "gate failed — commit aborted, staging reset"; git -C "$p" reset -q -- "${paths[@]}"; return 1; fi
  git -C "$p" commit -q -m "$msg" || return 1
  if [ "$push" = 1 ]; then git -C "$p" push -q origin "HEAD:$branch" && log "pushed $name -> $branch"; fi
  log "committed $name on $branch"
}

cmd_doctor() {
  echo "registry sessions vs live worktrees:"
  awk '$0!~/^#/ && NF>=2 {print $1"\t"$2}' "$REGISTRY" | while IFS=$'\t' read -r name branch; do
    [ "$name" = ea ] && branch="$CNS_EA_BRANCH"
    local p; p="$(wt_for_branch "$branch")"
    local st
    if [ -z "$p" ]; then st="- not provisioned"
    elif is_primary "$p"; then
      if [ "$branch" = main ]; then st="ok  MAIN clone on main (baseline; D3: EA may want a dedicated worktree)"
      else st="!! ANTI-PATTERN: $branch occupies the MAIN clone (R-5)"; fi
    else st="ok  $p"; fi
    printf "  %-24s %-36s %s\n" "$name" "$branch" "$st"
  done
  local mh; mh="$(git -C "$MAIN" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  case "$mh" in main|HEAD) echo "MAIN clone HEAD: $mh (ok)";; *) echo "MAIN clone HEAD: $mh  <-- WARNING: a session branch occupies the shared clone (R-5 risk)";; esac
  [ -d "$LOCK" ] && echo "note: provisioning lock present ($LOCK) — stale if nothing is provisioning"
  echo "unregistered live worktrees (instruments/lanes):"
  git worktree list | awk -v m="$MAIN" '$1!=m{print "  "$0}'
}

cmd_remove() {
  local name="$1" force=""; shift || true
  [ "${1:-}" = "--force" ] && force="--force"
  local p; p="$(attached_path "$name")" || { log "nothing to remove for $name"; return 0; }
  if git worktree remove $force "$p"; then log "removed $p"
  else log "remove failed (dirty worktree? re-run: remove $name --force): $p"; return 1; fi
}

self_test() {
  local pass=0 fail=0
  t() { if eval "$2"; then pass=$((pass+1)); echo "  ok  : $1"; else fail=$((fail+1)); echo "  FAIL: $1"; fi; }
  echo "self-test:"
  t "registry parses >=8 sessions"        '[ "$(grep -cE "^[a-z]" "$REGISTRY")" -ge 8 ]'
  t "branch_for development resolves"      '[ "$(branch_for development)" = "division/development" ]'
  t "ea resolves to CNS_EA_BRANCH"         '[ "$(ea_branch_for ea)" = "$CNS_EA_BRANCH" ]'
  t "std_path flat-sibling default"        '[ "$(std_path foo)" = "$(dirname "$MAIN")/${REPO}-foo" ]'
  t "std_path honors CNS_WT_ROOT"          '[ "$(CNS_WT_ROOT=/tmp/x std_path foo)" = "/tmp/x/foo" ]'
  t "unknown session rejected"             '! branch_for nope | grep -q .'
  t "lock acquire+release"                 'lock && unlock'
  t "gate locatable on this branch"        '[ -n "$(find_gate)" ]'
  t "diff-extract keeps +content drops +++ header" '[ "$(printf "+++ b/f\n+content line\n" | grep -E "^\+" | grep -Ev "^\+\+\+" | sed "s/^+//")" = "content line" ]'
  echo "self-test: $pass passed, $fail failed"; [ "$fail" -eq 0 ]
}

case "${1:-}" in
  provision) shift; cmd_provision "$@" ;;
  path)      shift; attached_path "$@" ;;
  assert)    shift; cmd_assert "$@" ;;
  commit)    shift; cmd_commit "$@" ;;
  list)      git worktree list ;;
  doctor)    cmd_doctor ;;
  remove)    shift; cmd_remove "$@" ;;
  --self-test) self_test ;;
  *) cat >&2 <<'USAGE'
usage: worktrees.sh <command>
  provision <name> [branch] [--from <base>]   ensure an isolated worktree (idempotent)
  path <name>                                 print the session's worktree path
  assert <name>                               verify the worktree is on the right branch
  commit <name> -m <msg> [--push] -- <paths>  guarded commit (asserts branch + runs gates)
  list | doctor | remove <name> | --self-test
USAGE
     exit 2 ;;
esac
