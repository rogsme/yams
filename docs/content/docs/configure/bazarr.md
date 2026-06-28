---
weight: 6
title: Bazarr
---


# What is Bazarr?

From their [website](https://www.bazarr.media/):

> Bazarr is a companion application to Sonarr and Radarr that manages and downloads subtitles based on your requirements.

In YAMS, Bazarr is your subtitle superstar! 🌟 It's going to download subtitles in any language you choose, sort them, and put them right where Emby/Jellyfin/Plex can find them. No more hunting for subtitles manually!

## Initial Configuration

In your browser, go to [http://{your-ip-address}:6767/]() and you'll see Bazarr's settings page.

{{< image src="/pics/bazarr/bazarr-1.png" alt="" title="" loading="auto" >}}

The default settings here are fine - no need to change anything yet!

### Languages

On the left side menu, click on "Languages". This is where the fun begins! 🎬

In the "Languages Filter" box, pick all the languages you want subtitles for. For this tutorial, I'm going with:
- `English` (because why not?)
- `Spanish` (¿por qué no?)
- `Latin American Spanish` (different flavor, same great taste!)

After choosing your languages, click on "Add New Profile"

{{< image src="/pics/bazarr/bazarr-2.png" alt="" title="" loading="auto" >}}

In the "Edit Languages Profile" modal:
1. Give your profile a name (anything you want!)
2. Click on "Add Language"
3. **Important:** Click "Add Language" once for EACH language you picked earlier!

Since I picked 3 languages earlier, I need to click "Add Language" three times. Math! 🧮

When you're done, click "Save" at the bottom.

{{< image src="/pics/bazarr/bazarr-3.png" alt="" title="" loading="auto" >}}

Back on the "Languages" page, set your new profile as the default for both Series and Movies.

{{< image src="/pics/bazarr/bazarr-4.png" alt="" title="" loading="auto" >}}

You should end up with something like this:

{{< image src="/pics/bazarr/bazarr-5.png" alt="" title="" loading="auto" >}}

Happy with how it looks? Hit "Save" at the top of the page!

{{< image src="/pics/bazarr/bazarr-6.png" alt="" title="" loading="auto" >}}

### Providers

Time to tell Bazarr where to find those subtitles! Click on "Providers" in the left menu, then click that big ➕ sign.

{{< image src="/pics/bazarr/bazarr-7.png" alt="" title="" loading="auto" >}}

You'll see a HUGE list of providers - and they even include descriptions! How thoughtful! 📚

{{< image src="/pics/bazarr/bazarr-8.png" alt="" title="" loading="auto" >}}

For this tutorial, we'll just add [OpenSubtitles.org](https://www.opensubtitles.org/en/search/subs), but feel free to add more later! The more providers you have, the better chance of finding perfect subtitles.

Some providers (including OpenSubtitles.org) need a username and password. If you don't have an account yet, go ahead and create one - I'll wait! ⏳

Got your login info? Great! Enter it and click "Save"

{{< image src="/pics/bazarr/bazarr-9.png" alt="" title="" loading="auto" >}}

Now you'll see OpenSubtitles.org in your providers list! Click "Save" at the top of the page if you're happy with the changes.

{{< image src="/pics/bazarr/bazarr-10.png" alt="" title="" loading="auto" >}}

### Subtitles

Click on "Subtitles" in the left menu and scroll down to "Performance / Optimization".

First thing to do: Disable "Use Embedded Subtitles". We want our subtitles free-range, not caged! 🐓

A bit further down, you'll find "Post-Processing". Enable these options:
- "Encode Subtitles to UTF8" (keeps everything readable)
- "Hearing Impaired" (removes those [DOOR CREAKS] descriptions)
- "Remove Tags" (cleans up formatting)
- "OCR Fixes" (fixes common scanning errors)
- "Common Fixes" (fixes... common stuff! 😅)
- "Fix Uppercase" (NO MORE SHOUTING IN SUBTITLES)

{{< image src="/pics/bazarr/bazarr-11.png" alt="" title="" loading="auto" >}}

Now scroll aaaaaall the way to the bottom and enable:
- "Automatic Subtitles Synchronization"
- Set both "Series Score Threshold" and "Movies Score Threshold" to 50

Why 50? I've found it's a good balance - Bazarr can still find good subtitles but won't use terrible ones. Feel free to adjust this if you want to be more or less picky!

{{< image src="/pics/bazarr/bazarr-12.png" alt="" title="" loading="auto" >}}

Happy with your settings? Hit "Save" at the top!

{{< image src="/pics/bazarr/bazarr-13.png" alt="" title="" loading="auto" >}}

### Connecting to Sonarr

Time to link Bazarr with [Sonarr](/docs/configure/sonarr)! First, we need Sonarr's API key.

Head to [http://{your-ip-address}:8989/settings/general]() and find the API Key under "Security".

{{< image src="/pics/bazarr/bazarr-14.png" alt="" title="" loading="auto" >}}

Copy that key and keep it safe!

Back in Bazarr, click on "Sonarr" in the left menu.

By default, Sonarr is disabled. Let's fix that! Enable Sonarr and you'll see lots of new options. Don't panic - you only need to change a few:

- Address: set to `sonarr`
- API Key: paste in Sonarr's API Key
- Click "Test"

If everything's working, you'll see your Sonarr version on the button! 🎉

{{< image src="/pics/bazarr/bazarr-15.png" alt="" title="" loading="auto" >}}

Click "Save" at the top of the page to finish up.

{{< image src="/pics/bazarr/bazarr-16.png" alt="" title="" loading="auto" >}}

Magic time! The "Series" section should appear in your left menu! ✨

{{< image src="/pics/bazarr/bazarr-19.png" alt="" title="" loading="auto" >}}

### Connecting to Radarr

Now let's connect to [Radarr](/docs/configure/radarr)! First step: get that API key.

Go to [http://{your-ip-address}:7878/settings/general]() and find the API Key under "Security".

{{< image src="/pics/bazarr/bazarr-17.png" alt="" title="" loading="auto" >}}

Copy that key and keep it handy!

Back in Bazarr, click "Radarr" in the left menu.

Just like with Sonarr, Radarr is disabled by default. Enable it and fill in:
- Address: set to `radarr`
- API Key: paste in Radarr's API Key
- Click "Test"

If the test works, you'll see your Radarr version on the button! 🎯

{{< image src="/pics/bazarr/bazarr-18.png" alt="" title="" loading="auto" >}}

Click "Save" at the top to wrap things up.

{{< image src="/pics/bazarr/bazarr-20.png" alt="" title="" loading="auto" >}}

More magic! The "Movies" section appears in your left menu! ✨

{{< image src="/pics/bazarr/bazarr-21.png" alt="" title="" loading="auto" >}}

### Almost there! 🏃‍♂️

Just one last step! Time to set up your media service. Pick your path:
- [Jellyfin](/docs/configure/jellyfin)
- [Emby](/docs/configure/emby)
- [Plex](/docs/configure/plex)

## Want to become a subtitle master? 🎓

If you want to really dive into Bazarr's settings, check out the [TRaSH Guide for Bazarr](https://trash-guides.info/Bazarr/). They've got some amazing advanced configurations in there!