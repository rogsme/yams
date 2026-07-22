---
weight: 110
title: Running everything together
---


## First, I want to congratulate you 🎉

You did it! You installed and configured YAMS! Give yourself a good pat on the back - you've earned it! 🙇‍♂️

{{< image src="/pics/party.gif" alt="" title="" loading="auto" >}}

Now comes the fun part: Adding your shows/movies and watching everything work together like a well-oiled machine! 😎

## Radarr & Sonarr

These instructions work for both Radarr and Sonarr. To keep things simple, I'll show you with Radarr, but the process is super similar for TV shows!

Open Radarr at [http://{your-ip-address}:7878/]() and click on "Add New" in the left menu. For this demo, I'll use "The Godfather" (because it's a classic!), but you can search for any movie you want.

Pro tip: For your first test, pick something popular - it'll be easier to find!

{{< image src="/pics/running-everything-together/running-everything-together-1.png" alt="" title="" loading="auto" >}}

Click on the movie you want to download:

{{< image src="/pics/running-everything-together/running-everything-together-2.png" alt="" title="" loading="auto" >}}

Now you can pick your quality preferences. If your movie is part of a collection (like The Godfather is), you can choose to download the whole series in the "Monitor" box. I'm going for the whole trilogy because, well, why not?

Finally, click "Add Movie"!

{{< image src="/pics/running-everything-together/running-everything-together-3.png" alt="" title="" loading="auto" >}}

Head back to "Movies" and you'll see your selections:

{{< image src="/pics/running-everything-together/running-everything-together-4.png" alt="" title="" loading="auto" >}}

Click on "Activity" to watch the magic happen - you can see everything downloading in real-time! 🪄

{{< image src="/pics/running-everything-together/running-everything-together-5.png" alt="" title="" loading="auto" >}}

## qBittorrent

Want to see what's going on under the hood? Open qBittorrent at [http://{your-ip-address}:8081/]() and you'll see your movies downloading!

This means everything is working perfectly! When downloads finish, Radarr will automatically organize them into the right folders.

{{< image src="/pics/running-everything-together/running-everything-together-6.png" alt="" title="" loading="auto" >}}

## Media service

After your downloads finish, head over to your media service and... ta-da! 🎉 Your movies are right there waiting for you!

Jellyfin:
{{< image src="/pics/running-everything-together/running-everything-together-12.png" alt="" title="" loading="auto" >}}

Emby:
{{< image src="/pics/running-everything-together/running-everything-together-7.png" alt="" title="" loading="auto" >}}

Plex:
{{< image src="/pics/running-everything-together/running-everything-together-11.png" alt="" title="" loading="auto" >}}

Open up a movie and look - subtitles are already there! That's [Bazarr](/docs/configure/bazarr) doing its thing! 🎯

{{< image src="/pics/running-everything-together/running-everything-together-8.png" alt="" title="" loading="auto" >}}

{{< image src="/pics/running-everything-together/running-everything-together-9.png" alt="" title="" loading="auto" >}}

You can even start watching right from your browser, with subtitles and everything:
{{< image src="/pics/running-everything-together/running-everything-together-10.png" alt="" title="" loading="auto" >}}

## Your filesystem

Curious about how everything's organized? Check out your `/mediafolder/media/movies` folder:

```bash
roger@debian:/srv/media/movies$ tree .
.
├── The Godfather (1972)
│   ├── The Godfather (1972).en.srt
│   ├── The Godfather (1972).es.srt
│   └── The Godfather (1972).mp4
├── The Godfather Part II (1974)
│   ├── The Godfather Part II (1974).en.srt
│   ├── The Godfather Part II (1974).es.srt
│   └── The Godfather Part II (1974).mp4
└── The Godfather Part III (1990)
    ├── The Godfather Part III (1990).en.srt
    ├── The Godfather Part III (1990).es.srt
    └── The Godfather Part III (1990).mp4

3 directories, 9 files
```

Not a fan of how things are named? No problem! You can always change the naming format in [Radarr's media management page](/docs/configure/radarr#media-management) or [Sonarr's settings](/docs/configure/sonarr#media-management).

# Final step and conclusions

You did it! 🎉 You've got your very own media server up and running! That's a huge step toward breaking free from subscription services like Netflix or Amazon Prime.

And guess what? There's still so much more you can do to make your setup even better! Head over to the [Recommendations](/docs/configure/recomendations) page for some cool ideas on what to try next.

 🙌 Thanks for following along with the tutorial! Hope you enjoy your awesome new media server - you've earned it! 😎