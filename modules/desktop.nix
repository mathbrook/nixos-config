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
    
    brave # Browser
    obsidian # Note taking
    discord
    slack
    vscode-fhs

    # add more desktop packages as needed
  ];
  # Optionally, import your i3 and picom configs
  imports = [ ./i3/i3.nix ];


  # You can add more Home Manager desktop config here as needed
}
