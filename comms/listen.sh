#!/usr/bin/env bash
# comms/listen.sh — canonical division bus listener (the cheap shell wait).
# ONE copy, every division. ALWAYS-ON: a perpetual background loop that EXITS
# (re-invoking the agent) ONLY when a NEW dispatch appears — never on a heartbeat.
# WHY no heartbeat: in this harness EVERY background-command exit re-invokes the agent
# and surfaces a turn the Founder sees (a ping). A heartbeat exit would therefore ping
# the Founder on every cycle — that is the regression that made sessions choose between
# pinging the Founder and going dark. The loop ends ONLY on a real dispatch (a turn
# worth surfacing); liveness is the EA's job (comms/health.sh), not a self-heartbeat.
# READ-ONLY. On a dispatch the agent re-engages (resolve canonical bus from origin/main
# -> process behind the gate -> push the outbox -> relaunch this). See comms/LISTENER.md.
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

# --max: 0 (default) = INDEFINITE — exit ONLY on a dispatch (the always-on, no-ping
# standard). A POSITIVE --max heartbeats after N polls and is for DEBUG ONLY: it
# re-invokes the agent (and pings the Founder) every N polls. Do not use it in prod.
MAX="${1:-0}"
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
  if [ "$MAX" -gt 0 ] && [ "$i" -ge "$MAX" ]; then echo "HEARTBEAT div=$DIV polls=$i (debug cap)"; exit 0; fi
  sleep "$POLL"
done
