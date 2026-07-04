---
weight: 1
title: Adding Custom Containers
bookCollapseSection: true
---

WRITE ABOUT HOW TO ADD OTHER CONTAINERS< HOW TO ADAPT AN EXAMPLE COMPOSE

# Make YAMS Your Own! 🚀

Want to add more containers to your YAMS setup? Maybe a cool new app you found, or something specific for your needs? No problem! YAMS makes it super easy to expand your media server with custom containers.

## The Basics 📚

When you install YAMS, it creates two important files:
- `docker-compose.yaml`: This is YAMS's brain! Don't modify this file directly.
- `docker-compose.custom.yaml`: This is your playground! Add all your custom containers here.

## Getting Started 🎯

First, let's find your YAMS installation. I'll use `/opt/yams` in these examples, but replace it with your actual install location:

```bash
cd /opt/yams
```

## The Magic Variables ✨

YAMS provides some handy environment variables you can use in your custom containers. These are defined in your central [`.env` settings file](link broken) (learn more about it!) and make it super easy to keep your custom containers working in harmony with YAMS:

```yaml
PUID: Your user ID
PGID: Your group ID
MEDIA_DIRECTORY: Your media folder location
INSTALL_DIRECTORY: Your YAMS installation location
```

These make it super easy to keep your custom containers working in harmony with YAMS!

## Let's Add a Container! 🎮

Let's walk through an example by adding [Seerr](https://seerr.dev/) - a fantastic request management app for your media server.

1. First, open `docker-compose.custom.yaml`:
```bash
nano docker-compose.custom.yaml
```

2. If this is your first custom container, you'll need to uncomment the `services:` line. To uncomment you must remove the `#` symbol and the space. Your file should start like this:

```yaml
services:  # Make sure this line is uncommented and there's no spaces around it!
```

3. Now let's add Seerr with all the YAMS goodies:

```yaml
  seerr:
    image: ghcr.io/seerr-team/seerr:latest
    container_name: seerr
    user: ${PUID}:${PGID}
    init: true
    environment:
      - TZ=${TZ}
    ports:
      - 5055:5055
    volumes:
      - ${INSTALL_DIRECTORY}/config/seerr:/app/config
    healthcheck:
      test: wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1
      start_period: 20s
      timeout: 3s
      interval: 15s
      retries: 3
    restart: unless-stopped
```
4. Before we start the container, let's create the config folder for Seerr to avoid any permission issues. Ensure you are in a shell session, logged in as the same user that runs YAMS.

Then, navigate to your YAMS installation directory and create the config folder for Seerr at the path `${INSTALL_DIRECTORY}/config/seerr`.

This command below is an example and will *not work!* You must manually replace the `<INSTALL_DIRECTORY>` placeholder with your actual YAMS installation path (e.g., `/opt/yams`):
```bash
mkdir -p <INSTALL_DIRECTORY>/config/seerr
```

5. Now, it's time to start your new container:
```bash
yams start seerr
```

You should see something like:
```bash
 ⠙ seerr Pulling                                                                     5.2s
[...]
```

That's it! Your new container is up and running! 🎉

### Other Containers

Not a fan of Seerr? No worries! Lets take a look at how to add many popular apps into the YAMS system.

Each of these docker compose entries can be added right into your `docker-compose.custom.yaml` file, under the `services` parent item.

> *TIP: Adding a TZ environment varible to your `.env` file can help make adding new services and avoid timezone related issues!*

Remember, since all services are run in the same Docker network, references to other services from within an app can be completed using their name and port. For example, need to enter your Radarr URL? Use `http://radarr:7878`! No pesky IPs needed.

### Qui

