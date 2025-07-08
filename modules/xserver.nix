{ config, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "none+i3";
      
      autoLogin = {
        enable = true;
        user = "matty";
      };

      lightdm = {
        enable = true;
        background = "/run/current-system/sw/share/backgrounds/alma.jpg";
        # You can adjust the path above if you want to use almaBackgrounds
      };
    };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        rofi
        dunst
        i3blocks
        xss-lock
        xsecurelock
        xautolock
        polybar
        polybar-pulseaudio-control
        i3status
        i3-gaps
        feh
        acpi
        arandr
        autorandr
        dex
        xbindkeys
        xorg.xbacklight
        xorg.xdpyinfo
        sysstat
      ];
    };
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  # Add any other graphical system services here (e.g., printing, picom, etc.)
}
