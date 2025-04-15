{
  description = "NixOS config for my computers :3c";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  };

  outputs = { self, nixpkgs, ... }@inputs: {

    nixosConfigurations = {
      virtualbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
        ./virtualbox/configuration.nix
        ./modules/common.nix
      ];
      };
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
        ./laptop/configuration.nix
        ./modules/common.nix
      ];
      };
    };
  };
}
