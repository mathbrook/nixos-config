{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    rtl-sdr = {
      enable = mkEnableOption "RTL-SDR software defined radio support";

      blacklistKernelModules = mkOption {
        type = types.listOf types.str;
        default = [ "dvb_usb_rtl28xxu" ];
        description = ''
          Kernel modules to blacklist. Default is dvb_usb_rtl28xxu.
          For some devices like Orange Pi, you may need to blacklist dvb_usb_rtl2832u instead.
        '';
        example = [ "dvb_usb_rtl28xxu" "dvb_usb_rtl2832u" ];
      };

      installSdrSoftware = mkOption {
        type = types.bool;
        default = true;
        description = "Install SDR software packages (GQRX, CubicSDR)";
      };

      users = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of users to add to the plugdev group for RTL-SDR access";
        example = [ "matty" ];
      };
    };
  };

  config = mkIf config.rtl-sdr.enable {
    # Install RTL-SDR drivers and tools
    environment.systemPackages = with pkgs; [
      rtl-sdr
      libusb1
    ] ++ optionals config.rtl-sdr.installSdrSoftware [
      gqrx
      # Note: SDR++ and CubicSDR may need to be added separately if available in nixpkgs
      # You can add them here if they're available in your nixpkgs version
    ];

    # Blacklist DVB-T kernel modules so RTL-SDR can access the device
    boot.blacklistedKernelModules = config.rtl-sdr.blacklistKernelModules;

    # Udev rules for RTL-SDR devices
    # This allows non-root users to access the RTL-SDR hardware
    services.udev.packages = [ pkgs.rtl-sdr ];

    # Add specified users to plugdev group for device access
    users.groups.plugdev = {};
    users.users = mkMerge (
      map (username: {
        ${username}.extraGroups = [ "plugdev" ];
      }) config.rtl-sdr.users
    );
  };
}
