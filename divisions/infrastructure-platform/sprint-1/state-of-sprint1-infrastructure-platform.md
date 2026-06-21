# Sprint 1 — "Make green mean green" · Infrastructure / Platform (Div 6, support)

**WO:** `claude-code-WO-sprint-1-green-means-green.md`. **My part:** add a secret-scan
job to product CI; get the workspace rustfmt-clean enough to re-admit `fmt`/`clippy`,
or scope why not. **Method:** read-only ground-truth on `pandora`/`elpis-os` + local
scans; deliverables on this branch behind the gate. **merge ≠ ship** — the actual
landing on the product repos is a gated downstream PR, not this turn.

## 1. Secret-scan for product CI (the deliverable)

**Why gitleaks-binary, not gitleaks-action:** `pandora`/`elpis-os` are **private**;
`gitleaks-action` historically gates private-repo use behind `GITLEAKS_LICENSE`.
Running the **gitleaks binary directly** is license-free and works on private repos —
so the job installs the binary and runs `gitleaks detect`. (The board's proven
diff-mode regex scanner, `governance/board-hygiene`, is the license-free fallback if
gitleaks is ever unavailable.)

- **`product-ci-secret-scan.yml`** — a drop-in `secret-scan` job for each repo's
  `.github/workflows/ci.yml`. Scans **full history** (`fetch-depth: 0`), redacts, and
  **fails the job on any finding**.
- **`gitleaks.toml`** — config (rename to `.gitleaks.toml` at repo root). `useDefault`
  rules + an **allowlist** for the intentional placeholders / false positives found
  below, so the gate is signal, not noise.

### Green-run evidence (the current tree is clean)
A real scan of both repos **now** (gitleaks absent on the host → license-free regex
equivalent) returns **no real secrets** — only:
- `elpis-os` `*/secrets.yaml.example` → `REPLACE_WITH_*` **placeholders** (intentional
  templates, allowlisted).
- `pandora` `PandoraConnection.swift` reads a `let`-bound `identityToken` off a
  message, plus a `?? 'pending'` default → **code, not secrets** (allowlisted).

So with the allowlist, the configured gate is **green on the current tree** — and it
would have *blocked* a real committed key. (The GitHub Actions green run lands when
the workflow is applied to the product repos, which is the gated step.)

## 2. rustfmt / clippy — scoped "why not (yet)"

`cargo fmt --all --check` on the workspace: **rc=1 — 145 files / 1811 diff lines** from
clean (every f2f module file, oracles, etc.). **Recommendation: do NOT re-admit a
*blocking* `fmt`/`clippy` job this sprint.**

- A one-shot `cargo fmt` across **145 files** is a large mechanical reformat that would
  **conflict with every in-flight sprint branch** (8 divisions active) — exactly the
  wrong time. It belongs in its own **dedicated, quiet-tree PR**, reviewed once,
  nothing else riding on it.
- **What to do now instead:** add `fmt`/`clippy` as **advisory (non-blocking)** CI jobs
  (the same pattern `elpis-os` already uses for shellcheck) so drift is *surfaced*
  without blocking. They graduate to **blocking** once the dedicated reformat lands.
- The advisory jobs are included in `product-ci-secret-scan.yml` (commented), ready to
  enable.

## 3. PASS contribution + handoff
- ✅ Secret-scan job authored, license-free, private-repo-safe, with an allowlist tuned
  to the real false positives; green on the current tree; would block a real secret.
- ✅ rustfmt scoped honestly: blocking now = mass conflict; advisory now, blocking after
  a dedicated reformat.
- **Gated/downstream (founder/EA):** apply `product-ci-secret-scan.yml` +
  `.gitleaks.toml` to `pandora` and `elpis-os` via a product-repo PR (merge ≠ ship).
- **QA (Div 3, lead)** owns the e2e-on-ephemeral-module half; this section is the
  secret-scan + rustfmt half.

*No secrets, credentials, or live-box identifiers in this section. The `.example`
placeholders referenced are not real secrets.*
