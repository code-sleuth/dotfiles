#!/bin/bash
set -euo pipefail

FEATURES="nix-command flakes"
NIX_PROFILE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

if [ "$(uname -s)" != "Darwin" ]; then
  echo "error: macOS only" >&2
  exit 1
fi

if [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  echo "nix already installed, skipping install"
else
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

if [ -f "$NIX_PROFILE" ]; then
  set +u
  # shellcheck disable=SC1090
  . "$NIX_PROFILE"
  set -u
fi

effective_features() {
  nix config show experimental-features 2>/dev/null || nix show-config experimental-features 2>/dev/null || true
}

features_ok() {
  local current f
  current=" $(effective_features) "
  for f in $FEATURES; do
    case "$current" in
      *" $f "*) ;;
      *) return 1 ;;
    esac
  done
}

if features_ok; then
  echo "experimental features already enabled: $(effective_features)"
else
  # Determinate Nix owns /etc/nix/nix.conf; user settings belong in nix.custom.conf
  conf=/etc/nix/nix.conf
  [ -x /usr/local/bin/determinate-nixd ] && conf=/etc/nix/nix.custom.conf
  echo "enabling '$FEATURES' in $conf"
  sudo mkdir -p /etc/nix
  sudo touch "$conf"
  if grep -q '^experimental-features' "$conf"; then
    sudo sed -i '' "s/^experimental-features.*/experimental-features = $FEATURES/" "$conf"
  else
    printf 'experimental-features = %s\n' "$FEATURES" | sudo tee -a "$conf" >/dev/null
  fi
  sudo launchctl kickstart -k system/systems.determinate.nix-daemon 2>/dev/null \
    || sudo launchctl kickstart -k system/org.nixos.nix-daemon 2>/dev/null \
    || true
  sleep 2
  if features_ok; then
    echo "experimental features enabled: $(effective_features)"
  else
    echo "error: features still not active; check $conf and restart the nix daemon" >&2
    exit 1
  fi
fi

echo
echo "done. open a new terminal, then:"
echo "  cd $(cd "$(dirname "$0")" && pwd) && just switch \$(hostname -s)"
