# mathSavant Front 1 — Sandbox Runtime: build plan + status

**STATUS: RUNTIME NOT YET INSTANTIATED.** The sandbox is a *ratified spec* (D-023,
founder-affirmed) and the host-side pusher is built (`front1-pusher.sh`), but the
**enforcement runtime does not exist yet.** The worktree
(`C:/GitRepos/cnsUnltd-mathsavant-grind`, branch `instrument/mathsavant-grind` @
`00936f8`) currently sits as a plain sibling on the bare host — full filesystem, full
network. A session launched there is **unsandboxed**; the savant's startup check 3
would (correctly) refuse to grind.

**Why this is prepared, not yet executed:** instantiating the cage is a privileged,
hard-to-reverse mutation of a **live host running other VMs** (`elpis-dev`, `Pandora`),
and it is the **security-critical containment** the order says the independent Security
audit will adversarially test. The EA does not unilaterally rush a security boundary or
self-certify "dark." This plan is reviewable; on the founder's mechanism choice the EA
executes it **step-by-step, with a verification checkpoint before each irreversible
step**, and the result is then handed to Security's audit before the savant runs.

The branch is safe on origin (`00936f8`), so the worktree can be **re-created inside the
sandbox from origin with zero data loss.**

---

## Mechanism A (RECOMMENDED) — network-dark Hyper-V VM
Airtight by construction; matches the f2f dev-VM precedent.
1. `New-VM` (Gen 2), **no network adapter** (or an adapter connected to a vSwitch that
   has *no* uplink) — network-dark is then **structural**, not policy: there is no path
   to the internet to misconfigure.
2. Install a minimal guest OS; install the toolchain the savant needs (git, the CC
   runtime, the verifier/Lean toolchain) — **fetched on the host, copied in via
   `Copy-VMFile` (Guest Service Interface, over VMBus — no VM network)**, never pulled
   from inside.
3. `git clone`/checkout `instrument/mathsavant-grind` **from a host-supplied bundle**
   into the VM (Copy-VMFile in; no VM network).
4. **Bridge (no VM network):** the host reaches the VM over **PowerShell Direct**
   (`Invoke-Command -VMName`, VMBus) + `Copy-VMFile` — NOT the network. The VM-side
   step runs `git bundle create` of the branch; the host copies the bundle out, fetches
   from it, and runs the existing `front1-pusher.sh` (host has network + creds) to push
   to origin. Savant writes in the dark VM; the host carries commits out.
5. Filesystem write-scope is the VM boundary itself (it cannot touch the host FS,
   `main`, other worktrees, `.180`, or any reference box).

**Cost:** a real multi-step build (OS + toolchain inside) + host RAM/disk alongside the
running VMs — hence the resource/blast-radius confirmation below.

## Mechanism B (FALLBACK) — restricted account + firewall egress-block + ACLs
Lighter, **only acceptable if it provably meets 1–3** — and it is harder to prove:
1. Dedicated restricted local account (`New-LocalUser`) the savant runs as.
2. Outbound **deny** firewall rule scoped to that account/process (`New-NetFirewallRule`).
3. `icacls` scoping writes to the worktree only; deny elsewhere.
- **Honest caveats:** per-account/per-process outbound filtering on Windows is leaky
  (a CC session spawns subprocesses; program-path rules hit all instances); a host-wide
  firewall change has **blast radius on the two running VMs' networking** and the host;
  proving it airtight is exactly Security's adversarial job. Bridge is simpler (the
  worktree is on the host FS, so `front1-pusher.sh` reads it directly).

---

## Done-criteria — verified with a PROBE inside (not the real savant; green is earned)
Run a throwaway probe process *inside the instantiated sandbox*:
- **Network egress FAILS** from inside — DNS lookup, an HTTPS GET, and a `git push` all blocked.
- A write **outside** the worktree **FAILS**; a write **inside** the worktree **succeeds**.
- The **host-side pusher still bridges** a test commit to origin end-to-end (savant-dark, host-carries).
- The worktree is present, on `instrument/mathsavant-grind` off `instrument/mathsavant`, write-scoped — so the savant's checks 1–3 pass at launch.
Only when all pass is the runtime "enforced." Then it goes to Security's audit; then the founder launches.

## Out of scope (unchanged)
Launching/creating the savant session (founder's keystroke); the bus clearance (STEP 5)
and the independent Security audit (separate, alongside); any founder-only button; any
live mutation of `.180` or a reference box.
