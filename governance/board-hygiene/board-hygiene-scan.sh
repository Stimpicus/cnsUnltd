#!/usr/bin/env bash
# board-hygiene-scan.sh — keep live-box identifiers and secrets off the cnsUnltd board.
#
# WHY: cnsUnltd is the org board. The standing policy keeps live-box *identifiers*
# (routable/LAN IPs, MAC addresses, private-key files) and secrets out of it — box
# nicknames (".180", ".196", "dev VM") are fine; the full identifier behind the
# nickname is not. This guard makes that rule mechanical instead of relying on the
# EA's eye. It is the board analogue of the product repos' secret-scan (orchestration
# WO P-4). The load-bearing enforcement point is:
#   * by the EA, before integration:    board-hygiene-scan.sh divisions/<name>/
# (The --staged extraction uses ERE — see extract_staged — and is guarded by a --staged
#  regression in --self-test. This fixed the 2026-06 BRE bug; Security-signed-off + landed
#  2026-06-20 (ledger D-031), the §7 BLOCK lifted. Per-division --staged is now a verified,
#  advisory pre-commit mode; the binding board gate remains the EA directory scan.)
#
# EXIT:  0 = clean (WARN findings may print, do not fail) · 1 = BLOCK findings
#        present (do not commit / integrate) · 2 = usage error.
#
# Two tiers on purpose (mirrors the elpis-os CI "bash -n blocking / shellcheck
# advisory" split): a guard that cries wolf gets disabled, so only high-signal,
# low-false-positive patterns BLOCK; softer signals WARN. This file self-skips in
# directory scans (it documents the patterns; it never contains a real identifier).
set -uo pipefail

# --- BLOCK patterns (any hit fails the scan) ---------------------------------
# Private/LAN IPv4 (RFC1918 + CGNAT 100.64/10 + link-local 169.254/16). Public and
# RFC5737 documentation IPs are NOT flagged — they are not live-box LAN identifiers.
RE_PRIV_IP='(^|[^0-9.])((10\.([0-9]{1,3}\.){2}[0-9]{1,3})|(172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})|(192\.168\.[0-9]{1,3}\.[0-9]{1,3})|(100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]{1,3}\.[0-9]{1,3})|(169\.254\.[0-9]{1,3}\.[0-9]{1,3}))'
RE_MAC='([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}'
RE_PRIVKEY_BANNER='-{3,}BEGIN [A-Z0-9 ]*PRIVATE KEY'
RE_PRIVKEY_FILE='[A-Za-z0-9_./\-]+\.key([^A-Za-z0-9]|$)'
RE_SSH_KEYNAME='[A-Za-z0-9_-]*id_(ed25519|rsa|ecdsa|dsa)'
RE_SECRET_ASSIGN='(password|passwd|secret|token|api[_-]?key|bearer|hmac_secret)["'"'"' ]*[:=]["'"'"' ]*[A-Za-z0-9/_+.=-]{8,}'
BLOCK_RE="(${RE_PRIV_IP})|(${RE_MAC})|(${RE_PRIVKEY_BANNER})|(${RE_PRIVKEY_FILE})|(${RE_SSH_KEYNAME})|(${RE_SECRET_ASSIGN})"

# --- WARN patterns (print, do not fail) --------------------------------------
RE_PEM_FILE='[A-Za-z0-9_./\-]+\.pem([^A-Za-z0-9]|$)'
RE_HOME_PATH='(/home/[a-z]|/root/\.ssh|[Cc]:\\Users\\)'
WARN_RE="(${RE_PEM_FILE})|(${RE_HOME_PATH})"

SELF="$(basename "$0")"
FOUND_BLOCK=0

scan_file() { # <label> <path>
  local label="$1" f="$2" b w
  b="$(grep -nEi -- "$BLOCK_RE" "$f" 2>/dev/null)"
  if [ -n "$b" ]; then printf '%s\n' "$b" | sed "s#^#BLOCK  ${label}:#" >&2; FOUND_BLOCK=1; fi
  w="$(grep -nEi -- "$WARN_RE" "$f" 2>/dev/null | grep -vEi -- "$BLOCK_RE")"
  if [ -n "$w" ]; then printf '%s\n' "$w" | sed "s#^#warn   ${label}:#" >&2; fi
}

