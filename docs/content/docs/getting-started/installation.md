---
weight: 2
---

# Installation

## Dependencies

YAMS only needs a few things to get started.

Your machine _must_ be running Debian 13 (recommended) or Ubuntu 24.04 on bare metal, inside a VM or certain container types.

{{% details "ℹ️ Proxmox LXC Users" %}}
YAMS can be installed within an unprivileged Proxmox LXC container, but this requires specific configuration on the Proxmox host before you run the YAMS installation script inside the container. Please follow the steps below to ensure Docker and the VPN component (Gluetun) can function correctly within the LXC environment by providing access to the necessary TUN device.

1. Log into your Proxmox server via SSH or use the web UI’s shell access for the node (not the LXC console).
2. Open the configuration file specific to the LXC container where you intend to install YAMS. Replace <container-ID> with the actual numeric ID of your LXC container.

```sh
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

- **A config location**: This is where the docker containers will store all their data. Config files, caching, stuff like that. _This is NOT where you shows are movies are stored._ The script defaults to `/opt/yams` but hey, you do you! Just make sure your user can write to wherever you choose.

- **A media folder**: This is where all your media will be stored (and it can sure take up lots of storage space). For example, if you pick `/srv/media`, the script will create:

```
.
└── srv/media/
    ├── tvshows
    ├── movies
    ├── music
    ├── books
    ├── downloads
    └── blackhole
```

- **A regular user to run and own the media files**: Don’t use `root` (I mean, I can’t stop you, but come on! 😬). Make sure you are in a shell session owned by that user so you are ready to go.

- **A VPN service (optional but *STRONGLY* recommended)**: First lesson! A VPN is a paid service that encrypts your server's traffic, and masks its public IP address whilst it's sailing the high seas. This hides your activity from cooperations such as your ISP or copyright providers.
  - Note that most of these services are paid but don't worry, they aren't too expensive. (Cheaper than paying for 4 streaming services 😅)
  - To learn more about VPNs and how to pick a good option, check out the [YAMS VPN page](../advanced/concept%20explanations/vpn)
  - **Ensure you have an account with your chosen VPN provider before continuing with the installation and guide**

## Pre-Installation Setup

{{< path-personaliser >}}

#### 1. Setup your install location

Remember from before? This is where all the config files and application storage goes! First, create the folder and set up your user permissions if it hasn't been done already.

```
sudo mkdir -p [[config_path]]
sudo chown -R $USER:$USER [[config_path]]
```

#### 2. Setup your media directory

This is where your media files are stored (make sure it has tons of space).
If your media directory doesn’t exist yet, you’ll need to create it and set the correct permissions.

```
sudo mkdir -p [[media_path]]
sudo chown -R $USER:$USER [[media_path]]
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

If you receive this output, you are good to go! Else, use `sudo apt install curl` to first install the package, then run the command above to check.

---

> [!NOTE]
> If you have **already installed** Docker, make sure you can run it without sudo! Try this:
`docker run hello-world`
>
> If it fails, you might need to add your user to the docker group. Follow Docker’s [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user), and try the command again. Great!


---

## Installation


Its go time! If you have completed all the pre-installation steps above, its time actually get installing!

### 1. Get YAMS on your system

First, let's grab a fresh copy of YAMS and put it in a temporary location (we like to keep things tidy!):

```bash
git clone --depth=1 https://gitlab.com/rogs/yams.git /tmp/yams
cd /tmp/yams
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
====================================================
```

### 3. Docker Installation (if needed)

The installer will first check for Docker:
```bash
Checking prerequisites...
⚠️ Docker not found! ⚠️
Do you want YAMS to install docker and docker-compose? IT ONLY WORKS ON DEBIAN AND UBUNTU! [y/N]: y
```

- If you don't have Docker installed:
  - Type `y` and hit `Enter` to let YAMS handle the Docker installation
  - The script will install both Docker and Docker Compose
  - This only works on Debian and Ubuntu!

- If you already have Docker:
  - You'll see "docker exists ✅" instead
  - The installer will move to the next step

### 4. Choose Installation Location

```bash
Where do you want to install the docker-compose file? [/opt/yams]:
```

- Press Enter to use the default `/opt/yams` or type a different path if you want to install somewhere else.
  - Based on your configuration of this guide, you should type `[[config_path]]`
- **Important**: You must use an absolute path (e.g., `/mnt/yams`). Docker does not expand `~` to your home directory, so avoid using something like `~/yams`

### 5. Select User

```bash
What's the user that is going to own the media server files? [your_current_user]:
```

- Press Enter to use your current user (recommended) or type a different username
- Remember: Don't use `root`!
- The user must exist and have sudo privileges

### 6. Set Media Directory

```bash
Please, input your media directory [/srv/media]:
```

- Press Enter to use the default `/srv/media` or type the path where you want your media stored. This path can also be a SMB/NFS mount, an external drive or a different partition.
  - Based on your configuration of this guide, you should type `[[media_path]]`
- **Important**: You must use an absolute path (e.g., `/mnt/media`). Docker does not expand `~` to your home directory, so avoid using something like `~/media`

Then confirm your choice:
```bash
Are you sure your media directory is "/srv/media"? [y/N]:
```

- Type `y` and press Enter if the path is correct
- Type `n` or press Enter to go back and change it

### 7. Choose Media Service

```bash
Time to choose your media service.
Your media service is responsible for serving your files to your network.
Supported media services:
- jellyfin (recommended, easier)
- emby
- plex (advanced, always online)

Choose your media service [jellyfin]:
```

Pick your streaming service:
- Press Enter for Jellyfin (recommended for beginners)
- Type `emby` for Emby
- Type `plex` for Plex