[Qui](https://getqui.com/) is an alternate web interface for qBitTorrent, and provides a simple way to facilitate cross seeding across trackers, and automating torrent workflows.

Keep in mind the torrent automations have the ability to delete downloads and manipulate torrents. Always be careful when configuring this feature, and test dangerous actions with harmless 'tagging' actions first to observer output whilst avoiding unwanted deletions.

```yaml
  qui:
    image: ghcr.io/autobrr/qui:latest
    container_name: qui
    restart: unless-stopped
    ports:
      - "7476:7476"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${INSTALL_DIRECTORY}/config/qui:/config
      # optional, but required for filesystem-enabled features like hardlink detection
      - ${MEDIA_DIRECTORY}/downloads/torrents:/data/downloads/torrents
```

*If you want to jump straight into a guided setup, check out *[Seeding with Qui](/docs/advanced/community-guides/seeding-with-qui)* for a setup where all torrents are seeded whilst the media remains in your server, and then smoothly removed after the item is watched in your streaming application.*


### Shelfmark 📚

[Shelfmark](https://github.com/calibrain/shelfmark) is a simple app for download books and audiobooks from various sources.

```yaml
  shelfmark:
    image: ghcr.io/calibrain/shelfmark:latest
    container_name: shelfmark
    ports:
      - 8084:8084
    environment:
      TZ: ${TZ}
      PUID: ${PUID}
      PGID: ${PGID}
    restart: unless-stopped
    volumes:
      - ${MEDIA_DIRECTORY}/books:/books
      - ${INSTALL_DIRECTORY}/config/shelfmark:/config
      - ${MEDIA_DIRECTORY}/downloads/torrents:/data/downloads/torrents
```

### Profilarr 📖
[Profilarr](https://dictionarry.dev/) is similar to Recyclarr, but syncs naming conventions, quality profiles and custom formats from the [Dictionarry database](https://github.com/Dictionarry-Hub/database) instead.

It is more intuitive to use as it is configured through a handy Web UI!

```yaml
  profilarr:
    image: ghcr.io/dictionarry-hub/profilarr:latest
    container_name: profilarr
    restart: unless-stopped
    ports:
      - "6868:6868"
    volumes:
      - ${INSTALL_DIRECTORY}/config/profilarr:/config
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - UMASK=022
      - TZ=${TZ}
```

### Autobrrr 🐇

[Autobrr](https://autobrr.com/introduction) is an app that allows you connect to an Indexer's IRC channel, immediately starting torrent downloads for newer movies/shows without relying on Radarr/Sonarr's slower RSS feed. This allows you to help build ratio on private trackers by beating everyone else to the torrent, so you can seed it to everyone else!

```yaml
  autobrr:
    container_name: autobrr
    image: ghcr.io/autobrr/autobrr:latest
    restart: unless-stopped
    ports:
      - 7474:7474
    environment:
      - TZ=${TZ}
      - PUID=${PUID}
      - PGID=${PGID}
    volumes:
      - ${INSTALL_DIRECTORY}/config/autobrr:/config
```

Done! To fully connect Autobrr to your media server's downloads, continue with the full guide [here](/docs/advanced/adding-your-own-containers/autobrr).

### Recyclarr 🗑️

[Recyclarr](https://recyclarr.dev/) is an app to sync Trash Guide's recommended naming conventions, quality profiles and formats straight to your media stack!

```yaml
  recyclarr:
    image: ghcr.io/recyclarr/recyclarr
    container_name: recyclarr
    restart: unless-stopped
    volumes:
      - ${INSTALL_DIRECTORY}/config/recyclarr:/config
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
```
Now, run the command `docker exec -it recyclarr recyclarr config create` to create a starter `recyclarr.yml` configuration file. (Remember this format of executing commands - it's how you manually control Recyclarr!).

Great! Now, check out Recyclarr's docs to customise this configuration file to your needs. Check out the [reference](https://recyclarr.dev/wiki/yaml/config-reference/) and [example files](https://recyclarr.dev/wiki/yaml/config-examples/). If you have a simple setup, one of the [templates](https://recyclarr.dev/wiki/guide-configs/) might be good enough for you!


### Unpackerr 📦

[Unpackerr](https://unpackerr.zip/) is an app that automatically extracts any downloads that are an archive, ensuring Radarr and Sonarr don't get stuck waiting for manual intervention.

```yaml
  unpackerr:
    image: golift/unpackerr
    container_name: unpackerr
    volumes:
      - ${MEDIA_DIRECTORY}:/data
    restart: unless-stopped
    environment:
      - TZ=${TZ}
      - UN_LOG_FILE=/downloads/unpackerr.log
      - UN_SONARR_0_URL=http://sonarr:8989
      - UN_SONARR_0_API_KEY=${SONARR_API_KEY}
      - UN_RADARR_0_URL=http://radarr:7878
      - UN_RADARR_0_API_KEY=${RADARR_API_KEY}
```

Make sure to add the `SONARR_API_KEY` and `RADARR_API_KEY` environment variables to your YAMS `.env` file so the service can connect correctly. That's it!

### qBitManage 🛠️

[qBitManage](https://github.com/StuffAnThings/qbit_manage) is an extremely handy tool for creating all kinds of workflows relating to torrents within qBitTorrent.

The power of this app is a double edged sword. It can help you to amazingly automate your media server just how you like, but keep in mind that, if misconfigured, it has the ability to delete downloads and manipulate torrents. Expect to invest some time into learning its decently complicated configuration before reaching your desired state.

```yaml
  qbitmanage:
    container_name: qbitmanage
    image: ghcr.io/stuffanthings/qbit_manage
    volumes:
      - ${MEDIA_DIRECTORY}:/data
      - ${INSTALL_DIRECTORY}/config/qbitmanage:/config
    ports:
      - "8080:8080"  # Web API port (when enabled)
    environment:
      # Web API Configuration
      - QBT_WEB_SERVER=true     # Set to true to enable web API and web UI
      - QBT_PORT=8080           # Web API port (default: 8080)

      # Scheduler Configuration
      - QBT_RUN=false
      - QBT_SCHEDULE=1440
      - QBT_CONFIG_DIR=/config
      - QBT_LOGFILE=qbit_manage.log

      # Command Flags
      - QBT_RECHECK=false
      - QBT_CAT_UPDATE=false
      - QBT_TAG_UPDATE=false
      - QBT_REM_UNREGISTERED=false
      - QBT_REM_ORPHANED=false
      - QBT_TAG_TRACKER_ERROR=false
      - QBT_TAG_NOHARDLINKS=false
      - QBT_SHARE_LIMITS=false
      - QBT_SKIP_CLEANUP=false
      - QBT_DRY_RUN=false
      - QBT_STARTUP_DELAY=0
      - QBT_SKIP_QB_VERSION_CHECK=false
      - QBT_DEBUG=false
      - QBT_TRACE=false

      # Logging Configuration
      - QBT_LOG_LEVEL=INFO
      - QBT_LOG_SIZE=10
      - QBT_LOG_COUNT=5
      - QBT_DIVIDER==
      - QBT_WIDTH=100
```

Before you get qBitManage up and running, you'll have to take a deep dive into how it's configured, and how it runs. Configuration is very dependant on the specific environment it operates within, and the requirements of the user. Read the [Docker Installation Guide](https://github.com/StuffAnThings/qbit_manage/wiki/Docker-Installation) in its entirety.

Whilst configuring, ensure you set the `root_directory` option with the `directory` parent to `/data/downloads/torrents`. If you ever have trouble with paths, remember, qBitManage operates from the base level of your YAMS `${MEDIA_DIRECTORY}` variable.

## Pro Tips 🎓

### 1. Container Discovery
Looking for cool containers to add? Check out:
- [linuxserver.io fleet](https://fleet.linuxserver.io/) (Highly recommended!)
- [Docker Hub](https://hub.docker.com/)

### 2. Network Magic 🌐
All containers in your `docker-compose.custom.yaml` automatically join YAMS's network! This means they can talk to each other using their container names as hostnames.

For example, if you need to connect to Radarr from a custom container, just use `http://radarr:7878` as the URL.

### 3. VPN Access 🔒
Want your custom container to use YAMS's VPN? Add this to your container config:
```yaml
    network_mode: "service:gluetun"
```

Check out [Running Prowlarr behind the VPN](/docs/advanced/prowlarr-vpn) for a detailed example!

### 4. Static IP Address 📍
For some advanced setups, you might want to assign a static IP address to your custom container within the YAMS network. This can be useful for consistent access or firewall rules.

To do this, add a `networks` section to your container definition and specify the `yams_network` with an `ipv4_address`:

```yaml
  my_custom_container:
    image: my/image:latest
    container_name: my_custom_container
    # ... other configurations ...
    networks:
      yams_network:
        ipv4_address: 172.60.0.X # Replace X with an available IP address (e.g., 21-254)
```

**Important:**
- The YAMS network uses the `172.60.0.0/24` subnet.
- YAMS's core services use IP addresses from `172.60.0.10` to `172.60.0.20`.
- **Always choose an IP address outside of this range to avoid conflicts**, for example, `172.60.0.21` or higher. You can check the `docker-compose.example.yaml` file for the IPs used by YAMS's services.

### 5. Variable Power 💪
You can access any environment variable defined in YAMS's [`.env` file](link broken) within your custom containers. Just use the `${VARIABLE_NAME}` syntax! This is great for things like API keys or other settings you want to manage centrally.

## Common Gotchas 🚨

1. **YAML Formatting Errors**: YAML is very sensitive to spacing and indentation. Even a single misplaced space can break your configuration! We highly recommend using a YAML validator like [yamllint.com](https://www.yamllint.com/) to check your syntax before applying changes.
2. **Container Names**: Make sure your custom container names don't conflict with YAMS's built-in containers.
3. **Port Conflicts**: Double-check that your new containers don't try to use ports that are already taken.
4. **Permissions**: If your container needs to access media files, remember to use `PUID` and `PGID`!

## Need Ideas? 💡

Here are some popular containers that work great with YAMS:

1. **[Seerr](https://seerr.dev/)** / **[Petio](https://petio.tv/)**: Let users request movies and shows
2. **[Tautulli](https://tautulli.com/)**: Advanced Plex monitoring and statistics
3. **[Organizr](https://organizr.app/)**: Create a sleek dashboard for all your services

## Need Help? 🆘

If you run into any issues:
1. Check our [Common Issues](/docs/faqs/) page
2. Visit the [YAMS Forum](https://forum.yams.media)
3. Join our [Discord](https://discord.gg/Gwae3tNMST) chat

Remember: YAMS is all about making your media server work for YOU. Don't be afraid to experiment and make it your own! 😎