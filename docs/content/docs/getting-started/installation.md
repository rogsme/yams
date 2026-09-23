---
weight: 20
---

# Installation

## Dependencies

YAMS only needs a few things to get started.

Your machine _must_ be running Debian 13 (recommended) or Ubuntu 24.04 on bare metal, inside a VM or certain container types.

{{% details "ℹ️ Proxmox LXC Users" %}}
YAMS can be installed within an unprivileged Proxmox LXC container, but this requires specific configuration on the Proxmox host before you run the YAMS installation script inside the container. Please follow the steps below to ensure Docker and the VPN component (Gluetun) can function correctly within the LXC environment by providing access to the necessary TUN device.

Make sure **Keyctl** and **Nesting** features are enabled under the container’s 'Options' in the Proxmox VE Web UI. Docker requires these features to run correctly inside the container.

1. Log into your Proxmox server via SSH or use the web UI’s shell access for the **node** (not the LXC console).
2. Open the configuration file specific to the LXC container where you intend to install YAMS. Replace <container-ID> with the actual numeric ID of your LXC container.

```bash
nano /etc/pve/lxc/<container-ID>.conf
```

3. Append the following lines to the end of the file. These lines grant the container necessary permissions and mount the /dev/net/tun device from the host into the container.

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

4. Save the changes to the configuration file and exit the editor.

5. For the changes to take effect, you must restart the LXC container. You can do this via the Proxmox web UI or using the following commands on the Proxmox host:

```
pct stop <container-ID>
pct start <container-ID>
```

And that's it. You are good to continue with the normal guide!

{{% /details %}}

Your OS needs to be properly configured. That means:

- You have a user that is not root (because we’re responsible adults 😎)
- You can run `sudo apt update` and `sudo apt upgrade` without errors
- Having `git` installed, you'll need this to clone the YAMS repository. Check if it’s installed with `git --version`. If you don’t have it yet, it’s easy to install with `sudo apt update && sudo apt install git` on Debian/Ubuntu.


Don't worry if you don't have docker set up already. The script can handle that for you. And if you already do, you are still good to go!

> [!WARNING]
> If you’re using Ubuntu, make sure you are **NOT** using the snap version of docker! The snap version runs in a sandbox and can’t access what it needs to run a proper media stack. You can check by running the command `which docker` in your terminal. If you see `/snap/bin/docker` as the output, you won’t be able to install YAMS. ⚠️


## Prerequisites

Before you get the script up and running, you'll have to do some thinking about how you want your system to operate. You'll need:

- **Some free time**: This guide removes most of the complexity of getting set up with a media server, but it still takes time to follow though. Leave about 1 hour free to follow through the guide, possibly conduct research and (hopefully no) debugging!

- **An install directory**: This is where the docker containers will store all their data. Config files, caching, stuff like that. _This is NOT where your shows or movies are stored._ The script defaults to `/opt/yams` but hey, you do you! Just make sure your user can write to wherever you choose.

- **A media folder**: This is where all your media will be stored (and it can sure take up lots of storage space). For example, if you pick `/srv/media`, the script will create:

```
_MEDIA_PATH_
  ├── blackhole/
  ├── books/
  ├── downloads/
  │   ├── torrents/
  │   └── usenet/
  │       ├── complete/
  │       └── incomplete/
  ├── movies/
  ├── music/
  └── tvshows/
```

- **A regular user to run and own the media files**: Don’t use `root` (I mean, I can’t stop you, but come on! 😬). Make sure you are in a shell session owned by that user so you are ready to go.

- **A VPN service (optional but *STRONGLY* recommended)**: First lesson! A VPN is a paid service that encrypts your server's traffic, and masks its public IP address whilst it's sailing the high seas. This hides your activity from cooperations such as your ISP or copyright providers.
  - Note that most of these services are paid but don't worry, they aren't too expensive. (Cheaper than paying for 4 streaming services 😅)
  - To learn more about VPNs and how to pick a good option, check out the [YAMS VPN page](/docs/advanced/vpn/)
  - **Ensure you have an account with your chosen VPN provider before continuing with the installation and guide**

## Pre-Installation Setup

{{< path-personaliser >}}

#### 1. Setup your install directory

