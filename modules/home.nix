{
  config,
  pkgs,
  lib,
  ...
}:
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
      nodejs # needed on PATH for claude code plugin lifecycle hooks (e.g. ponytail)

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

    # Opt out of home-manager's implicit `Host *` defaults and declare the
    # ones we actually want below, so upstream default changes can't surprise us.
    enableDefaultConfig = false;

    settings = {
      "*" = {
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ServerAliveCountMax = 3;
        ControlPath = "~/.ssh/master-%r@%n:%p";
      };

      # Lab/test machines are reimaged constantly, so their host keys churn.
      "emitter-*" = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };
      "cassette-*" = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };

      oxos-test-server = {
        HostName = "oxos-test-server";
        User = "microc";
        ForwardX11Trusted = true;
        ForwardAgent = true;
      };
    };
  };

  # Cursor size and DPI for HiDPI monitors
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 130;
  };

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
      name = "catppuccin-mocha-blue-standard+rimless";
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };
    # Keep the legacy behaviour of theming GTK4 with the GTK3 theme above.
    # (Upstream's new default is null; being explicit silences the warning.)
    gtk4.theme = config.gtk.theme;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Home cursor theme (for applications that check home.pointerCursor)
  home.pointerCursor = {
    enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
    gtk.enable = true;
  };

}
