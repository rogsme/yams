---
weight: 10
title: Adding Custom Containers
bookCollapseSection: true
---

# Make YAMS Your Own!

Want to add more containers to your YAMS setup? Maybe a cool new app you found, or something specific for your needs? No problem! YAMS makes it super easy to expand your media server with custom containers.

## The Basics

When you install YAMS, it creates two important files:
- `docker-compose.yaml`: This is YAMS's brain! Don't modify this file directly.
- `docker-compose.custom.yaml`: This is your playground! Add all your custom containers here.

> [!SUCCESS]
> If you are still unsure about what containers are or how files are organised, make sure to check out our [Docker Fundamentals](/docs/fundamentals/docker-and-compose/) guide for a quick explanation of how YAMS functions.


## The Magic Variables

YAMS provides some handy environment variables you can use in your custom containers. These are defined in your central [`.env` settings file](/docs/fundamentals/environment-variables) (learn more about it!) and make it super easy to keep your custom containers working in harmony with YAMS:

```yaml
PUID: Your user ID
PGID: Your group ID
TZ: Your timezone
MEDIA_DIRECTORY: Your media folder location
INSTALL_DIRECTORY: Your YAMS install directory
```

These make it super easy to keep your custom containers working in harmony with YAMS!

## How to add a container

> This specific guide will focus on adding Seerr, but the same principles apply to any container you want to add. Just make sure to check the container's documentation for any specific requirements.

Let's learn how to adapt a docker compose entry for a new container and add it to your YAMS setup.

Let's walk through adding [Seerr](https://seerr.dev/) - a fantastic request management app for your media server. You don't need to add this if you don't want! Check out the [Other Containers](#other-containers) section for more options, or adapt this section to add your own container.

#### 1. First, open `[[install_path]]/docker-compose.custom.yaml`:
```bash
nano [[install_path]]/.docker-compose.custom.yaml
```

If this is your first custom container, you'll need to uncomment the `services:` line. To uncomment you must remove the `#` symbol and the space. Your file should start like this:

```yaml
# Add your custom services here!
services:  -> When you uncomment, remember to remove the space too! "services:" must be left without any spaces around it
```

#### 2. Adapt the Docker Compose entry.

Most projects will have an explain Docker Compose entry in their documentation. You can copy this and adapt it to work with YAMS. Let's walk through adapting Seerr's example Docker Compose entry to work with YAMS. **This logic can work with any container!**

Let's take a look at Seerr's example Docker Compose entry:

```yaml {filename="Seerr's example docker-compose.yaml"}
seerr:
  image: ghcr.io/seerr-team/seerr:latest
  init: true
  container_name: seerr
  environment:
    - LOG_LEVEL=debug
    - TZ=Asia/Tashkent
    - PORT=5055 #optional
  ports:
    - 5055:5055
  volumes:
    - /path/to/appdata/config:/app/config
  restart: unless-stopped
```

The things we want to look for when adapting this to YAMS are:
- **Environment Variables**: Replace hardcoded values with YAMS environment variables. Add/remove any optional environment variables as needed.
- **Volume Paths**: Use YAMS-defined paths for config directories.
- **User IDs**: Use YAMS-defined PUID and PGID.

So let's adapt these environment variables:
- The `TZ` environment variable is already defined in your `.env` file, so we can use `${TZ}` instead of hardcoding it.
- The `PORT` environment variable is optional, so we can remove it if we want to use the default.
- The `LOG_LEVEL` environment variable is set to `debug`, which is only needed for troubleshooting. We can remove it for normal operation. *Add it if you are experiencing issues, so you can use Dozzle to see those extra-informative logs!*

Now, lets adapt the volume paths. Remember, the path on the left if the path on our machine. Since YAMS has a standardised config path, we can use `${INSTALL_DIRECTORY}/config/seerr` instead of `/path/to/appdata/config`. The path on the right is the path inside the container, which we will leave as-is.

Finally, lets's fix up user permissions. Most commonly this involves adding the `PUID=${PUID}` and `PGID=${PGID}` environment variables to ensure the container runs with the correct permissions. We can add these to the `environment` section.

> Seerr actually operates a bit differently in terms of user permissions as it is a non-root container, meaning we have to specify the user explicitly using the `user` directive. Always read the documentation for the container you are adding!*


```yaml {filename="Adapted docker-compose entry for Seerr"}
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
  restart: unless-stopped
```
#### 3. Creating the config folder

Before you start up your new container, it can be a good idea to create the config folder for it to avoid any permission issues. This isn't entirely necessary, but it can help prevent permission issues down the line. Make sure you are in a shell session, logged in as the same user that runs YAMS.

Run this command to create the config folder for Seerr, and set the correct permissions (if you are adding another container remember to change the folder name to match the container you are adding!):
```bash
mkdir -p [[install_path]]/config/seerr && chown -R $(id -u):$(id -g) [[install_path]]/config/seerr
```
#### 4. Starting the container
Now, it's time to start your new container:
```bash
yams start seerr
```

