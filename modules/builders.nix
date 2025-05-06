{ config, lib, pkgs, ... }:

{
  # Required, otherwise buildMachines are ignored
  nix.distributedBuilds = true;

  # Optional, useful when the builder has a faster internet connection than yours
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "ubuntu-matty";
      system = "aarch64-linux";
      sshUser = "ubuntu";
      sshKey = "/root/.ssh/nixremote";
      maxJobs = 7;
      # protocol = "ssh-ng";
      supportedFeatures = [ ];
    }
  ];
}
