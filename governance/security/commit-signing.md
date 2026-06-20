# EA commit signing — write-auth tamper-evidence (F2 closure)

**Status:** founder-DECIDED (2026-06-20). Closes **F2** (`main`-write authority is procedural,
not enforced — D-042) by *identity-by-signature*, **not** paid-tier branch protection.

## The decision
The free tier has no branch protection and sessions can share credentials, so a forged push to
`main` is not *blocked*. It is, however, made **detectable**: the EA signs its `main` commits, so a
commit that is unsigned or signed by a key not on the allowlist is a forged/foreign write — visible
to anyone who verifies. Tamper-evident, not tamper-proof. Paid-tier enforcement is **shelved**
unless signature-based tamper-evidence proves insufficient in practice.

This is **dogfooding**: it is built on the same cryptographic-identity primitive the product runs on
— an ED25519 key, the device identity being `sha256(DER SPKI of the ED25519 public key)`. The org
authenticates its own writes the way the substrate authenticates devices.

## Mechanism
- **Algorithm:** SSH commit signing, `ssh-ed25519`. `gpg.format = ssh`.
- **Key:** the EA's private signing key lives only in `~/.ssh/cnsunltd_ea_sign_ed25519`. It is
  **never committed** (a private-key banner would be blocked by the pre-commit secret-scan).
- **Public allowlist:** `governance/security/allowed_signers` maps the EA committer identity to its
  public key. This file IS committed — a public key is meant to be published.

## Per-clone setup (the local, machine-specific half)
```sh
git config gpg.format ssh
git config user.signingkey  ~/.ssh/cnsunltd_ea_sign_ed25519.pub
git config commit.gpgsign   true
git config gpg.ssh.allowedSignersFile "$(git rev-parse --show-toplevel)/governance/security/allowed_signers"
```

## Verify any commit
```sh
git log --show-signature -1            # look for: Good "git" signature for <ea-email>
git verify-commit <sha>                # exits non-zero if unsigned / wrong key
```

## Scope + limits (named, not hidden)
- Tamper-**evidence**, not prevention — a forged write still lands; it is just visibly not the EA's.
- Verification depends on this `allowed_signers` file being trusted (it lives on `main`, under the
  EA chokepoint — the same root of trust it secures; a defender cross-checks key fingerprint
  `SHA256:1iIntsqbgEd5uow5qhIl2t2Z/rjCYMbMt7pmftbMCmY` out of band on first adoption).
- Key rotation / multi-session EA identity is a follow-up: today there is one EA signing key.
- Security reviews this scheme as the F2 enforcement-specification owner before it is blessed on
  `main`; it lands on this branch first, behind the gate.
