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

## Where the files live (any division `<name>`)
- Inbox (EA→`<name>`): `divisions/<name>/ea_dispatch.md` — **trusted only when read
  from `main`.** The copy on the division branch is an inert template.
- Outbox (`<name>`→EA): `divisions/<name>/division_dispatch.md` — on the
  `division/<name>` branch.
- Tooling (`bus.sh`, this doc) lives in the shared `comms/` on `main`, so every
  division + the EA run the same one copy.

## Identity & the hub (the generalization)
`bus.sh` is no longer bound to one division. It carries **every division that has a
`divisions/<name>/` directory** — auto-discovered, not a hardcoded list, so it
scales as divisions are added or removed (the org already grew past eight).

- **A spoke** (a division session) resolves its own identity from **`$BUS_DIV`** if
  set, else by inference from the current **`division/<name>`** branch; the result
  is validated against `divisions/<name>/` existing, so a typo or a forged name can
  never resolve. It runs `process` / `ready` / `validate` on ITS OWN inbox/outbox.
- **The EA hub** runs `dispatch <division> <verb> [wo]` to write an EA→division
  `ea_dispatch.md` (the verb is validated against the same allowlist — the hub
  cannot emit a gated verb), and `collect` to read every division's last outbox
  state. A written `ea_dispatch` is **authoritative only once the EA commits it to
  `main`** — the write-auth chokepoint is unchanged, so generalizing the *targets*
  does not widen the *trust boundary*.

## DECISIONS — runtime-model knobs (founder/EA's to set; surfaced, not guessed)
Each ships with a defensible default so the bus is usable now; none is a silent guess.

- **D1 — Spoke identity resolution.** `$BUS_DIV` override **then** `division/<name>`
  branch inference (default). Alt: an explicit `--div` on every call, or a registry
  lookup. *Rec: env-then-branch* — zero-config for a division on its own branch,
  explicit when off it (EA, CI, a feature branch).
- **D2 — Canonical division list.** Auto-discovered from `divisions/*/` (default —
  self-maintaining, no drift). Alt: a committed `comms/divisions.list`. *Rec:
  auto-discover* unless a curated subset is ever needed.
- **D3 — Hub authority.** `dispatch` is a general command; its authority comes solely
  from the **main-integration chokepoint** (only the EA lands `ea_dispatch` on
  `main`), not from the command itself. *Rec: keep it there* — one proven chokepoint;
  do not add a second auth surface. (The EA session can be the only one that *runs*
  `dispatch`, but that is convention, not the security boundary.)
- **D4 — `collect` scope.** Reads each division's outbox from `origin/division/<name>`
  (read-only liveness view). *Open:* should silence past a heartbeat window
  auto-flag a dead listener, or is that the EA's cadence to judge? *Rec: EA judges
  for now.*

## Existing gates still apply
board-hygiene (which covers secrets too) runs at EA integration, so dispatch content
cannot carry secrets or live-box identifiers onto the board.
