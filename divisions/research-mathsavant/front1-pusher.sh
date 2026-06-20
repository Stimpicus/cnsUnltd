#!/usr/bin/env bash
# front1-pusher.sh — host-side durability pusher for mathSavant Front 1 (option b).
#
# DURABILITY MODEL (option b, founder-preferred): the savant runs network-DARK — the
# base sandbox is unchanged (no egress, no push credential inside the auto-executing
# process). This pusher runs on the HOST, OUTSIDE the sandbox, with the host's own
# credentials. It reads the savant's own branch from its worktree and pushes it to
# origin on a tight cadence, so a dead box loses at most "work since the last push"
# (the bound the founder relies on) instead of the entire local branch.
#
# The push to origin is the IRREVERSIBLE step, so this gate runs board-hygiene +
# secret-scan on the to-be-pushed content BEFORE every push; a BLOCK means no push.
# The savant never gets network or a push credential — that asymmetry is the point.
#
# Usage:  front1-pusher.sh <savant-worktree-path> [--dry-run]
# Cadence: run by the host on a loop / cron (tight interval keeps the loss window
#          small). One invocation pushes whatever is new on the branch, if clean.
set -uo pipefail

WT="${1:?usage: front1-pusher.sh <savant-worktree-path> [--dry-run]}"
DRY="${2:-}"
BRANCH="instrument/mathsavant-grind"

cd "$WT" 2>/dev/null || { echo "[pusher] no worktree at $WT" >&2; exit 2; }
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "[pusher] not a git worktree" >&2; exit 2; }
BH="$ROOT/governance/board-hygiene/board-hygiene-scan.sh"

git fetch -q origin "$BRANCH" 2>/dev/null || true
RANGE="origin/$BRANCH..HEAD"
if [ -z "$(git rev-list "$RANGE" 2>/dev/null)" ]; then echo "[pusher] nothing to push (origin up to date)"; exit 0; fi

mapfile -t FILES < <(git diff --name-only "$RANGE")
echo "[pusher] to-be-pushed files: ${FILES[*]:-<none>}"

# Gate 1 — board-hygiene on the changed files (no live-box identifiers reach origin).
if [ -f "$BH" ] && [ "${#FILES[@]}" -gt 0 ]; then
  bash "$BH" "${FILES[@]}" || { echo "[pusher] BLOCK: board-hygiene — not pushing" >&2; exit 1; }
fi

# Gate 2 — secret-scan on the added lines of the push range.
ADDED="$(git diff "$RANGE" -U0 | grep -E '^\+' | grep -v '^\+\+\+' | sed 's/^\+//')"
if printf '%s\n' "$ADDED" | grep -qIE '192\.168|172\.(1[6-9]|2[0-9]|3[01])\.|10\.[0-9]+\.[0-9]+\.[0-9]+|[0-9a-f]{32,}|BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|(passwd|password|secret|api[_-]?key|access[_-]?token|bearer)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9/_+.=-]{8,}'; then
  echo "[pusher] BLOCK: secret-scan — not pushing" >&2; exit 1
fi

echo "[pusher] gates CLEAN"
if [ "$DRY" = "--dry-run" ]; then echo "[pusher] dry-run: would push HEAD:$BRANCH"; exit 0; fi
git push origin "HEAD:$BRANCH" && echo "[pusher] pushed HEAD:$BRANCH to origin"
