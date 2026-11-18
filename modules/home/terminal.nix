# foot, a Wayland terminal.
{ lib, osConfig, ... }:
let
  theme = osConfig.my.theme;
  # foot wants colors without the leading #.
  c = lib.mapAttrs (_: lib.removePrefix "#") theme.palette;
in
lib.mkIf osConfig.my.desktop.enable {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${theme.fonts.mono.name}:size=${toString theme.fonts.size}";
        pad = "8x8";
      };

      mouse.hide-when-typing = "yes";

      # Catppuccin Mocha terminal colors.
      colors-dark = {
        foreground = c.text;
        background = c.base;
        regular0 = c.surface1;
        regular1 = c.red;
        regular2 = c.green;
        regular3 = c.yellow;
        regular4 = c.blue;
        regular5 = c.pink;
        regular6 = c.teal;
        regular7 = c.subtext1;
        bright0 = c.surface2;
        bright1 = c.red;
        bright2 = c.green;
        bright3 = c.yellow;
        bright4 = c.blue;
        bright5 = c.pink;
        bright6 = c.teal;
        bright7 = c.subtext0;
        selection-foreground = c.text;
        selection-background = c.surface1;
        urls = c.blue;
      };
    };
  };
}
