#!/usr/bin/env bash
# comms/health.sh — org functionality check: are the divisions actually answering the EA?
#
# An org is only as real as its divisions' responsiveness. For each rostered division this
# compares its INBOX nonce (the EA's latest dispatch, read from origin/main) to its OUTBOX
# `step` (the nonce it last answered, read from origin/division/<name>):
#   step == inbox nonce  → RESPONSIVE (the division answered the EA's latest dispatch)
#   step != inbox nonce  → UNANSWERED (a dispatch is sitting unread — the division is not
#                          currently listening; a STALL signal, not progress)
# Read-only. Exit 0 = healthy (all answer); exit 1 = degraded (≥1 unanswered) — usable as a gate
# or a cadence check. The EA runs it each turn and flags any degradation UP to the CEO; the CEO
# never again assumes the loop turns — it verifies.
set -uo pipefail
MAIN="$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0,10);exit}')"
[ -n "$MAIN" ] || { echo "[health] not inside a cnsUnltd checkout" >&2; exit 2; }
ROSTER="$MAIN/comms/divisions.list"
roster(){ grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$ROSTER" 2>/dev/null | tr -d '\r' | awk 'NF{print $1}'; }
field(){ awk -v k="^$1:" '/^```dispatch/{f=1;next} /^```/{f=0} f&&$0~k{print $2;exit}'; }
git -C "$MAIN" fetch -q origin 2>/dev/null || true
resp=0; tot=0; stalled=""
printf "  %-24s %-9s %-9s %s\n" division inbox last-ans answered?
while IFS= read -r d; do
  [ -n "$d" ] || continue; tot=$((tot+1))
  inb="$(git -C "$MAIN" show "origin/main:divisions/$d/ea_dispatch.md" 2>/dev/null | field nonce)"
  step="$(git -C "$MAIN" show "origin/division/$d:divisions/$d/division_dispatch.md" 2>/dev/null | field step)"
  if [ -n "$inb" ] && [ "$step" = "$inb" ]; then a=YES; resp=$((resp+1)); else a="NO  <-- unanswered"; stalled="$stalled $d"; fi
  printf "  %-24s %-9s %-9s %s\n" "$d" "${inb:-–}" "${step:-–}" "$a"
done < <(roster)
echo "  ----"
if [ "$resp" -eq "$tot" ]; then
  echo "  HEALTHY: $resp/$tot divisions answer their EA."
else
  echo "  DEGRADED: $resp/$tot answering; NOT answering:$stalled"
  echo "  (a division that isn't answering its EA is dark — the org is not functional until it is.)"
  exit 1
fi
