{
  config,
  inputs,
  ...
}:
{
  ##################################################################################################################
  #
  # sops-nix: encrypted secrets committed to this (public) repo.
  #
  # Secrets live encrypted in secrets/*.yaml and are decrypted at activation
  # into /run/secrets/<name>, which is a tmpfs — they never land in the
  # world-readable /nix/store, and never survive a reboot in plaintext.
  #
  # Editing:   nix run nixpkgs#sops -- secrets/laptop.yaml
  # Rekeying:  nix run nixpkgs#sops -- updatekeys secrets/laptop.yaml
  # Recipients are configured in ../.sops.yaml
  #
  ##################################################################################################################
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/laptop.yaml;
    defaultSopsFormat = "yaml";

    # Decrypt using the host's SSH key converted to an age identity. This is
    # why the machine can decrypt at boot with no human present and no extra
    # key material stored on disk.
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Don't invent a /var/lib/sops-nix key; the host SSH key above is the
      # only identity we rely on.
      generateKey = false;
    };

    secrets = {
      # Work VPN profile. openvpn reads this path directly, so render it
      # as a standalone file rather than an env var.
      "work-vpn/ovpn" = {
        # openvpn-work.service runs as root.
        owner = "root";
        group = "root";
        mode = "0400";
        # Restart the VPN when the profile changes.
        restartUnits = [ "openvpn-work.service" ];
      };

      # SSH private key used by nix to reach the aarch64 remote builder.
      "nixremote/key" = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
