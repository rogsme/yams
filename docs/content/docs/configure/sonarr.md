---
weight: 40
title: Sonarr
---


# What is Sonarr?

From their [wiki](https://wiki.servarr.com/sonarr):

> Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

In YAMS, Sonarr is your TV show manager - it's going to handle everything from downloads to organizing your episodes. Think of it as your personal TV assistant! 📺

## Initial configuration

In your browser, go to [http://{your-ip-address}:8989/](). Just like with Radarr, we'll start with some basic security settings.

- Select "Forms (Login Page)" as the "Authentication Method"
- In "Authentication Required" select "Disabled for Local Addresses" (so you can browse freely on your home network)

Create your username and password, then click save:

{{< image src="/pics/sonarr/sonarr-18.png" alt="" title="" loading="auto" >}}

You'll see Sonarr's empty page. Don't mind those 3 system messages - we'll get to them later!

{{< image src="/pics/sonarr/sonarr-1.png" alt="" title="" loading="auto" >}}

### Media management

Let's tell Sonarr how to handle our TV shows! Go to "Settings" and then "Media management". Here's what we need to do:
- Click on "Show Advanced" (it sounds scary but we'll keep it simple!)
- Check the "Rename Episodes" box
- Set up these naming formats:
  - "Standard Episode Format": `{Series Title} - S{season:00}E{episode:00} - {Episode Title}`
  - "Daily Episode Format": `{Series Title} - {Air-Date} - {Episode Title}`
  - "Anime Episode Format": `{Series Title} - S{season:00}E{episode:00} - {Episode Title}`
  - "Series Folder Format": `{Series TitleYear}`

{{< image src="/pics/sonarr/sonarr-2.png" alt="" title="" loading="auto" >}}

Scroll down to "Root Folders" and click on "Add Root Folder".

{{< image src="/pics/sonarr/sonarr-3.png" alt="" title="" loading="auto" >}}

Add the `/data/tvshows/` folder:

{{< image src="/pics/sonarr/sonarr-4.png" alt="" title="" loading="auto" >}}

**Note:** Just like with Radarr, this path is inside the docker environment - it maps to your server's `/mediafolder/media/tvshows/` folder. Docker magic at work! ✨

Finally, click on "Save Changes".

{{< image src="/pics/sonarr/sonarr-5.png" alt="" title="" loading="auto" >}}

### Download Clients

Time to connect Sonarr to our download tools! We'll link up with [qBittorrent](/docs/configure/qbittorrent) and [SABnzbd](/docs/configure/sabnzbd).

#### qBittorrent Setup

In "Settings", go to "Download Clients" and click on the ➕ button.

{{< image src="/pics/sonarr/sonarr-13.png" alt="" title="" loading="auto" >}}

Find and click on "qBittorrent" in the list.

{{< image src="/pics/sonarr/sonarr-14.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: qBittorrent (or whatever clever name you come up with!)
- Host: your server IP address (like `192.168.0.190`)
- Port: 8081
- Username: `admin`
- Password: your qBittorrent password

{{< image src="/pics/sonarr/sonarr-15.png" alt="" title="" loading="auto" >}}

Hit that "Test" button - if everything's working, you'll see a happy green checkmark! ✅
{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

All good? Click "Save". Your download client should now appear on the page:

{{< image src="/pics/sonarr/sonarr-16.png" alt="" title="" loading="auto" >}}

#### SABnzbd Setup

Back in "Download Clients", click that ➕ button again.

{{< image src="/pics/sonarr/sonarr-13.png" alt="" title="" loading="auto" >}}

This time, let's find and click on "SABnzbd".

{{< image src="/pics/sonarr/sonarr-19.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: SABnzbd (or something fun)
- Host: your server IP address (like `192.168.0.190`)
- Port: 8080
- API Key: your SABnzbd API key

Need to find your SABnzbd API key? No problem! Check here: [Getting your API key for Sonarr and Radarr](/docs/configure/sabnzbd/#getting-your-api-key-for-sonarr-and-radarr)

{{< image src="/pics/sonarr/sonarr-20.png" alt="" title="" loading="auto" >}}

Another test time! Click "Test" - hopefully another green checkmark! ✅
{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

If the test passed, hit "Save". You should now see both download clients ready to go:

{{< image src="/pics/sonarr/sonarr-21.png" alt="" title="" loading="auto" >}}

## Moving forward! 🚀

That's it! Now we can move on to [Prowlarr](/docs/configure/prowlarr). We're getting close to having your own personal streaming service!

## Want to become a Sonarr power user?

If you want to really dive into what Sonarr can do, check out the [TRaSH Guide for Sonarr](https://trash-guides.info/Sonarr/). They've got some amazing advanced tips and tricks! 🔧