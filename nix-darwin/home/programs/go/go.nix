{ config, pkgs, ... }:
let
  cache = "${config.home.homeDirectory}/Library/Caches/go-build";
  log = "${config.home.homeDirectory}/Library/Logs/go-cache-trim.log";
  unusedMinutes = 1440;
  trim = pkgs.writeShellApplication {
    name = "go-cache-trim";
    runtimeInputs = [ pkgs.findutils pkgs.coreutils ];
    text = ''
      removed=$(find "${cache}" -ignore_readdir_race -type f \( -name '*-a' -o -name '*-d' \) -mmin +${toString unusedMinutes} -print -delete | wc -l)
      echo "$(date -u +%FT%TZ) removed $removed entries unused for ${toString unusedMinutes} minutes from ${cache}"
    '';
  };
in
{
  launchd.agents.go-cache-trim = {
    enable = true;
    config = {
      ProgramArguments = [ "${trim}/bin/go-cache-trim" ];
      StartInterval = 3600;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = log;
      StandardErrorPath = log;
    };
  };
}
