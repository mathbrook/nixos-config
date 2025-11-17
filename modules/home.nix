{ config, pkgs, ... }:
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
    ./desktop.nix
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
      glxinfo
      picom
    ];
    # backupFileExtension = "backup";
    
    # Shell aliases
    shellAliases = {
      # NixOS rebuild alias - automatically detects hostname for flake derivation
      nos = "sudo nixos-rebuild switch --flake /home/matty/dev/nixos-config#$(hostname)";
      
      # Additional helpful aliases
      nrs = "sudo nixos-rebuild switch --flake /home/matty/dev/nixos-config#$(hostname)";
      nrb = "sudo nixos-rebuild boot --flake /home/matty/dev/nixos-config#$(hostname)";
      nrt = "sudo nixos-rebuild test --flake /home/matty/dev/nixos-config#$(hostname)";
    };
  };
  programs.home-manager.enable = true;

  # Enable bash with the aliases
  programs.bash = {
    enable = true;
    enableCompletion = true;
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
