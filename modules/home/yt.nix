# `yt`: a small yt-dlp wrapper.
#   yt audio <link>   best audio as MP3 into the current directory
#   yt video <link>   best video (MP4) into the current directory
# Extra arguments go to yt-dlp, e.g. `yt video <link> -f 'bv[height<=1080]+ba'`.
{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  yt = pkgs.writeShellApplication {
    name = "yt";
    runtimeInputs = with pkgs; [
      yt-dlp
      ffmpeg
      deno # JavaScript runtime yt-dlp needs for YouTube's player challenges
    ];
    text = ''
      usage() {
        echo "usage: yt audio|video <link> [yt-dlp options...]" >&2
        exit 1
      }
      [ $# -ge 2 ] || usage
      mode=$1
      shift

      case "$mode" in
        audio)
          exec yt-dlp -x --audio-format mp3 --audio-quality 0 \
            --embed-thumbnail --embed-metadata \
            -o '%(title)s.%(ext)s' "$@"
          ;;
        video)
          exec yt-dlp -f 'bv*+ba/b' --merge-output-format mp4 \
            --embed-metadata --embed-subs \
            -o '%(title)s.%(ext)s' "$@"
          ;;
        *) usage ;;
      esac
    '';
  };
in
lib.mkIf osConfig.my.shell.enable {
  home.packages = [ yt ];
}
