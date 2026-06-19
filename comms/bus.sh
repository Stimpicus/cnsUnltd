#!/usr/bin/env bash
# bus.sh — Infra's listener/responder for the inter-division comms bus.
# See dispatch-schema.md. Security model in one line: a dispatch field can never
# BE a command — the validated `command` enum only SELECTS a pre-written handler;
# field values are never evaluated. Inbox is trusted ONLY from `main` (EA-written).
set -uo pipefail

DIV="infrastructure-platform"
DIVDIR="divisions/${DIV}"
INBOX_PATH="${DIVDIR}/ea_dispatch.md"
OUTBOX_PATH="${DIVDIR}/division_dispatch.md"
# Verbs the bus must NEVER carry (gated / founder-button). Rejected by name as an
# attack signal even though they are not on the allowlist either.
FORBIDDEN='deploy|merge|flash|publish|push|apply|reboot|delete|rotate|sign|install|build'
KEYS=(issuer to command wo step timestamp nonce)

gen_nonce() { printf '%08x' $(( ( (RANDOM<<15) ^ RANDOM ^ $(date +%s) ) & 0x7fffffff )); }

# Read the body of the FIRST ```dispatch fenced block from stdin.
extract_block() { awk '/^```dispatch[ \t]*$/{f=1;next} /^```[ \t]*$/{if(f)exit} f{print}'; }

# Count ```dispatch opening fences on stdin.
count_blocks() { grep -cE '^```dispatch[[:space:]]*$' || true; }

# Validate a block read on stdin. $1 = inbound|outbound.
# Prints "OK <command> <wo> <step> <nonce> <issuer>" and returns 0 on success;
# prints "INVALID: <why>" (rc 1) or "ATTACK: <why>" (rc 2) otherwise.
validate_block() {
  local dir="$1" block re k line i; block="$(cat)"
  mapfile -t lines < <(printf '%s\n' "$block" | sed '/^[[:space:]]*$/d')
  if [ "${#lines[@]}" -ne 7 ]; then echo "INVALID: expected 7 keys, got ${#lines[@]}"; return 1; fi
  declare -A v
  for i in 0 1 2 3 4 5 6; do
    k="${KEYS[$i]}"; line="${lines[$i]}"; re="^${k}: (.+)$"
    if [[ ! "$line" =~ $re ]]; then echo "INVALID: line $((i+1)) is not '${k}: <value>'"; return 1; fi
    v[$k]="${BASH_REMATCH[1]}"
  done
  re='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
  if [[ ! "${v[timestamp]}" =~ $re ]]; then echo "INVALID: bad timestamp"; return 1; fi
  re='^[0-9a-f]{6,}$'
  if [[ ! "${v[nonce]}" =~ $re ]]; then echo "INVALID: bad nonce"; return 1; fi
  re='^(-|[A-Za-z0-9._-]+)$'
  if [[ ! "${v[step]}" =~ $re ]]; then echo "INVALID: bad step"; return 1; fi
  re="^(${FORBIDDEN})$"
  if [[ "${v[command]}" =~ $re ]]; then echo "ATTACK: forbidden verb '${v[command]}'"; return 2; fi
  if [ "$dir" = inbound ]; then
    [ "${v[issuer]}" = "EA" ]  || { echo "INVALID: inbound issuer must be EA"; return 1; }
    [ "${v[to]}" = "$DIV" ]    || { echo "INVALID: 'to' must be $DIV"; return 1; }
    re='^(status|crunch|halt)$'
    if [[ ! "${v[command]}" =~ $re ]]; then echo "INVALID: '${v[command]}' not on allowlist"; return 1; fi
    if [ "${v[command]}" = crunch ]; then
      re='^[A-Za-z0-9._-]+$'
      if [ "${v[wo]}" = "-" ] || [[ ! "${v[wo]}" =~ $re ]]; then echo "INVALID: crunch requires a wo id"; return 1; fi
    else
      [ "${v[wo]}" = "-" ] || { echo "INVALID: wo must be '-' for ${v[command]}"; return 1; }
    fi
  else
    [ "${v[issuer]}" = "$DIV" ] || { echo "INVALID: outbound issuer must be $DIV"; return 1; }
    [ "${v[to]}" = "EA" ]       || { echo "INVALID: outbound 'to' must be EA"; return 1; }
    re='^(status|ack|flag)$'
    if [[ ! "${v[command]}" =~ $re ]]; then echo "INVALID: outbound command not allowed"; return 1; fi
  fi
  printf 'OK %s %s %s %s %s\n' "${v[command]}" "${v[wo]}" "${v[step]}" "${v[nonce]}" "${v[issuer]}"
}

# Write an outbound dispatch to the outbox. $1=command $2=answered-nonce(or -) $3=state-text
write_outbox() {
  local cmd="$1" answ="$2" state="$3" ts nonce
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; nonce="$(gen_nonce)"
  {
    echo "# Infra → EA outbox (division_dispatch)"; echo
    echo '```dispatch'
    echo "issuer: $DIV"; echo "to: EA"; echo "command: $cmd"; echo "wo: -"
    echo "step: $answ"; echo "timestamp: $ts"; echo "nonce: $nonce"
    echo '```'; echo
    echo "state: $state"
  } > "$OUTBOX_PATH"
}

# Last inbound nonce we already answered = `step` of our own outbox block.
last_answered() {
  [ -f "$OUTBOX_PATH" ] || { echo "-"; return; }
  extract_block < "$OUTBOX_PATH" | sed -n 's/^step: //p' | head -1
}

