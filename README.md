# YAMS: Yet Another Media Server

<img src="https://visitor-badge.laobi.icu/badge?page_id=rogs.yams" alt="visitor badge"/>

<img alt="Discord" src="https://img.shields.io/discord/1168025418243256391?logo=discord&label=Discord">

This is a highly opinionated media server that simplifies the setup and management of your home media collection.

- Website: https://yams.media
- Code documentation: https://gitlab.com/rogs/yams/-/blob/master/docs.org
- Discord: https://discord.gg/Gwae3tNMST
- Matrix: https://matrix.to/#/#yams-space:rogs.me

## Description

YAMS installs and configures a complete media server stack using Docker containers:

### Download Management

- [qBittorrent](https://www.qbittorrent.org/) - Torrent client
- [SABnzbd](https://sabnzbd.org/) - Usenet downloader
- [Gluetun](https://github.com/qdm12/gluetun) - VPN client for secure downloads

### Media Management

- [Sonarr](https://sonarr.tv/) - TV show management and automation
- [Radarr](https://radarr.video/) - Movie management and automation
- [Lidarr](https://lidarr.audio) - Music management and automation
- [Bazarr](https://www.bazarr.media/) - Automatic subtitle management
- [Prowlarr](https://prowlarr.com/) - Indexer management for your *arr apps

### Media Servers (Choose One)

- [Jellyfin](https://jellyfin.org/) (**Recommended**) - Open source media server
- [Emby](https://emby.media/) - Media server with premium features
- [Plex](https://www.plex.tv/) - Popular media server with advanced features

### Management & Monitoring

- [Portainer](https://www.portainer.io/) - Container management UI
- [Watchtower](https://containrrr.dev/watchtower/) - Automatic container updates

## Features

YAMS provides a comprehensive media server solution with:

### Smart Media Management

Automatically organizes your media library:

- Downloads new episodes and movies as they become available
- Categorizes content into appropriate folders
- Manages music and book collections
- Fetches subtitles in your preferred languages

### Flexible Media Access

Access your content anywhere:

- Web interface for browser-based streaming
- Apps for mobile devices (iOS/Android)
- Smart TV apps
- Roku, Apple TV, and other streaming devices
- Transcoding for optimal playback on any device

### Security and Privacy

- Built-in VPN support for secure downloads
- User management and sharing controls
- SSL/TLS encryption support

### Easy Management

- Simple CLI interface with `yams` command
- Web-based management through Portainer
- Automatic container updates via Watchtower
- Backup and restore functionality

## Dependencies

### Required

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

The installation script can automatically install these on Debian/Ubuntu systems.

## Before Installation

Prepare the following:

### 1. Installation Location

- Default: `~/opt/yams`
- Ensure your user has write permissions

### 2. Media Directory

- Default: `~/srv/media`
- Will contain subdirectories:
  - `~/srv/media/tvshows` — TV series
  - `~/srv/media/movies` — Movies
  - `~/srv/media/music` — Music files
  - `~/srv/media/books` — Books and audiobooks
  - `~/srv/media/downloads` — Temporary download location
  - `~/srv/media/blackhole` — Watch folder for torrents

### 3. Non-root User

- Regular system user to own and manage files
- Must have sudo privileges for initial setup

### 4. VPN Service (Optional but Recommended)

- Supported providers listed at https://yams.media/advanced/vpn#official-supported-vpns
- [ProtonVPN](https://protonvpn.com/) recommended for:
  - Simple configuration
  - Port forwarding

## Installation

Quick installation:

```bash
git clone --depth=1 https://gitlab.com/rogs/yams.git /tmp/yams
cd /tmp/yams
bash install.sh
```

Follow the interactive prompts to configure your installation.

### Tested On

- Debian 11/12
- Ubuntu 22.04

## Usage

YAMS provides a simple CLI interface:

```text
yams - Yet Another Media Server

Usage: yams [command] [options]

Commands:
--help                    displays this help message
restart                   restarts yams services
stop                      stops all yams services
start                     starts yams services
status                    checks yams services status
destroy                   destroy yams services so you can start from scratch
check-vpn                 checks if the VPN is working as expected
backup                    backs up yams to the destination location
update-containers         updates all yams containers

Examples:
  yams start                   # Start all YAMS services
  yams backup /path/to/backup  # Backup YAMS to specified directory
  yams update-containers       # Update all containers
```

## Configuration

Complete configuration guide:

https://yams.media/config/

## Future Development

Planned features and improvements:

- [x] Multiple media server support (Jellyfin/Emby/Plex)
- [x] Portainer integration
- [x] Update functionality
- [x] Lidarr and Readarr integration
- [x] Enhanced Usenet support
- [ ] Alpine-based images for reduced footprint
- [x] Additional download clients
- [x] Jackett integration (https://yams.media/advanced/add-your-own-containers/)
- [x] Request management (Jellyseerr/Overseerr) (https://yams.media/advanced/add-your-own-containers/)
- [x] Dashboard integration (Organizr/Heimdall) (https://yams.media/advanced/add-your-own-containers/)
- [ ] Enhanced themes and customization
- [x] WireGuard VPN support (https://yams.media/advanced/wireguard/)
- [x] Filebrowser integration (https://yams.media/advanced/add-your-own-containers/)
- [x] Jellyfin account management (https://yams.media/advanced/add-your-own-containers/)

## Donations

If you'd like to support YAMS, please consider donating to the underlying projects:

- [linuxserver.io](https://www.linuxserver.io/donate)
- [Sonarr](https://sonarr.tv/donate)
- [Radarr](https://radarr.video/donate)
- [Jellyfin](https://opencollective.com/jellyfin)
- [qBittorrent](https://www.qbittorrent.org/donate)
- [SABnzbd](https://sabnzbd.org/donate/)
- [Prowlarr](https://opencollective.com/Prowlarr#sponsor)
- [Bazarr](https://www.paypal.com/donate/?cmd=_s-xclick&hosted_button_id=XHHRWXT9YB7WE&source=url)
- [Gluetun](https://www.paypal.me/qmcgaw)

### YAMS Donations: The Very Last Priority 🏆

Okay, so you REALLY want to support YAMS? First, thank you! But honestly, I'm not doing this for money. YAMS is a passion project I created for myself and my friends. If you've already supported the projects above and still want to chip in, here are some options:

#### Donation Methods 💸

- BuyMeACoffee: https://buymeacoffee.com/rogs
- Paypal: https://paypal.me/rogsme21
- BTC: [bc1qn092rw6q5nwha093qau6xryk6u3g9uwvy4tgdu](https://yams.media/pics/btc.webp)
- XMR: [8B2QC3RPEqEhbUKKL96CGzZBqoDq8kjzd5uUVCTHvyG8fACh5up3Svz4iNKiGEoZTqUXt4cJHqC4EeaTmrbVVHXfRrrRcBq](https://yams.media/pics/xmr.webp)

## Special Thanks

YAMS wouldn't be possible without:

- [linuxserver.io](https://info.linuxserver.io/) for amazing Docker images
- All the core applications listed above
- Contributors (in no particular order!):
  - [xploshioOn](https://github.com/xploshioOn)
  - [norlis](https://github.com/norlis)
  - [isaac152](https://github.com/isaac152)
  - [Jay Taggart](https://gitlab.com/jataggart)
  - [Mason Stooksbury](https://gitlab.com/MasonStooksbury)
  - [gloof](https://gitlab.com/gloof11)
  - [Metin Bektas](https://github.com/methbkts)
  - [Austin](https://gitlab.com/austin.eschweiler)
  - [Loriage](https://gitlab.com/Loriage) (Thank you for the French translation! 🇫🇷)
  - [MoMoiin](https://github.com/MoMoiin)
  - [ak4zh](https://github.com/ak4zh)
  - [zavan](https://gitlab.com/zavan) (Thank you for the macOS port! https://gitlab.com/zavan/yams)
  - [not-first](https://github.com/not-first)
- The YAMS community for testing and feedback
- https://patorjk.com/software/taag/ for the ASCII art!

And most importantly: **Thank you for using YAMS!** 🙏

### Contributors

<a href="https://github.com/rogsme/yams/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=rogsme/yams" />
</a>

<a href="https://github.com/rogsme/yams.media/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=rogsme/yams.media" />
</a>

Made with [contrib.rocks](https://contrib.rocks).