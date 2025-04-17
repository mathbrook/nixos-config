{
  description = "NixOS config for my computers :3c";

  inputs = {
    # NixOS official package source, using nixos-unstable. Scary!
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs: {

    nixosConfigurations = {
      virtualbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./virtualbox/configuration.nix ./modules/common.nix ];
      };
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./laptop/configuration.nix
          ./modules/common.nix
          ./modules/spotify.nix
          nixos-hardware.nixosModules.framework-13-7040-amd
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "home-manager.backup";
            home-manager.users.matty = import ./modules/home.nix;
          }
        ];
      };
      virtualbox-lg = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./virtualbox-lg/configuration.nix ./modules/common.nix ];
      };
    };
  };
}