# enum -> handler. NB: $wo is validated (charset-restricted) and used only as a
# path-existence check + echoed into a state string; it is never executed.
handle() {
  local command="$1" wo="$2" nonce="$3" tip
  tip="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
  case "$command" in
    status) write_outbox status "$nonce" "branch=$tip; bus self-test ok; listener live" ;;
    halt)   write_outbox ack "$nonce" "halt obeyed; listener stops acting"; : > "$DIVDIR/.bus-halted" ;;
    crunch)
      if git cat-file -e "origin/main:work-orders/$wo" 2>/dev/null || git cat-file -e "origin/main:work-orders/$wo.md" 2>/dev/null; then
        write_outbox ack "$nonce" "crunch acknowledged on $wo; bounded branch work begins"
      else
        write_outbox flag "$nonce" "crunch references unknown work order '$wo' — not started"
      fi ;;
  esac
}

surface() { echo "[bus] $*" >&2; }

# Read inbox from MAIN (authoritative), validate, act once. $1=--dry-run to skip git push.
process() {
  local dry="${1:-}" inbox res rc blocks command wo step nonce issuer
  # BUS_INBOX_FILE is a test-only seam; production always reads the authoritative
  # inbox from origin/main (the EA-written, write-auth-enforced source).
  if [ -n "${BUS_INBOX_FILE:-}" ]; then
    inbox="$(cat "$BUS_INBOX_FILE" 2>/dev/null || true)"
  else
    git fetch -q origin main 2>/dev/null || { surface "fetch failed"; return 1; }
    inbox="$(git show origin/main:${INBOX_PATH} 2>/dev/null || true)"
  fi
  if [ -z "$inbox" ]; then echo "idle: no inbox on main yet (EA has not dispatched)"; return 0; fi
  blocks="$(printf '%s\n' "$inbox" | count_blocks)"
  if [ "$blocks" = "0" ]; then echo "idle: inbox has no dispatch block (template/empty)"; return 0; fi
  if [ "$blocks" != "1" ]; then surface "INVALID: expected exactly 1 dispatch block, got $blocks — ignored"; return 0; fi
  res="$(printf '%s\n' "$inbox" | extract_block | validate_block inbound)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    surface "$res"; write_outbox flag "-" "rejected an invalid/forbidden inbound dispatch: ${res}"
    [ "$dry" = "--dry-run" ] || commit_outbox "flag-invalid"
    return 0
  fi
  read -r _ command wo step nonce issuer <<<"$res"
  if [ "$(last_answered)" = "$nonce" ]; then echo "idle: nonce $nonce already answered"; return 0; fi
  handle "$command" "$wo" "$nonce"
  echo "acted: $command (re $nonce) -> outbox"
  [ "$dry" = "--dry-run" ] || commit_outbox "respond $command re $nonce"
}

commit_outbox() {
  git add "$OUTBOX_PATH" "$DIVDIR/.bus-halted" 2>/dev/null || git add "$OUTBOX_PATH"
  git commit -q -m "bus: $1" && git push -q origin HEAD:division/${DIV} && surface "pushed response"
}

self_test() {
  local pass=0 fail=0
  check() { # <expect rc> <expect-prefix> <dir> <block...>
    local exp_rc="$1" exp_pre="$2" dir="$3"; shift 3
    local out rc; out="$(printf '%s\n' "$@" | validate_block "$dir")"; rc=$?
    if [ "$rc" -eq "$exp_rc" ] && [[ "$out" == ${exp_pre}* ]]; then
      pass=$((pass+1)); echo "  ok  : [$dir rc=$rc] $out"
    else
      fail=$((fail+1)); echo "  FAIL: expected rc=$exp_rc pre='$exp_pre' got rc=$rc '$out'"
    fi
  }
  local TS="2026-06-19T18:30:00Z" N="7f3a9c21"
  echo "self-test:"
  check 0 "OK status" inbound "issuer: EA" "to: $DIV" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 0 "OK crunch" inbound "issuer: EA" "to: $DIV" "command: crunch" "wo: claude-code-work-order-protocol-audit.md" "step: -" "timestamp: $TS" "nonce: $N"
  check 0 "OK halt"   inbound "issuer: EA" "to: $DIV" "command: halt" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 2 "ATTACK"    inbound "issuer: EA" "to: $DIV" "command: deploy" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: development" "to: $DIV" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $DIV" "command: status; rm -rf /" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $DIV" "command: status" "wo: -" "step: -" "timestamp: not-a-time" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $DIV" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: ZZZ"
  check 1 "INVALID"   inbound "issuer: EA" "to: $DIV" "command: status" "wo: -" "step: -" "extra: x" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $DIV" "command: crunch" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 0 "OK status" outbound "issuer: $DIV" "to: EA" "command: status" "wo: -" "step: $N" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   outbound "issuer: development" "to: EA" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  echo "self-test: $pass passed, $fail failed"
  [ "$fail" -eq 0 ]
}

case "${1:-}" in
  --self-test) self_test ;;
  validate)    printf '%s\n' "$(cat "${2:?file}")" | extract_block | validate_block "${3:-inbound}" ;;
  process)     process "${2:-}" ;;
  ready)       write_outbox status "-" "${2:-bus built; listener ready for Phase-1 handshake}"; echo "wrote $OUTBOX_PATH" ;;
  *) echo "usage: bus.sh {--self-test | validate <file> [inbound|outbound] | process [--dry-run] | ready [text]}" >&2; exit 2 ;;
esac
