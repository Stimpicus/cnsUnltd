#!/usr/bin/env bash
# wheel-turn.sh — EA harness: prove worktree ISOLATION + bus COORDINATION at EXACT 8x.
#
# WHAT IT PROVES: eight truly-parallel lanes each provision an isolated worktree (through
# Infra's provisioner), write a benign heartbeat at divisions/<name>/status/
# wheel-turn-test-<id>.md, guard-commit it, and dispatch over the bus. PASS = all eight
# merge clean under the full gate, with each heartbeat on its OWN branch and the shared
# MAIN clone HEAD never hijacked — i.e. the R-5 race cannot occur at 8x concurrency.
#
# OWNERSHIP: the EA ADJUDICATES. The provisioner under test (worktrees.sh) is INFRA'S —
# this harness calls its interface as a BLACK BOX and never modifies or judges its
# internals. Likewise the bus (comms/bus.sh) is Infra's.
#
# DESIGN DECISIONS (surfaced + confirmed, not guessed — 2026-06-20):
#   D-H1 true-parallel launch = BARRIER-SYNCHRONIZED. Every lane provisions + stages, then
#        blocks on a shared "go" barrier; the harness releases all 8 at once so their
#        guarded-commit critical sections fire at the same instant — maximal race exposure
#        ("exact 8x"). (Portable spin-barrier; no mkfifo dependency on Windows Git Bash.)
#   D-H2 race detection = IN-LANE GUARD + POST-HOC ADJUDICATION. In-lane: the provisioner's
#        guarded `commit` asserts branch==lane (fail-fast at the instant of race) + we record
#        each lane's exit. Post-hoc: each branch holds exactly its own heartbeat, nothing on
#        a wrong branch, `doctor` confirms MAIN clone HEAD un-hijacked, all 8 merge clean.
#
# FAIL-CLOSED + GATED: preflight refuses unless preconditions are met, and the live run is
# the FOUNDER-GATED wheel-turn — it will not fire without CNS_WHEEL_TURN_GO=1.
set -uo pipefail

# ─────────── config (env-overridable) ───────────
RUN_ID="${CNS_WHEEL_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
# Infra's provisioner. Defaults to its on-repo path (present once the provisioner lands to
# the running branch). Override CNS_PROVISIONER to point at a specific checkout.
PROVISIONER="${CNS_PROVISIONER:-divisions/infrastructure-platform/deliverables/session-isolation/worktrees.sh}"
# The 8 division lanes (name<TAB>branch) — sourced from the provisioner's registry by default.
REGISTRY="${CNS_SESSION_REGISTRY:-divisions/infrastructure-platform/deliverables/session-isolation/sessions.tsv}"
# Bus dispatch leg: comms/bus.sh is hardcoded DIV=infrastructure-platform. Set =1 ONLY when
# the bus accepts a per-division DIV; otherwise the dispatch leg is SKIPPED (flagged), and the
# harness still proves isolation (the merge/adjudication legs). See README §Preconditions.
BUS_GENERALIZED="${CNS_BUS_GENERALIZED:-0}"
WORKDIR="${CNS_WHEEL_WORKDIR:-$(git rev-parse --show-toplevel)/.wheel-turn-$RUN_ID}"

lanes() { [ -f "$REGISTRY" ] || return 0; grep -vE '^\s*#|^\s*$' "$REGISTRY" | awk -F'\t' '$3=="division"{print $1"\t"$2}'; }

# ─────────── preflight (fail-closed) ───────────
preflight() {
  local ok=1
  echo "== wheel-turn preflight (run $RUN_ID) =="
  if [ -f "$PROVISIONER" ]; then
    if bash "$PROVISIONER" --self-test >/dev/null 2>&1; then echo "  P1 provisioner: present + self-test GREEN ✓"
    else echo "  P1 provisioner: present but --self-test FAILED ✗"; ok=0; fi
  else echo "  P1 provisioner ABSENT at $PROVISIONER — land feature/session-isolation-provisioner or set CNS_PROVISIONER ✗"; ok=0; fi
  local n; n=$(lanes | wc -l)
  [ "$n" -eq 8 ] && echo "  P-lanes: 8 division lanes in registry ✓" || { echo "  P-lanes: expected 8, got $n ✗"; ok=0; }
  if [ "$BUS_GENERALIZED" = "1" ]; then echo "  P2 bus: generalized (per-division dispatch enabled) ✓"
  else echo "  P2 bus: comms/bus.sh is Infra-hardcoded — dispatch leg will be SKIPPED+flagged (isolation still proven). Generalize the bus (Infra) for full bus-coordination proof."; fi
  if [ "${CNS_WHEEL_TURN_GO:-}" = "1" ]; then echo "  P3 founder-go: CNS_WHEEL_TURN_GO=1 ✓ (live wheel-turn authorized)"
  else echo "  P3 founder-go: NOT set — the live 8x turn is the founder-gated wheel-turn; refusing to fire. (set CNS_WHEEL_TURN_GO=1 to run)"; ok=0; fi
  [ "$ok" -eq 1 ] && { echo "preflight: READY"; return 0; } || { echo "preflight: NOT READY (fail-closed)"; return 1; }
}

