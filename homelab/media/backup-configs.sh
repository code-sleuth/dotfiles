#!/usr/bin/env bash
# Back up the media stack's app-config Docker named volumes (the SQLite/Postgres
# databases) to the 980 drive. Excludes regenerable caches/metadata/artwork.
# Restore instructions: Homelab/Media/Volumes/<volume>.md in the Obsidian vault.
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DEST="/Volumes/980/data/backups/configs"
KEEP=7   # daily snapshots to retain

# Fail clearly if the drive isn't mounted
if [ ! -d "/Volumes/980/data" ]; then
  echo "ERROR: /Volumes/980 not mounted — aborting backup" >&2
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$DEST/$STAMP"
mkdir -p "$OUT"

backup_vol() {                       # backup_vol <volume> [exclude-glob ...]
  local vol="$1"; shift
  local -a exc=()
  for e in "$@"; do exc+=(--exclude="./$e"); done
  if docker volume inspect "$vol" >/dev/null 2>&1; then
    docker run --rm -v "$vol":/src:ro -v "$OUT":/dst alpine \
      tar czf "/dst/$vol.tgz" -C /src "${exc[@]}" . && echo "  ok  $vol"
  else
    echo "  skip $vol (no such volume)"
  fi
}

echo "Backing up config volumes -> $OUT"
# *arr apps: exclude artwork (MediaCover) + log DBs (regenerable)
backup_vol sonarr-config      MediaCover logs "logs.db*"
backup_vol radarr-config      MediaCover logs "logs.db*"
backup_vol lidarr-config      MediaCover logs "logs.db*"
backup_vol prowlarr-config    logs "logs.db*"
backup_vol bazarr-config
backup_vol qbittorrent-config
backup_vol nzbget-config
backup_vol seerr-config       cache logs
backup_vol tautulli-config    logs cache
# Plex: keep DB + Preferences + Metadata; drop the 2GB regenerable Cache
backup_vol plex-config        "Library/Application Support/Plex Media Server/Cache"
# Jellyfin: keep config + data/*.db; drop regenerable metadata/cache/transcodes/logs
backup_vol jellyfin-config    data/metadata cache transcodes log
backup_vol jellystat-backup

# Jellystat DB is Postgres — use a consistent logical dump, not a volume tar
if docker ps --format '{{.Names}}' | grep -q '^jellystat-db$'; then
  docker exec jellystat-db pg_dump -U postgres -d jfstat -Fc -f /tmp/jfstat.dump
  docker cp jellystat-db:/tmp/jfstat.dump "$OUT/jellystat-db.dump" >/dev/null
  docker exec jellystat-db rm -f /tmp/jfstat.dump
  echo "  ok  jellystat-db (pg_dump)"
fi

# Rotation: keep the newest $KEEP snapshot dirs
ls -1dt "$DEST"/*/ 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r d; do rm -rf "$d"; done

echo "Done. $(du -sh "$OUT" | awk '{print $1}') in $OUT"
