#!/usr/bin/env bash
# comms/listen.sh — canonical division bus listener (the cheap shell wait).
# ONE copy, every division. 5-MINUTE SILENT-HEARTBEAT standard (Founder order, D-077):
#   * exits (re-invoking the agent) on a NEW dispatch — the agent processes + reports; OR
#   * exits on a 5-MINUTE HEARTBEAT (--max 5 @ 60s) — the agent RELAUNCHES SILENTLY and says
#     NOTHING (no Founder-facing output, no prose, no narration). Only a real dispatch ever
#     produces a visible turn / a report.
# WHY 5-min heartbeat: a background command that runs PAST the ~10-min ceiling does not reliably
# deliver its completion wake (an indefinite listener silently missed a directive — D-076). A
# 5-min heartbeat exits well UNDER the ceiling, so the re-invoke is dependable. WHY silent: the
# Founder is pinged by agent CHATTER, not by the mechanism — so the heartbeat re-invoke must
# produce zero Founder-facing output (silent relaunch). Reliable AND quiet.
# READ-ONLY. On a dispatch the agent re-engages (resolve canonical bus from origin/main ->
# process behind the gate -> push the outbox -> relaunch this). See comms/LISTENER.md.
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

# --max: heartbeat after N polls. DEFAULT 5 (= 5 min @ 60s) — the silent-heartbeat standard, sized
# UNDER the ~10-min ceiling for a dependable re-invoke. On a HEARTBEAT exit the agent relaunches
# SILENTLY (zero Founder-facing output). Tune only with LISTEN_POLL_SECS if the poll cadence differs.
MAX="${1:-5}"
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
  # 5-min HEARTBEAT: exit so the re-invoke stays under the ceiling. The agent must relaunch
  # SILENTLY on this — no Founder-facing output.
  if [ "$MAX" -gt 0 ] && [ "$i" -ge "$MAX" ]; then echo "HEARTBEAT div=$DIV polls=$i (SILENT relaunch — no Founder output)"; exit 0; fi
  sleep "$POLL"
done
