#!/bin/sh
# secret-scan.sh — cnsUnltd pre-commit secret-VALUE guard.
# Blocks any commit whose STAGED diff contains secret-like *values* (keys, tokens, …).
#
# Wired as cnsUnltd's pre-commit hook via `.githooks/pre-commit` + `core.hooksPath`
# (durable: committed in-repo; each clone runs `git config core.hooksPath .githooks` once
# — see `.githooks/README.md`). Adopted from the product repos' P-4 scanner: a correct
# DIFF-MODE ERE pipeline — NOT the board scanner's buggy `--staged` BRE path (see
# `divisions/security-redteam/deliverables/finding-board-hygiene-staged-bre.md`).
#
# SCOPE: secret VALUES only. Live-box IDENTIFIERS (LAN IPs / MACs) are board-hygiene's
# job; until the board-hygiene `--staged` fix lands + Security signs off, identifier
# hygiene is the EA pre-integration DIRECTORY scan (the binding board gate). This hook
# complements it — it does not replace it.
#
# Matches assigned secret VALUES, not the words "token"/"secret" in identifiers, so
# normal credential-handling code (getToken(), a secret_path var) passes while an actual
# embedded key/token is blocked. Extraction uses ERE (grep -E / grep -vE) deliberately.

added=$(git diff --cached --unified=0 -- . 2>/dev/null | grep -E '^\+' | grep -vE '^\+\+\+')
fail=0
flag() {
  echo "$added" | grep -nEi "$1" >/dev/null 2>&1 && {
    echo "  [BLOCK] $2"
    echo "$added" | grep -nEi "$1" | sed 's/^/      /' | head -3
    fail=1
  }
}

flag 'BEGIN ((RSA|EC|OPENSSH|DSA|PGP|ENCRYPTED) )?PRIVATE KEY' 'private key block'
flag 'AKIA[0-9A-Z]{16}'                                        'AWS access key id'
flag 'gh[posu]_[0-9A-Za-z]{20,}'                               'GitHub token'
flag 'eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]'  'JWT'
flag '(secret|token|passwd|password|api[_-]?key|private[_-]?key|hmac|bearer|client[_-]?secret)["'"'"' ]*[:=][[:space:]]*["'"'"'][A-Za-z0-9+/=_.-]{16,}["'"'"']' 'secret value assignment'

if [ "$fail" = 1 ]; then
  echo "" >&2
  echo "COMMIT BLOCKED by cnsUnltd secret-scan (governance/board-hygiene/secret-scan.sh)." >&2
  echo "Remove the secret value (reference it by path / env var), then re-stage." >&2
  exit 1
fi
exit 0
