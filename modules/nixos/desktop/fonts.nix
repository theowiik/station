# Fonts: the theme fonts plus a broad default set with emoji and CJK.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  fonts = config.my.theme.fonts;
in
lib.mkIf config.my.desktop.enable {
  fonts = {
    # DejaVu, Liberation, FreeFont, TeX Gyre, Unifont and Noto Color Emoji.
    enableDefaultPackages = true;

    packages = [
      fonts.sans.package
      fonts.mono.package
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-color-emoji
      pkgs.liberation_ttf
    ];

    fontconfig.defaultFonts = {
      sansSerif = [
        fonts.sans.name
        "Noto Sans"
      ];
      serif = [ "Noto Serif" ];
      monospace = [
        fonts.mono.name
        "Noto Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
