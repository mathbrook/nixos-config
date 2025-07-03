{
  config,
  lib,
  pkgs,
  ...
}:
let
  oxos-config-path = "/opt/oxos/config";
in
{
  options.emitter-orchestrator-service.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable or disable the emitter-orchestrator";
  };

  config = lib.mkIf config.emitter-orchestrator-service.enable {

    systemd.services.emitter-orchestrator-service = {
      description = "emitter-orchestrator";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        After = [ "network.target" ];
        ExecStart = "${pkgs.emitter-orchestrator}/bin/emitter-orchestrator";
        ExecStop = "/bin/kill -9 $MAINPID";
        Restart = "on-failure";
      };
    };

    # Create oxos config directory if it doesn't exist
    system.activationScripts.createConfigDir = pkgs.lib.mkForce ''
      mkdir -p "${oxos-config-path}"
      chown nixos:users "${oxos-config-path}"
    '';

    # Write JSON content from repo to /home/nixos/config/drivebrain_config.json file if it doesn't exist
    system.activationScripts.writeConfigFile = pkgs.lib.mkForce ''
      if [ ! -f "${oxos-config-path}/emitter-orchestrator-config.json" ]; then
        cp "${pkgs.emitter-orchestrator}/lib/emitter-orchestrator-config.json" "${oxos-config-path}"
        chown nixos:users "${oxos-config-path}/emitter-orchestrator-config.json"
      fi
    '';

  };
}
