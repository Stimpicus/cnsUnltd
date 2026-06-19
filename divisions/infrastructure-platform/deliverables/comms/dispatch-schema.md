# Inter-Division Dispatch — strict schema & security model

**Owner:** Infrastructure / Platform (Div 6) · 2026-06-19 · paired with `bus.sh`.
This is the wire format for the org's comms bus and the reference description the
Security/Red-Team audit checks the implementation against.

## Security thesis (why a write can't become an unauthorized command)
The bus is a command-dispatch surface, so the flagship attack class —
**write-to-execute via a subscription substrate** — applies to it directly. It is
defended **by construction**, not by a new mechanism:

1. **Write-authorization = the board's write-authorization.** EA→division dispatch
   is only trusted when read from **`main`**, which only the EA can integrate.
   Division→EA dispatch lives on the **division's own branch**, which only that
   division can write. A division therefore cannot forge another's command, and
   cannot place an authoritative EA command. No new auth surface is introduced.
2. **The field can never *be* the command.** The parser extracts only a fixed set
   of keys from exactly one fenced block and validates each against an exact regex.
   Field values are **never** evaluated, sourced, or interpolated into a shell
   command. The validated `command` value only *selects* one of a fixed set of
   pre-written handlers (an enum→handler `case`). There is no path from dispatch
   content to code execution.
3. **Consent-by-default allowlist.** Only three inbound verbs exist; every gated /
   founder-button verb (`deploy`, `merge`, `flash`, `publish`, …) is absent and is
   additionally rejected *by name* as an attack signal. Anything not on the
   allowlist is ignored and surfaced, never executed.
4. **Tamper-evident.** Every dispatch is a committed file; git history is the audit
   trail.

## Wire format (exactly one fenced block; everything else is ignored)
A dispatch file may contain prose, but the bus reads **only** the first fenced
block tagged ```` ```dispatch ````. The block is exactly seven `key: value` lines,
in this fixed order, no extra keys, no missing keys:

```dispatch
issuer: EA
to: infrastructure-platform
command: status
wo: -
step: -
timestamp: 2026-06-19T18:30:00Z
nonce: 7f3a9c21
```

### Per-key validation (exact)
| Key | Rule |
|---|---|
| `issuer` | inbound (EA→div): literal `EA`. outbound (div→EA): the division name. |
| `to` | inbound: this division's name. outbound: `EA`. |
| `command` | inbound ∈ {`status`,`crunch`,`halt`}. outbound ∈ {`status`,`ack`,`flag`}. |
| `wo` | `-` for `status`/`halt`. for `crunch`: `^[A-Za-z0-9._-]+$` AND must name an existing file under `work-orders/`. |
| `step` | `-` or `^[A-Za-z0-9._-]+$`. |
| `timestamp` | ISO-8601 UTC: `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$`. |
| `nonce` | `^[0-9a-f]{6,}$` — dispatch id; also the anti-replay/idempotency key. |

Any deviation (extra key, wrong order, bad regex, >1 block, 0 blocks, a forbidden
verb, wrong issuer/source) → **INVALID → ignored + surfaced, never executed.**

## The three inbound verbs (EA→division)
- **status** — report state to the outbox (read-only). Doubles as the liveness
  heartbeat: the EA expects a response; silence = a dead listener.
- **crunch** — enter crunch on the referenced WO (`wo:` required, must exist).
  Bounded, branch-only, gated, merge≠ship — crunch runs inside the constitution.
- **halt** — stop acting (coordination kill-switch). The founder also retains a
  direct halt independent of the bus.

## Outbound responses (division→EA)
- **status** — a state report (answers an inbound `status`; carries `re: <nonce>`).
- **ack** — acknowledges a `crunch`/`halt` it has begun/obeyed.
- **flag** — surfaces an invalid/forbidden inbound dispatch (the audit signal).

## Idempotency / replay
A response carries `re: <inbound-nonce>` in its state line. Before acting, the
listener compares the inbound nonce to the last one it answered (read from its own
outbox); an already-answered nonce is a no-op. Replays cannot double-fire.

## Where the files live
- Inbox (EA→Infra): `divisions/infrastructure-platform/ea_dispatch.md` — **trusted
  only when read from `main`.** The copy on the division branch is an inert
  template.
- Outbox (Infra→EA): `divisions/infrastructure-platform/division_dispatch.md` — on
  the `division/infrastructure-platform` branch.
- Tooling (`bus.sh`, this doc): proposed for promotion to a shared `comms/` on
  `main` so all 8 divisions + the EA share one copy (same pattern as the
  board-hygiene bundle).

## Existing gates still apply
board-hygiene + secret-scan run at EA integration, so dispatch content cannot carry
secrets or live-box identifiers onto the board.
