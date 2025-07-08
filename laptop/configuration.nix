# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../modules/xserver.nix
  ];

  environment.systemPackages = with pkgs; [
    libinput
    # still does not work!
    libinput-gestures

  ];
  services.xserver.libinput.enable = true;
  # services.xserver.libinput-gestures.enable = true;

  services.xserver.libinput.naturalScrolling = true;
  services.xserver.libinput.horizontalScrolling = true;

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

  services.udev.extraRules = ''ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c --match-edid"'';
  # Audio and pipewire config for desktop systems
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.printing.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Optional
    dedicatedServer.openFirewall = true; # Optional
  };
  # Xresources for cursor and DPI
  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 130;
  # };
}
