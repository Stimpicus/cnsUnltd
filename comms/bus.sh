#!/usr/bin/env bash
# bus.sh — inter-division comms bus (any of the eight divisions + the EA hub).
# See dispatch-schema.md. Security model in one line: a dispatch field can never BE
# a command — the validated `command` enum only SELECTS a pre-written handler; field
# values are never evaluated. Inbox is trusted ONLY from `main` (EA-written).
#
# A spoke (a division session) runs: process / ready / validate — operating on ITS
# OWN inbox/outbox. The EA hub runs: dispatch <division> <verb> [wo] / collect.
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
# Verbs the bus must NEVER carry (gated / founder-button). Rejected by name as an
# attack signal even though they are not on the allowlist either.
FORBIDDEN='deploy|merge|flash|publish|push|apply|reboot|delete|rotate|sign|install|build'
KEYS=(issuer to command wo step timestamp nonce)

# ── Canonical division roster (DESIGN DECISION D2 — see dispatch-schema.md §Decisions) ──
# AUTHORITATIVE source = the committed allowlist comms/divisions.list (a deliberate eight-
# division roster). A division is recognised ONLY if it is on the list — adding one is a
# conscious edit, never auto-absorbed from a new divisions/<name>/ dir. Auto-discovery is
# demoted to a hygiene SENTINEL (the `sentinel` command) that FLAGS any divisions/*/ dir
# absent from the list; the sentinel never grants membership.
ROSTER_FILE="$REPO_ROOT/comms/divisions.list"
roster()    { [ -f "$ROSTER_FILE" ] && grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$ROSTER_FILE" | tr -d '\r' | awk 'NF{print $1}'; }
on_roster() { [ -n "${1:-}" ] && roster | grep -qxF -- "$1"; }

# ── Division identity (DESIGN DECISION D1 — see dispatch-schema.md §Decisions) ──
# A spoke's own division = $BUS_DIV if set, else inferred from the current branch
# (`division/<name>`). Validated against the AUTHORITATIVE roster (on_roster), so a typo,
# a forged name, or an undeclared divisions/*/ dir can never resolve. The EA hub never
# needs a self-division.
infer_div() { local b; b="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"; case "$b" in division/*) echo "${b#division/}";; *) echo "";; esac; }
valid_div() { on_roster "${1:-}"; }
inbox_path()  { echo "divisions/$1/ea_dispatch.md"; }
outbox_path() { echo "divisions/$1/division_dispatch.md"; }
require_self_div() {
  DIV="${BUS_DIV:-$(infer_div)}"
  valid_div "$DIV" || { echo "[bus] cannot determine a valid division — set BUS_DIV=<name> or run on a division/<name> branch (got: '${DIV:-}')" >&2; exit 2; }
  DIVDIR="divisions/$DIV"; INBOX_PATH="$(inbox_path "$DIV")"; OUTBOX_PATH="$(outbox_path "$DIV")"
}

gen_nonce() { printf '%08x' $(( ( (RANDOM<<15) ^ RANDOM ^ $(date +%s) ) & 0x7fffffff )); }
extract_block() { awk '/^```dispatch[ \t]*$/{f=1;next} /^```[ \t]*$/{if(f)exit} f{print}'; }
count_blocks() { grep -cE '^```dispatch[[:space:]]*$' || true; }
surface() { echo "[bus] $*" >&2; }

# Validate a block on stdin. $1=inbound|outbound  $2=this spoke's division name.
# Prints "OK <command> <wo> <step> <nonce> <issuer>" (rc 0); else "INVALID:"/"ATTACK:".
validate_block() {
  local dir="$1" selfdiv="$2" block re k line i; block="$(cat)"
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
    [ "${v[issuer]}" = "EA" ]      || { echo "INVALID: inbound issuer must be EA"; return 1; }
    [ "${v[to]}" = "$selfdiv" ]    || { echo "INVALID: 'to' must be $selfdiv"; return 1; }
    re='^(status|crunch|halt)$'
    if [[ ! "${v[command]}" =~ $re ]]; then echo "INVALID: '${v[command]}' not on allowlist"; return 1; fi
    if [ "${v[command]}" = crunch ]; then
      re='^[A-Za-z0-9._-]+$'
      if [ "${v[wo]}" = "-" ] || [[ ! "${v[wo]}" =~ $re ]]; then echo "INVALID: crunch requires a wo id"; return 1; fi
    else
      [ "${v[wo]}" = "-" ] || { echo "INVALID: wo must be '-' for ${v[command]}"; return 1; }
    fi
  else
    [ "${v[issuer]}" = "$selfdiv" ] || { echo "INVALID: outbound issuer must be $selfdiv"; return 1; }
    [ "${v[to]}" = "EA" ]           || { echo "INVALID: outbound 'to' must be EA"; return 1; }
    re='^(status|ack|flag)$'
    if [[ ! "${v[command]}" =~ $re ]]; then echo "INVALID: outbound command not allowed"; return 1; fi
  fi
  printf 'OK %s %s %s %s %s\n' "${v[command]}" "${v[wo]}" "${v[step]}" "${v[nonce]}" "${v[issuer]}"
}

# ── Spoke side (a division: reads ITS inbox from main, writes ITS outbox) ──────
write_outbox() { # $1=command $2=answered-nonce(or -) $3=state-text  (uses $DIV/$OUTBOX_PATH)
  local cmd="$1" answ="$2" state="$3" ts nonce
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; nonce="$(gen_nonce)"
  {
    echo "# $DIV → EA outbox (division_dispatch)"; echo
    echo '```dispatch'
    echo "issuer: $DIV"; echo "to: EA"; echo "command: $cmd"; echo "wo: -"
    echo "step: $answ"; echo "timestamp: $ts"; echo "nonce: $nonce"
    echo '```'; echo
    echo "state: $state"
  } > "$OUTBOX_PATH"
}
last_answered() { [ -f "$OUTBOX_PATH" ] || { echo "-"; return; }; extract_block < "$OUTBOX_PATH" | sed -n 's/^step: //p' | head -1; }

handle() { # enum -> handler. $wo is charset-validated, only path-checked + echoed; never executed.
  local command="$1" wo="$2" nonce="$3" tip
  tip="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
  case "$command" in
    status) write_outbox status "$nonce" "div=$DIV branch=$tip; listener live" ;;
    halt)   write_outbox ack "$nonce" "halt obeyed; listener stops acting"; : > "$DIVDIR/.bus-halted" ;;
    crunch)
      if git cat-file -e "origin/main:work-orders/$wo" 2>/dev/null || git cat-file -e "origin/main:work-orders/$wo.md" 2>/dev/null; then
        write_outbox ack "$nonce" "crunch acknowledged on $wo; bounded branch work begins"
      else
        write_outbox flag "$nonce" "crunch references unknown work order '$wo' — not started"
      fi ;;
  esac
}

process() { # read inbox from MAIN (authoritative), validate, act once. $1=--dry-run skips push.
  local dry="${1:-}" inbox res rc blocks command wo step nonce issuer
  # F1 fence (Security STEP-5.1): the inbox is authoritative ONLY from origin/main. The
  # BUS_INBOX_FILE seam is a TEST-ONLY substitute and is honored *only* when CNS_BUS_ALLOW_TEST_INBOX=1
  # is also set — so a stray or forged BUS_INBOX_FILE in production can never substitute a forged
  # inbox (the write-to-execute residual). Default/production path reads only origin/main.
  if [ -n "${BUS_INBOX_FILE:-}" ] && [ "${CNS_BUS_ALLOW_TEST_INBOX:-}" = "1" ]; then   # test-only, gated
    inbox="$(cat "$BUS_INBOX_FILE" 2>/dev/null || true)"
  else
    [ -n "${BUS_INBOX_FILE:-}" ] && surface "BUS_INBOX_FILE IGNORED — production reads only origin/main; set CNS_BUS_ALLOW_TEST_INBOX=1 to honor it in tests"
    git fetch -q origin main 2>/dev/null || { surface "fetch failed"; return 1; }
    inbox="$(git show "origin/main:$INBOX_PATH" 2>/dev/null || true)"
  fi
  if [ -z "$inbox" ]; then echo "idle: no inbox on main yet (EA has not dispatched to $DIV)"; return 0; fi
  blocks="$(printf '%s\n' "$inbox" | count_blocks)"
  if [ "$blocks" = "0" ]; then echo "idle: inbox has no dispatch block (template/empty)"; return 0; fi
  if [ "$blocks" != "1" ]; then surface "INVALID: expected exactly 1 dispatch block, got $blocks — ignored"; return 0; fi
  res="$(printf '%s\n' "$inbox" | extract_block | validate_block inbound "$DIV")"; rc=$?
  if [ "$rc" -ne 0 ]; then
    surface "$res"; write_outbox flag "-" "rejected an invalid/forbidden inbound dispatch: ${res}"
    [ "$dry" = "--dry-run" ] || commit_outbox "flag-invalid"
    return 0
  fi
  read -r _ command wo step nonce issuer <<<"$res"
  if [ "$(last_answered)" = "$nonce" ]; then echo "idle: nonce $nonce already answered"; return 0; fi
  handle "$command" "$wo" "$nonce"
  echo "acted: $command (re $nonce) -> $OUTBOX_PATH"
  [ "$dry" = "--dry-run" ] || commit_outbox "respond $command re $nonce"
}

commit_outbox() {
  git add "$OUTBOX_PATH" "$DIVDIR/.bus-halted" 2>/dev/null || git add "$OUTBOX_PATH"
  git commit -q -m "bus($DIV): $1" && git push -q origin "HEAD:division/$DIV" && surface "pushed response"
}

# ── Hub side (the EA: dispatch to any division, collect all outboxes) ──────────
cmd_dispatch() { # <target-division> <verb> [wo]   — writes an EA→division ea_dispatch
  local target="${1:-}" verb="${2:-}" wo="${3:--}"
  valid_div "$target" || { surface "unknown target division '${target:-}' (not on comms/divisions.list — the authoritative roster)"; return 2; }
  case "$verb" in
    status|halt) wo="-";;
    crunch) { [ "$wo" != "-" ] && [[ "$wo" =~ ^[A-Za-z0-9._-]+$ ]]; } || { surface "crunch requires a wo id: dispatch $target crunch <wo>"; return 2; };;
    ''|*) surface "verb '${verb:-}' not on allowlist (status|crunch|halt) — the bus carries no gated verb"; return 2;;
  esac
  local ts nonce path; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; nonce="$(gen_nonce)"; path="$(inbox_path "$target")"
  {
    echo "# EA → $target inbox (ea_dispatch). Authoritative ONLY once on main (EA-integrated)."; echo
    echo '```dispatch'
    echo "issuer: EA"; echo "to: $target"; echo "command: $verb"; echo "wo: $wo"
    echo "step: -"; echo "timestamp: $ts"; echo "nonce: $nonce"
    echo '```'
  } > "$path"
  echo "wrote $path  (EA -> $target: $verb wo=$wo nonce=$nonce)"
  surface "commit this to main to make it authoritative — only the EA integrates to main"
}

cmd_collect() { # read every ROSTERED division's outbox from its branch (hub liveness view)
  git fetch -q origin 2>/dev/null || true
  printf "%-26s %s\n" "division" "last-outbox-state (from origin/division/<name>)"
  local name ob state
  while IFS= read -r name; do
    ob="$(git show "origin/division/$name:$(outbox_path "$name")" 2>/dev/null || true)"
    state="$(printf '%s\n' "$ob" | sed -n 's/^state: //p' | head -1)"
    printf "  %-24s %s\n" "$name" "${state:-<no outbox pushed>}"
  done <<EOF
$(roster)
EOF
}

cmd_sentinel() { # hygiene: auto-discovery demoted to a DRIFT sentinel (never authoritative)
  local rc=0 d name
  # (a) PRIMARY — a divisions/*/ dir ABSENT from the authoritative list (stray / instrument / undeclared)
  for d in "$REPO_ROOT"/divisions/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    on_roster "$name" || { echo "[sentinel] DRIFT: divisions/$name/ exists but is ABSENT from comms/divisions.list (undeclared — instrument? stray?)"; rc=1; }
  done
  # (b) advisory — a listed division with no divisions/*/ dir (declared but not materialised)
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    [ -d "$REPO_ROOT/divisions/$name" ] || { echo "[sentinel] DRIFT: '$name' is on comms/divisions.list but has no divisions/$name/ dir"; rc=1; }
  done <<EOF
$(roster)
EOF
  [ "$rc" -eq 0 ] && echo "[sentinel] clean: divisions/*/ and comms/divisions.list agree (every dir is a declared division)"
  return "$rc"
}

self_test() {
  local pass=0 fail=0 TEST_DIV="infrastructure-platform"
  check() { local exp_rc="$1" exp_pre="$2" dir="$3"; shift 3
    local out rc; out="$(printf '%s\n' "$@" | validate_block "$dir" "$TEST_DIV")"; rc=$?
    if [ "$rc" -eq "$exp_rc" ] && [[ "$out" == ${exp_pre}* ]]; then pass=$((pass+1)); echo "  ok  : [$dir rc=$rc] $out"
    else fail=$((fail+1)); echo "  FAIL: expected rc=$exp_rc pre='$exp_pre' got rc=$rc '$out'"; fi; }
  local TS="2026-06-19T18:30:00Z" N="7f3a9c21"
  echo "self-test (TEST_DIV=$TEST_DIV):"
  check 0 "OK status" inbound "issuer: EA" "to: $TEST_DIV" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 0 "OK crunch" inbound "issuer: EA" "to: $TEST_DIV" "command: crunch" "wo: claude-code-WO-infra-crunch-session-isolation.md" "step: -" "timestamp: $TS" "nonce: $N"
  check 0 "OK halt"   inbound "issuer: EA" "to: $TEST_DIV" "command: halt" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 2 "ATTACK"    inbound "issuer: EA" "to: $TEST_DIV" "command: deploy" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: intruder" "to: $TEST_DIV" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: design-product" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $TEST_DIV" "command: status; rm -rf /" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $TEST_DIV" "command: status" "wo: -" "step: -" "timestamp: not-a-time" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $TEST_DIV" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: ZZZ"
  check 1 "INVALID"   inbound "issuer: EA" "to: $TEST_DIV" "command: status" "wo: -" "step: -" "extra: x" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   inbound "issuer: EA" "to: $TEST_DIV" "command: crunch" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  check 0 "OK status" outbound "issuer: $TEST_DIV" "to: EA" "command: status" "wo: -" "step: $N" "timestamp: $TS" "nonce: $N"
  check 1 "INVALID"   outbound "issuer: EA" "to: EA" "command: status" "wo: -" "step: -" "timestamp: $TS" "nonce: $N"
  # ── D2 roster assertions: the authoritative allowlist + the drift sentinel ──
  if on_roster "$TEST_DIV"; then pass=$((pass+1)); echo "  ok  : roster includes $TEST_DIV (allowlist authoritative)"; else fail=$((fail+1)); echo "  FAIL: roster missing $TEST_DIV"; fi
  if on_roster research-mathsavant; then fail=$((fail+1)); echo "  FAIL: roster wrongly includes research-mathsavant (an instrument, not a division)"; else pass=$((pass+1)); echo "  ok  : roster excludes research-mathsavant (instrument, not a division)"; fi
  if [ "$(roster | grep -c .)" -eq 8 ]; then pass=$((pass+1)); echo "  ok  : roster = exactly 8 divisions"; else fail=$((fail+1)); echo "  FAIL: roster = $(roster | grep -c .) entries, expected 8"; fi
  if cmd_sentinel >/dev/null 2>&1; then pass=$((pass+1)); echo "  ok  : sentinel clean (divisions/*/ ⟷ divisions.list agree)"; else fail=$((fail+1)); echo "  FAIL: sentinel reports drift — $(cmd_sentinel 2>&1 | head -1)"; fi
  echo "self-test: $pass passed, $fail failed"; [ "$fail" -eq 0 ]
}

case "${1:-}" in
  --self-test) self_test ;;
  validate)    require_self_div; printf '%s\n' "$(cat "${2:?file}")" | extract_block | validate_block "${3:-inbound}" "$DIV" ;;
  process)     require_self_div; process "${2:-}" ;;
  ready)       require_self_div; write_outbox status "-" "${2:-bus ready; $DIV listener live}"; echo "wrote $OUTBOX_PATH" ;;
  dispatch)    shift; cmd_dispatch "$@" ;;
  collect)     cmd_collect ;;
  sentinel)    cmd_sentinel ;;
  *) cat >&2 <<'USAGE'
usage: bus.sh <command>
  spoke (a division — identity from $BUS_DIV or the division/<name> branch):
    process [--dry-run]            read this division's inbox from main, validate, respond
    ready [text]                   write a readiness signal to this division's outbox
    validate <file> [in|outbound]  validate a dispatch file
  hub (the EA):
    dispatch <division> <verb> [wo]  write an EA->division dispatch (verb: status|crunch|halt)
    collect                          show every rostered division's last outbox state
    sentinel                         hygiene: flag any divisions/*/ dir absent from divisions.list
  --self-test
USAGE
     exit 2 ;;
esac
