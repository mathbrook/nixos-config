{
  description = "NixOS config for my computers :3c";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

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
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
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
