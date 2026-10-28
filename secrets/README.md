# Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) and are
**encrypted in this repo**, so this repo can stay public. There is no separate
private repo to keep in sync.

## How it works

- `../.sops.yaml` lists the age recipients and which files they apply to.
- `laptop.yaml` holds the laptop's secrets, encrypted. Keys are readable,
  values are ciphertext — so diffs stay reviewable.
- At activation, sops-nix decrypts into `/run/secrets/<name>`, a tmpfs with
  per-secret owner/mode. Plaintext never enters `/nix/store` and never
  survives a reboot.

Recipients are **age keys derived from existing ed25519 SSH keys**, so there is
no new private key to back up:

| Recipient | Derived from | Purpose |
|---|---|---|
| `matty` | `~/.ssh/id_ed25519` | lets you edit secrets |
| `laptop` | `/etc/ssh/ssh_host_ed25519_key` | lets the machine decrypt at boot |

## Editing a secret

From the repo root (`nix develop` puts `sops` on your PATH):

```sh
nix develop
sops secrets/laptop.yaml
```

That opens your editor on the decrypted content and re-encrypts on save.
Then rebuild:

```sh
sudo nixos-rebuild switch --flake .#laptop
```

## Current secrets

- `work-vpn.ovpn` → `/run/secrets/work-vpn/ovpn`, read by `openvpn-work.service`
- `nixremote.key` → `/run/secrets/nixremote/key`, the aarch64 remote builder SSH key

Both currently contain **placeholders** — replace them with the real values via
`sops secrets/laptop.yaml` before expecting the VPN or remote builder to work.

## Adding a new machine

1. Get its age recipient: `nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub`
2. Add it to `../.sops.yaml` under `keys:` and the relevant `creation_rules`.
3. Re-encrypt so the new recipient can read existing secrets:
   `nix run nixpkgs#sops -- updatekeys secrets/laptop.yaml`

## Reinstalling a machine

A fresh install generates a **new** host SSH key, so the old recipient is dead.
Re-derive it and run `sops updatekeys` as above. (Your user key is unchanged, so
you can always still decrypt and rekey.)
