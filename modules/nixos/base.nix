# Settings every host gets: Nix itself, the boot loader, networking and power.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my = {
    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Unfree packages that may be installed, by package name. Each module
        adds the ones it needs, so the full list stays explicit.
      '';
    };

    hardwarePlaceholder = lib.mkOption {
      type = lib.types.bool;
      default = false;
      internal = true;
      description = "Set by the placeholder hardware-configuration.nix files.";
    };
  };

  config = {
    warnings = lib.optional config.my.hardwarePlaceholder ''
      hosts/${config.networking.hostName}/hardware-configuration.nix is still the
      placeholder. Replace it with the output of nixos-generate-config before
      installing (see README.md).
    '';

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.my.unfreePackages;

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Flakes only. Without channels there is no package state outside this repo.
      channel.enable = false;

      # Weekly garbage collection of old generations and unused store paths.
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
        persistent = true;
      };

      # Weekly store optimisation (identical files are hard linked).
      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
    };

    boot.loader = {
      systemd-boot = {
        enable = true;
        # At most this many generations in the boot menu. This also keeps the
        # EFI system partition from filling up with old kernels.
        configurationLimit = 10;
        # Do not allow editing kernel parameters from the boot menu.
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };

    # Never hibernate. Suspend stays available; whether it works on the
    # hardware is a TODO in each host file.
    systemd.sleep.settings.Sleep = {
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };

    networking.networkmanager.enable = true;
    networking.firewall.enable = true;

    # Compressed swap in RAM.
    zramSwap.enable = true;
    services.fstrim.enable = true;

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      pciutils
      usbutils
    ];
  };
}
