{
  description = "NixOS config for my computers :3c";

  inputs = {
    # NixOS official package source, using nixos-unstable. Scary!
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Every host gets `inputs` in scope and the shared common module.
      mkHost =
        { modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./modules/common.nix ] ++ modules;
        };

      # The laptop, with home-manager wired in as a NixOS module.
      laptop = mkHost {
        modules = [
          ./laptop/configuration.nix
          ./modules/spotify.nix
          ./modules/builders.nix
          ./modules/secrets.nix
          nixos-hardware.nixosModules.framework-13-7040-amd
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "home-manager.backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.matty = import ./modules/home.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        inherit laptop;
        # Alias so `nixos-rebuild` works unqualified on this host, whose
        # hostname is matty-framework.
        matty-framework = laptop;

        virtualbox = mkHost { modules = [ ./virtualbox/configuration.nix ]; };
        virtualbox-lg = mkHost { modules = [ ./virtualbox-lg/configuration.nix ]; };
        chonker = mkHost {
          modules = [
            ./chonker/configuration.nix
            ./modules/builders.nix
          ];
        };
      };

      # `nix fmt`
      formatter.${system} = pkgs.nixfmt-tree;

      # `nix flake check` builds every host's toplevel. Checks must be
      # derivations, so map each config to its system closure.
      checks.${system} = nixpkgs.lib.mapAttrs' (
        name: cfg: nixpkgs.lib.nameValuePair "host-${name}" cfg.config.system.build.toplevel
      ) (nixpkgs.lib.removeAttrs self.nixosConfigurations [ "matty-framework" ]);

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nixfmt
          nix-output-monitor
          deadnix
          statix
          # Secrets editing: `sops secrets/laptop.yaml`
          sops
          ssh-to-age
          age
        ];
      };
    };
}
