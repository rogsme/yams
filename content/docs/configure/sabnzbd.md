---
weight: 2
title: SABnzbd
---


## Note - SABnzbd is optional

SABnzbd is an optional component. If you prefer to use torrents exclusively, you can skip this section and proceed to the [Radarr configuration](/config/radarr). To use SABnzbd, you will need a Usenet server and indexers, which are typically paid services.

## What is SABnzbd?

From their [website](https://sabnzbd.org/):

> SABnzbd is a program to download binary files from Usenet servers. Many people upload all sorts of interesting material to Usenet and you need a special program to get this material with the least effort.

So basically, SABnzbd is going to help us download stuff from Usenet servers. Pretty cool! 😎

## Initial configuration

In your browser, go to [http://{your-ip-address}:8080/]() and you'll see SABnzbd's setup page. First, choose your language and click on "Start Wizard":

{{< image src="/pics/sabnzbd/sabnzbd-1.png" alt="" title="" loading="auto" >}}

Next up, you'll need to choose a Usenet server. [Newshosting](https://www.newshosting.com/) usually has good deals going on, but you can use whatever server you prefer!

When you've got your server details ready, input them and click on "Next".

{{< image src="/pics/sabnzbd/sabnzbd-2.png" alt="" title="" loading="auto" >}}

You should now see the final wizard page - congrats! 🎉

You'll notice the Completed and Uncompleted download folders aren't quite where we want them. Don't worry, we'll fix that in a minute!

For now, just click on "Go to SABnzbd".

{{< image src="/pics/sabnzbd/sabnzbd-3.png" alt="" title="" loading="auto" >}}

Head over to the settings page by clicking on the cog-wheel icon in the top right.

{{< image src="/pics/sabnzbd/sabnzbd-4.png" alt="" title="" loading="auto" >}}

On the "General" page, set the "External internet access" to "Full API" and click on "Save Changes"

{{< image src="/pics/sabnzbd/sabnzbd-7.png" alt="" title="" loading="auto" >}}

Now, click on "Folders" and let's get those paths sorted:
- Set your "Temporary Download Folder" to `/data/downloads/usenet/incomplete`
- Set your "Completed Download Folder" to `/data/downloads/usenet/complete`
- Click on "Save Changes"

{{< image src="/pics/sabnzbd/sabnzbd-5.png" alt="" title="" loading="auto" >}}

## Getting your API key for Sonarr and Radarr

You'll need this API key later when we set up Radarr and Sonarr. Feel free to skip this section for now if you want - you can always come back!

To get your API key:

First, head back to the settings.

{{< image src="/pics/sabnzbd/sabnzbd-4.png" alt="" title="" loading="auto" >}}

Then, go to "General" and scroll down to "Security". You'll find your API Key right there!

{{< image src="/pics/sabnzbd/sabnzbd-6.png" alt="" title="" loading="auto" >}}

## That's done! 🎉

Excellent! Now we can move forward with [Radarr](/config/radarr). Get ready - this is where things start getting really fun! 😄