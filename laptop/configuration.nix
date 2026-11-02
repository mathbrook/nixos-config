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
    installSdrSoftware = false; # Disable GQRX to avoid CUDA/gr-osmosdr issues
  };

  environment.systemPackages = with pkgs; [
    libinput
    # still does not work!
    libinput-gestures
    # iPod/iOS device support
    libimobiledevice
    ifuse
    # candump/cansend for the oxos-canon vcan test network
    can-utils
  ];

  # Libinput configuration (moved from services.xserver.libinput)
  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;
  services.libinput.touchpad.horizontalScrolling = true;

  # Track the latest Linux kernel release for improved hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Virtual CAN + ISO-TP, for oxos-canon's vcan test network
  # (~/dev/oxos-canon/tests/network/README.md). Both are mainline in-tree
  # modules; nothing to build. After rebuild, bring the interface up with
  # oxos-canon's scripts/setup_vcan.sh (module load alone does not create it).
  boot.kernelModules = [
    "vcan"
    "can-isotp"
  ];

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
    8080
    8081
    8082
    8083
    6969
    8086
    8090
    8787
    8788
    8802
    9082
    # Emitter container ports
    8087
    8088
    # SSH forwards
    2023
    2024
    # Additional port
    3000
    # Orthanc DICOM (C-STORE from cassette) — OXOS-11220 smoke harness
    4242
  ];

  # Work VPN — manage with: sudo systemctl {start,stop,status} openvpn-work
  #
  # The profile is stored encrypted in secrets/laptop.yaml (sops-nix) and
  # decrypted at activation to the path below; see modules/secrets.nix.
  # Edit it with:  nix run nixpkgs#sops -- secrets/laptop.yaml
  #
  # autoStart stays off: this is a work VPN we bring up on demand, and a
  # broken/expired profile shouldn't fail every nixos-rebuild.
  services.openvpn.servers.work = {
    config = "config ${config.sops.secrets."work-vpn/ovpn".path}";
    autoStart = false;
  };

  system.stateVersion = "24.11"; # Did you read the comment?

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c --match-edid"
    # Radcal AccuGold digitizer (FTDI FT232, product "Accu-Gold") — owned by matty, no dialout/sudo needed.
    # Covers both the ftdi_sio tty node and the raw usbfs device node (for libftdi/libusb access when ftdi_sio is unbound).
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="RCSD45K0", OWNER="matty", MODE="0660"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="RCSD45K0", OWNER="matty", MODE="0660"
  '';
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
