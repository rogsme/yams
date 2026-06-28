---
weight: 3
title: Radarr
---


# What is Radarr?

From their [wiki](https://wiki.servarr.com/radarr):

> Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.

In YAMS, Radarr is going to manage all our movies: download them, sort them, and keep everything organized. It's like having your own personal movie butler! 🎬

## Initial configuration

In your browser, go to [http://{your-ip-address}:7878/](). First up, we need to set up some basic security.

- Select "Forms (Login Page)" as the "Authentication Method"
- In "Authentication Required" select "Disabled for Local Addresses" (this way you won't need to login when you're at home)

Fill in your username and password, then click on save:

{{< image src="/pics/radarr/radarr-18.png" alt="" title="" loading="auto" >}}

You'll see Radarr's empty page. Don't worry about those 3 messages in the system tab - we'll deal with them soon!

{{< image src="/pics/radarr/radarr-1.png" alt="" title="" loading="auto" >}}

### Media management

First things first - let's tell Radarr how to handle our movies. Go to "Settings" and then "Media management". On this screen:
- Click on "Show Advanced" (don't worry, we'll keep it simple!)
- Check the "Rename Movies" box
- Change "Standard Movie Format" to `{Movie Title} ({Release Year})`

{{< image src="/pics/radarr/radarr-2.png" alt="" title="" loading="auto" >}}

At the bottom of the same screen, go to "Root folders" and click on "Add Root Folder".

{{< image src="/pics/radarr/radarr-3.png" alt="" title="" loading="auto" >}}

Now add the `/data/movies/` folder:

{{< image src="/pics/radarr/radarr-4.png" alt="" title="" loading="auto" >}}

**Note:** This isn't actually on your filesystem! The `/data/movies/` folder exists inside the docker environment and maps to your server's `/mediafolder/media/movies/` folder. Magic! ✨

Finally, click on "Save Changes".

{{< image src="/pics/radarr/radarr-5.png" alt="" title="" loading="auto" >}}

### Download Clients

Time to connect Radarr to our download tools! This is where we'll link up with [qBittorrent](/docs/configure/qbittorrent) and [SABnzbd](/docs/configure/sabnzbd).

#### qBittorrent Setup

In "Settings", go to "Download Clients" and click on the ➕ button.

{{< image src="/pics/radarr/radarr-13.png" alt="" title="" loading="auto" >}}

On the "Add Download Client" screen, scroll down and click on "qBittorrent".

{{< image src="/pics/radarr/radarr-14.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: qBittorrent (or whatever you want to call it!)
- Host: your server IP address (like `192.168.0.190`)
- Port: 8081
- Username: `admin`
- Password: your qBittorrent password

{{< image src="/pics/radarr/radarr-15.png" alt="" title="" loading="auto" >}}

Click that "Test" button at the bottom - if everything's good, you'll see a nice green checkmark! ✅
{{< image src="/pics/radarr/radarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/radarr/radarr-11.png" alt="" title="" loading="auto" >}}

If the test passed, click "Save". Your download client should now show up on the page:

{{< image src="/pics/radarr/radarr-16.png" alt="" title="" loading="auto" >}}

#### SABnzbd Setup

Back in "Download Clients", click that ➕ button again.

{{< image src="/pics/radarr/radarr-13.png" alt="" title="" loading="auto" >}}

This time, scroll down and pick "SABnzbd".

{{< image src="/pics/radarr/radarr-19.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: SABnzbd (or any name you like)
- Host: your server IP address (like `192.168.0.190`)
- Port: 8080
- API Key: your SABnzbd API key

Don't have your SABnzbd API key handy? No worries! You can find it here: [Getting your API key for Sonarr and Radarr](/docs/configure/sabnzbd/#getting-your-api-key-for-sonarr-and-radarr)

{{< image src="/pics/radarr/radarr-20.png" alt="" title="" loading="auto" >}}

Time for another test! Click that "Test" button - hopefully you'll see another green checkmark! ✅
{{< image src="/pics/radarr/radarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/radarr/radarr-11.png" alt="" title="" loading="auto" >}}

If the test worked, hit "Save". You should now see both download clients on the page:

{{< image src="/pics/radarr/radarr-21.png" alt="" title="" loading="auto" >}}

## Moving forward! 🚀

Looking good! Now we can continue with [Sonarr](/docs/configure/sonarr). We're getting closer to having your own personal Netflix!

## Want to get really fancy?

If you want to dive deeper into Radarr's configuration, I highly recommend checking out the [TRaSH Guide for Radarr](https://trash-guides.info/Radarr/). They've got some really cool advanced settings in there! 🔧
