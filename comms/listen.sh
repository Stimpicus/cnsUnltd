#!/usr/bin/env bash
# comms/listen.sh — canonical division bus listener (the cheap shell wait).
# ONE copy, every division — retires the per-division ad-hoc poll scripts (same DRY
# win as comms/bus.sh and the provisioner). READ-ONLY: polls THIS division's inbox on
# origin/main and EXITS (re-invoking the agent) on a NEW dispatch or after --max
# heartbeat polls. The agent runs this via its background primitive; on exit it
# re-engages (resolve canonical bus from origin/main -> process the dispatch behind the
# gate -> push the outbox -> relaunch this). See comms/LISTENER.md for the full pattern.
set -uo pipefail

# Anchor to the main clone (git's own path format) so EVERY read is branch- and
# worktree-independent — a stale or wrong-branch tree never leaves a listener deaf.
MAIN="$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0,10); exit}')"
[ -n "$MAIN" ] || { echo "[listen] not inside a cnsUnltd checkout" >&2; exit 2; }

# Identity, exactly like the rest of the bus: $BUS_DIV, else the division/<name> branch.
infer_div(){ local b; b="$(git -C "$MAIN" rev-parse --abbrev-ref HEAD 2>/dev/null)"; case "$b" in division/*) echo "${b#division/}";; *) echo "";; esac; }
DIV="${BUS_DIV:-$(infer_div)}"
[ -n "$DIV" ] || { echo "[listen] cannot resolve division — set BUS_DIV=<name> or run on a division/<name> branch" >&2; exit 2; }
INBOX="divisions/$DIV/ea_dispatch.md"
OUTBOX="divisions/$DIV/division_dispatch.md"

# --max: heartbeat after N polls. Default 8 (~8 min) is SIZED TO EXIT CLEANLY under the
# agent's ~10-minute background-command ceiling — re-invocation on a clean exit is
# reliable; a kill-on-timeout is not. Do NOT raise --max past that ceiling. POLL=60s.
MAX="${1:-8}"
POLL="${LISTEN_POLL_SECS:-60}"
field(){ awk -v k="^$1:" '/^```dispatch/{f=1;next} /^```/{f=0} f&&$0~k{print $2;exit}'; }

i=0
while :; do
  git -C "$MAIN" fetch -q origin main "division/$DIV" 2>/dev/null || true
  inbox_nonce="$(git -C "$MAIN" show "origin/main:$INBOX" 2>/dev/null | field nonce)"
  answered="$(git -C "$MAIN" show "origin/division/$DIV:$OUTBOX" 2>/dev/null | field step)"
  # New dispatch IFF the inbox nonce differs from the one our outbox last answered.
  # (Idempotency: an already-answered dispatch never re-fires.)
  if [ -n "$inbox_nonce" ] && [ "$inbox_nonce" != "$answered" ]; then
    echo "DISPATCH div=$DIV nonce=$inbox_nonce answered=${answered:-none}"; exit 0
  fi
  i=$((i+1))
  if [ "$i" -ge "$MAX" ]; then echo "HEARTBEAT div=$DIV polls=$i (alive; no new dispatch)"; exit 0; fi
  sleep "$POLL"
done
