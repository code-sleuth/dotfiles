# Plex Setup Guide
Plex is a solid media server, and honestly the easiest one to get family and friends on. I personally prefer Jellyfin, but I have so many people on my Plex server, it's just easier to keep it running too. So let's dive into getting it set up the right way.

> [!NOTE]
> Just like with Jellyfin, it's recommended to run Plex with Docker inside a __virtual machine__ if you're on Proxmox. See more info [here](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_pct).

## Data Directory
### Folder Mapping
Same approach as the rest of the stack. All containers get the same `/data:/data` bind mount so everything looks like one filesystem inside the container. Makes hardlinks, atomic moves, and library scans way easier.

```
data
├── movies
├── music
└── shows
docker
└── plex
    ├── plex
    └── tautulli
```

For the full breakdown on directory structure and why this matters, check out the [main media README](https://github.com/TechHutTV/homelab/tree/main/media#data-directory).

### Network Share (VM)
If you're running Plex on a VM and your media lives on a NAS, you'll want to mount that share inside the VM. The setup is identical to the Jellyfin guide, so go ahead and follow [that section over here](https://github.com/TechHutTV/homelab/tree/main/media/jellyfin#network-share-vm).

## User Permissions
Bind mounts (`path/to/config:/config`) can cause permission headaches between the host and the container. The `PUID` and `PGID` variables in the compose file fix that. By default I'm using `1000:1000` which is the default user on most Linux systems.

Run this to confirm your user's IDs:
```bash
id your_user
```
You'll get back something like:
```
uid=1000(brandon),gid=1000(brandon),groups=1000(brandon),988(docker)
```

If you're using a network share mounted through `/etc/fstab`, match the permissions there. If you run into errors after creating folders, you can fix them with `chown`:
```bash
sudo chown -R 1000:1000 /data
sudo chown -R 1000:1000 /docker
```

## Installation
### Docker Setup (Recommended)
Docker is the easiest way to run Plex and it's what I recommend. Grab the `compose.yaml` from this folder, drop it into your docker directory, and you're pretty much good to go.

```yaml
services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    network_mode: host
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Los_Angeles
      - VERSION=docker
      - PLEX_CLAIM=
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - ./plex:/config
      - /data:/data
    restart: unless-stopped
```

> [!TIP]
> We're using `network_mode: host` because Plex relies on UDP broadcast for autodiscovery and DLNA. If you switch to bridge mode you lose that, and clients on your LAN won't auto-find the server. Do note that host mode means Plex binds every port it wants on the host (32400, 1900, 3005, 5353, 8324, 32410, 32412-32414, 32469), so don't run anything else on those ports.

### Plex Claim Token
On first run you'll want a claim token so the server gets linked to your Plex account automatically. Go ahead and grab one from [plex.tv/claim](https://plex.tv/claim) and drop it into the `PLEX_CLAIM` variable before you start the container.

> [!CAUTION]
> The claim token expires after 4 minutes. So generate it, paste it in, and start the container right away. After first run you can leave the variable blank.

Fire it up:
```bash
docker compose up -d
```

And just like that, head to `http://SERVER-IP:32400/web` and you should be in.

## Hardware Transcoding
This is the big gotcha with Plex. Hardware transcoding requires a [Plex Pass](https://www.plex.tv/plex-pass/) subscription. Without it, that `/dev/dri:/dev/dri` device passthrough does nothing and Plex will fall back to CPU transcoding. If you want hardware transcoding for free, that's a point for Jellyfin.

> [!CAUTION]
> I no longer recommend buying Plex Pass. As of July 1, 2026, the lifetime price jumped from **$249.99 to $749.99**. Monthly is still $6.99 and yearly is still $69.99, but at $750 for lifetime, the math just doesn't work for me anymore. If you want hardware transcoding without paying a subscription, go [run Jellyfin](https://github.com/TechHutTV/homelab/tree/main/media/jellyfin) instead. It does it for free and it's fully open source. I held a lifetime pass for years and thought it was a great value at $120, even at $250 it was defensible. At $750 I can't tell anyone with a straight face that it's worth it.

This section focuses on Intel QuickSync because in my experience it's the best option for the price. If you're on AMD you can pick up an Intel Arc GPU pretty cheap and pass that through. For everything else, check the official Plex [hardware transcoding docs](https://support.plex.tv/articles/115002178853-using-hardware-accelerated-streaming/).

### Proxmox Passthrough

#### Running on a VM (Recommended)
In the Proxmox UI, head to your VM and click **Hardware** in the sidebar. Then _Add > PCI Device_, select **Raw**, and pick the device for QuickSync. It's usually the first Intel device, something like "Alderlake" in the name.

#### Running on an Unprivileged LXC
If you're running Plex directly on an LXC, you need to manually pass the device through. Edit the container config and drop these in:
```bash
nano /etc/pve/lxc/100.conf
```
```
#Add these for Intel QuickSync
dev0: /dev/dri/card0,gid=44
dev1: /dev/dri/renderD128,gid=104
```
Change the container ID to match yours.

### Enabling in Plex
Once the device is passed through, head to _Settings > Transcoder_ in the Plex web UI. Check **Use hardware acceleration when available** and **Use hardware-accelerated video encoding**. Save, then play something that needs transcoding and confirm it's working.

You can verify the GPU is actually being used by installing `intel-gpu-tools` on your host and watching it work:
```bash
sudo apt install intel-gpu-tools
intel_gpu_top
```

## Tautulli
Tautulli is a must-have alongside Plex. It tracks watch history, gives you nice stats, and can send notifications when stuff is added or someone starts a stream. It's included in the `compose.yaml` and uses a healthcheck so Docker knows when it's actually ready.

Once your stack is up, head to `http://SERVER-IP:8181` and walk through the setup wizard. You'll need to point it at your Plex server and log in with your Plex account. Pretty simple.

## Remote Access
By default, Plex tries to set up remote access automatically using Plex Relay. It works but it's slow and capped at 2 Mbps, which means transcoding from your remote server to your phone over cellular is going to look rough.

For better remote access you've got a few options:

1. **Port forwarding.** Open port 32400 on your router and point it at your Plex server. Plex will detect this and use a direct connection. Fast and free, but you're exposing a port to the internet.
2. **VPN back home.** I personally use [NetBird](https://github.com/TechHutTV/homelab/tree/main/netbird) which gives me a private mesh network back to my homelab. No port forwarding, all encrypted. This is what I recommend.
3. **Reverse proxy.** If you want a clean URL like `plex.yourdomain.com`, throw it behind a reverse proxy. Check out the [proxy guide](https://github.com/TechHutTV/homelab/tree/main/proxy) for that.

## Plex Alternatives
With the new Plex Pass pricing, I'd seriously consider [Jellyfin](https://github.com/TechHutTV/homelab/tree/main/media/jellyfin) before committing to Plex. It's fully open source, hardware transcoding is free, and the feature gap has gotten really small over the last few years. The only real reason to stay on Plex at this point is if you have family members already using it and you don't want to migrate them, which honestly is my situation too.

I do hope this helps you get Plex up and running. If you run into anything weird, feel free to open an issue on the repo. Have a great one.
