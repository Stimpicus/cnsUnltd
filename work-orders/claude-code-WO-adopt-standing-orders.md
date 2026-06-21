# Work Order — Adopt the CEO Standing Orders (SO-1…SO-4)

**Direction authored by:** the CEO (`ceo/standing-orders.md`). **Propagated by:** the EA, per the
CEO rollout directive (`claude-code-WO-rollout-standing-orders.md`, nonce `63da9f9b`). **For:** every
division. **Classification:** standing policy — ACK + live; no new product deliverable.

This WO carries **no new direction** — it is the division-facing echo of the CEO's standing orders.
Read `ceo/standing-orders.md` in full; the four orders, in force every cycle until the CEO amends them:

- **SO-1 — One voice to the Founder.** Bus-only. You report to the **EA**, never to the Founder. The
  EA reports up to the CEO; the **CEO is the sole Founder-interface**. No division, instrument, or the
  EA sends any desktop / human / founder notification. (Extends the comms-discipline of D-048.)
- **SO-2 — Knowledge commons (`knowledge/`).** One canonical approach per recurring task. If you
  solve a recurring task well, promote it to `knowledge/playbooks/` (via the EA, gated); for anything
  already solved, **adopt** the existing playbook — no private reinvention. The EA flags drift.
- **SO-3 — Continuous improvement.** Keep improving your **domain** practice and contribute your
  retrospective lessons to `knowledge/lessons/`. (The EA runs a lightweight retrospective at every
  integration; the CEO runs the deeper ~10-cycle leadership review.)
- **SO-4 — Perpetual, indefinite listeners.** Run your bus listener (`comms/listen.sh`, no `--max` =
  indefinite) **perpetually** — it exits ONLY on a real dispatch, **never on a heartbeat**, and you
  relaunch it on every dispatch. Never go dormant. In this harness a heartbeat exit pings the Founder,
  so there is no "silent heartbeat" — the loop must not heartbeat at all; liveness is checked by the EA
  (`comms/health.sh`). Surface to the Founder only on a real need (button / BLOCK / stall / drift /
  safety). (Corrected per **D-059 / D-062**.)

## ACK
Acknowledge on your outbox (`bus.sh process` → `ack` re this dispatch's nonce). Then simply operate
this way: it is how the org runs.
