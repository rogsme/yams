# v3 Branch Review

Reviewed `v3` (`b2213a8`) against canonical `master` (`12981bf`) and canonical website `origin/master` (`ac04f22`). Deployment and redirect behavior are out of scope per the requester.

**Verdict: do not merge yet.** Two serious runtime blockers and several incomplete documentation migrations remain.

## Scope Correction

This is not only "YAMS moved to `src`, website moved to `docs`." It also changes VPN routing defaults, replaces Portainer with Dozzle, adds WireGuard and profiles, changes network topology, introduces remote installation, and adds a self-updater. Treat it as a major product release.

## Critical

### 1. ~~Dozzle exposes unauthenticated container control~~ (***FIXED***)

`src/docker-compose.template.yaml:165-176` publishes Dozzle on every interface, enables shell access and container actions, mounts `docker.sock` read-write, and configures no authentication. Dozzle's documentation explicitly treats socket access as host-root equivalent. Anyone reaching port `8777` can execute commands in containers and control them.

### 2. ~~Fresh installs break on the first CLI lifecycle command~~ (***FIXED PREVIOUSLY***)

The installer starts only `docker-compose.yaml` at `src/install.sh:675-681`, creating the implicit `yams_default` network. The CLI always adds `docker-compose.custom.yaml` at `src/yams:5`, which requires an external `yams_network` at `src/docker-compose.custom.yaml:1-4`. Nothing creates it. Consequently, `yams start`, `restart`, and `update-containers` fail on fresh installs. Existing v2 hosts may hide this because they already have `yams_network`. Reproduced via Compose dry run.

## High

### 3. ~~Production installation remains controlled by `not-first/v3`~~ (***ignore for now***)

`src/install.sh:42,481` and `docs/content/docs/getting-started/installation.md:146` download executable code and Compose files from the collaborator's mutable feature branch. That is reasonable for preview testing, but must not survive the merge into official `master`.

### 4. The new `update-cli` command cannot work

`src/yams:266` uses a Gitea browser-page URL for root-level `yams`, while v3's file is `src/yams`; the configured request currently returns HTTP 403. Even after correcting the URL, `src/yams:296-297` attempts an unprivileged replacement of `/usr/local/bin/yams`, which the installer creates using `sudo` at `src/install.sh:619-623`.

### 5. ~~The documentation says rerunning the installer is safe, but it overwrites configuration~~ (***FIXED***)

`docs/content/docs/getting-started/installation.md:138-146` explicitly encourages reruns. `src/install.sh:468-486` unconditionally replaces `.env`, `docker-compose.yaml`, and `docker-compose.custom.yaml`. The overwrite behavior predates v3, but the new promise can cause users to erase credentials and custom services.

## Medium

### 6. ~~Core setup instructions disagree with the new stack~~ (***content-related, ignore for now***)

SABnzbd is exposed on host port `8090` at `src/docker-compose.template.yaml:49-51`, but the installation, SABnzbd, Radarr, and Sonarr guides all use `8080`. Portainer was replaced by Dozzle but remains advertised in `README.md:74` and `installation.md:586`. The Lidarr guide uses nonexistent `/music/` instead of its `/data` mount at `docs/content/docs/advanced/custom-containers/lidarr.md:27-31`.

### 7. ~~"Automatic port forwarding" is not implemented~~ (***FIXED***)

`src/docker-compose.template.yaml:42-43` enables Gluetun port allocation, but nothing updates qBittorrent's listening port. The current live website includes `VPN_PORT_FORWARDING_UP_COMMAND` and `DOWN_COMMAND`; v3 drops these while still promising automatic forwarding at `docs/content/docs/configure/qbittorrent.md:120-124`.

### 8. ~~Important replacement content remains unfinished~~ (***content-related, ignore for now***)

`docs/content/docs/advanced/vpn/prowlarr-vpn.md:6` consists only of `WRITE THIS TO USE THE GLUETUN HTTP PROXY`. The homepage remains Hugo starter text at `docs/content/_index.md:7-19`. A static audit also found 18 missing internal targets and three invalid heading fragments.

### 9. ~~Custom-container networking documentation describes a network v3 removed~~ (***content-related, ignore for now***)

`docs/content/docs/advanced/custom-containers/_index.md:318-333` instructs users to attach to `yams_network` with static `172.60.0.x` addresses. The main Compose template no longer defines that network or subnet, and the custom file exposes only the key `default`. The example will not work as written.

### 10. ~~Mullvad's default path is now invalid~~ (***FIXED***)

`src/install.sh:263-267` defaults every provider to OpenVPN. Mullvad removed OpenVPN on January 15, 2026, and v3 removed master's Mullvad-specific warning. Selecting Mullvad and accepting the default now guarantees VPN failure.

## Low

### ~~11. Imported assets include definite artifacts~~ (***FIXED***)

`docs/assets/pics/plex/plex-11.png` is a 20-byte text file containing `400: Invalid request`; the canonical website has the valid 33 KB PNG. `docs/.DS_Store` is also tracked despite being ignored, and three introductory logos reference `/icons/logos/...` while residing under `docs/assets/`.

### ~~12. Security follow-up: public screenshots show complete API keys~~ (*intended*)

Several Bazarr, Prowlarr, and Lidarr screenshots expose full API keys. These images already exist on the current website, so v3 did not originate the exposure, but the keys should be confirmed as fixtures or rotated.

## ~~Website Sync~~ (***content-related, ignore for now***)

The latest website commits are **not literally included**.

- Canonical website tip: `ac04f22216b967282ed37170d9cd26f01f7e21c7`
- Collaborator's website fork stops at: `e10d4707a07b11b98a7ddaaa7c6a6b7618f0c091`
- V3 imports an unrelated rewrite through subtree merge `b607c2b`, whose source is synthetic commit `9952a72`, not canonical `yams.media` history.
- The seven canonical commits after content snapshot `5bd2d74` are absent: `4026657`, `1966b06`, `ebb6c37`, `123e3dd`, `d2dcb28`, `e58ab81`, and `ac04f22`. They affect configuration, build/deployment, and `AGENTS.md`, not article content.

The latest article post-state is broadly represented: all configuration guides are present, the latest Qui/custom-container changes are included, and 219 of 246 canonical static assets match exactly. It is not content-complete, chiefly because port forwarding, Prowlarr VPN, advanced torrenting placement, and qBitManage were omitted or unfinished.

---

## Verification

- Compared canonical `master` `12981bf` against current remote `v3` `b2213a8`.
- Checked canonical website `origin/master` and the live `https://yams.media`.
- `bash -n src/install.sh src/yams` passes.
- Compose parsing passed, while the missing external-network failure was reproduced.
- No tracked files were changed (except this review) and no GitHub comments were posted.
- Deployment and redirect behavior were excluded as requested.
