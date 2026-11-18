# Helium browser (https://helium.computer), a Chromium-based browser.
#
# Not in nixpkgs, so this wraps the official x86_64 AppImage from
# github.com/imputnet/helium-linux. The hash pins the exact file.
#
# To update: change version, then put the new sha256 of
# helium-<version>-x86_64.AppImage in hash (GitHub shows it on the release
# page, or build once and copy the hash from the error).
{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "helium";
  version = "0.21.3.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-qFQFlsk6RGMWBWAvO8Tu2lv/g+saOosC5NBKTIRz4p0=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The desktop file says Exec=helium and Icon=helium, which match the
  # wrapper name and the icon below.
  extraInstallCommands = ''
    install -Dm444 ${contents}/helium.desktop -t $out/share/applications
    install -Dm444 ${contents}/usr/share/icons/hicolor/256x256/apps/helium.png \
      -t $out/share/icons/hicolor/256x256/apps
  '';

  meta = {
    description = "Chromium-based web browser";
    homepage = "https://helium.computer";
    license = lib.licenses.gpl3Only;
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
