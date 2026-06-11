# Immich - Self-Hosted Photo and Video Backup

Immich is a self-hosted alternative to Google Photos with a real focus on privacy. It keeps your photos and videos on your own hardware with full support for RAW files, facial recognition, and automatic organization. The mobile app for both [Android](https://play.google.com/store/apps/details?id=app.immich) and [iOS](https://apps.apple.com/app/immich/id1613945652) handles auto-backup out of the box, which is honestly the killer feature.

> [!NOTE]
> Most of the steps below are based on their [official docs](https://docs.immich.app/install/docker-compose). I'd give those a read too, especially as things change between versions.

## Prerequisites
1. A server running Docker. Check out our [docker guide](https://techhut.tv/7-docker-basics-for-beginners/) if you're new to it.
2. At least 6GB of RAM and a 4-core CPU is recommended ([learn more](https://immich.app/docs/install/requirements)).
3. Enough storage for your media. This really depends on your collection. I'd plan for at least double what you currently have to leave room for growth.

## Setup

### Prepare Your Environment
Create a directory for Immich. If your root filesystem is small you'll probably want to point `library` at a network drive or external storage. Check out [this guide on auto-mounting drives](https://techhut.tv/auto-mount-drives-in-linux-fstab/) in Linux.

```bash
mkdir -p ~/docker/immich
cd ~/docker/immich
```

Now go ahead and grab the `compose.yaml` and `.env` files from this repo.

```bash
wget https://github.com/TechHutTV/homelab/raw/refs/heads/main/cloud/immich/compose.yaml && wget https://github.com/TechHutTV/homelab/raw/refs/heads/main/cloud/immich/.env
```

### Configure the .env File
```bash
nano .env
```

**You have to change these:**
- `DB_PASSWORD` — Set this to a random strong password. Stick to `A-Za-z0-9` so Docker doesn't choke on special characters. The default is intentionally broken so the stack won't start until you change it.
- `TZ` — Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List).
- `UPLOAD_LOCATION` — Where your photos and videos will live. Network shares are fine here.
- `DB_DATA_LOCATION` — Where the Postgres database lives. Do **not** put this on a network share, Immich will not be happy.

### Deploy the Stack
```bash
docker compose up -d
```

Give it a few minutes to pull images and initialize. If something fails to start, check the logs:
```bash
docker logs immich_server
```

### Access Immich
1. Open `http://your-server-ip:2283` in your browser.
2. Create your admin account. The first user to register becomes admin, so do this before sharing the URL with anyone.
3. Configure the basics:
   - **Storage Template** — Make your library [human readable](https://immich.app/docs/install/post-install) so backups outside Immich are useful.
   - **Machine Learning** — Turn on facial recognition and smart search if you want it.

And there we go, you should have Immich running.

## Mobile App Setup
This is where Immich really shines. Auto-backup from your phone is the whole reason most people self-host this.

1. Install Immich from the [App Store](https://apps.apple.com/app/immich/id1613945652) or [Play Store](https://play.google.com/store/apps/details?id=app.immich).
2. Connect to your server:
   - Server URL: `http://your-server-ip:2283`
   - Log in with the admin account you just created (or a regular user account if you set one up).
3. Head into settings and turn on auto-backup. Pick your photo and video albums, set the backup behavior (foreground, background, on Wi-Fi only, and whatnot), and you're good to go.

## Remote Access
Hosting Immich at home is great, but you'll probably want to reach it from outside your network for backups while traveling.

- **[NetBird](https://netbird.io/) (Recommended)** — A zero-trust mesh network built on WireGuard. No port forwarding, no exposing services to the open internet. Follow our [NetBird setup guide](https://techhut.tv/self-host-netbird-pocketid) to get going.
- **Reverse Proxy** — If you want a clean URL like `photos.yourdomain.com`, set up NGINX Proxy Manager ([video guide](https://www.youtube.com/watch?v=79e6KBYcVmQ)). Forward your hostname to `http://immich-server:2283` and you're set.

## Optional Configuration

### Hardware Transcoding
For Intel QuickSync, uncomment the `devices` section in the `immich-server` service in `compose.yaml`. This speeds up video transcoding significantly. [Learn more](https://immich.app/docs/features/hardware-transcoding/#single-compose-file).

```yaml
devices:
  - /dev/dri:/dev/dri
```

### Hardware-Accelerated Machine Learning
The `compose.yaml` has commented blocks for Intel OpenVINO and Google Coral. Pick the one matching your accelerator, uncomment, and recompose. For NVIDIA, AMD, ARM NN, or RKNN check the [full hardware ML docs](https://immich.app/docs/features/ml-hardware-acceleration).

If you don't have any hardware acceleration, that's fine. ML runs on CPU by default and works well enough for most homelab libraries.

### External Libraries
External libraries let Immich index existing photo directories without copying them into its managed storage. Super useful if you already have a sorted library on disk and don't want to import everything.

To use them, mount the directory into the `immich-server` container so it can read it:
```yaml
immich-server:
  volumes:
    - ${UPLOAD_LOCATION}:/data
    - /mnt/photos:/mnt/photos:ro  # read-only is safer for existing libraries
    - /etc/localtime:/etc/localtime:ro
```

Then in the Immich web UI go to _Administration > Libraries_, create a new External Library for the admin user, and add `/mnt/photos` as the import path. Do note that the path is the path **inside the container**, not your host. [Learn more](https://immich.app/docs/features/libraries/).

### Disable Machine Learning
If you don't want facial recognition or smart search, you can drop the whole `immich-machine-learning` service from `compose.yaml`. This saves a few GB of RAM, which is nice on a smaller server.

### Bulk Uploading with the CLI
If you've got a giant existing library you want to import (rather than mount as external), the [Immich CLI](https://immich.app/docs/features/command-line-interface) is the way to go. It's way faster than dragging files into the web UI and handles huge batches without timing out.

Install it on your desktop or any machine that can reach the server:
```bash
npm install -g @immich/cli
```

Then log in and upload:
```bash
immich login http://your-server-ip:2283 your-api-key
immich upload --recursive /path/to/your/photos
```

You can grab an API key from _Account Settings > API Keys_ in the web UI.

## Storage Templates
Storage templates automatically sort photos into folders based on metadata like date or camera model. This is what makes your library actually browsable outside Immich, which matters a lot if you're ever doing manual backups or migrating.

A solid default:
```
{{y}}/{{MMMM}}-{{DD}}/{{filename}}
```
Generates: `2024/July-15/IMG_1234.jpg`

Go to _Settings > Storage Template_ in the web UI to set this up. You can also re-run it on existing libraries, which is great if you change your mind on the structure later.

## Backup Strategy
- Back up your `DB_DATA_LOCATION` directory regularly. Without the database, your photos lose all metadata, faces, and albums.
- Keep a copy of your `UPLOAD_LOCATION` somewhere offsite. I use [restic](https://restic.net/) to a Backblaze B2 bucket, but rsync to another machine works fine for smaller libraries.
- The whole thing is just files on disk and a Postgres dump, so you don't need any Immich-specific backup tool.

## Troubleshooting

**Port Conflicts** — Make sure port 2283 is free, or remap with `IMMICH_PORT` in your `.env` (e.g. `IMMICH_PORT=8283`).

**Permission Errors** — Check ownership on your `UPLOAD_LOCATION` and `DB_DATA_LOCATION` directories with `ls -l`. The Immich containers run as their own user inside.

**ML Container Failing** — Usually a RAM issue. Either give the host more memory or temporarily disable ML by removing the `immich-machine-learning` service.

**Reset Admin Password:**
```bash
docker exec immich_server npm run reset-admin-password
```

## Maintenance

### Updating
To pull the latest images and recreate the containers:
```bash
docker compose pull && docker compose up -d
```

The `.env` ships with `IMMICH_VERSION=v2`, which pins to the v2 major version. You'll auto-get minor and patch updates but stay on v2 forever until you bump it manually. This is intentional. Immich does ship breaking schema changes in major releases, so do go check the [release notes](https://github.com/immich-app/immich/releases) before jumping to v3 (or whatever's next).

If you want to pin to an exact version for stability, change `IMMICH_VERSION` to something like `v2.1.0`.

### Housekeeping
- Watch your `UPLOAD_LOCATION` for storage growth. The mobile app will quietly fill it up.
- Set retention policies in _Administration > Settings > Trash_ if you want auto-cleanup.
- Run _Administration > Jobs > External Library Scan_ periodically if you're using external libraries that change.

With all that, you should have a pretty solid Immich setup. I do hope this helps, have a great one.
