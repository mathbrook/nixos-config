# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:
let
  onnxruntime-gpu-wheel =
    ps:
    ps.buildPythonPackage {
      pname = "onnxruntime-gpu";
      version = "1.16.3";
      format = "wheel";

      src = pkgs.fetchurl {
        url = "https://pypi.jetson-ai-lab.dev/jp5/cu114/+f/43e/f0cec5f026159/onnxruntime_gpu-1.16.3-cp311-cp311-linux_aarch64.whl";
        sha256 = "43ef0cec5f026159306e69540138f457ecbc8eb0282d1f7166761e7fbc84288e";
      };

      propagatedBuildInputs = with ps; [
        coloredlogs
        flatbuffers
        numpy
        packaging
        protobuf
        sympy
      ];
    };
  cudainfo = pkgs.writeScriptBin "cudainfo" (builtins.readFile ../scripts/cudainfo.py);
  pythonPackages =
    ps: with ps; [
      pipx
      pip
      virtualenv
      numpy
      wheel
      onnx
      tqdm
      matplotlib
      pycuda
      (onnxruntime-gpu-wheel ps)
    ];
in
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      require-sigs = false;
      trusted-users = [
        "root"
        "nixos"
        "ubuntu"
        "matty"
        "brookie"
      ];
      substituters = [ "https://cuda-maintainers.cachix.org" ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

  };
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "xavier-nx-emmc"; # Other options include orin-agx, xavier-nx, and xavier-nx-emmc
  hardware.nvidia-jetpack.carrierBoard = "devkit";
  hardware.nvidia-jetpack.modesetting.enable = false;
  hardware.graphics.enable = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelParams = [ "fbcon=map:1" ];
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # services.sshd.enable = true;
  # services.sshd.settings.X11Forwarding = true;
  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.defaultSession = "gnome";
  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # remember to keep the cachix keys updated for nvidia: while using cachix for the nvidia latest packages
  # do this by running `cachix use cuda-maintainers`

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    password = "nixos";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "dialout"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ tree ];
  };

  # programs.firefox.enable = true;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # pkgs.cudainfo = pkgs.writeScriptBin "cudainfo" (builtins.readFile ../scripts/cudainfo.py);
  environment.variables = with pkgs; {
    # LD_LIBRARY_PATH = lib.makeLibraryPath [
    #   stdenv.cc.cc.lib
    #   cudaPackages.cudatoolkit
    #   cudaPackages.cudnn
    #   cudaPackages.tensorrt
    #   # cudaPackages.vpi2
    #   nvidia-jetpack.l4t-cuda
    #   nvidia-jetpack.l4t-gstreamer
    #   nvidia-jetpack.l4t-multimedia
    #   nvidia-jetpack.l4t-camera
    # ];
    # NVCC_PREPEND_FLAGS = "--compiler-bindir ${pkgs.gcc11}/bin/gcc";
    # NVCC_APPEND_FLAGS = "-I${pkgs.cudaPackages.cuda_cudart.include}/include";
  };

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    micro
    git
    btop
    usbutils
    pciutils
    tmux
    nixfmt
    # sw
    gcc
    # cuda thingies
    cudainfo
    cudaPackages.cuda_nvcc
    nvidia-jetpack.samples.cuda-test
    nvidia-jetpack.samples.cudnn-test
    opencv
    #python
    (python311.withPackages pythonPackages)
    # Networking
    tcpdump
    ethtool
    wget
    iperf3
    # cudainfo
    # Pain and Suffering:
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    emitter-orchestrator
  ];

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
