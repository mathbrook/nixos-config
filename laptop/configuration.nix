# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../modules/xserver.nix
    ../modules/docker.nix
    ../modules/rtl-sdr.nix
  ];

  # Enable Docker and add users to docker group
  docker.users = [ "matty" ];

  # Enable RTL-SDR support (without GUI software to avoid CUDA dependencies)
  rtl-sdr = {
    enable = true;
    users = [ "matty" ];
    installSdrSoftware = false;  # Disable GQRX to avoid CUDA/gr-osmosdr issues
  };

  environment.systemPackages = with pkgs; [
    libinput
    # still does not work!
    libinput-gestures
    # iPod/iOS device support
    libimobiledevice
    ifuse
  ];

  # Libinput configuration (moved from services.xserver.libinput)
  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;
  services.libinput.touchpad.horizontalScrolling = true;

  # Track the latest Linux kernel release for improved hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable binfmt for ARM64 emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.registrations.aarch64-linux = {
    fixBinary = true;
  };

  # Enable fingerprint reader support
  services.fprintd.enable = true;
  # Enable firmware updates
  services.fwupd.enable = true;
  # Enable usbmuxd for iPod/iOS device support
  services.usbmuxd.enable = true;
  # Framework recommend turning this on
  services.power-profiles-daemon.enable = true;
  # Suwayomi server for manga
  services.suwayomi-server = {
    enable = true;
    settings.server.port = 4567;
  };
  # FlareSolverr for bypassing Cloudflare protection
  services.flaresolverr = {
    enable = true;
    port = 8191;
  };
  services.tlp.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Suspend on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "matty-framework"; # Define your hostname.

  # Open firewall for port-forward-to-office.sh ports
  networking.firewall.allowedTCPPorts = [
    # Cassette container ports
    8080 8081 8082 8083 6969 8086 8090 8787 8788 8802 9082
    # Emitter container ports
    8087 8088
    # SSH forwards
    2023 2024
    # Additional port
    3000
  ];

  # Work VPN — starts at boot; manage with: systemctl {start,stop,status} openvpn-work
  # Place your .ovpn file at /etc/openvpn/work.ovpn before rebuilding.
  services.openvpn.servers.work = {
    config = "config /etc/openvpn/work.ovpn";
    autoStart = true;
  };

  system.stateVersion = "24.11"; # Did you read the comment?

  services.udev.extraRules = ''ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c --match-edid"'';
  # Audio and pipewire config for desktop systems
  services.pulseaudio.enable = false;
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
