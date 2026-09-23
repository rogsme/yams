---
weight: 50
title: Lidarr
---

# What is Lidarr?

Lidarr is an application that controls behind-the-scenes processes related to **music**. It will do many helpful things in our media server:
- Search for music we have added across our indexers to find available torrents and Usenet files
- Rank these based information such as file size, quality, number of seeders, etc
- Send the best match to the downloader (qBitTorrent for torrents, SABnzbd for Usenet)
- After the download is done, hardlink the file into an organised folder on disk for our streaming application to read from

In short, Lidarr is going to manage all our movies: find them, pick sort them, and keep everything organized on disk.

Check out their website [here](https://lidarr.audio/).


## Initial configuration

In your browser, go to [http://{your-ip-address}:8686/]() and you'll see Lidarr's empty page. You'll also notice you have 3 messages on the system tab, but we'll deal with them later.

{{< image src="/pics/lidarr/lidarr-1.png" alt="" title="" loading="auto" >}}

### Media management

First, go to "Settings" and then "Media management". On this screen, click on the big ➕ sign.

{{< image src="/pics/lidarr/lidarr-2.png" alt="" title="" loading="auto" >}}

On the "Add root folder" modal, add the following information:

- On "Name", set it to "Music"
- On "Path", set it to "/music/"

Finally, click on "Save".

{{< image src="/pics/lidarr/lidarr-3.png" alt="" title="" loading="auto" >}}

You should see your new "Music" root folder.

{{< image src="/pics/lidarr/lidarr-4.png" alt="" title="" loading="auto" >}}

### Download Clients

Here, you'll add the download clients for Lidarr. That's where you'll tie in Lidarr with [qBittorrent](/docs/configure/qbittorrent).

In "Settings", go to "Download Clients" and click on the ➕ button.

{{< image src="/pics/lidarr/lidarr-5.png" alt="" title="" loading="auto" >}}

On the "Add Download Client" screen, scroll down and click on "qBittorrent".

{{< image src="/pics/lidarr/lidarr-6.png" alt="" title="" loading="auto" >}}

- In Name, add the name of your download client (qBittorrent).
- On Host, add your server IP address (in my case, `192.168.0.169`).
- On Username, add `admin`.
- On Password, add `adminadmin`.

{{< image src="/pics/lidarr/lidarr-7.png" alt="" title="" loading="auto" >}}

At the bottom, you can click on "Test" and if everything is OK you should see a ✅
{{< image src="/pics/radarr/radarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/radarr/radarr-11.png" alt="" title="" loading="auto" >}}

If everything is fine, click on "Save". You should see your download client added to the "Download Clients" page now!

{{< image src="/pics/lidarr/lidarr-8.png" alt="" title="" loading="auto" >}}

### Prowlarr config

First, you are going to need your Lidarr API Key.

You can get your Lidarr API Key in Lidarr. Go to [http://{your-ip-address}:8686/settings/general]() to open Lidarr's settings, and you'll find the API Key under the "Security" section.

{{< image src="/pics/lidarr/lidarr-11.png" alt="" title="" loading="auto" >}}

For now, just copy it and keep it in a safe location.

In "Settings", go to "Apps" and click on the ➕ button.

{{< image src="/pics/lidarr/lidarr-9.png" alt="" title="" loading="auto" >}}

On the "Add Application" modal, click on "Lidarr"

{{< image src="/pics/lidarr/lidarr-10.png" alt="" title="" loading="auto" >}}

- In "Prowlarr Server", add `http://prowlarr:9696`
- In "Lidarr Server", add `http://lidarr:8686`
- In "ApiKey", add your Lidarr API key.

{{< image src="/pics/lidarr/lidarr-12.png" alt="" title="" loading="auto" >}}

At the bottom, you can click on "Test" and if everything is OK you should see a ✅
{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

To finish, click on "Save". You should see Lidarr added to the "Apps" list!

{{< image src="/pics/lidarr/lidarr-13.png" alt="" title="" loading="auto" >}}

**Remeber to add Music indexers!**. You won't be able to download if you don't add Music indexers in Prowlarr. To add indexers, go to [Prowlarr's Indexer configuration](/docs/configure/prowlarr/#indexers).

## Usage

Back in Lidarr, go to "Library/Add New" and search for a band. Select it to add it to Lidarr.

{{< image src="/pics/lidarr/lidarr-14.png" alt="" title="" loading="auto" >}}

On the "Add new Artist" modal, select the Quality Profile, click on "Start search for missing albums" anf finally, click on "Add".

{{< image src="/pics/lidarr/lidarr-15.png" alt="" title="" loading="auto" >}}

And that should be it! You should see your band added and it will start downloading soon.

{{< image src="/pics/lidarr/lidarr-16.png" alt="" title="" loading="auto" >}}