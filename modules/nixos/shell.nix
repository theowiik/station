# zsh as the login shell. The zsh configuration itself is in
# modules/home/shell.nix (Home Manager).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.shell.enable = lib.mkEnableOption "zsh as the login shell, configured with Home Manager";

  config = lib.mkIf config.my.shell.enable {
    programs.zsh.enable = true;
    users.users.${config.my.user.name}.shell = pkgs.zsh;

    # Completions for system packages, as the Home Manager zsh module asks.
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
