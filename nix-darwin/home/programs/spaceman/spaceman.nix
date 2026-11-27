{ config, pkgs, ... }:
let
  spaceman = "/Applications/Spaceman.app/Contents/MacOS/spaceman";
  profiles = "${config.home.homeDirectory}/dotfiles/spaceman";
  active = "${config.xdg.stateHome}/spaceman/config.toml";
  movedProfile = "${config.xdg.stateHome}/spaceman/moved-profile";
  ultrawideDisplay = "LC49G95T";
  log = "${config.home.homeDirectory}/Library/Logs/spaceman-profile.log";
  selectProfile = pkgs.writeShellApplication {
    name = "spaceman-profile";
    runtimeInputs = [ pkgs.jq pkgs.coreutils ];
    text = ''
      if [[ ! -x "${spaceman}" ]]; then
        exit 0
      fi

      displays=$("${spaceman}" displays)
      profile=laptop
      if jq -e --arg name "${ultrawideDisplay}" 'any(.[]; .name == $name)' <<<"$displays" >/dev/null; then
        profile=ultrawide
      fi

      target="${profiles}/$profile.toml"
      current=$(readlink "${active}" || true)
      if [[ "$current" != "$target" ]]; then
        mkdir -p "$(dirname "${active}")"
        ln -sfn "$target" "${active}.next"
        mv -fT "${active}.next" "${active}"
        touch "$target"
        echo "$(date -u +%FT%TZ) using the $profile profile"
      fi

      moved=$(cat "${movedProfile}" 2>/dev/null || true)
      if [[ "$moved" == "$profile" ]]; then
        exit 0
      fi

      status=$("${spaceman}" ctl status 2>/dev/null || true)
      if ! jq -e '.mode == "automatic"' <<<"$status" >/dev/null 2>&1; then
        exit 0
      fi

      SPACEMAN_CONFIG="$target" "${spaceman}" rules list --json \
        | jq -r '.rules[] | select(.action == "route" and .title == null and .title_contains == null) | "\(.bundle_id) \(.workspace)"' \
        | while read -r bundle workspace; do
            if [[ -z "$(lsappinfo find bundleid="$bundle")" ]]; then
              echo "$(date -u +%FT%TZ) skipped $bundle, it is not running"
              continue
            fi
            "${spaceman}" ctl move-app "$bundle" "$workspace" >/dev/null
            echo "$(date -u +%FT%TZ) moved $bundle to workspace $workspace"
          done
      echo "$profile" >"${movedProfile}"
    '';
  };
in
{
  home.file."Library/Application Support/Spaceman/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink active;

  launchd.agents.spaceman-profile = {
    enable = true;
    config = {
      ProgramArguments = [ "${selectProfile}/bin/spaceman-profile" ];
      StartInterval = 10;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = log;
      StandardErrorPath = log;
    };
  };
}