Remember from before? This is where all the config files and application storage goes! First, create the folder and set up your user permissions if it hasn't been done already.

```bash
sudo mkdir -p _INSTALL_PATH_
sudo chown -R $USER:$USER _INSTALL_PATH_
```

#### 2. Setup your media directory

This is where your media files are stored (make sure it has tons of space).
If your media directory doesn’t exist yet, you’ll need to create it and set the correct permissions.

```bash
sudo mkdir -p _MEDIA_PATH_
sudo chown -R $USER:$USER _MEDIA_PATH_
```

Important notes:
- Make sure your user has full read/write permissions to this directory
- If you’re using an external drive or NFS/SMB mount, mount it first, then set permissions
- The installer will create subdirectories (tvshows, movies, music, etc.) automatically

#### 3. Install `curl`

In order to download and run the YAMS script, you need to be able to run the `curl` command on your machine. This is an extremely common utility, so check if it is already installed by running an empty `curl` command.

```bash
$ curl
curl: try 'curl --help' or 'curl --manual' for more information
```

If you receive this output, you are good to go! Else, use `sudo apt update && sudo apt install curl` to first install the package, then run the command above to check.

---

> [!NOTE]
> If you have **already installed** Docker, make sure you can run it without sudo! Try this:
`docker run hello-world`
>
> If it fails, you might need to add your user to the docker group. Follow Docker’s [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user), and try the command again. Great!


---

## Installation

Its go time! If you have completed all the pre-installation steps above, its time actually get installing!

> [!SUCCESS]
> Note that the installation script can be rerun if it fails or exits. If you realise you have set up your system wrong or the script itself reports a problem, you can simply rerun it and it will still work fine!

> [!DANGER]
> Do *NOT* re-run the installer if you have fully completed you configuration and have a functioning media server. This will overwrite your configuration files and you will lose your settings and credentials.

### 1. Download the installer script

First, let's use `curl` to download the main installer script into the current directory:

```bash
curl -fsSL -o install.sh https://raw.githubusercontent.com/rogsme/yams/v4/src/install.sh
```

### 2. Start the installer

```bash
bash install.sh
```

You'll see this welcome screen:
```bash
====================================================
                 ___           ___           ___
     ___        /  /\         /__/\         /  /\
    /__/|      /  /::\       |  |::\       /  /:/_
   |  |:|     /  /:/\:\      |  |:|:\     /  /:/ /\
   |  |:|    /  /:/~/::\   __|__|:|\:\   /  /:/ /::\
 __|__|:|   /__/:/ /:/\:\ /__/::::| \:\ /__/:/ /:/\:\
/__/::::\   \  \:\/:/__\/ \  \:\~~\__\/ \  \:\/:/~/:/
   ~\~~\:\   \  \::/       \  \:\        \  \::/ /:/
     \  \:\   \  \:\        \  \:\        \__\/ /:/
      \__\/    \  \:\        \  \:\         /__/:/
                \__\/         \__\/         \__\/
====================================================
Welcome to YAMS (Yet Another Media Server)
Installation process should be really quick
We just need you to answer some questions
We are going to ask for your sudo password in the end
to finish the installation of the CLI
====================================================
```

### 3. Docker Installation (if needed)

The installer will first check for Docker:
```bash
Checking prerequisites...
curl exists ✅
sed exists ✅
awk exists ✅
⚠️  Docker/Docker Compose not found! ⚠️
Do you want YAMS to install docker and docker-compose? [y/N]: y
```

- If you don't have Docker installed:
  - Type `y` and hit `Enter` to let YAMS handle the Docker installation by running the official installation script
  - The script will install both Docker and Docker Compose
  - You may need to enter your `sudo` password
  - It will take a second!


- If you already have Docker:
  - You'll see "docker exists ✅" instead
  - Permissions will be checked
  - The installer will move to the next step

- If the script has installed Docker or fixed missing Docker permissions, you wil have to refresh these manually
- Run the command `newgrp docker`, and then re-run the installation script!

### 4. Select User

```bash
User to own the media server files? [your_current_user]:
```

- Press Enter to use your current user (recommended, you should be in a shell session owned by your YAMS user) or type a different username
- Remember: Don't use `root`!
- The user must exist and have sudo privileges

### 4. Choose Installation Location

