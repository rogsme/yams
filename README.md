# YAMS v4 TODO
- [ ] Finalise installer script and templates
- [ ] Website
  - [ ] Website content
    - [ ] Main guide
      - [ ] Dozzle
      - [ ] qBittorrent
      - [ ] SABnzbd
      - [ ] Radarr
      - [ ] Sonarr
      - [ ] Lidarr
      - [ ] Prowlarr
      - [ ] Bazarr
      - [ ] Jellyfin
      - [ ] Emby
      - [ ] Plex
      - [ ] Update running everything together
      - [ ] Revamp recommendations
    - [ ] Write guide on moving install/media location
    - [ ] Change wording of remote access guide
    - [ ] Update portainer guide to account for the fact it is now an optional addon
    - [ ] Update Prowlarr guide to use http proxy
    - [ ] Write port forwarding page (how to enable/disable it, how to automatically change the forwarded port)
  - [ ] Website functionality
    - [ ] Film asciinema of setup process for use on landing + what is YAMS page
    - [ ] Create new landing page
    - [ ] Add dark theme
    - [ ] Finalise layout
      - [ ] Reposition links to be in a better spot
      - [ ] Fix colours and structure to be a true YAMS-like theme
    - [ ] Add Unami analytics
    - [ ] Finalise placeholder functionality
      - [ ] Allow use in markdown links to open in new tab (use these for service/dozzle links directly in docs)
      - [ ] Allow clicking to redirect to editing box
    - [ ] Add dynamic dozzle user generation command + any other interactive components
- [ ] Add proper website deploying
- [ ] Simplify/update main REPO readme
- [ ] Update CONTRIBUTING.md + CODE_OF_CONDUCT.md if needed
- [ ] Get community feedback!
- [ ] Consider/clean up old outdated PRs and issues on main repos




---
# YAMS: Yet Another Media Server

<img src="https://visitor-badge.laobi.icu/badge?page_id=rogs.yams" alt="visitor badge"/>

<img alt="Discord" src="https://img.shields.io/discord/1168025418243256391?logo=discord&label=Discord">

This is a highly opinionated media server script and guide that simplifies the setup and management of your home media collection, targeted towards beginners.

- Website: https://yams.media
- Discord: https://discord.gg/Gwae3tNMST
- Matrix: https://matrix.to/#/#yams-space:rogs.me

## Description

YAMS installs a docker compose file and has handwritten guides on constructing a complete media server stack using Docker containers:

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

- [Dozzle](https://dozzle.dev/) - Container log management UI
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

## Configuration

 To explore more or to install, view the complete main website:

https://yams.media/

## Testing

The installer test suite runs entirely in Docker. It uses Bats to exercise the interactive installation flow and validates the generated configuration with Docker Compose without starting the media stack.

```bash
tests/run
```

Docker is the only local prerequisite. The same command is used by CI.

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
