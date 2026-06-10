---
weight: 1
---

# Installation
## Dependencies

YAMS only needs a few things to get started.

Your machine *must* be running Debian 13 (recommended) or Ubuntu 24.04 on bare metal, inside a VM or certain container types.

{{% details "ℹ️ Proxmox LXC Users" %}}
YAMS can be installed within an unprivileged Proxmox LXC container, but this requires specific configuration on the Proxmox host before you run the YAMS installation script inside the container. Please follow the steps below to ensure Docker and the VPN component (Gluetun) can function correctly within the LXC environment by providing access to the necessary TUN device.

1. Log into your Proxmox server via SSH or use the web UI’s shell access for the node (not the LXC console).
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


{{% hint warning %}}
If you’re using Ubuntu, make sure you are **NOT** using the snap version of docker! The snap version runs in a sandbox and can’t access what it needs to run a proper media stack.. You can check by running the command `which docker` in your terminal.

If you see:
```bash
$ which docker
/snap/bin/docker
```
You won’t be able to install YAMS. ⚠️

{{% /hint %}}

## Prerequisites
Before you get the script up and running, you have to do some thinking about how you want your system to operate. You'll need:

- **An installation location**: This is where the docker containers will store all their data. Config files, caching, you know it! *This is NOT where you shows are movies are stored.* The script defaults to /opt/yams but hey, you do you! Just make sure your user can write to wherever you choose.

- **A media folder**: This is where all your media will be stored. For example, if you pick /srv/media, the script will create:
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

- **A regular user to run and own the media files**: Don’t use root (I mean, I can’t stop you, but come on! 😅)

- **A VPN service (optional but STRONGLY recommended)**: First lesson! A VPN is a paid service that encrypts your server's traffic, and masks its public IP address whilst it's sailing the high seas. This hides your activity from cooperations such as your ISP or copyright providers. Although its not strictly necessary, be aware of the risks of choosing not to use one. Pick one from this list LINK HERE which YAMS officially supports.

## Pre-Installation Setup
#### 1. Setup your install location
The `/opt/yams` location is recommended and used throughout the guide, but you can use whatever you like if your user has permissions:
```
sudo mkdir -p /opt/yams
sudo chown -R $USER:$USER /opt/yams
```

#### 2. Setup your media directory
If your media directory doesn’t exist yet, you’ll need to create it and set the correct permissions. For example, if you’re using `/srv/media`:

```
sudo mkdir -p /srv/media
sudo chown -R $USER:$USER /srv/media
```

Important notes:
- Make sure your user has full read/write permissions to this directory
- If you’re using an external drive or NFS/SMB mount, mount it first, then set permissions
- The installer will create subdirectories (tvshows, movies, music, etc.) automatically
- Don’t use root as the owner, use your regular user account!


### 3. If you already have docker installed…
Make sure you can run docker without sudo! Try this:
`docker run hello-world`

If it fails, you might need to add your user to the docker group. Follow Docker’s [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user), and try the command again. Great!

Now let's get into the real installation.

---
## Installation

COMPLETE THIS SECTION IN NEW INSTALLATION TEST

{{% steps %}}
1. ## Install Script
   A simple bash setup script you run on your machine, handling all the initial complexity. It wrangles permissions, files structures and initial docker compose content in the background and surfaces a simple interface in your terminal.

2. ## Setup Guide
   A handwritten guide with step-by-step instructions (including screenshots!) on how to connect all the applications within your stack together. Don't worry if you don't know what they are yet, you'll learn more about each one as you go!

3. ## CLI Tool
   A bash CLI installed on your machine that simplifies the operation of your media server. Stop, start and backup your server with simple terminal commands.

4. ## Community
   A welcoming community across the YAMS forum and Discord, ready to help or chat!
{{% /steps %}}