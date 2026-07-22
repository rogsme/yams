---
weight: 4
title: Seeding with Qui
---

# Seeding with Qui

In general, it is good practice to seed any torrents you download. Seeding is the act of sharing a media file you have downloaded with other users, helping with their downloads.

Many private trackers also require maintenance of a 'ratio'. This ratio is calculating by the amount seeded over the amount downloaded, and must be maintained above a limit to ensure you are contributing to a tracker community.

Within a default YAMS setup, [seeding is not enabled](https://yams.media/docs/configure/qbittorrent/#is-this-a-dick-move) once you have downloaded the file. However, if you already have the file downloaded you might as well seed it to others, right?

This is a guide on how to automate a flexible seeding setup within your media server:
- Once movies and shows are downloaded, they will be automatically seeded whilst the media remains within your server
- When media is watched from your streaming platform, it is deleted from within Radarr and Sonarr
- These now 'loose' torrents are ensured to meet any minimum seeding requirements for your tracker, and then seamlessly deleted, freeing up your storage space!

Note that if previously have a cross seeding setup, this guide should not be followed word for word. Extra manipulation of the provided workflows may be necessary.

But what is meant by a 'loose' torrent? Let's explore the concept of hardlinking.

# Hardlinking 🔗

Hardlinking is enabled in YAMS by default, **and required for this guide to work, with no exceptions.** To verify if hardlinking is enabled in your setup, ensure "Use Hardlinks instead of Copy" is enabled in Radarr's *Settings > Media Management (Show Advanced settings at the top left of the page) > Importing.*

## What is a Hardlink?

Check out the explanation of a hardlink [here](../../fundamentals/file-structure#what-is-a-hardlink).

## Why is this helpful?

With hardlinks enabled:
- qBitTorrent can continue seeding the torrent from the downloads folder
- Jellyfin/Emby/Plex can stream the same file from the library folder

Not only this, each 'link' has equal ownership over the data on disk. This means that data will persist on the disk until ALL references to it are deleted, regardless of their order of creation.

In this guide, the deletion flow will be setup like this:
- After download, each media file should have 2 hardlinks. One for qBitTorrent (the original one!), and one for Radarr/Sonarr.
- qBitTorrent's hardlink will be seeded indefinitely.
- After watching the media in Jellyfin/Plex, it will be deleted.
- Qui will detect the torrent file has no hardlink (only 1 reference to the file exits), and remove the torrent from qBitTorrent.


This allows maximum seeding whilst the media remains within your setup, but as soon as you are done watching, it cleans right up!

Lets get started into actually creating this setup.

# Creating the Stack

## Using a Deletion Tool
To set up this stack, a deletion tool should be used. This refers to any tool that deletes unwanted media from your Jellyfin/Plex libray.

You can use the Jellyfin plugin [Media Cleaner](https://github.com/shemanaev/jellyfin-plugin-media-cleaner) which deletes watched movies/shows in Jellyfin after a specified amount of time. If you are using Jellyfin, this is a good option that doesn't require running a seperate container.

If you wish to use another service, maybe to delete unwatched media too, please do. Do some research on the many Plex and Jellyfin tools available to clean up your libraries. Any tools that delete media will work, as long as they *don't mess with your torrents*.

## Setting up Qui 🛠️
[Qui](https://getqui.com/) is an extremely handy web UI for qBitTorrent, but it also has powerful automation features. We will be using its automation features to monitor our torrents, and delete them when they are no longer needed.

Be sure to refer to Qui's [documentation](https://getqui.com/docs/getting-started/installation) if you want to explore further!

### Docker Compose Entry

Add the following entry in your `docker-compose.custom.yml` file, below the `services:` parent item.
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

Then, run `yams start qui` in your terminal to get it up and running! Access the web UI at `http://your-server-ip:7476`.

---

## Connecting Qui to qBitTorrent 🔗

First, open up the Qui web UI, and create an new account. Make sure to save your login details!

> Now, before we get started, lets make qBitTorrent allow connections from Qui by ***optionally*** bypassing authentication within the YAMS network. Jump over the this section from the [YAMS docs](/docs/configure/qbittorrent/#configuring-web-ui-settings) and ensure *in addition* to your local IP, you also add a new line with the YAMS subnet: `172.60.0.0/24`. Make sure to save, and then say goodbye to the qBitTorrent web UI - you might not need it again!

> This bypass is safe only because qBitTorrent is running in your home server and not directly exposed to the internet. Do not use this if you expose qBitTorrent's port externally. If you do, simply use your qBitTorrent username and password when connecting Qui to qBitTorrent in the next steps.

You should see a 'Dashboard' page. From here, click on the 'Add Instance' button in the center.

Enter the following details:
- A name for the instance, e.g. 'Server'
- Your qBitTorrent URL. If you are running qBitTorrent behind your vpn, its URL will be `http://gluetun:8081`. Otherwise, it will be `http://qbittorrent:8081`.
- Turn on 'Local Filesystem Access' - this is required for hardlink detection to work.
- If you added the YAMS subnet to qBitTorrent's web UI settings, you can turn off authentication by toggling 'Bypass Authentication'. If not, enter your qBitTorrent username and password.

{{< image src="/pics/qui/qui-1.png" alt="" title="" loading="auto" >}}

Then, hit 'Add Instance'! In the sidebar, you should now see your qBitTorrent instance listed. Click on it to connect, and you should see your torrents load up.

This is your main Qui interface, equivalent to the qBitTorrent web UI. Save this URL for later if you ever want quick access!

## Disabling Auto Remove in Radarr/Sonarr

Radarr and Sonarr both have built in features that can automatically remove stopped torrents they have imported. We DO NOT want this enabled, as it will unexpectedly and silently interfere with any workflows we may create.

{{< image src="/pics/qui/qui-8.png" alt="" title="" loading="auto" >}}

Navigate to Radarr and Sonarr's settings > 'Download Clients' section > qBitTorrent > ensure the 'Remove Completed' checkbox at the bottom is disabled. Do this in both Radarr and Sonarr.


## Setting up Automations ⚙️

Now, navigate to the 'Automations' tab in the sidebar.

{{< image src="/pics/qui/qui-2.png" alt="" title="" loading="auto" >}}

### Understanding the Workflow Builder

Workflows in Qui have three main sections:
- **Trackers**: What trackers' torrents the automation will apply to. This is useful if you want to only apply this seeding setup to certain trackers, e.g. only private ones.
- **Conditions**: What conditions must be met for the action to be taken. It acts as a filter, ensuring the action is only taken on torrents that meet certain criteria, e.g. only movies, or only files without any hardlinks.
- **Actions**: What actions to perform when the conditions are met. This action is taken on every torrent that matches the conditions, e.g. tag the torrent with a specific tag.

Finally, for each workflow you specify how often you want it to run. This is how often Qui will check your torrents for matches to the workflow, and perform the specified action on them.

### Creating a Workflow

In order to create our seeding setup, we will have to split our wanted automation into 5 separated workflows. This makes it easier to determine which part of the workflow is not working if something goes wrong, and also allows for more flexibility in the future if you want to change part of the workflow.

Tags will be used to link the workflows together and provide visual cues if you ever want to manually debug, so make sure to use unique tags that aren't used by any other workflow!

The workflows we will create are as follows:
1. A workflow to tag non-hardlinked torrents with a `noHL` tag.
2. A workflow to apply seeding requirements (through qBitTorrent 'limits') to `noHL` tagged torrents.
3. A workflow to tag finished torrents with `readyToDelete` once they have met their seeding requirements and been stopped.
4. A workflow to delete torrents tagged with `readyToDelete`.

Lets say a torrent is downloaded from a private tracker with a 7 day seeding requirement, and is deleted from the media library after 3 days. The workflow will work like this:
- The torrent is tagged with `noHL` as it has no hardlink (the media file only has 1 reference on disk, the one in the downloads folder).
- The torrent will have a 7-day seeding limit applied to it. It will be tagged with `seedingRequired` until it has seeded for 7 days.
- After seeding for 7 days, the torrent will be tagged with `readyToDelete`, and stopped. Then, it will be deleted.

It can be smart to set a seeding limit slightly longer than the actual seeding requirement, to account for any small discrepancies in time tracking. For example, if the seeding requirement is 7 days, set the limit to 8 days.

#### Workflow 1: Tagging non-hardlinked torrents

 > Optional manual import link [here](https://gist.githubusercontent.com/not-first/874d6186a77b9057fe290ee2a1884817/raw/d796a3133880c155ad9b56b676624a86f5a9dd69/tag-noHL.json).

{{< image src="/pics/qui/qui-3.png" alt="" title="" loading="auto" >}}

Create a new rule, and name the workflow 'Tag noHL Torrents'.

Add a condition that uses regex to only apply to the `radarr` and `sonarr` categories (`^(radarr|sonarr)$`). This ensures that this workflow only applies to media torrents, and not any other torrents you might have in your setup.

Add a second condition that checks if the hardlink scope is 'None'.

Add a third condition that checks the state is 'Completed', to ensure only fully downloaded torrents are tagged.

Finally, add an action to tag the torrent with `noHL`, and save.


#### Workflow 2: Applying seeding requirements

 > Optional manual import link [here](https://gist.githubusercontent.com/not-first/874d6186a77b9057fe290ee2a1884817/raw/86e1360be2fd5d5a2e40014e8ff4c27a91b15715/enforce-requirements-EXAMPLE.json).

{{< image src="/pics/qui/qui-4.png" alt="" title="" loading="auto" >}}

Create a new rule, and name the workflow 'Enforce Seeding Requirements (TRACKER NAME)'. This is the workflow that will enforce seeding requirements for torrents from a specific tracker, so make sure to specify the tracker in the name.

In the trackers section, select the tracker(s) this workflow will apply to. This ensures that only torrents from this tracker will have seeding requirements applied to them.

Add a condition that checks if the torrent is tagged with `noHL`, using the tags contains operator.
Add another condition that checks if the torrent's seeding time is less than the seeding requirement for the tracker.

Add an action to set a seeding time or ratio limit on the torrent. This is done by selecting 'Set Limit' as the action type, and then setting the seeding time limit to match the seeding requirements of your tracker, e.g 7 days (make sure to enter it in minutes!). Save the workflow, and repeat this process for each tracker you download from with different seeding requirements.

Finally, add an action to tag the torrent with `seedingRequired`, and save.

It can be a good idea to enter in a value slightly more than the actual seeding requirement, to account for any small discrepancies in time tracking.

One of these should be added for each tracker you download from with different seeding requirements.

#### Workflow 3: Tagging ready-to-delete torrents

> Optional manual import link [here](https://gist.githubusercontent.com/not-first/874d6186a77b9057fe290ee2a1884817/raw/d54a84d62a7271e2b85fca536df3eec0c22c920a/tag-ready-to-delete.json).

{{< image src="/pics/qui/qui-6.png" alt="" title="" loading="auto" >}}

Create a new rule, apply it to all trackers, and name the workflow 'Tag Ready to Delete'.

Add a condition that checks if the torrent is not tagged with `seedingRequired`, and another condition that checks if the torrent is tagged with `noHL`, using the tags contains operator.
Add a third condition that checks if the torrent's state is 'Stopped', to ensure only torrents that have met their seeding requirements, and thus been stopped by qBitTorrent, are tagged.

Add an action to tag the torrent with `toBeDeleted`, and save.

#### Workflow 5: Deleting retired torrents after 7 days

> Optional manual import link [here](https://gist.githubusercontent.com/not-first/874d6186a77b9057fe290ee2a1884817/raw/4183b34922eca4009f772e8d9d0a377e0ea3cc02/delete-torrents.json).

{{< image src="/pics/qui/qui-7.png" alt="" title="" loading="auto" >}}

Create a new rule, apply it to all trackers, and name the workflow 'Delete Torrents'.

Add a condition that checks if the torrent is tagged with `toBeDeleted`, using the tags contains operator.

Add an action to delete the torrent with files (preserve cross-seeds), and save.

---

And that's it! You now have a fully automated seeding setup that ensures you are always seeding your media files until you are done with them, at which point they are seamlessly removed from your server after meeting any seeding requirements.

The state of all of your torrents can be easily monitored through the tags applied to them, and you can easily adjust any part of the workflow in Qui's interface if you want to change how it works in the future. In addition, Qui's automation menu has a log of all automation actions taken, so if you ever want to check what's happening to your torrents, you can easily check the log to see what actions have been taken on them and why.

What's more, the new Qui app can fully replace qBitTorrent's web UI, so you can manage your torrents from there going forward if you like the interface!

Be sure to keep checking in on your system every so often to ensure it is working as expected!

---

*Thanks to Faker on Discord for contributing to this guide!*