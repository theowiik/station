# All NixOS modules of this repo.
#
# base, locale, user and theme apply to every host. The feature modules
# (desktop, nvidia, gaming, flstudio, shell, devtools) do nothing until a host turns
# them on with my.<name>.enable, so a future host (a laptop, say) can pick
# only what it needs.
{
  imports = [
    ./base.nix
    ./locale.nix
    ./user.nix
    ./theme.nix
    ./desktop
    ./nvidia.nix
    ./gaming.nix
    ./flstudio.nix
    ./shell.nix
    ./devtools.nix
  ];
}
