# Plain zsh: completion, history, autosuggestions and syntax highlighting
# (all built into Home Manager), a Starship prompt and a few aliases. No
# framework and no personal repos.
{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  # The aliases, in the order stn-help lists them. Each one becomes a zsh
  # alias and a line in stn-help, so the two cannot drift apart.
  aliases = [
    {
      name = "stn-help";
      command = "stn-help";
      description = "this overview";
    }
  ]
  # niri-help comes from modules/home/niri.nix, which only exists with a desktop.
  ++ lib.optional osConfig.my.desktop.enable {
    name = "niri-help";
    command = "niri-help";
    description = "niri keybinds; niri-help <word> filters them";
  }
  ++ [
    {
      name = "rebuild";
      # The flake output is picked by hostname.
      command = "sudo nixos-rebuild switch --flake ~/station";
      description = "apply config changes from ~/station";
    }
    {
      name = "update";
      command = "nix flake update --flake ~/station && sudo nixos-rebuild switch --flake ~/station";
      description = "update all flake inputs (flake.lock), then rebuild";
    }
    {
      name = "ll";
      command = "ls -lh";
      description = "long listing, human-readable sizes";
    }
    {
      name = "la";
      command = "ls -lAh";
      description = "like ll, plus hidden files";
    }
  ];

  # stn-help and niri-help are scripts, not aliases, so they are left out of
  # shellAliases.
  shellAliases = lib.listToAttrs (
    map (a: lib.nameValuePair a.name a.command) (lib.filter (a: a.name != a.command) aliases)
  );

  width = lib.foldl' lib.max 0 (map (a: lib.stringLength a.name) aliases);

  stnHelp = pkgs.writeShellScriptBin "stn-help" ''
    if [ -t 1 ]; then b=$'\e[1m'; d=$'\e[2m'; r=$'\e[0m'; else b= d= r=; fi

    printf '%s%s%s  NixOS %s\n\n' "$b" "$(${pkgs.hostname}/bin/hostname)" "$r" "$(nixos-version)"

    printf '%sAliases%s\n' "$b" "$r"
    ${lib.concatMapStrings (a: ''
      printf '  %-${toString width}s  %s\n' ${lib.escapeShellArg a.name} ${lib.escapeShellArg a.description}
      ${lib.optionalString (a.name != a.command) ''
        printf '  %-${toString width}s  %s%s%s\n' "" "$d" ${lib.escapeShellArg a.command} "$r"
      ''}
    '') aliases}
    printf '\n%sConfig%s\n' "$b" "$r"
    printf '  ~/station            edit here, then run rebuild\n'
    printf '  ~/station/README.md  install notes and layout of the repo\n'
  '';
in
lib.mkIf osConfig.my.shell.enable {
  home.packages = [ stnHelp ];

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

    inherit shellAliases;

    initContent = ''
      bindkey -e
    '';
  };

  # The prompt, two lines:
  #
  #    ~/station   main !1 ?2   nix-shell  took 3s
  #   ❯
  #
  # user@host only shows over SSH. The arrow turns red when the last command
  # failed. Colors are the shared palette (modules/nixos/theme.nix).
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      palette = "station";
      palettes.station = osConfig.my.theme.palette;

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$os"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$nix_shell"
        "$python"
        "$nodejs"
        "$rust"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      username = {
        format = "[$user]($style)";
        style_user = "bold mauve";
        style_root = "bold red";
      };
      hostname = {
        format = "[@$hostname]($style) ";
        style = "bold mauve";
      };

      os = {
        disabled = false;
        format = "[$symbol]($style)";
        style = "bold cornflower";
        symbols.NixOS = " ";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold lavender";
        truncation_length = 4;
        truncation_symbol = "…/";
        truncate_to_repo = false;
        read_only = " 󰌾";
        read_only_style = "red";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold mauve";
      };
      git_state.style = "bold yellow";
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "peach";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        style = "bold sapphire";
        impure_msg = "nix-shell";
        pure_msg = "pure";
      };

      python = {
        format = "[$symbol$version( \\($virtualenv\\))]($style) ";
        symbol = " ";
        style = "yellow";
      };
      nodejs = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "green";
      };
      rust = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "peach";
      };

      cmd_duration = {
        format = "[took $duration]($style)";
        style = "overlay1";
        min_time = 2000;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
