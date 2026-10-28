# NixOS Config — Claude Instructions

## Repository Structure

This is a NixOS + Home Manager configuration flake.

- `flake.nix` — top-level flake. Hosts are built by the `mkHost` helper, which
  injects `inputs` and `modules/common.nix` into every host.
- `modules/` — shared modules. NixOS-level: `common.nix`, `xserver.nix`,
  `docker.nix`, `rtl-sdr.nix`, `builders.nix`, `spotify.nix`. Home Manager:
  `home.nix` (entry point), `shell.nix`, `wayland.nix`, `media.nix`,
  `hyprland/`, `terminal/`.
- `laptop/`, `chonker/`, `virtualbox/`, `virtualbox-lg/` — per-host configs
- `alma.jpg` — wallpaper source file

Hosts: `laptop` (aka `matty-framework`, the same config under both names),
`chonker`, `virtualbox`, `virtualbox-lg`.

## Conventions

- Home Manager modules go in `modules/` and are imported from `modules/home.nix`.
  Don't import the same module from two places — `imports` is deduped, but it
  makes ownership unclear.
- Run `nix fmt` before committing; CI enforces formatting.
- `nix flake check` builds every host.
- Secrets are managed by **sops-nix**, encrypted in `secrets/` and committed.
  Never add a plaintext secret to the repo. Edit with `nix develop` then
  `sops secrets/laptop.yaml`; see `secrets/README.md`. Consumers reference
  `config.sops.secrets."<name>".path` (resolves under `/run/secrets/`) rather
  than hardcoding `/etc/...` paths.

## Key Rules

- **Do not run `nixos-rebuild` or `home-manager switch`** — these require sudo/user interaction. Always instruct the user to run them.
- After making config changes, tell the user to run: `sudo nixos-rebuild switch --flake .#laptop`
- Do not run `home-manager switch` — the home-manager config is managed as a NixOS module, so `nixos-rebuild` handles everything.

## Hardware

- Laptop with two monitors: `eDP-1` (built-in) and `DP-3` (external Dell U3821DW)
- Compositor: Hyprland (Wayland)
- Wallpaper daemon: hyprpaper

## Workflow

1. Edit config files
2. Run `nix fmt`, then verify with `nix flake check`
3. Tell the user to run `sudo nixos-rebuild switch --flake .#laptop`

## Gotchas

- Never run `nix` against this repo under `sudo` — it leaves root-owned files
  in `.git/objects`, after which `nix flake lock`/`nix fmt` fail with
  "insufficient permission for adding an object to repository database".
  Fix with `sudo chown -R matty:users .git`.
- Don't hand-edit files that Home Manager manages (e.g. `~/.ssh/config`).
  HM owns them as store symlinks; converting one to a real file makes the
  *next* rebuild try to back it up, and the rebuild fails outright once a
  backup from a previous cycle already exists.
