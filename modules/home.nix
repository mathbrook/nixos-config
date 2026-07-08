{ config, pkgs, lib, ... }:
{
  ##################################################################################################################
  #
  # All matty's Home Manager Configuration
  #
  ##################################################################################################################
  imports = [
    ./terminal/kitty.nix
    ./hyprland/hyprland.nix
    ./media.nix
    ./wayland.nix
    ./shell.nix
  ];

  home = {
    username = "matty";
    homeDirectory = "/home/matty";
    stateVersion = "24.11";
    packages = with pkgs; [
      xdg-utils

      btop # replacement of htop/nmon
      iotop # io monitoring
      iftop # network monitoring

      # system call monitoring
      strace # system call monitoring
      ltrace # library call monitoring
      lsof # list open files

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb
      mesa-demos # includes glxinfo
      picom
    ];
    # backupFileExtension = "backup";
  };
  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "emitter-*" = {
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
      "cassette-*" = {
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
    };
  };

  # SSH config is symlinked to the Nix store (read-only, 0777), which SSH rejects.
  # Copy the store file to a real mutable file with correct permissions.
  home.activation.fixSshConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD cp --remove-destination $(readlink -f ${config.home.homeDirectory}/.ssh/config) ${config.home.homeDirectory}/.ssh/config
    $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.ssh/config
  '';


  # Cursor size and DPI for HiDPI monitors
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 130;
  };

  # GTK configuration
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };
  };

  # Home cursor theme (for applications that check home.pointerCursor)
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
    gtk.enable = true;
  };


}
