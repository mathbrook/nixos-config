# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  ...
}:
{
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
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };
  services.tailscale.enable = true;
  services.mullvad-vpn.enable = true;
  programs.ssh.startAgent = true;

  # Enable polkit for authentication
  security.polkit.enable = true;

  # Enable libinput for touchpad gestures
  services.libinput.enable = true;

  users.users.matty = {
    isNormalUser = true;
    description = "matty";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWUeixmFX1/A4zBYY89ExPZ1/02egXg+HOpOBKvgfL+ matty@DESKTOP-17ID03O"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2JsGOoTTi33HED/8zli99uWpKovHVP00TlR7IxTKw8 mathewos@DESKTOP-17ID03O"
    ];
    packages = with pkgs; [
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
      init = {
        defaultBranch = "main";
      };
      user = {
        name = "Matthew Samson";
        email = "mathos.brook@gmail.com";
      };
    };
  };

  # programs.light.enable = true; # Needed for the /run/wrappers/bin/light SUID wrapper.
  # services.actkbd = {
  #   enable = true;
  #   bindings = [
  #     { keys = [ 233 ]; events = [ "key" ]; command = "brightnessctl s +5"; }
  #     { keys = [ 232 ]; events = [ "key" ]; command = "brightnessctl s -5"; }
  #   ];
  # };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = [
    "matty"
    "nixos"
    "ubuntu"
    "brookie"
  ];
  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget # Get things
    micro # Fuck nano
    tmux # goat
    nixfmt-classic # Format .nix files
    mullvad-vpn
    neofetch
    # mpv
    ffmpeg
    wmctrl
    wmname
    # python310
    neovim
    alacritty
    kitty
    noto-fonts
    # font-awesome
    # screenshot utils
    llvmPackages_20.clang-unwrapped

    openvpn
  ];
}