You should see something like:
```bash
 ⠙ seerr Pulling                                                                     5.2s
[...]
```

That's it! Your new container is up and running! 🎉

---

Not a fan of Seerr? No worries! Lets take a look at how to add many popular apps into the YAMS system.

Each of these docker compose entries can be added right into your `docker-compose.custom.yaml` file, under the `services` parent item.

> [!SUCCESS]
> 💡**TIP**: Remember, since all services are run in the same Docker network, references to other services from within an app can be completed using their name and port. For example, need to enter your Radarr URL? Use `http://radarr:7878`! No pesky IPs needed.

---

### Qui 📥

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

*If you want to jump straight into a guided setup, check out *[Seeding with Qui](/docs/advanced/custom-containers/qui)* for a setup where all torrents are seeded whilst the media remains in your server, and then smoothly removed after the item is watched in your streaming application.*


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
[Profilarr](https://dictionarry.dev/) syncs reliable naming conventions, quality profiles and custom formats from the [Dictionarry database](https://github.com/Dictionarry-Hub/database) to all your systems. **Its a great way to ensure you are fetching good quality media, and keeping your media server organised.**

It is intuitive to use as it is configured through a handy Web UI!

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

Done! To fully connect Autobrr to your media server's downloads, continue with the full guide [here](/docs/advanced/custom-containers/autobrr).

### Recyclarr 🗑️

[Recyclarr](https://recyclarr.dev/) is an app to sync [Trash Guide's](https://trash-guides.info/) recommended naming conventions, quality profiles and formats straight to your media stack! It's just like Profilarr but uses the well-known Trash Guide's setup instead of Dictionarry's.

(To be honest, its a little more confusing to configure as it uses text-only configuration files)

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

[Unpackerr](https://unpackerr.zip/) is an app that automatically extracts any downloads that are an archive (e.g., .`zip`, `.rar`), ensuring Radarr and Sonarr don't get stuck waiting for manual intervention.

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

> [!INFO]
> Qui (see above) is a great alternative to qBitManage. Although it is a full qBitTorrent interface replacement, it provides an "Automations" feature which can do similar tasks.

```yaml
  qbitmanage:
    container_name: qbitmanage
    image: ghcr.io/stuffanthings/qbit_manage
    volumes:
      - ${MEDIA_DIRECTORY}:/data
      - ${INSTALL_DIRECTORY}/config/qbitmanage:/config
    ports:
      - "8085:8085"  # Web API port (when enabled)
    environment:
      # CONSULT QBITMANAGE'S DOCUMENTATION FOR ALL AVAILABLE ENVIRONMENT VARIABLES
      # CRAFT THESE TO YOUR NEEDS!
```

Before you get qBitManage up and running, you'll have to take a deep dive into how it's configured, and how it runs. Configuration is very dependant on the specific environment it operates within, and the requirements of the user. Read the [Docker Installation Guide](https://github.com/StuffAnThings/qbit_manage/wiki/Docker-Installation) in its entirety.

> [!WARNING]
> Whilst configuring, ensure you set the `root_directory` option with the `directory` parent to `/data/downloads/torrents`. If you ever have trouble with paths, remember, qBitManage operates from the base level of your YAMS `${MEDIA_DIRECTORY}` variable.

### Others

The container you want not listed here? No worries! You can add any container you want to your YAMS setup. Just make sure to check the container's documentation for any specific requirements, and adapt the Docker Compose entry to work with YAMS's environment variables and volume paths (see above).

Or, if you have added an additional container that you think would be useful for others, please consider contributing it to the YAMS documentation!

## Pro Tips 🎓

### VPN Access
Want your custom container to use YAMS's VPN? Remove the port mapping and add this to your container config:
```yaml
network_mode: "service:gluetun"
```
Now your service will be routed through the YAMS network, and any ports must be added to Gluetuns compose entry to be accessible from outside the VPN.

> [!INFO]
> If you application supports utilising a HTTP Proxy, you can simply add Gluetun's proxy settings to your container config (its a lot easier). Check out [Running Prowlarr behind the VPN](/docs/advanced/vpn/prowlarr-vpn) for a detailed example!

### Variable Power
You can access any environment variable defined in YAMS's [`.env` file](/docs/fundamentals/environment-variables) within your custom containers. Just use the `${VARIABLE_NAME}` syntax! This is great for things like API keys or other settings you want to manage centrally.

## Common Gotchas

1. **YAML Formatting Errors**: YAML is very sensitive to spacing and indentation. Even a single misplaced space can break your configuration! We highly recommend using a YAML validator like [yamllint.com](https://www.yamllint.com/) to check your syntax before applying changes, or use an editor with this built in.
2. **Container Names**: Make sure your custom container names don't conflict with YAMS's built-in containers.
3. **Port Conflicts**: Double-check that your new containers don't try to use ports that are already taken.
4. **Permissions**: If your container needs to access media files, remember to use `PUID` and `PGID` and manually create the necessary directories and set their ownership beforehand!

---

Remember: YAMS is all about making your media server work for YOU. Don't be afraid to experiment and make it your own! 😎