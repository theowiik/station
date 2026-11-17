# Plain zsh: completion, history, autosuggestions and syntax highlighting
# (all built into Home Manager), a small prompt and a few aliases. No
# framework and no personal repos.
{ lib, osConfig, ... }:
lib.mkIf osConfig.my.shell.enable {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      share = true;
    };

    shellAliases = {
      ll = "ls -lh";
      la = "ls -lAh";
      # Rebuild this machine from the clone in ~/station. The flake output is
      # picked by hostname (station or station-vm).
      rebuild = "sudo nixos-rebuild switch --flake ~/station";
    };

    initContent = ''
      bindkey -e

      # Prompt: user@host, the directory, and the git branch when in a repo.
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
      setopt PROMPT_SUBST
      PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f''${vcs_info_msg_0_} %# '
    '';
  };
}
