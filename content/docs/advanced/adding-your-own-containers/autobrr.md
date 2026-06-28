---
weight: 3
title: Autobrr
---


[Autobrr](https://autobrr.com/introduction) is an app that allows you connect to an Indexer's IRC channel, immediately starting torrent downloads for newer movies/shows without relying on Radarr/Sonarr's slower RSS feed. This allows you to help build ratio on private trackers by beating everyone else to the torrent, so you can seed it to everyone else!

Note that although this is recommended with private trackers to build ratio, it isn't required for just managing a personal library. Earlier torrents might be lower quality, resulting in multiple upgrades as more torrents are released, which can be a waste of bandwidth and storage. If you don't care about being the first to download, you can just rely on Radarr/Sonarr's default RSS feed.

But if you do want to be the first to download, let's get it set up!

To get started, add this container declaration into your `docker-compose.custom.yaml` file under the `services:` parent item.
```yaml
  autobrr:
    container_name: autobrr
    image: ghcr.io/autobrr/autobrr:latest
    restart: unless-stopped
    ports:
      - 7474:7474
    environment:
      - TZ=${TZ}
      - PUID=${PUID}
      - PGID=${PGID}
    volumes:
      - ${INSTALL_DIRECTORY}/config/autobrr:/config
```

Easy! Now, get that container up by running
```bash
yams start
```


## Configuration
How the process will work:
- Autobrr will monitor new torrent announcements from your indexer, sending them to Radarr/Sonarr
- The torrent is checked by Radarr/Sonarr. If it is not relevant, it is rejected. If it passes the criteria (e.g quality/formats) it is sent to qBitTorrent for downloaded.

Open up Autobrr's web interface in your browser.

###### 1. Add your indexer.

{{< image src="/pics/autobrr/autobrr-1.png" alt="" title="" loading="auto" >}}

Navigate to the 'Settings' tab, and then the 'Indexers' section. Click on 'Add new indexer'.

This will require you to enter your indexer name and RSS Key. Be sure to follow the [IRC Guide](https://autobrr.com/configuration/irc) paired with any resources for your tracker to determine required IRC information.

###### 2. Add Radarr and Sonarr Clients

{{< image src="/pics/autobrr/autobrr-2.png" alt="" title="" loading="auto" >}}

Navigate to the 'Client' section and click 'Add new Client'.

Name your client 'Radarr', and select Radarr from the list of client options. Then, enter `http://radarr:7878` as the Host and put in your API key.

Now, let's create another client for tv shows. Name this one 'Sonarr', and select Sonarr from the list of client options. Then, enter `http://sonarr:8989` as the Host and put in your API key. Done!

> API keys can be found in Radarr/Sonarr by going to Settings > General > Security

###### 3. Add Movie and Tv Show Filters and Actions

{{< image src="/pics/autobrr/autobrr-3.png" alt="" title="" loading="auto" >}}


Now, navigate to the 'Filters' tab and select 'Add new'.

Name this filter 'Movies'

{{< image src="/pics/autobrr/autobrr-4.png" alt="" title="" loading="auto" >}}

Ensure the announce type is set to 'NEW', and all correct indexers are applied.

Now, let's add an action to actually send these torrent announcements to Radarr.

{{< image src="/pics/autobrr/autobrr-5.png" alt="" title="" loading="auto" >}}

Within the filter's settings, select the 'Actions' tab. Click 'Add new'.
Set the action type to 'Radarr', and name it 'Send to Radarr'.
Select Radarr as the download client and click 'Save'.

Now Radarr's filter is set up. Repeat the entire process of step 3, instead naming it 'Tv Shows', with a Send to Sonarr action.

Perfect. Now we have 2 filters to movies and tv shows, ready to send torrents to Radarr and Sonarr. Enable them both in the Filters tab!

###### 4. Create Lists for Radarr and Sonarr

Lists are a feature that automatically use Radarr/Sonarr's monitored items to update a filter, only accepting required items.

{{< image src="/pics/autobrr/autobrr-6.png" alt="" title="" loading="auto" >}}

Navigate back to 'Settings' and the 'Lists' section, and then click 'Add new list.'

{{< image src="/pics/autobrr/autobrr-7.png" alt="" title="" loading="auto" >}}

Let's first create a list for Radarr. Enter 'Radarr' as the name, type and client. Set the Filter to your previously created 'Movies' filter. Click Save.

Repeat the process for Sonarr. Enter 'Sonarr' as the name, type and client. Set the Filter to your previously created 'TV Shows' filter. Click Save.

###### 5. Enable IRC

Almost done! All we have to do now is simply enable Autobrr's IRC server, so we start recieving new announcements.

{{< image src="/pics/autobrr/autobrr-8.png" alt="" title="" loading="auto" >}}

Navitage to the 'IRC' section inside of 'Settings', and enable all of your Indexers.

---

And that's it! 🥳

Now you have automatic fetching of relevant torrents as soon as they release, enabling you to level up your seeding!

---

*Thanks to [not-first](https://github.com/not-first) on Github for contributing to this guide!*