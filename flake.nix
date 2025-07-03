{
  description = "NixOS config for my computers :3c";
  nixConfig = {
    extra-substituters = [ "https://cuda-maintainers.cachix.org" ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  inputs = rec {
    # NixOS official package source, using nixos-unstable. Scary!
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    jetpack.url = "github:anduril/jetpack-nixos/master";
    jetpack.inputs.nixpkgs.follows = "nixpkgs";
    mcx-emitter = {
      type = "git";
      url = "ssh://git@github.com/oxosmedical/mcx-emitter.git";
      ref = "nix";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      jetpack,
      mcx-emitter,
      ...
    }:
    rec {
      nixpkg_overlays = {
        nixpkgs.overlays = [
          (final: prev: {
            inherit (final.nvidia-jetpack) cudaPackages;
            opencv4 = prev.opencv4.override { inherit (final) cudaPackages; };
          })
          jetpack.overlays.default
          mcx-emitter.overlays.default
          mcx-emitter.inputs.mcx-common-libs.overlays.default
        ];
        nixpkgs.config = {
          allowUnfree = true;
          cudaSupport = true;
          cudaCapabilities = [ "7.2" ]; # I think we only need 7.2 for the xavier
        };
      };
      nixosConfigurations = {
        jetson = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit self; };
          modules = [
            ./jetson/configuration.nix
            ./modules/builders.nix
            (nixpkg_overlays)
            jetpack.nixosModules.default
            # mcx-emitter.packages.emitter-orchestrator
          ];
        };
      };
      jetson_top = nixosConfigurations.jetson.config.system.build.toplevel;
      # images.xavier = nixosConfigurations.jetson.config.system.build.sdImage;
      # jetson_top = nixosConfigurations.jetson.config.system.build.toplevel;
    };
}
