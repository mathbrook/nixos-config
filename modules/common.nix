# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
let
  almaBackgrounds = pkgs.runCommand "alma-backgrounds" { } ''
    mkdir -p $out/share/backgrounds
    cp ${../alma.jpg} $out/share/backgrounds/alma.jpg
  '';
in {
  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "America/New_York";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
# services.xserver.displayManager.lightdm.greeters.gtk.extraConfig = ''user-background = false'';
  # Enable the X11 windowing system
  services = {
    xserver = {
      enable = true;
      displayManager = {
        lightdm = {
          enable = true;
          background = "${almaBackgrounds}/share/backgrounds/alma.jpg";
          # greeters.gtk = {
          #   enable = false;
          #   # theme = {
          #   #   name = "WhiteSur-dark-alt-purple";
          #   #   package = pkgs.whitesur-gtk-theme;
          #   # };
          # };
        };
        defaultSession = "xfce+i3";
        autoLogin = {
          enable = true;
          user = "matty";
        };
      };
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
          enableScreensaver = false;
        };
      };
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          rofi # application launcher, the same as dmenu
          dunst # notification daemon
          i3blocks # status bar
          i3lock # default i3 screen locker
          xss-lock
          xsecurelock
          xautolock # lock screen after some time
          i3status # provide information to i3bar
          i3-gaps # i3 with gaps
          # picom # transparency and shadows
          feh # set wallpaper
          acpi # battery information
          arandr # screen layout manager
          dex # autostart applications
          xbindkeys # bind keys to commands
          xorg.xbacklight # control screen brightness
          xorg.xdpyinfo # get screen information
          sysstat # get system information
        ];
      };
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    # Add picom to do transparency in i3 i hope lmao
    # picom.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
  };
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matty = {
    isNormalUser = true;
    description = "matty";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  # programs.hyprland.enable = true;
  programs.firefox.enable = false;
  programs.git = {
    enable = true;
    config = {
      init = { defaultBranch = "main"; };
      user = {
        name = "Matthew Samson";
        email = "mathos.brook@gmail.com";
      };
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;
  nix.channel.enable =
    false; # remove nix-channel related tools & configs, we use flakes instead.

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget # Get things
    micro # Fuck nano
    tmux # goat
    nixfmt # Format .nix files
    brave # Browser
    obsidian # Note taking
    xdg-desktop-portal
    xdg-desktop-portal-gtk # For GTK apps, like GNOME/KDE portals
    # pulseaudio # Include this so the volume buttons work
    # window manager
    st
    sxhkd
    termite
    # picom
    neofetch
    mpv
    ffmpeg
    wmctrl
    wmname
    python310
    discord
    slack
    vscode
    neovim
    alacritty
    kitty
  ];
}
