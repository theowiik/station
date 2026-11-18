# Shares on the Synology NAS (syno.local, on the home network), mounted at
# /mnt/syno/<share>.
#
# Each share connects the first time something opens its folder and
# disconnects after 10 idle minutes, so an offline NAS never holds up boot.
# Files show up as owned by the main user.
#
# The password is not in this repo. It lives in a root-only file on this
# machine, created once with:
#
#   sudo install -m 600 /dev/null /etc/nixos/syno-credentials
#   sudoedit /etc/nixos/syno-credentials
#
# containing the single line `password=<your Synology password>`.
{ config, lib, ... }:
let
  host = "syno.local";
  username = "theo"; # the Synology account
  credentials = "/etc/nixos/syno-credentials";

  # Add more shares here.
  shares = [
    "theo"
    "wiik"
    "media"
  ];

  user = config.my.user.name;
in
{
  fileSystems = lib.listToAttrs (
    map (
      share:
      lib.nameValuePair "/mnt/syno/${share}" {
        device = "//${host}/${share}";
        fsType = "cifs";
        options = [
          "username=${username}"
          "credentials=${credentials}"
          "uid=${user}"
          "gid=users"
          "vers=3"
          # Mount on first access, unmount when idle, never block boot.
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
          "x-systemd.mount-timeout=15s"
          "_netdev"
          "nofail"
        ];
      }
    ) shares
  );

  # One sidebar entry per share in Nautilus and the GTK file chooser. Home
  # Manager owns this bookmarks file, so bookmarks added in Nautilus itself
  # are not kept; add them here instead.
  home-manager.users.${user}.gtk.gtk3.bookmarks = map (
    share: "file:///mnt/syno/${share} syno ${share}"
  ) shares;
}
