---
weight: 60
title: Prowlarr
---


## What is Prowlarr?

From their [Github repo](https://github.com/Prowlarr/Prowlarr/):

> Prowlarr is an indexer manager/proxy built on the popular *arr .net/reactjs base stack to integrate with your various PVR apps. Prowlarr supports management of both Torrent Trackers and Usenet Indexers. It integrates seamlessly with Lidarr, Mylar3, Radarr, and Sonarr offering complete management of your indexers with no per app Indexer setup required (we do it all).

So basically, we're going to use Prowlarr to **search for torrents**, and then it will pass those on to [qBittorrent](/docs/configure/qbittorrent) or [SABnzbd](/docs/configure/sabnzbd) to download. Think of it as your personal search engine! 🔍

## Initial configuration

In your browser, go to [http://{your-ip-address}:9696/]() and you'll see the "Authentication required" screen. Let's set up some basic security:
- Select "Forms (Login Page)" as the "Authentication Method"
- In "Authentication Required" select "Disabled for Local Addresses" (so you can browse freely on your home network)

{{< image src="/pics/prowlarr/prowlarr-1.png" alt="" title="" loading="auto" >}}

### Understanding Indexers

Before we dive in, let's talk about the two types of indexers you can use with Prowlarr:

#### Usenet Indexers 📰
Most good Usenet indexers are paid services, but they're usually pretty affordable and worth checking out! A couple of popular ones are:
- [DrunkenSlug](https://drunkenslug.com) (invite only!)
- [NZBGeek](https://nzbgeek.info)

Remember, if you want to use Usenet indexers, you'll also need a Usenet provider configured in [SABnzbd](/docs/configure/sabnzbd)!

#### Torrent Indexers 🧲
For this tutorial, we'll focus on free torrent indexers since they're easier to get started with. Just remember to always use a VPN when torrenting!

### Adding Indexers

On the homepage, click on "Add Next Indexer" - time to teach Prowlarr where to look for content!

{{< image src="/pics/prowlarr/prowlarr-2.png" alt="" title="" loading="auto" >}}

For this tutorial, I'll add two popular indexers: YTS (great for movies) and eztv (perfect for TV shows). But you can add whatever indexers you like!

Find your indexer and click on it:

{{< image src="/pics/prowlarr/prowlarr-3.png" alt="" title="" loading="auto" >}}

You'll see a new modal called "Add Indexer - Cardigann (your indexer)". All you need to do here is pick a URL from the "Base Url" list. Easy peasy!

{{< image src="/pics/prowlarr/prowlarr-4.png" alt="" title="" loading="auto" >}}

Hit that "Test" button at the bottom - if everything's working, you'll see a happy green checkmark! ✅
{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

Looking good? Click "Save" and you'll be back at the "Add Indexer" modal.

#### How many indexers should I add? 🤔

As many as you want! Just repeat those steps for each new indexer in Prowlarr. The more indexers you have, the better chance of finding what you're looking for! It's like having more libraries to check for books. 📚

When you're done adding indexers, close the modal and you'll see all your indexers on the main page:

{{< image src="/pics/prowlarr/prowlarr-5.png" alt="" title="" loading="auto" >}}

### Connecting to Radarr and Sonarr

Now comes the fun part - connecting Prowlarr to Radarr and Sonarr! This is where everything starts working together. ✨

#### Radarr Connection

First, we need your Radarr API Key. Head over to Radarr's settings at [http://{your-ip-address}:7878/settings/general]() and look for the API Key under "Security".

{{< image src="/pics/bazarr/bazarr-17.png" alt="" title="" loading="auto" >}}

Copy that API key and keep it handy!

In Prowlarr, go to "Settings", click "Apps" and hit the ➕ button.

{{< image src="/pics/prowlarr/prowlarr-6.png" alt="" title="" loading="auto" >}}

Click on "Radarr":

{{< image src="/pics/prowlarr/prowlarr-7.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Prowlarr Server: `http://prowlarr:9696`
- Radarr Server: `http://radarr:7878`
- API Key: paste your Radarr API key here

{{< image src="/pics/prowlarr/prowlarr-8.png" alt="" title="" loading="auto" >}}

Test time! Click that "Test" button - hopefully you'll see a green checkmark! ✅
{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

If the test passed, click "Save". You should see Radarr in your Apps list:

{{< image src="/pics/prowlarr/prowlarr-9.png" alt="" title="" loading="auto" >}}

#### Sonarr Connection

Time for Sonarr! First, grab your Sonarr API Key from [http://{your-ip-address}:8989/settings/general]() - it's under "Security" just like in Radarr.

{{< image src="/pics/bazarr/bazarr-14.png" alt="" title="" loading="auto" >}}

Copy that API key for safekeeping!

Back in Prowlarr, go to "Settings", "Apps" and click that ➕ button again.

{{< image src="/pics/prowlarr/prowlarr-10.png" alt="" title="" loading="auto" >}}

This time click on "Sonarr":

{{< image src="/pics/prowlarr/prowlarr-11.png" alt="" title="" loading="auto" >}}

Fill in these details:
- Prowlarr Server: `http://prowlarr:9696`
- Sonarr Server: `http://sonarr:8989`
- API Key: paste your Sonarr API key here

{{< image src="/pics/prowlarr/prowlarr-12.png" alt="" title="" loading="auto" >}}

One more test! Click "Test" - green checkmark time! ✅
{{< image src="/pics/sonarr/sonarr-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/sonarr/sonarr-11.png" alt="" title="" loading="auto" >}}

All good? Hit "Save". You should now see both Radarr and Sonarr in your Apps list:

{{< image src="/pics/prowlarr/prowlarr-13.png" alt="" title="" loading="auto" >}}

Finally, click on "Sync App Indexers" - this is where the magic happens! 🎩

{{< image src="/pics/prowlarr/prowlarr-14.png" alt="" title="" loading="auto" >}}

Want to see something cool? Go check Sonarr and Radarr's "Indexer" settings - your indexers have been automatically added! No copy-pasting needed!

{{< image src="/pics/prowlarr/prowlarr-15.png" alt="" title="" loading="auto" >}}

{{< image src="/pics/prowlarr/prowlarr-16.png" alt="" title="" loading="auto" >}}

## Moving forward! 🚀

Now we can move on to [Bazarr](/docs/configure/bazarr) - it's going to handle all your subtitle needs!

## Want to become a Prowlarr pro?

If you want to really dive into what Prowlarr can do, check out the [TRaSH Guide for Prowlarr](https://trash-guides.info/Prowlarr/). They've got some amazing tips for power users! 🔧