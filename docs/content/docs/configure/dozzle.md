---
weight: 10
title: Dozzle
---

Installation is complete! Good job. However, this was the easiest step. You still have all the containers and services to configure. Don't worry though, we will walk you through it step by step! The first service we will configure is Dozzle.

---

# Dozzle

### What is Dozzle?

> [!INFO]
> If you are unsure what Docker is, or how it works, please read the [Docker Fundamentals](/docs/fundamentals/docker-and-compose/) page first.

Dozzle is a simple log viewer for Docker containers. It allows you to view the logs of your containers in real time, which is very useful for troubleshooting and monitoring your applications. It also providers the ability to perform simple actions on containers such as stop, start, update, and even run commands inside them! It will help us verify that everything is working as we go along, and allow us to spot any errors that might occur.

*Check out Dozzle's Github [here](https://github.com/amir20/dozzle) and the documentation [here](https://dozzle.dev/guide/getting-started).*

## Configuring Dozzle

### Quick note: using the default editor

When you need to edit a config file in YAMS, the default terminal editor is usually `nano`. This is the easiest option to use for files like `.env`, `docker-compose.yaml`, and other text-based config files. For example:

```bash
nano _INSTALL_PATH_/.env
```

- Use the arrow keys to move around
- Edit the file directly
- Press `Ctrl+O`, then `Enter` to save
- Press `Ctrl+X` to exit

This is the simplest way to make changes when the guide tells you to open a file. Of course, feel free to use any other method if you wish!

### Creating a user

Since Dozzle can perform actions on containers, YAMS creates it with authentication enabled by default. The installer utilises a completely random hash as its default user, meaning it is impossible to sign into the default `yams` account. Its only there to make sure Dozzle doesn't panic about having no user at the very start 😝. But don't worry, we are about to create you one you can actually use!

In order to create this user, we will have to generate a valid user YAML to add into our Dozzle configuration files. Utilise the generator below to build this command for you:
- `username` is the, well, username of your new user
- `password` is the password for this new user
- `name` is the display name that will show in the UI

> [!WARNING]
> Always be careful about entering your credentials into websites. The code for YAMS is fully open source [here](https://git.rogs.me/rogs/yams) and does not take any action using your entered credentials.

{{< dozzle-user-generator >}}

After you have filled out and copied the generation command for *your* user, copy it and run it on your machine.

You'll get something like this returned in your terminal:
```yml
users:
    admin:
        email: ""
        name: Admin
        password: $2a$11$FYTyP5VcWdhCwaUjMRx2eOoYPrLkck3jK7y5PORcg36qfWfQeoWQ2
        filter: ""
        roles: ""
```

Perfect. Now, lets send this output straight into the Dozzle `users.yml` file. Add this to the **end** of your generated command:
```
 > _INSTALL_PATH_/config/dozzle/users.yml
```

and run it again. Now the generated Dozzle user has been placed in the correct location. You can even use `cat _INSTALL_PATH_/config/dozzle/users.yml` to print the file's output just to verify!

Now its time to use the YAMS CLI for the first time: lets restart Dozzle with the new user. Run this command:
```bash
yams restart dozzle
```
Once its fully started again, you are good to go.

---

## Using the interface

### Logging In
Now the user has been created, we can safely sign in and check Dozzle out!!

Open up your Dozzle interface by using this link: [http://_USER_IP_:8777](http://_USER_IP_:8777)

You will see a sign in screen.

{{< image src="/pics/dozzle/dozzle-1.png" alt="Dozzle login screen" title="" loading="auto" >}}

Enter in the username and password you just created your user with. You are in!

### Using Dozzle
Now, Dozzle is a very simple utility. That's a big part of the reason why it is so great. This is what it looks like:

{{< image src="/pics/dozzle/dozzle-2.png" alt="Main Dozzle interface screenshot" title="" loading="auto" >}}

> [!TIP]
> Click on images throughout the guide to temporarily make them bigger. Click again to make them small again.

On the left you will see all the docker containers that are running.

If you don't have any container selected, you will see a nice overview screen! Dozzle will display how much of your server's CPU and RAM is being used in total, and by all of your running applications just below. However, it is more useful to actually use it for its main purpose: viewing logs. Click on the 'radarr' container in the sidebar.

{{< image src="/pics/dozzle/dozzle-3.png" alt="Dozzle container view screenshot" title="" loading="auto" >}}


And wow, look at that! All of the internal logs from Radarr being handily presented straight to you. You can scroll through them, filter them and even search them! This is the ***first*** place you want to look when anything goes wrong with an application because it is where it logs its activity!
*Remember, Dozzle is just a viewer for the Docker container logs. If Dozzle is down, you can still view container logs using the standard `docker logs` commands.*

However, Dozzle has one other handy feature. If you are already in the terminal, using the `yams` CLI is pretty darn easy, but Dozzle actually allows you to stop/start/restart these containers right within the interface. Click on the two-dots icon in the very top right and a context menu will show.

{{< image src="/pics/dozzle/dozzle-4.png" alt="" title="" loading="auto" >}}


And there is it! If you ever need to emergency stop or restart a container from your phone, that is how you can do it. *Remember, Dozzle only shows running container by default! If you want to see stopped ones too, click the three dots at the top left of the sidebar and select 'Show All Containers'.*

> [!INFO]
> Another useful Dozzle feature is selecting 'Shell' from the menu, which connects you to a shell *inside* a Docker container. This is an easier alternative to running `docker exec` commands, and can make setting up/debugging some applications easier.

---

And that is it! Main point: Dozzle is how you check on your containers.

Mostly their logs, but also if they are actually running, and to see their resource usage. Remember this as your progress throughout the guide.

**Next up: qBitTorrent.**