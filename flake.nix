{
  description = "NixOS configuration for my gaming desktop";

  inputs = {
    # NixOS 26.05 "Yarara", the current stable release.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # The Home Manager branch that matches NixOS 26.05.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      # A host is the shared modules plus its own directory under hosts/.
      mkHost =
        hostDir:
        nixpkgs.lib.nixosSystem {
          modules = [
            home-manager.nixosModules.home-manager
            ./modules/nixos
            hostDir
          ];
        };
    in
    {
      nixosConfigurations = {
        station = mkHost ./hosts/station;
        station-vm = mkHost ./hosts/station-vm;
      };

      # `nix fmt` formats every Nix file in the repo.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
