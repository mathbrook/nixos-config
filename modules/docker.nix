{ config, lib, pkgs, ... }:

{
  options = {
    docker.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to add to the docker group";
      example = [ "matty" "otheruser" ];
    };
  };

  config = {
    # Enable Docker
    virtualisation.docker = {
      enable = true;
    };

    # Add specified users to docker group
    users.users = lib.mkMerge (
      map (username: {
        ${username}.extraGroups = [ "docker" ];
      }) config.docker.users
    );
  };
}