# ─────────── per-lane worker (runs as a subprocess) ───────────
# args: <name> <branch> <barrier_dir>
lane() {
  local name="$1" branch="$2" bar="$3"
  local hb="divisions/$name/status/wheel-turn-test-$RUN_ID.md"
  local res="$bar/result.$name"
  # 1) provision an isolated worktree for this lane (Infra's provisioner, black-box).
  # cmd_provision echoes the worktree PATH on stdout (its logs go to stderr) — capture
  # it directly. Do NOT re-derive via `list`+regex: a branch like division/development
  # contains /,[,] and is not a literal regex (it becomes a char-class that mis-matches).
  local wt
  wt="$(bash "$PROVISIONER" provision "$name" 2>>"$bar/log.$name")" || { echo "FAIL provision" >"$res"; return; }
  wt="$(printf '%s\n' "$wt" | tail -n1 | tr -d '\r')"
  [ -n "$wt" ] && [ -d "$wt" ] || { echo "FAIL no-worktree[$wt]" >"$res"; return; }
  # 2) write the benign heartbeat in THIS lane's worktree
  mkdir -p "$wt/divisions/$name/status"
  printf '# wheel-turn heartbeat — %s\n\nBenign isolation/coordination test. Run %s. No payload.\nLane=%s branch=%s. Proves the lane committed to its OWN branch at 8x concurrency.\n' \
    "$name" "$RUN_ID" "$name" "$branch" > "$wt/$hb"
  # 3) BARRIER: signal ready, then block until the harness releases all 8 at once
  : > "$bar/ready.$name"
  while [ ! -f "$bar/GO" ]; do :; done      # tight spin — fire on release
  # 4) CRITICAL SECTION (contended): guarded commit (provisioner asserts branch + runs gate)
  if bash "$PROVISIONER" commit "$name" -m "wheel-turn $RUN_ID: $name heartbeat" --push -- "$hb" >>"$bar/log.$name" 2>&1; then
    local landed; landed="$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    # 5) dispatch over the bus (only if generalized; else flag)
    local disp="skipped(bus-not-generalized)"
    if [ "$BUS_GENERALIZED" = "1" ]; then
      BUS_DIV="$name" bash comms/bus.sh ready "wheel-turn $RUN_ID heartbeat" >>"$bar/log.$name" 2>&1 && disp="dispatched" || disp="dispatch-FAIL"
    fi
    printf 'PASS committed-on=%s dispatch=%s\n' "$landed" "$disp" >"$res"
  else
    echo "FAIL guarded-commit (branch-assert or gate)" >"$res"
  fi
}

# ─────────── orchestrate the 8 lanes, barrier-synchronized ───────────
run() {
  preflight || return 1
  local bar="$WORKDIR/barrier"; mkdir -p "$bar"
  echo "== launching 8 lanes (barrier-synchronized) =="
  local pids=""
  while IFS=$'\t' read -r name branch; do
    ( lane "$name" "$branch" "$bar" ) & pids="$pids $!"
  done < <(lanes)
  # wait until ALL 8 lanes are prepared + blocking on the barrier
  local ready=0; while [ "$ready" -lt 8 ]; do ready=$(ls "$bar"/ready.* 2>/dev/null | wc -l); done
  echo "  all 8 lanes staged + at the barrier — RELEASING simultaneously"
  : > "$bar/GO"                              # release → exact-8x contention
  wait $pids
  echo "== lane results =="; for f in "$bar"/result.*; do echo "  $(basename "$f" | sed 's/^result\.//'): $(cat "$f")"; done
}

# ─────────── EA post-hoc adjudication ───────────
adjudicate() {
  echo "== adjudication (run $RUN_ID) =="
  git fetch -q --all 2>/dev/null || true
  local verdict=PASS
  bash "$PROVISIONER" doctor 2>/dev/null | sed 's/^/  doctor: /'
  bash "$PROVISIONER" doctor 2>/dev/null | grep -q 'R-5 risk' && { echo "  ✗ MAIN clone HEAD hijacked (R-5)!"; verdict=FAIL; }
  # each branch must hold EXACTLY its own heartbeat; none on a wrong branch
  while IFS=$'\t' read -r name branch; do
    local hb="divisions/$name/status/wheel-turn-test-$RUN_ID.md"
    git cat-file -e "origin/$branch:$hb" 2>/dev/null && echo "  ✓ $name: heartbeat on its own branch $branch" || { echo "  ✗ $name: heartbeat missing on $branch"; verdict=FAIL; }
    # cross-contamination: this lane's heartbeat must NOT be on any OTHER division branch
    while IFS=$'\t' read -r o ob; do
      [ "$ob" = "$branch" ] && continue
      git cat-file -e "origin/$ob:$hb" 2>/dev/null && { echo "  ✗ RACE: $name heartbeat also on $ob"; verdict=FAIL; }
    done < <(lanes)
  done < <(lanes)
  echo "  NOTE: the 8-way clean MERGE to main under the full gate (board-hygiene+secret-scan+"
  echo "  structural) is the EA integration step — run it after the lanes; PASS requires all"
  echo "  eight to merge with zero conflict. (Disjoint paths divisions/<name>/status/ ⇒ expect clean.)"
  echo "VERDICT (pre-merge checks): $verdict"
}

case "${1:-}" in
  --preflight) preflight ;;
  --run)       run ;;
  --adjudicate) adjudicate ;;
  --self-test) bash -n "$0" && echo "wheel-turn.sh: syntax OK; preflight is fail-closed without CNS_WHEEL_TURN_GO=1" ;;
  *) echo "usage: wheel-turn.sh {--preflight | --run | --adjudicate | --self-test}" >&2
     echo "  live --run requires: P1 provisioner present, P3 CNS_WHEEL_TURN_GO=1 (founder gate)." >&2; exit 2 ;;
esac
