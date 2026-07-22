---
weight: 4
title: File Structure and Hardlinking
---

# File Structure and Hardlinking

YAMS mounts folders from your local filesystem into the Docker containers for them to store data on. It has two main locations that you will have to declare in the installation script. You can see these values in your `.env` file:

```{filename="[[install_path]]/.env"}
MEDIA_DIRECTORY=[[media_path]]
INSTALL_DIRECTORY=[[install_path]]
```

### Media Directory

*The default media directory is `/srv/media`, you have configured the guide to use [[media_path]].*

The media directory is the main storage directory for your Docker containers. It is used by your downloaders (qBitTorrent, sabnzbd) to store torrents, and by Radarr/Sonarr to organise these media files into a nice folder structure Jellyfin then reads. Your media folder will look like this:
```text
/srv/media/
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

Media files can take up a lot of space, especially if you have a lot of them! However, YAMS provides a filesystem setup that allows Radarr and Sonarr to use something called **hardlinking** to prevent unnecessary storage usage.

#### What is a Hardlink?

When you download a torrent, the file is downloaded into your YAMS torrent folder. Without hardlinking, when Radarr/Sonarr import this file, it would **copy** it to your server's media directory - meaning you'd have two copies taking up double the storage space.

A **hardlink** is different, and it's purpose is in the name: 'link'. Instead of copying the file, it creates a second reference to the same data on your disk. Think of there being two 'links' on your disk, **one in your torrents folder** and **one in your Radarr/Sonarr-managed folder**, both pointing to the same data on disk.

This allows the file to essentially exist in two places in your media server, all whilst only taking up the storage space of one copy.

> [!INFO]
> A cool fact is that none of these links have 'ownership' over the data! One hardlink **isn't** the *true* file and the other just a link. Both of these hardlinks are equal references to the data on the physical disk, and the data is only deleted once both of these references are gone. If you delete a file from your Radarr folder, it will still exist in qBitTorrent's folder!

---

### Install Directory

*The default install directory is `/opt/yams`, you have configured the guide to use [[install_path]].*

This is the top-level YAMS directory where the `.env` file and Docker Compose files live.

Also in this directory is the `config` folder, which contains named configuration folders mounted into each of the Docker containers. This is where all your container data is stored, such as Radarr's database (inside `[[install_path]]/config/radarr`), qBitTorrent's settings (in `[[install_path]]/config/qbittorrent`), and Jellyfin's metadata (in `[[install_path]]/config/jellyfin`).

> [!WARNING]
> It is important to back this folder up, as it contains all your settings and data for your YAMS containers. If you ever need to restore your YAMS setup, this is the folder you will need to restore from backup. Check out our [Backing up YAMS](/docs/advanced/backups/) guide for more information on how to do this.





