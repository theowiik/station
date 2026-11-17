# Time zone, language, regional formats and keyboard layout.
#
# Each host sets my.locale from one variable at the top of its host file.
{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.my.locale;
in
{
  options.my.locale = {
    timeZone = mkOption {
      type = types.str;
      example = "Europe/Stockholm";
      description = "Time zone.";
    };

    language = mkOption {
      type = types.str;
      example = "en_US.UTF-8";
      description = "Locale for messages and the user interface.";
    };

    formats = mkOption {
      type = types.str;
      example = "sv_SE.UTF-8";
      description = "Locale for dates, numbers, currency, paper size and units.";
    };

    keyboardLayout = mkOption {
      type = types.str;
      example = "se";
      description = ''
        XKB keyboard layout. Used by the text console, the login screen and
        both compositors.
      '';
    };
  };

  config = {
    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.language;
    i18n.extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (_: cfg.formats);

    services.xserver.xkb.layout = cfg.keyboardLayout;
    # The console (and so the text login screen) uses the same layout.
    console.useXkbConfig = true;
  };
}
