# The main user, and Home Manager (as a NixOS module) for that user.
{ config, lib, ... }:
let
  cfg = config.my.user;
in
{
  options.my.user = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Login name of the main user.";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Full name of the main user.";
    };
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = cfg.fullName;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      # No password in the repo. Set it once with `passwd` (see README.md).
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      # If a file that Home Manager manages already exists (for example one a
      # program wrote on its first start), move it aside instead of failing.
      backupFileExtension = "hm-backup";
      overwriteBackup = true;

      users.${cfg.name} = {
        imports = [ ../home ];
        home.stateVersion = "26.05";
      };
    };
  };
}
