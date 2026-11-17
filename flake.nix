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
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # The hosts are added once their modules exist.
      nixosConfigurations = { };

      # `nix fmt` formats every Nix file in the repo.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
