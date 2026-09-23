---
weight: 40
title: Sonarr
---


# What is Sonarr?

Sonarr is an application that controls behind-the-scenes processes related to **TV shows**. It will do many helpful things in our media server:
- Search for TV shows we have added across our indexers to find available torrents and Usenet files
- Rank these based information such as file size, quality, number of seeders, etc
- Send the best match to the downloader (qBitTorrent for torrents, SABnzbd for Usenet)
- After the download is done, hardlink the file into an organised folder on disk for our streaming application to read from

In short, Sonarr is going to manage all our TV shows: find them, pick sort them, and keep everything organized on disk. Its functionality and interface is almost exactly like Radarr so this setup will be a breeze.

Check out their website [here](https://sonarr.tv/).

## Initial configuration

In your browser, go to [http://_USER_IP_:8989/](http://_USER_IP_:8989/). Just like with Radarr, we'll start with some basic security settings.

- Select "Forms (Login Page)" as the "Authentication Method"
- Optionally, in "Authentication Required" select "Disabled for Local Addresses" (this means you won't need to login when you're at home - but neither will any other device on your network!)

Create your username and password, then click save:

{{< image src="/pics/sonarr/sonarr-1.png" alt="" title="" loading="auto" >}}

You'll see Radarr's empty page.

{{< image src="/pics/sonarr/sonarr-2.png" alt="" title="" loading="auto" >}}


### Media management

Let's tell Sonarr how to handle our TV shows! Go to "Settings" and then "Media management". Here's what we need to do:
- Click on 'Settings' in the sidebar
- Click on 'Media Management'
- Click the button labelled 'Add Root Folder'.

{{< image src="/pics/sonarr/sonarr-3.png" alt="" title="" loading="auto" >}}

Add the `/data/tvshows/` folder:

{{< image src="/pics/sonarr/sonarr-4.png" alt="" title="" loading="auto" >}}

> [!INFO]
> Remember, this isn't actually on your filesystem! The `/data/tvshows/` folder exists inside the docker environment and maps to your server's `_MEDIA_PATH_/movies/` folder. Check out [our quick guide](/docs/fundamentals/docker-and-compose/#volumes) if you are unsure what this means!


#### qBittorrent Setup

In 'Settings', go to 'Download Clients' and click on the ➕ button.

{{< image src="/pics/sonarr/sonarr-5.png" alt="" title="" loading="auto" >}}

On the "Add Download Client" screen, scroll down and click on "qBittorrent".

{{< image src="/pics/sonarr/sonarr-6.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: qBittorrent (or whatever you want to call it!)
- Host: `gluetun` (since it is running masked *behind* the Gluetun VPN container)
- Port: 8081
- API Key: Your qBitTorrent API key [you generated earlier](/docs/configure/qbittorrent/#generating-an-api-key). It is probably in your `_INSTALL_PATH_/.env`, you could copy it over from there.
- All other settings can stay the same.

{{< image src="/pics/sonarr/sonarr-7.png" alt="" title="" loading="auto" >}}

Click that "Test" button at the bottom - if everything's good, you'll see a nice green checkmark! ✅
{{< image src="/pics/sonarr/sonarr-8.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-9.png" alt="" title="" loading="auto" >}}

If the test passed, click "Save". Your download client should now show up on the page:

{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}

#### SABnzbd Setup

> [!INFO]
> If you are not using SABnzbd you can safely skip this section.

Back in "Download Clients", click that ➕ button again.

{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

This time, scroll down and pick "SABnzbd".

{{< image src="/pics/sonarr/sonarr-12.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Name: SABnzbd (or any name you like)
- Host: `gluetun` (since it is running masked *behind* the Gluetun VPN container)
- Port: 8080
- API Key: your SABnzbd API key from before
- All other settings can stay the same.

> Don't have your SABnzbd API key handy? No worries! You can find it here: [Getting your API key for Sonarr and Radarr](/docs/configure/sabnzbd/#getting-your-api-key-for-sonarr-and-radarr)

{{< image src="/pics/sonarr/sonarr-13.png" alt="" title="" loading="auto" >}}

Time for another test! Click that "Test" button - hopefully you'll see another green checkmark! ✅
{{< image src="/pics/sonarr/sonarr-8.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-9.png" alt="" title="" loading="auto" >}}

If the test worked, hit "Save". You should now see both download clients on the page:

{{< image src="/pics/radarr/radarr-14.png" alt="" title="" loading="auto" >}}

## Moving forward!

Looking good! Now we can continue with [Lidarr](/docs/configure/sonarr). It's essentially just repeating the same thing *again* but for our music configuration instead 😵‍💫. Remember that Lidarr is an optional application that you may have disabled in the installer!
