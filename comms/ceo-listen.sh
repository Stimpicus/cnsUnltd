#!/usr/bin/env bash
# comms/ceo-listen.sh — the CEO listener. The mirror of ea-hub-listen.sh for the one channel the
# CEO watches: the EA's outbox (executive-assistant/ea_dispatch.md, EA→CEO reports-up) on origin/main.
# Same four rules: READ-ONLY + branch-independent (anchored to the main clone), idempotent by a local
# last-SEEN nonce, heartbeat sized UNDER the ~10-min background ceiling (--max 8 @ 60s = clean exit).
# Exits (re-invoking the CEO) on a new EA report or a heartbeat. Read-only: no commits, no pushes.
#
# Re-engage protocol (on EA-REPORT): read the EA's outbox, synthesize, author the next turn (work
# orders to the EA over ceo_dispatch); `ceo-listen.sh mark` to record it seen; relaunch. On
# CEO-HEARTBEAT: silently relaunch (do not narrate).
set -uo pipefail
MAIN="$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0,10);exit}')"
[ -n "$MAIN" ] || { echo "[ceo-listen] not inside a cnsUnltd checkout" >&2; exit 2; }
EA_OUTBOX="executive-assistant/ea_dispatch.md"
SEEN="${CEO_SEEN:-$MAIN/.git/ceo-listen-seen}"        # local state, never committed
field()   { awk -v k="^$1:" '/^```dispatch/{f=1;next} /^```/{f=0} f&&$0~k{print $2;exit}'; }
ea_nonce(){ git -C "$MAIN" show "origin/main:$EA_OUTBOX" 2>/dev/null | field nonce; }

if [ "${1:-}" = "mark" ]; then
  git -C "$MAIN" fetch -q origin main 2>/dev/null || true
  ea_nonce > "$SEEN"; echo "[ceo-listen] marked EA outbox seen (nonce=$(cat "$SEEN" 2>/dev/null))"; exit 0
fi

MAX="${1:-8}"; POLL="${LISTEN_POLL_SECS:-60}"; i=0
while :; do
  git -C "$MAIN" fetch -q origin main 2>/dev/null || true
  n="$(ea_nonce)"
  if [ -n "$n" ] && [ "$n" != "$(cat "$SEEN" 2>/dev/null)" ]; then echo "EA-REPORT nonce=$n (EA answered on its outbox)"; exit 0; fi
  i=$((i+1))
  if [ "$i" -ge "$MAX" ]; then echo "CEO-HEARTBEAT polls=$i (alive; EA quiet)"; exit 0; fi
  sleep "$POLL"
done
