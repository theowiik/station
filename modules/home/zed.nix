# Zed editor with declarative settings. Home Manager writes settings.json, so
# change settings here rather than in Zed's settings UI.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
lib.mkIf osConfig.my.desktop.enable {
  # nixpkgs names the CLI `zeditor`; add `zed` like on other systems.
  home.packages = [
    (pkgs.runCommand "zed-alias" { } ''
      mkdir -p $out/bin
      ln -s ${lib.getExe' config.programs.zed-editor.package "zeditor"} $out/bin/zed
    '')
  ];

  programs.zed-editor = {
    enable = true;
    userSettings = {
      disable_ai = true; # hides the agent panel, edit predictions and other AI features
      debugger.button = false;
      collaboration_panel.button = false;
      title_bar.show_sign_in = false;
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };
  };
}
