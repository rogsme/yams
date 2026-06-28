---
weight: 7
title: Jellyfin
---


# What is Jellyfin?

From their [website](https://jellyfin.org/):

> Jellyfin is the volunteer-built media solution that puts you in control of your media. Stream to any device from your own server, with no strings attached. Your media, your server, your way.

In YAMS, Jellyfin is going to be your personal Netflix! 🍿 It's 100% open source and lets you stream your TV shows and movies to any device. Best part? No monthly fees!

## Initial configuration

In your browser, go to [http://{your-ip-address}:8096/]() and you'll see Jellyfin's setup page.

First things first - pick your display language and click "Next".

{{< image src="/pics/jellyfin/jellyfin-1.png" alt="" title="" loading="auto" >}}

Time to create your first user! This will be your admin account, so make it secure. When you're done, click "Next".

{{< image src="/pics/jellyfin/jellyfin-2.png" alt="" title="" loading="auto" >}}

Now we're at the "Setup Media Libraries" page. Click on "New Library" - let's tell Jellyfin where to find all your media! 📚

{{< image src="/pics/jellyfin/jellyfin-3.png" alt="" title="" loading="auto" >}}

### Setting up your TV Shows library

On the "New Library" modal, pick "Shows" as your Content type and click the big ➕ sign next to "Folders".

{{< image src="/pics/jellyfin/jellyfin-4.png" alt="" title="" loading="auto" >}}

In "Select Path", choose the `/data/tvshows` folder and click "Ok"

{{< image src="/pics/jellyfin/jellyfin-5.png" alt="" title="" loading="auto" >}}

**Magic Container Note:** 🎩 The `/data/tvshows/` folder isn't actually on your filesystem - it's a special path inside the docker environment that maps to your server's `/mediafolder/media/tvshows/` folder!

You should see your new folder all ready to go in the modal:

{{< image src="/pics/jellyfin/jellyfin-6.png" alt="" title="" loading="auto" >}}

Now set your preferred metadata language. The other default settings are fine, but feel free to tweak them if you want to get fancy!

Your setup should look something like this:

{{< image src="/pics/jellyfin/jellyfin-7.png" alt="" title="" loading="auto" >}}

Happy with the settings? Click "Ok". Your TV Shows library is now added! 📺

{{< image src="/pics/jellyfin/jellyfin-8.png" alt="" title="" loading="auto" >}}

### Setting up your Movies library

Time for round two! Click that "New Library" button again.

This time, pick "Movies" as your Content type and click the ➕ next to "Folders".

{{< image src="/pics/jellyfin/jellyfin-9.png" alt="" title="" loading="auto" >}}

Choose the `/data/movies` folder and click "Ok"

{{< image src="/pics/jellyfin/jellyfin-10.png" alt="" title="" loading="auto" >}}

**More Container Magic:** 🎩✨ Just like before, `/data/movies/` is a special docker path that maps to your server's `/mediafolder/media/movies/` folder!

You should see your movies folder ready to go:

{{< image src="/pics/jellyfin/jellyfin-11.png" alt="" title="" loading="auto" >}}

Set your preferred metadata language again. Default settings are still your friend here!

Your setup should look like this:

{{< image src="/pics/jellyfin/jellyfin-12.png" alt="" title="" loading="auto" >}}

Looking good? Click "Ok". Your Movies library is now added! 🎬

{{< image src="/pics/jellyfin/jellyfin-13.png" alt="" title="" loading="auto" >}}

Time to move forward - click that "Next" button!

{{< image src="/pics/jellyfin/jellyfin-14.png" alt="" title="" loading="auto" >}}

### Final Setup Steps

On the "Preferred Metadata Language" page, pick your favorite language and country. Then click "Next".

{{< image src="/pics/jellyfin/jellyfin-15.png" alt="" title="" loading="auto" >}}

For the "Set up Remote Access" page, let's keep things simple - disable "Allow remote connections to this server" and click "Next".

{{< image src="/pics/jellyfin/jellyfin-16.png" alt="" title="" loading="auto" >}}

You're done! Click "Finish" to head to your shiny new Jellyfin dashboard. 🎉
{{< image src="/pics/jellyfin/jellyfin-17.png" alt="" title="" loading="auto" >}}

### Logging in to Jellyfin

Time to test drive your new setup! On the login screen, use the username and password you created earlier.

{{< image src="/pics/jellyfin/jellyfin-18.png" alt="" title="" loading="auto" >}}

And there it is! Your very own streaming service homepage! 🌟

{{< image src="/pics/jellyfin/jellyfin-19.png" alt="" title="" loading="auto" >}}

## That's all folks! 🎬

YAMS is now fully up and running! Ready to add some content? Move on to [Running everything together](/config/running-everything-together) to see how all these pieces work together!