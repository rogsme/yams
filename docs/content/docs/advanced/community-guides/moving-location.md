---
weight: 10
title: Moving YAMS Directories
---

# Moving YAMS

There are many situations where you might want to either relocate your media or your docker compose and service files. You might have just upgraded to a new hard drive, or maybe you simply are improving your server!

### Changing Installation Location

*This guide currently has your installation saved as [[install_path]]. If you change your YAMS setup, remember to edit this value by clicking on it!*


##### 1. Stop all services
If we are conducting some major restructuring, we want to make sure nothing breaks. Open your terminal and stop YAMS gracefully:

```bash
yams stop

```

##### 2. Move the YAMS directory

Use the `mv` command to move your entire YAMS installation folder to its new location. For example, to move it to a new location at `/new/path/yams`:

> [!WARNING]
> This command has been automatically filled with your configured install path. Verify this is right before taking any action!

```bash
sudo mv [[install_path]] /new/path/yams

```

##### 3. Update the YAMS CLI

The `yams` command-line tool (usually located at `/usr/local/bin/yams`) has your original installation path hardcoded into it. You'll need to update this script so it knows where to look for your docker-compose files.

Open the file in a text editor (like nano):

```bash
sudo nano /usr/local/bin/yams

```

Find the line that has the install path (usually `INSTALL_DIR="[[install_path]]"`) and change it to your new directory:

```bash
INSTALL_DIR="/new/path/yams"

```

Save and exit.

##### 4. Verify and restart

Navigate to your new directory to make sure everything looks correct, then start YAMS back up!

```bash
yams start

```

---

### Changing Media Location

Moving your media (movies, tv shows, downloads) is often required when you upgrade to a larger hard drive or NAS setup. Because YAMS uses a centralized `.env` file to mount volumes to your Docker containers, this process is surprisingly simple.

##### 1. Stop all services

Just like moving the installation, ensure nothing is actively reading or writing to your media folders:

```bash
yams stop

```

##### 2. Move your media files

Move your existing media folder to your new drive or location. Make sure you are moving the parent folder that contains your `movies`, `tvshows`, and `downloads` folders.

```bash
sudo mv /old/media/path /new/media/path

```

*Note: Make sure your current user still has read/write permissions for the new media folder! (`sudo chown -R $USER:$USER /new/media/path`)*

##### 3. Update your YAMS `.env` file

YAMS relies on the `.env` file located inside your installation directory to know where your media lives.

Open the `.env` file:

```bash
nano [[install_path]]/.env

```

Look for the `MEDIA_DIRECTORY` variable and update it to your new path:

```text
MEDIA_DIRECTORY=/new/media/path

```

Save and exit the file.

##### 4. Restart YAMS

Because Docker maps this path dynamically, your containers (like Radarr, Sonarr, and Plex/Jellyfin) will still see the files in the exact same internal locations (e.g., `/data` or `/media`).

Start your services back up:

```bash
yams start

```

You don't need to change any root folder paths inside the *arr applications themselves!

```

```

---
*Thanks to `faker` on Discord for contributing to this guide!*