```bash
Installation directory? [/opt/yams]:
```

- Press Enter to use the default `/opt/yams` or type a different path if you want to install somewhere else.
  - Based on your configuration of this guide, you should type `_INSTALL_PATH_`

> [!WARNING]
> You must use an absolute path (e.g., `/mnt/yams`). Docker does not expand `~` to your home directory, so avoid using something like `~/yams`


### 6. Set Media Directory

```bash
Media directory [/srv/media]:
```

- Press Enter to use the default `/srv/media` or type the path where you want your media stored. This path can also be a SMB/NFS mount, an external drive or a different partition.
  - Based on your configuration of this guide, you should type `_MEDIA_PATH_`

> [!WARNING]
> You must use an absolute path (e.g., `/mnt/media`). Docker does not expand `~` to your home directory, so avoid using something like `~/media`

Then confirm your choice:
```bash
Are you sure your media directory is "_MEDIA_PATH_"? (y/N) [Default = n]:
```

- Type `y` and press Enter if the path is correct
- Type `n` or press Enter to abort the script. Make required changes to your system, then re-run the script again.

### 7. Choose Media Service

```bash
Time to choose your media service.
Your media service is responsible for serving your files to your network.
Supported media services:
- jellyfin (recommended, easier)
- emby
- plex (advanced, best product quality, expensive)

Choose your media service [jellyfin]:
```


