---
weight: 20
title: SABnzbd
---


## Note - SABnzbd is optional

SABnzbd is an optional component. If you prefer to use torrents exclusively, you can skip this section and proceed to the [Radarr configuration](/docs/configure/radarr). **To use SABnzbd, you will need a Usenet server and indexers, which are typically paid services.**

## What is SABnzbd?

SABnzbd is a Usenet downloader. Similarly to how qBitTorrent manages downloads from the BitTorrent network, Sabnzbd deals with Usenet files. Pretty easy! 😎

Check out their website [here](https://sabnzbd.org/).

## Initial configuration

In your browser, go to [http://_USER_IP_:8090/](http://_USER_IP_:8090/) and you'll see SABnzbd's setup page. First, choose your language and click on "Start Wizard":

{{< image src="/pics/sabnzbd/sabnzbd-1.png" alt="" title="" loading="auto" >}}

Next up, you'll need to choose a Usenet server. [Newshosting](https://www.newshosting.com/) usually has good deals going on, but you can use whatever provider you prefer!

When you've got your server details ready, input them and click on "Next".

{{< image src="/pics/sabnzbd/sabnzbd-2.png" alt="" title="" loading="auto" >}}

You should now see the final wizard page - congrats! 🎉

You'll notice the Completed and Uncompleted download folders aren't quite where we want them. Don't worry, we'll fix that in a second. First, click on "Go to SABnzbd".

{{< image src="/pics/sabnzbd/sabnzbd-3.png" alt="" title="" loading="auto" >}}

Head over to the settings page by clicking on the cog-wheel icon in the top right.

{{< image src="/pics/sabnzbd/sabnzbd-4.png" alt="" title="" loading="auto" >}}

On the 'Folders' page, let's get those paths sorted:
- Set your "Temporary Download Folder" to `/data/downloads/usenet/incomplete`
- Set your "Completed Download Folder" to `/data/downloads/usenet/complete`
- Click on "Save Changes"

{{< image src="/pics/sabnzbd/sabnzbd-5.png" alt="" title="" loading="auto" >}}

Now, lets ensure that Radarr and Sonarr will be able to connect to SABnzbd. Go to the 'Special' page in the settings (top right) and scroll to the very bottom.
There should be a field called `host_whitelist()`. These are the hostnames that SABnzbd allows incoming connections from. Add a comma, then add the word 'gluetun'. Since SABnzbd is running behind the VPN, Radarr and Sonarr must access it through Gluetun, so we wil allow this! Save the changes.

> The random value that will exist already is simply the ID of the SABnzbd docker container. **Don't touch/change this!**

{{< image src="/pics/sabnzbd/sabnzbd-6.png" alt="" title="" loading="auto" >}}


## Optional - Set Username and Password

It can be a good idea to set up some account credentials so that no other machines on our local network can connect to SABnzbd. Just like how bypassing qBitTorrent authentication for local devices is optional, this technically is too. However this time we are opting *in* to be secure rather than *out*, and its always better to be slightly more secure. Just in case!

To create a username and password to login to Sabnzbd securely, click the 'General' tab inside of settings. Scroll down to the 'Security' section. Here, make up a new username nas password (please make yours more secure than mine) and hit 'Save Changes'!

{{< image src="/pics/sabnzbd/sabnzbd-8.png" alt="" title="" loading="auto" >}}

## Getting your API key for Sonarr and Radarr

You'll need this API key later when we set up Radarr and Sonarr. You can either save it now, or feel free to skip this section and come back later. *Radarr setup is next, so if you are continuing the setup in this session it's easier just to grab it now, or at least keep the page open 😝.*

To get your API key:

First, head back to the settings.

{{< image src="/pics/sabnzbd/sabnzbd-4.png" alt="" title="" loading="auto" >}}

Then, go to "General" and scroll down to "Security". You'll find your API Key right there!

{{< image src="/pics/sabnzbd/sabnzbd-7.png" alt="" title="" loading="auto" >}}

## That's done! 🎉

Excellent! Now we can move forward with [Radarr](/docs/configure/radarr). Get ready - this is where things start getting really fun! 😄