Each service has its strengths:
- **Jellyfin**: Free, open-source, easy to set up. Advised for most new or unsure users!
- **Emby**: Similar to Jellyfin but with premium features
- **Plex**: Most polished, but requires online account and is more complex to configure. Not advised for new users due to the negative direction the company is taking (it costs). Be aware of these [new limitations](https://www.plex.tv/blog/important-2025-plex-updates/) if you don't have a Plex Pass.

### 8. VPN Configuration

```bash
Time to set up the VPN.
Supported VPN providers: https://yams.media/docs/advanced/concept-explanations/vpn

Configure VPN? (Y/n) [Default = y]:
```

If you want to use a VPN (strongly recommended):
1. Press Enter or type `y` to configure VPN
2. Enter your VPN provider:
   ```bash
   VPN service? (with spaces) [protonvpn]:
   ```
   - Press Enter for ProtonVPN (recommended)
   - Or type your VPN provider's name

   The installer will show you where to find the setup documentation:
   ```bash
   Please check protonvpn's documentation for specific configuration:
   https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md
   ```
   Make sure to check this documentation - it will help you avoid common setup issues!

   If you are using ProtonVPN:
   ```bash
   DO NOT USE YOUR PROTON ACCOUNT USERNAME AND PASSWORD. REFER TO THE DOCUMENTATION ABOVE TO OBTAIN THE CORRECT VPN USERNAME AND PASSWORD.
   ```
   [Don't say you weren't warned](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md#openvpn-only).

   The installer will then ask:
   ```bash
   Are you using a free ProtonVPN account? (y/N) [Default = n]:
   ```
   - If you type `y` and press Enter:
     ```bash
     ⚠️ ProtonVPN Free Tier Users: If you plan to use a free ProtonVPN account, please be aware that port forwarding is not supported. See our ProtonVPN Free Tier guide here: https://yams.media/docs/advanced/concept-explanations/vpn/#protonvpn-free-tier for more details.
     ```
     The installer will automatically configure Gluetun for the free tier (setting `FREE_ONLY=on` and disabling port forwarding). You will **not** need to make manual changes to `docker-compose.yaml` or `.env` for this.
   - If you type `n` or press Enter (for a paid account):
     The installer will proceed to the general port forwarding question.

   If you are using Mullvad:
   ```bash
   Mullvad is removing OpenVPN support on January 15, 2026.
   If you plan to use Mullvad, you MUST migrate to WireGuard after installation.
   Read more: https://mullvad.net/en/blog/removing-openvpn-15th-january-2026
   WireGuard setup instructions: https://yams.media/docs/advanced/community-guides/gluetun-wireguard/
   ```

   Make sure you configure Wireguard **after** finishing the installation.

3. Configure port forwarding:
   ```bash
   Port forwarding allows for better connectivity in certain applications.
   However, not all VPN providers support this feature.
   Please check your VPN provider's documentation to see if they support port forwarding.
   Enable port forwarding? (y/N) [Default = n]:
   ```

4. Enter your credentials:
   ```bash
   VPN username (without spaces):
   VPN password:
   ```

Special notes:
- For ProtonVPN, the installer handles the `+pmp` suffix for port forwarding automatically if you enabled it in the previous step. Just enter your VPN username.
- For Mullvad, it will only ask you for your username, since Mullvad doesn't need a password.
- For other VPN providers, the installer will prompt you about port forwarding before asking for credentials.

If you don't want to configure VPN now:
- Type `n` and press Enter
- You can set it up later, but **always use a VPN when downloading torrents!**

### 9. Installation Process

After you've answered all the questions, you'll see:
```bash
Copying docker-compose.example.yaml to /opt/yams/docker-compose.yaml...
docker-compose.example.yaml was copied successfuly! ✅

Copying .env.example to /opt/yams/.env...
.env.example was copied successfuly! ✅

Copying docker-compose.custom.yaml to /opt/yams/docker-compose.custom.yaml...
docker-compose.custom.yaml was copied successfuly! ✅
Everything installed correctly! 🎉
Running the server...
This is going to take a while...
```

The installer will now:
1. Copy all necessary configuration files
2. Set up your chosen options
3. Start downloading and configuring Docker containers

You'll then see:
```bash
We need your sudo password to install the YAMS CLI and configure permissions...
```

Enter your sudo password to:
- Install the YAMS command-line tool
- Set proper permissions on your media folders

If everything works, you'll see these success messages:
```bash
YAMS CLI installed successfully ✅
Media directory ownership and permissions set successfully ✅
Install directory ownership and permissions set successfully ✅
Configuration folder "/opt/yams/config" exists ✅
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
qBittorrent: http://your.ip.address:8081/
SABnzbd: http://your.ip.address:8080/
Radarr: http://your.ip.address:7878/
Sonarr: http://your.ip.address:8989/
Lidarr: http://your.ip.address:8686/
Prowlarr: http://your.ip.address:9696/
Bazarr: http://your.ip.address:6767/
Media Service: http://your.ip.address:8096/
Portainer: http://your.ip.address:9000/
```

PERHAPS ADD IP ADDRESS PAST OPTION HERE?

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

Time to configure your media server!

If you are a bit unsure about how everything works, or can't conceptualise what YAMS is, check out the fundamentals section. There are simple explanations of YAMS and its backing technology (torrenting, VPNs, docker) to help you get a broader idea of how everything works together *before* configuration, to assist with debugging.

If you are confident or short on time, no worries! Head straight onto the configuration. The YAMS fundamentals will always be there for reference in the future, or as you see fit as you follow the guides.