Each service has its strengths:
- **Jellyfin**: Free, open-source, easy to set up. Advised for most new or unsure users!
- **Emby**: Similar to Jellyfin but with premium features
- **Plex**: Most polished, but requires online account and is more complex to configure. Not advised for new users due to the negative direction the company is taking (required payments for remote streaming). Be aware of these [new limitations](https://www.plex.tv/blog/important-2025-plex-updates/) if you don't have a Plex Pass.

Pick your streaming service:
- Press Enter for Jellyfin (recommended for most)
- Type `emby` for Emby
- Type `plex` for Plex

### 8. VPN Configuration

```bash
Time to set up the VPN.
Supported VPN providers: https://yams.media/docs/advanced/concept-explanations/vpn

Configure VPN? (Y/n) [Default = y]:
```

If you want to use a VPN (strongly recommended):
1. Press Enter or type `y` to configure a VPN.
2. Enter your VPN provider:
   ```bash
   VPN service? (with spaces) [protonvpn]:
   ```
   - Press Enter for ProtonVPN (recommended)
   - Or:
     - Head to the YAMS [Torrenting and VPNs](/docs/fundamentals/torrenting-and-vpns/) page to see a list of supported providers
     - Click on your provider to see the Gluetun documentation for it
     - Enter your VPN provider's name **exactly** as shown in the Gluetun documentation as the value of `VPN_SERVICE_PROVIDER` in the Gluetun example compose file
       - For example, if I see `VPN_SERVICE_PROVIDER=private internet access` in the Gluetun documentation, I would enter `private internet access` here.

3. Choose your VPN protocol:
   ```bash
   VPN type selection:
     openvpn:  Default. Works with most providers.
     wireguard: Only available for some providers. Only pick if you have your WireGuard credentials ready.

   VPN type? (openvpn/wireguard) [Default = openvpn]:
   ```

   ### Which VPN type should I choose?

   #### OpenVPN (Recommended for most users)

   - Supported by nearly every VPN provider
   - Easier to set up
   - Uses a username and password
   - Default option in YAMS

    > [!SUCCESS]
    >  Choose this unless your VPN provider specifically supports WireGuard and you already have your WireGuard configuration details.

   #### WireGuard

   - Generally faster than OpenVPN
   - Lower CPU usage
   - Requires WireGuard credentials from your VPN provider
   - Not available from every VPN provider

   Only choose WireGuard if: your VPN provider supports it, and you already have your WireGuard credentials ready (see Gluetun documentation on how to get them)

---

### Read Your Provider Documentation

The installer will display a warning screen and provide a direct link to your provider's documentation:

```bash
YOUR VPN DOCUMENTATION IS HERE:
https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md
```

**Read this documentation before continuing.**

Most VPN setup failures happen because users use the wrong credentials or skip provider-specific requirements.

Press Enter once you have reviewed the documentation:

```bash
Press ENTER after you've READ the VPN documentation to continue...
```

---

### ProtonVPN Users

If you selected ProtonVPN, the installer will display:

```bash
DO NOT USE YOUR PROTON ACCOUNT USERNAME AND PASSWORD.
REFER TO THE DOCUMENTATION ABOVE TO OBTAIN THE CORRECT VPN USERNAME AND PASSWORD.
```

**This is the most common VPN setup mistake.**

You must generate OpenVPN/WireGuard credentials from your ProtonVPN account dashboard.

The installer will then ask:

```bash
Are you using a free ProtonVPN account? (y/N) [Default = n]:
```

#### ProtonVPN Free Tier

If you answer `y`:

```bash
⚠️ ProtonVPN Free Tier Users:
Port forwarding is not supported.
```

YAMS will automatically:

- Configure Gluetun for the free tier
- Enable `FREE_ONLY`
- Disable all port forwarding settings

No manual configuration is required.

#### ProtonVPN Paid Tier

If you answer `n` (or simply press Enter):

- Port forwarding can optionally be enabled
- The installer will continue to the port forwarding step


### WireGuard Setup

> [!WARNING]
> Ensure you have read the Gluetun documentation for your provider, and have any Wireguard-related required values ready to go.

If you selected:

```bash
VPN type? (openvpn/wireguard): wireguard
```

the installer will ask for your WireGuard credentials: `WireGuard private key:`

Enter the private key provided by your VPN provider.

Next: `WireGuard addresses (comma separated):`

Enter the addresses provided by your VPN provider.


Finally: `WireGuard preshared key (enter only if your provider uses it, otherwise leave blank):`

Most providers don't require a preshared key. If your provider does not provide/need one, simply press Enter.


#### What does YAMS do with these values?

The installer automatically:
- Configures Gluetun for WireGuard
- Stores the values in `.env`
- Disables OpenVPN settings
- Enables the correct WireGuard environment variables

None of these values are used for anything else or shared externally, YAMS is all about privacy! Don't believe me? Feel free to read through the script yourself 🤷

---

### OpenVPN Credentials

If you selected OpenVPN, the installer will ask: `VPN username (without spaces):`

Then: `VPN password:`

Use the OpenVPN credentials provided by your VPN provider, after reading your provider's Gluetun documentation.

---

### Port Forwarding

Next, the installer will ask:

```bash
Port forwarding allows for better connectivity in certain applications.
However, not all VPN providers support this feature.
Please check your VPN provider's documentation to see if they support port forwarding.
Enable port forwarding? (y/N) [Default = n]:
```

Only respond with `y` for yes if you are certain your provider supports it!

Else, just hit enter.

#### ProtonVPN

For paid ProtonVPN accounts, YAMS automatically appends the required `+pmp` suffix to your username when port forwarding is enabled, if it isn't already present.

You do not need to add this yourself.

#### ProtonVPN Free Tier

Port forwarding is automatically disabled and this question is skipped.

---

### Skipping VPN Setup

If you do not want to configure a VPN now:

```bash
Configure VPN? (Y/n) [Default = y]: n
```

YAMS will:

- Disable the Gluetun container
- Connect qBittorrent directly to Docker networking
- Expose qBittorrent and SABnzbd ports on the host

You can configure a VPN later via manual editing of the `docker-compose.yaml` using our guides.

> **Warning:** Always use a VPN when downloading torrents. Running torrent clients without VPN protection may expose your real IP address.


### 9. Container Customisation

YAMS is designed to be a template usable by everyone! However, you may not want to utilise all of the containers within it. Note that all these configuration can be easily changed later via manually editing the `docker-compose.yaml` file utilising our guides. We know things may change as you go along, everything is reversible!

#### Usenet
Note that Usenet access mostly relies on having a paid provider, so only enable it if you understand the requirements (and know what it even is 🤣).

Answer `n` if you only plan to use torrents!

```bash
Time to set up Usenet.
Usenet allows you to download content via SABnzbd.
You can change this later by editing docker-compose.yaml.
You can skip this if you only plan to use torrents.
Enable Usenet/SABnzbd? (Y/n) [Default = y]:
```


Lidarr is used to query, add downloads to the download queue and index Music. Enable it if you wish to manage music with your media server. Else, answer `n`.
```bash
Time to set up Lidarr.
Lidarr is used to query, add downloads to the download queue and index Music.
You can change this later by editing docker-compose.yaml.
Enable Lidarr? (Y/n) [Default = y]:
```

### 9. Installation Process

After you've answered all the questions, you'll see:
```bash
Configuring the docker-compose file for user "yamstest" in "_INSTALL_PATH_"...

Downloading .env.template to _INSTALL_PATH_/.env...
.env.template downloaded successfully ✅

Downloading docker-compose.custom.yaml to _INSTALL_PATH_/docker-compose.custom.yaml...
docker-compose.custom.yaml downloaded successfully ✅

Downloading docker-compose.template.yaml to _INSTALL_PATH_/docker-compose.yaml...
docker-compose.template.yaml downloaded successfully ✅

Downloading yams to _INSTALL_PATH_/yams...
yams downloaded successfully ✅
Updating environment configuration...
Updating docker-compose configuration...
Configuring VPN settings in .env...
Updating YAMS CLI configuration...
Everything installed correctly! 🎉
Starting YAMS services...
This may take a while...
```

The installer has:
1. Downloaded the template YAMS files
2. Set up your chosen options
And will now start downloading and configuring Docker containers

You'll then see:
```bash
We need your sudo password to install the YAMS CLI and configure permissions...
```

Enter your sudo password to install the YAMS command-line tool and set proper permissions on your media folders.

If everything works, you'll see these success messages:
```bash
YAMS CLI installed successfully ✅
Media directory ownership and permissions set successfully ✅
Install directory ownership and permissions set successfully ✅
Configuration folder "_INSTALL_PATH_/config" exists ✅
Configuration folder ownership and permissions set successfully ✅
```

### 10. Final Success Screen

When everything's done, you'll see this awesome ASCII art:
```bash
========================================================
     _____          ___           ___           ___
    /  /::\        /  /\         /__/\         /  /\
   /  /:/\:\      /  /::\        \  \:\       /  /:/_
  /  /:/  \:\    /  /:/\:\        \  \:\     /  /:/ /\
 /__/:/ \__\:|  /  /:/  \:\   _____\__\:\   /  /:/ /:/_
 \  \:\ /  /:/ /__/:/ \__\:\ /__/::::::::\ /__/:/ /:/ /\
  \  \:\  /:/  \  \:\ /  /:/ \  \:\~~\~~\/ \  \:\/:/ /:/
   \  \:\/:/    \  \:\  /:/   \  \:\  ~~~   \  \::/ /:/
    \  \::/      \  \:\/:/     \  \:\        \  \:\/:/
     \__\/        \  \::/       \  \:\        \  \::/
                   \__\/         \__\/         \__\/
========================================================
```

Following this, you'll get a list of all your service URLs:
```bash
Service URLs:
qBittorrent: http://_USER_IP_:8081/
SABnzbd: http://_USER_IP_:8080/
Radarr: http://_USER_IP_:7878/
Sonarr: http://_USER_IP_:8989/
Lidarr: http://_USER_IP_:8686/
Prowlarr: http://_USER_IP_:9696/
Bazarr: http://_USER_IP_:6767/
Media Service: http://_USER_IP_:8096/
Portainer: http://_USER_IP_:9000/
```

Don't worry about memorizing these - they're saved in `~/yams_services.txt` for easy reference!

### Important Notes:

1. **First Start Time**
   - Services might take a few minutes to fully start
   - Be patient on first launch!

2. **VPN Check**
   If you configured a VPN, verify it's working:
   ```bash
   yams check-vpn
   ```
   You should see different IPs for your system and qBittorrent.

## What's Next?

Time to do some learning, and then configure your media server!

If you want to learn about the YAMS CLI (advised), continue onto the next page.

After this, if you are a bit unsure about how everything works or can't conceptualise what YAMS is, continue onto the fundamentals section. There are simple explanations of YAMS and its backing technology (torrenting, VPNs, Docker) to help you get a broader idea of how everything works together *before* configuration, to assist with debugging.

If you are confident or short on time, no worries! Head straight onto the configuration. The YAMS fundamentals will always be there for reference in the future, or as you see fit as you follow the guides.
