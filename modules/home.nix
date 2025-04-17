{ config, pkgs, ... }: {
  ##################################################################################################################
  #
  # All matty's Home Manager Configuration
  #
  ##################################################################################################################
  imports = [
          ./terminal/kitty.nix
          ./i3/i3.nix
          ./media.nix
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
  };
  programs.home-manager.enable = true;

}
