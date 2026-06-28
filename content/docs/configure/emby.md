---
weight: 8
title: Emby
---


# What is Emby?

From their [website](https://emby.media/about.html):

> Emby brings together your personal videos, music, photos, and live television. (...) Emby Server automatically converts and streams your personal media on the fly to play on any device.

In YAMS, Emby is your streaming service superstar! 🌟 Just like Netflix or Amazon Prime, Emby lets you stream all your media to any device. The best part? You're in complete control!

## Initial configuration

In your browser, go to [http://{your-ip-address}:8096/]() and you'll see Emby's setup page.

First up, pick your display language and click on "Next".

{{< image src="/pics/emby/emby-1.png" alt="" title="" loading="auto" >}}

Time to create your first user! This will be your admin account, so make it a good one. When you're done, click "Next".

{{< image src="/pics/emby/emby-2.png" alt="" title="" loading="auto" >}}

Now we're at the "Setup Media Libraries" page. Click on "New Library" - let's tell Emby where all your awesome content lives! 🎬

{{< image src="/pics/emby/emby-3.png" alt="" title="" loading="auto" >}}

### Setting up your TV Shows library

On the "New Library" modal, pick "TV shows" as your Content type and click that big ➕ sign next to "Folders".

{{< image src="/pics/emby/emby-4.png" alt="" title="" loading="auto" >}}

In "Select Path", choose the `/data/tvshows` folder and click "Ok"

{{< image src="/pics/emby/emby-5.png" alt="" title="" loading="auto" >}}

**Docker Magic Note:** 🎩 Don't worry if this path looks weird! The `/data/tvshows/` folder exists inside the docker environment and maps to your server's `/mediafolder/media/tvshows/` folder. It's all connected behind the scenes!

You'll see your newly added folder in the modal:

{{< image src="/pics/emby/emby-6.png" alt="" title="" loading="auto" >}}

Pick your preferred metadata language. All the default settings are good to go, but feel free to tweak them if you want to get fancy!

Your "New Library" screen should look something like this:

{{< image src="/pics/emby/emby-7.png" alt="" title="" loading="auto" >}}

Happy with how it looks? Click "Ok". Your TV Shows library is ready for action! 📺

{{< image src="/pics/emby/emby-8.png" alt="" title="" loading="auto" >}}

### Setting up your Movies library

Let's do that one more time! Click "New Library" again.

This time, pick "Movies" as your Content type and click the ➕ next to "Folders".

{{< image src="/pics/emby/emby-9.png" alt="" title="" loading="auto" >}}

Choose the `/data/movies` folder and click "Ok"

{{< image src="/pics/emby/emby-10.png" alt="" title="" loading="auto" >}}

**More Docker Magic:** ✨ Just like before, `/data/movies/` is actually mapping to your server's `/mediafolder/media/movies/` folder. Docker is doing its thing!

Your folder should show up in the modal:

{{< image src="/pics/emby/emby-11.png" alt="" title="" loading="auto" >}}

Set your preferred metadata language again. The defaults are still your friend here!

The screen should look something like this:

{{< image src="/pics/emby/emby-12.png" alt="" title="" loading="auto" >}}

All set? Click "Ok". Your Movies library is now ready! 🎬

{{< image src="/pics/emby/emby-13.png" alt="" title="" loading="auto" >}}

Time to move forward - click that "Next" button!

{{< image src="/pics/emby/emby-14.png" alt="" title="" loading="auto" >}}

### Wrapping up the setup

On the "Preferred Metadata Language" page, pick your language and country preferences, then click "Next".

{{< image src="/pics/emby/emby-15.png" alt="" title="" loading="auto" >}}

For the "Configure Remote Access" page, let's keep things simple and secure:
- Disable "Enable automatic port mapping"
- Click "Next"

{{< image src="/pics/emby/emby-16.png" alt="" title="" loading="auto" >}}

Time to accept the terms of service (you read those, right? 😉). Click "Next".

{{< image src="/pics/emby/emby-17.png" alt="" title="" loading="auto" >}}

You're all done! Click "Finish" to see your new Emby dashboard. 🎉
{{< image src="/pics/emby/emby-18.png" alt="" title="" loading="auto" >}}

### Logging in to Emby

First up, pick your user and log in with the credentials you created earlier.

{{< image src="/pics/emby/emby-19.png" alt="" title="" loading="auto" >}}

{{< image src="/pics/emby/emby-20.png" alt="" title="" loading="auto" >}}

And there it is! Your very own streaming service, ready to go! 🌟

{{< image src="/pics/emby/emby-21.png" alt="" title="" loading="auto" >}}

## That's all folks! 🎬

YAMS is fully up and running! Want to see how everything works together? Head over to [Running everything together](/config/running-everything-together).

## Pro Tip! 💡

If you're loving Emby, I highly recommend checking out [Emby Premiere](https://emby.media/premiere.html)! It's totally optional, but it gives you some really cool features like:
- Offline media for your devices
- Hardware transcoding (smoother playback!)
- Auto-conversion of your content
- And lots more!

I actually canceled all my streaming services, bought a 1-year Emby Premiere license, and never looked back. Just saying! 😉