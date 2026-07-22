---
weight: 20
title: Environment Variables
---

## Your Environment File (`.env`) - The YAMS Settings Hub!

Let's talk about the `.env` file. Don't let the technical name scare you; it's actually your best friend for customizing YAMS! Think of it as the central control panel for some of YAMS's key settings. It's a simple text file living right where you installed YAMS (remember specifying that location during the [install steps](/docs/getting-started/installation/)?).

You might notice that you don't immediately see this file when you list the contents of your YAMS directory. That's because files starting with a dot (`.`) are typically hidden on Linux/Unix systems. But don't worry, it's easy to find! To view it, just use the command `ls -a` in your terminal (the `-a` stands for "all", showing you all files, even the hidden ones).

### So, What Does It Do?

At its heart, the `.env` file holds **environment variables**. That sounds technical, but it's just a fancy way of saying "named settings". You give a setting a name, set its value, and then you can easily reuse that name elsewhere.

It looks like this inside:

```env
# Lines starting with # are comments (ignored)
PUID=1000
PGID=100
MEDIA_DIRECTORY=/srv/media
# You might add your own later!
# MY_API_KEY=supersecret123
```

See? Just `SETTING_NAME=some_value` on each line. It's incredibly straightforward to read and edit!

### How YAMS Uses It (The Magic Part!)

Now, where do these settings get used? Primarily in your `docker-compose.yaml` and `docker-compose-custom.yaml` files. These files tell Docker how to run all the YAMS services (like Radarr, Sonarr, Plex, etc.). *Learn more about them [here](/docs/fundamentals/docker-and-compose/)*

Inside the `environment` section of our docker compose folders, there is another environment variable list! These ones are the variables being passed into the application. So, quick recap: **.env** file has all the common env vars that the docker compose files can use. The `environment` section of each container is how we pass these on!

Instead of writing the same path or ID over and over again in those files, we can just use the *name* of the setting from `.env`, but with a dollar sign (`$`) in front, and wrapped inside curly brackets `{}`. Like this:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
# Inside a service definition in docker-compose.yaml...
environment:
  - PUID=${PUID} # Aha! Use the PUID value from .env
  - PGID=${PGID} # And the PGID value too!
  - WEBUI_PORT=8081 # just pass through the value 8081. No need to swap anything.
volumes:
  - ${MEDIA_DIRECTORY}:/data # Map the media folder defined in .env
```

When Docker starts the container, it automatically swaps `${PUID}` with `1000` (or whatever you set in `.env`), `${MEDIA_DIRECTORY}` with `/srv/media`, and so on. This makes your configuration much cleaner and easier to manage.

### Why Bother With `.env`? (Spoiler: It Makes Life Easier!)

Okay, why the extra step? It actually helps you out in a few great ways:

- **Keep Secrets Secret:** Got API keys or passwords? Pop them in your `.env` file. This way, you can share your `docker-compose.yaml` file if you need help, without accidentally giving away sensitive info! **Super Important:** Make sure you add `.env` to your `.gitignore` file (if you are using git) so you don't accidentally upload your secrets to your Git remote!
- **Change Once, Update Everywhere:** Imagine you move your media library. Instead of editing the path in *every single service* in your `docker-compose.yaml`, you just change the `MEDIA_DIRECTORY` line in your `.env` file once. Done! This saves you a ton of time and prevents errors.
- **Easy Tweaks:** It keeps your main `docker-compose.yaml` cleaner and lets you adjust core settings without digging through complex files. It's designed to be user-friendly!

And don't worry, you don't *have* to define *all* variables inside of here. If you just want to pass on one value to one container, skip the file and pop it straight in your compose!

### The Defaults YAMS Gives You

When you first set up YAMS, your `.env` file comes pre-filled with a few essentials:

- `PUID` and `PGID`: These numbers tell the containers which user on your computer "owns" the files they create. This is super important for permissions (making sure Radarr can actually save files to your media folder!). You usually *don't* need to change the defaults (often `1000` for both) unless you know you need to run things as a different specific user.
- `MEDIA_DIRECTORY`: This is the main folder on your computer where all your media lives (or will live!). The default is `/srv/media`. Feel free to change it to wherever you keep your stuff, just make sure the user from `PUID`/`PGID` can read and write there! **Heads Up:** For smooth sailing and efficient hardlinking (which saves disk space!), try to keep all your media (movies, TV, music, books) in *subfolders* under this *one* main directory.
- `INSTALL_DIRECTORY`: This tells YAMS where its own configuration files for each service should live. Default is `/opt/yams`. You set this during install and probably won't touch it again.
- `TZ`: This makes sure all the containers are on the same page about what your local timezone is.

---

*Thanks to Airwreck on Discord for contributing this guide!*