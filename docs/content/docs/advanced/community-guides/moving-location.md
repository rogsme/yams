---
weight: 10
title: Moving YAMS
---

# Moving YAMS

> [!DANGER]
> VERY IMPORTANT! Back up your YAMS installation before attempting to move anything! See [Backing up YAMS](/docs/advanced/backups). If anything goes wrong during moving, you do NOT want to be left with a segmented non-operational server. 😬

### Changing Installation Location

There are many situations where you might want to either relocate your media or your docker compose and service files. You might have just upgraded to a new hard drive, or maybe you simply are improving your server!

*This guide currently has your installation saved as [[install_path]]. If you change your YAMS setup, remember to edit this value by clicking on it!*


#### 1. Stop all services
If we are conducting some major restructuring, we want to make sure nothing breaks. Open your terminal and stop YAMS gracefully:

```bash
yams stop

```

#### 2. Move the YAMS directory

Use the `mv` command to move your entire YAMS installation folder to its new location. For example, to move it to a new location at `/new/path/yams`:

> [!WARNING]
> This command has been automatically filled with your currently configured install path. Verify this is right before taking any action!

```bash
sudo mv [[install_path]] /new/path/yams
```

> [!INFO]
> **Update the guide now to your new path so future commands will be correct!! Click on this value: [[install_path]]**

#### 3. Update your YAMS `.env` file

Open the **new** `.env` file:

```bash
nano [[install_path]]/.env
```

Look for the `MEDIA_DIRECTORY` variable and update it to your **new** path:

```text
MEDIA_DIRECTORY=[[install_path]]
```

Save and exit the file.


#### 4. Update the YAMS CLI

The `yams` command-line tool (usually located at `/usr/local/bin/yams`) has your original installation path hardcoded into it. You'll need to update this script so it knows where to look for your docker-compose files.

Open the file in a text editor (like nano):

```bash
sudo nano /usr/local/bin/yams

```

Find the line that has the install path (`INSTALL_DIR="/your/old/path"`) and change it to your **new** directory:

```bash
INSTALL_DIR="[[install_path]]"

```

Save and exit.

#### 5. Verify and restart

Navigate to your new directory to make sure everything looks correct, then start YAMS back up!

```bash
yams start

```

---

### Changing Media Location

Moving your media (movies, tv shows, downloads) is often required when you upgrade to a larger hard drive or NAS setup. Because YAMS uses a centralized `.env` file to mount volumes to your Docker containers, this process is surprisingly simple.

*This guide currently has your media path saved as [[media_path]]. If you change your YAMS setup, remember to edit this value by clicking on it!*


#### 1. Stop all services

Just like moving the installation, ensure nothing is actively reading or writing to your media folders:

```bash
yams stop

```

#### 2. Move your media files

Move your existing media folder to your new drive or location. Make sure you are moving the parent folder that contains your `movies`, `tvshows`, and `downloads` folders.

> [!WARNING]
> This command has been automatically filled with your currently configured install path. Verify this is right before taking any action!

```bash
sudo mv [[media_path]] /new/media/path
```

*Note: Make sure your current user still has read/write permissions for the new media folder! (`sudo chown -R $USER:$USER /new/media/path`)*

> [!INFO]
> **Update the guide now to your new path so future commands will be correct!! Click on this value: [[install_path]]**

#### 3. Update your YAMS `.env` file

YAMS relies on the `.env` file located inside your installation directory to know where your media lives.

Open the **new** `.env` file:

```bash
nano [[install_path]]/.env

```

Look for the `MEDIA_DIRECTORY` variable and update it to your **new** path:

```text
MEDIA_DIRECTORY=[[media_path]]

```

Save and exit the file.

#### 4. Restart YAMS

Because Docker maps this path dynamically, your containers (like Radarr, Sonarr, and Plex/Jellyfin) will still see the files in the exact same internal locations (e.g., `/data` or `/media`). Check out the [Docker Fundamentals](/docs/fundamentals/docker-and-compose/#volumes) guide if you want to learn some more!

Start your services back up:

```bash
yams start

```

And thats it!

---
*Thanks to `faker` on Discord for contributing to this guide!*