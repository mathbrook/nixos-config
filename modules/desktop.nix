{ config, pkgs, ... }:
{
  # Desktop environment and X11 configuration for Home Manager
  home.packages = with pkgs; [
    i3-gaps
    rofi
    dunst
    i3blocks
    xss-lock
    xsecurelock
    xautolock
    polybar
    polybar-pulseaudio-control
    i3status
    feh
    acpi
    arandr
    autorandr
    dex
    xbindkeys
    xorg.xbacklight
    xorg.xdpyinfo
    sysstat
    picom
    shotgun
    scrot
    brightnessctl
    gscreenshot
    slurp
    slop
    # add more desktop packages as needed
  ];
  environment.systemPackages = with pkgs; [
    # Desktop packages
    brave # Browser
    obsidian # Note taking
    discord
    slack
    vscode
    # You can add more desktop packages as needed
  ];
  # Optionally, import your i3 and picom configs
  imports = [ ./i3/i3.nix ];

  # Xresources for cursor and DPI
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 130;
  };

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
  # You can add more Home Manager desktop config here as needed
}
