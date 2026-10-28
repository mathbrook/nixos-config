{
  config,
  lib,
  pkgs,
  ...
}:

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
      # Prefer the sops-managed key when the host imports modules/secrets.nix
      # (laptop); fall back to the hand-placed path on hosts that don't
      # (chonker), so this module stays usable on both.
      sshKey =
        if (config ? sops) && (config.sops.secrets ? "nixremote/key") then
          config.sops.secrets."nixremote/key".path
        else
          "/root/.ssh/nixremote";
      maxJobs = 7;
      # protocol = "ssh-ng";
      supportedFeatures = [ "big-parallel" ];
    }
  ];
}
