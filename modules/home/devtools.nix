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

  # GitHub CLI. Also makes git use `gh auth` for https://github.com pushes and
  # pulls. Log in once with `gh auth login`.
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Per-project tool versions (Node, Python, ...) from mise.toml, activated
  # in zsh.
  programs.mise.enable = true;

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
    uv # Python package and project manager; mise.toml pins override it per project
    claude-code # unfree (modules/nixos/devtools.nix), from unstable (flake.nix)
    codex # OpenAI's coding agent CLI, from unstable (flake.nix)
    t3code # GUI for coding agents, from unstable (flake.nix)
  ];
}
