# PLACEHOLDER. Replace this whole file on the real machine.
#
# It exists only so that `nix flake check` and `nix build` work before NixOS
# is installed. The device names below are fake on purpose. They are not a
# guess at the real disk layout, and no kernel modules are listed. At install
# time, generate the real file on station and commit it:
#
#   sudo nixos-generate-config --root /mnt --show-hardware-config > hosts/station/hardware-configuration.nix
#
# (drop `--root /mnt` when running it on an installed system). See README.md.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Makes the build print a warning until this file is replaced.
  my.hardwarePlaceholder = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/PLACEHOLDER-ROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/PLACEHOLDER-ESP";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
