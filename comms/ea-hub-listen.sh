#!/usr/bin/env bash
# comms/ea-hub-listen.sh — canonical EA-HUB bus listener (companion to comms/listen.sh).
#
# listen.sh waits on ONE division's inbox; the EA hub has the inverse shape — it waits on
# the N division OUTBOXES (their replies / flags to the EA). Same four reliability rules as
# listen.sh, adapted for the hub:
#   1. READ-ONLY + branch-independent — reads origin/division/<name> anchored to the main
#      clone; a stale/wrong-branch worktree never leaves the hub deaf.
#   2. Idempotent by a per-division last-SEEN nonce. The hub has NO on-branch "answered"
#      marker (it collects, it doesn't reply per-division), so it keeps its own state file
#      and the EA seeds/updates it with what it has actually PROCESSED — never auto-marking
#      unprocessed traffic as seen (that was the bug in the EA's first hand-rolled poll).
#   3. Heartbeat sized UNDER the ~10-min background ceiling (--max 8 @ 60s) so the exit is a
#      clean re-invoke, not a kill-on-timeout.
#   4. Roster from the authoritative comms/divisions.list (same source as bus.sh).
#
# Exits (re-invoking the EA) on a NEW outbox dispatch from any rostered division, or a
# heartbeat. A `flag` is surfaced with priority. Read-only: no commits, no pushes.
#
# Re-engage protocol (what the EA does on a HUB-EVENT exit): process the new outbox(es) —
# route / integrate behind the gate / surface upward — then `ea-hub-listen.sh mark` to record
# them as seen, then relaunch. On HUB-HEARTBEAT: silently relaunch.
set -uo pipefail

MAIN="$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0,10);exit}')"
[ -n "$MAIN" ] || { echo "[ea-hub-listen] not inside a cnsUnltd checkout" >&2; exit 2; }
ROSTER="$MAIN/comms/divisions.list"
SEEN="${EA_HUB_SEEN:-$MAIN/.git/ea-hub-seen.tsv}"          # local state, NEVER committed (.git is ignored)

roster() { grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$ROSTER" 2>/dev/null | tr -d '\r' | awk 'NF{print $1}'; }
field()  { awk -v k="^$1:" '/^```dispatch/{f=1;next} /^```/{f=0} f&&$0~k{print $2;exit}'; }
seen_of(){ awk -F'\t' -v d="$1" '$1==d{print $2; exit}' "$SEEN" 2>/dev/null; }
out_nonce(){ git -C "$MAIN" show "origin/division/$1:divisions/$1/division_dispatch.md" 2>/dev/null | field nonce; }
ceo_inbox_nonce(){ git -C "$MAIN" show "origin/main:executive-assistant/ceo_dispatch.md" 2>/dev/null | field nonce; }

# `mark`: record the current outbox nonce of every rostered division as SEEN (call after
# processing, or to seed the baseline to the already-handled state).
if [ "${1:-}" = "mark" ]; then
  git -C "$MAIN" fetch -q origin main $(roster | sed 's#^#division/#') 2>/dev/null || true
  : > "$SEEN.tmp"
  printf '%s\t%s\n' "CEO" "$(ceo_inbox_nonce)" >> "$SEEN.tmp"           # the hub's own inbox from the CEO
  while IFS= read -r d; do [ -n "$d" ] || continue; printf '%s\t%s\n' "$d" "$(out_nonce "$d")" >> "$SEEN.tmp"; done < <(roster)
  mv "$SEEN.tmp" "$SEEN"; echo "[ea-hub-listen] marked CEO inbox + $(($(wc -l < "$SEEN")-1)) division outboxes as seen"; exit 0
fi

MAX="${1:-8}"; POLL="${LISTEN_POLL_SECS:-60}"; i=0
while :; do
  git -C "$MAIN" fetch -q origin main $(roster | sed 's#^#division/#') 2>/dev/null || true
  events=""
  # the hub's OWN inbox from the CEO (origin/main) — highest priority
  cn="$(ceo_inbox_nonce)"
  if [ -n "$cn" ] && [ "$cn" != "$(seen_of CEO)" ]; then events="$events CEO/directive/${cn}/CEO-DIRECTIVE"; fi
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    n="$(out_nonce "$d")"; [ -n "$n" ] || continue
    if [ "$n" != "$(seen_of "$d")" ]; then
      c="$(git -C "$MAIN" show "origin/division/$d:divisions/$d/division_dispatch.md" 2>/dev/null | field command)"
      tag="new"; [ "$c" = "flag" ] && tag="FLAG"
      events="$events ${d}/${c}/${n}/${tag}"
    fi
  done < <(roster)
  if [ -n "$events" ]; then echo "HUB-EVENT$events"; exit 0; fi
  i=$((i+1))
  if [ "$i" -ge "$MAX" ]; then echo "HUB-HEARTBEAT polls=$i (alive; bus quiet)"; exit 0; fi
  sleep "$POLL"
done
