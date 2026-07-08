# NixOS Config — Claude Instructions

## Repository Structure

This is a NixOS + Home Manager configuration flake.

- `flake.nix` — top-level flake with system and home-manager configs
- `modules/` — shared NixOS/HM modules (common, desktop, home, shell, hyprland/, xserver/)
- `laptop/` — laptop-specific configuration (`configuration.nix`)
- `alma.jpg` — wallpaper source file

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
2. Tell the user to run `sudo nixos-rebuild switch --flake .#laptop`
