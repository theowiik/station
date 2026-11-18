# Command line development tools.
{
  lib,
  pkgs,
  osConfig,
  ...
}:
lib.mkIf osConfig.my.devtools.enable {
  programs.git = {
    enable = true;
    # TODO(git): the name and email for your commits are not in this repo.
    # Add them below as user.name and user.email. (`git config --global`
    # cannot write here, because Home Manager owns ~/.config/git/config.)
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    btop
    tree
    file
    unzip
    nil # Nix language server
    nixfmt
    claude-code # unfree, allowed in modules/nixos/devtools.nix
  ];
}
