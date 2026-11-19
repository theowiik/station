{
  description = "NixOS configuration for my gaming desktop";

  inputs = {
    # NixOS 26.05 "Yarara", the current stable release.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Claude Code, Codex and T3 Code release far faster than the stable channel
    # backports them, so those packages come from unstable instead. So does
    # Wine, for a fix FL Studio needs (see modules/nixos/flstudio.nix).
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # The Home Manager branch that matches NixOS 26.05.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      # Packages taken from unstable instead of the pinned stable release.
      unstablePackages = [
        "claude-code"
        "codex"
        "t3code"
        "wineWow64Packages"
      ];

      # This pkgs set is built outside the NixOS module system, so the
      # my.unfreePackages allowlist in modules/nixos/base.nix cannot reach it.
      # The same list above therefore doubles as the unfree allowlist here.
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) unstablePackages;
      };

      unstableOverlay = _final: _prev: nixpkgs.lib.genAttrs unstablePackages (name: unstablePkgs.${name});

      # A host is the shared modules plus its own directory under hosts/.
      mkHost =
        hostDir:
        nixpkgs.lib.nixosSystem {
          modules = [
            home-manager.nixosModules.home-manager
            ./modules/nixos
            hostDir
            { nixpkgs.overlays = [ unstableOverlay ]; }
          ];
        };
    in
    {
      nixosConfigurations = {
        station = mkHost ./hosts/station;
      };

      # `nix fmt` formats every Nix file in the repo.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
