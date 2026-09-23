---
weight: 30
title: Radarr
---

# What is Radarr?

Radarr is an application that controls behind-the-scenes processes related to **movies**. It will do many helpful things in our media server:
- Search for movies we have added across our indexers to find available torrents and Usenet files
- Rank these based information such as file size, quality, number of seeders, etc
- Send the best match to the downloader (qBitTorrent for torrents, SABnzbd for Usenet)
- After the download is done, hardlink the file into an organised folder on disk for our streaming application to read from

In short, Radarr is going to manage all our movies: find them, pick sort them, and keep everything organized on disk.

Check out their website [here](https://radarr.video/).

## Initial configuration

In your browser, go to [http://_USER_IP_:7878/](http://_USER_IP_:7878/).

- Select "Forms (Login Page)" as the "Authentication Method"
- Optionally, in "Authentication Required" select "Disabled for Local Addresses" (this means you won't need to login when you're at home - but neither will any other device on your network!)

Fill a username and password to use as your new personal account, then click on save:

{{< image src="/pics/radarr/radarr-1.png" alt="" title="" loading="auto" >}}

You'll see Radarr's empty page.

{{< image src="/pics/radarr/radarr-2.png" alt="" title="" loading="auto" >}}

### Media management

First things first  let's tell Radarr where to actually put our finished movies.
In the sidebar, click 'Settings' then 'Media Management' and scroll to the bottom. Click the button labelled 'Add Root Folder'.
{{< image src="/pics/radarr/radarr-3.png" alt="" title="" loading="auto" >}}

Now add the `/data/movies/` folder:

{{< image src="/pics/radarr/radarr-4.png" alt="" title="" loading="auto" >}}

> [!INFO]
> Remember, this isn't actually on your filesystem! The `/data/movies/` folder exists inside the docker environment and maps to your server's `_MEDIA_PATH_/movies/` folder. Check out [our quick guide](/docs/fundamentals/docker-and-compose/#volumes) if you are unsure what this means!

Easy peasy. Now, Radarr knows where to store and organise its movies.

### Download Clients

Time to connect Radarr to our download tools! This is where we'll link it up with [qBittorrent](/docs/configure/qbittorrent) and [SABnzbd](/docs/configure/sabnzbd) (if you use it).

#### qBittorrent Setup

In 'Settings', go to 'Download Clients' and click on the ➕ button.

{{< image src="/pics/radarr/radarr-5.png" alt="" title="" loading="auto" >}}

On the "Add Download Client" screen, scroll down and click on "qBittorrent".

{{< image src="/pics/radarr/radarr-6.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: qBittorrent (or whatever you want to call it!)
- Host: `gluetun` (since it is running masked *behind* the Gluetun VPN container)
- Port: 8081
- API Key: Your qBitTorrent API key [you generated earlier](/docs/configure/qbittorrent/#generating-an-api-key). It is probably in your `_INSTALL_PATH_/.env`, you could copy it over from there.
- All other settings can stay the same.

{{< image src="/pics/radarr/radarr-7.png" alt="" title="" loading="auto" >}}

Click that "Test" button at the bottom - if everything's good, you'll see a nice green checkmark! ✅
{{< image src="/pics/radarr/radarr-8.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/radarr/radarr-9.png" alt="" title="" loading="auto" >}}

If the test passed, click "Save". Your download client should now show up on the page:

{{< image src="/pics/radarr/radarr-10.png" alt="" title="" loading="auto" >}}

#### SABnzbd Setup

> [!INFO]
> If you are not using SABnzbd you can safely skip this section.

Back in "Download Clients", click that ➕ button again.

{{< image src="/pics/radarr/radarr-11.png" alt="" title="" loading="auto" >}}

This time, scroll down and pick "SABnzbd".

{{< image src="/pics/radarr/radarr-12.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: SABnzbd (or any name you like)
- Host: `gluetun` (since it is running masked *behind* the Gluetun VPN container)
- Port: 8080
- API Key: your SABnzbd API key from before
- All other settings can stay the same.

> Don't have your SABnzbd API key handy? No worries! You can find it here: [Getting your API key for Sonarr and Radarr](/docs/configure/sabnzbd/#getting-your-api-key-for-sonarr-and-radarr)

{{< image src="/pics/radarr/radarr-13.png" alt="" title="" loading="auto" >}}

Time for another test! Click that "Test" button - hopefully you'll see another green checkmark! ✅
{{< image src="/pics/radarr/radarr-8.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/radarr/radarr-9.png" alt="" title="" loading="auto" >}}

If the test worked, hit "Save". You should now see both download clients on the page:

{{< image src="/pics/radarr/radarr-14.png" alt="" title="" loading="auto" >}}

## Moving forward! 🚀

Looking good! Now we can continue with [Sonarr](/docs/configure/sonarr). It's essentially just repeating the same steps but for our TV show configuration instead 😵‍💫.
