# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  services.xserver.libinput.naturalScrolling = true;
# Track the latest Linux kernel release for improved hardware support
boot.kernelPackages = pkgs.linuxPackages_latest;

# Enable fingerprint reader support
services.fprintd.enable = true;
# Enable firmware updates
services.fwupd.enable = true;
# Framework recommend turning this on 
services.power-profiles-daemon.enable = true;
services.tlp.enable = false;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "matty-framework"; # Define your hostname.
  system.stateVersion = "24.11"; # Did you read the comment?

}
