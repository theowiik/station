# PLACEHOLDER. Replace this whole file inside the VM.
#
# It exists only so that `nix flake check` and `nix build` work before the VM
# is installed. The device names below are fake on purpose and no kernel
# modules are listed. Inside the VM, generate the real file and commit it:
#
#   sudo nixos-generate-config --show-hardware-config > hosts/station-vm/hardware-configuration.nix
#
# See README.md.
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