# Extract added content from a unified diff on stdin (the --staged extraction).
# The second filter MUST be ERE (grep -vE): in BRE, `\+` is the one-or-more operator,
# so '^\+\+\+' matches EVERY added line and the gate would scan nothing — the 2026-06
# BRE bug (Security: finding-board-hygiene-staged-bre.md). The --self-test exercises
# this pipeline directly so the broken path can never ship untested again.
extract_staged() { grep -E '^\+' | grep -vE '^\+\+\+' | sed 's/^\+//'; }

usage() { echo "usage: $SELF [--staged | --self-test | <file-or-dir>...]" >&2; exit 2; }

case "${1:-}" in
  --self-test)
    # Fixtures are assembled at runtime so NO real or fixed identifier literal is
    # committed to the board. They match the PATTERNS without naming a live box.
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    o1=$((RANDOM%250+2)); o2=$((RANDOM%250+2))
    printf 'box .180 reachable; dev VM down; doc IP 203.0.113.7 (RFC5737)\n' > "$tmp/clean.md"
    { printf 'synthetic lan host 192.168.%s.%s\n' "$o1" "$o2"
      printf 'synthetic mac DE:AD:BE:%02X:%02X:01\n' "$o1" "$o2"
      printf 'ssh privkey name id_ed25519\n'
      printf -- '-----BEGIN PRIVATE KEY-----\n'
      printf 'token=%s\n' "abc123XYZ789def"; } > "$tmp/dirty.md"
    FOUND_BLOCK=0; scan_file clean "$tmp/clean.md"
    [ "$FOUND_BLOCK" -eq 0 ] && echo "self-test: clean fixture PASSED" || { echo "self-test FAIL: clean blocked"; exit 1; }
    FOUND_BLOCK=0; scan_file dirty "$tmp/dirty.md"
    [ "$FOUND_BLOCK" -eq 1 ] && echo "self-test: dirty fixture BLOCKED (ok)" || { echo "self-test FAIL: dirty not blocked"; exit 1; }
    # --staged extraction regression (Security sign-off condition #2): feed a synthetic
    # unified diff through the SAME extract_staged pipeline and assert a staged secret is
    # caught. With the BRE bug, extract_staged empties the input and this drops to
    # FOUND_BLOCK=0 — i.e. this test FAILS on the buggy script and PASSES on the fix.
    printf '%s\n' 'diff --git a/x b/x' '--- a/x' '+++ b/x' '@@ -0,0 +1,2 @@' \
      "+synthetic lan host 192.168.$o1.$o2" '+token=abc123XYZ789def' \
      | extract_staged > "$tmp/staged-dirty.md"
    FOUND_BLOCK=0; scan_file staged-regression-dirty "$tmp/staged-dirty.md"
    [ "$FOUND_BLOCK" -eq 1 ] && echo "self-test: --staged extraction BLOCKED dirty diff (ok)" || { echo "self-test FAIL: --staged extraction dropped the secret (BRE regression)"; exit 1; }
    printf '%s\n' 'diff --git a/y b/y' '+++ b/y' '@@ -0,0 +1 @@' '+box .180 reachable; nothing secret here' \
      | extract_staged > "$tmp/staged-clean.md"
    FOUND_BLOCK=0; scan_file staged-regression-clean "$tmp/staged-clean.md"
    [ "$FOUND_BLOCK" -eq 0 ] && echo "self-test: --staged extraction clean diff PASSED (ok)" || { echo "self-test FAIL: --staged clean diff blocked"; exit 1; }
    echo "self-test: PASS"; exit 0 ;;
  --staged)
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    git diff --cached -U0 | extract_staged > "$tmp/staged.txt"
    scan_file "staged" "$tmp/staged.txt" ;;
  ""|-h|--help) usage ;;
  *)
    for path in "$@"; do
      if [ -d "$path" ]; then
        while IFS= read -r f; do
          [ "$(basename "$f")" = "$SELF" ] && continue
          case "$f" in */.git/*|*.png|*.jpg|*.jpeg|*.gif|*.pdf|*.raw|*.vhdx|*.img) continue;; esac
          scan_file "$f" "$f"
        done < <(find "$path" -type f)
      else
        scan_file "$path" "$path"
      fi
    done ;;
esac

if [ "$FOUND_BLOCK" -eq 0 ]; then echo "board-hygiene-scan: CLEAN"; exit 0
else echo "board-hygiene-scan: BLOCK findings present — do not commit/integrate" >&2; exit 1; fi
