---
weight: 1
title: Docker and Docker Compose
---

Welcome to the fundamentals section! Note that these are simplified explanations aimed to equip you with enough knowledge to get started. For more curious media enthusiasts, ask our community or conduct some independent research!

---

# Docker and Docker Compose

YAMS is a media server template that operates using Docker and Docker Compose. But what are both of these technologies?

## What is Docker?

Firstly what is Docker?

Docker is a 'containerization' system that you install on your Linux machine. Instead of installing programs like Radarr, Sonarr and Jellyfin directly onto your server's operating system, they each run inside their own isolated container. A container packages an application together with everything it needs to run, so you don't have to manually install dependencies, configure services, or worry as much about software conflicts.

Lets try a simple analogy! Imagine your server is an apartment building.
- The host operating system is the building itself (e.g Debian/Ubuntu)
- Containers are apartments. Each application runs in its own little apartment
- The applications share the same building infrastructure (the Linux kernel), but they are mostly isolated from each other

This makes it much easier install and manage multiple applications.

### Images

An **image** is a template that a container can be created from. They are a ready-to-go blueprint for everything an app needs, and are mainly created by official project containers. However, anybody can create an image for any container: YAMS mainly uses [Linuxserver](https://www.linuxserver.io/) images, which ensures consistency!

Example:
```yaml
image: lscr.io/linuxserver/sonarr:latest
```

> This tells Docker to create a Sonarr container using the latest Sonarr image created by LinuxServer

### Containers

A **container** is a running instance of an image. It's when you grab the template and start it up so the application gets running!

A running container is like a mini-machine inside your server that represents a running instance of that application. Its a bit like starting up desktop apps on a traditional computer.

This container is like a mini-machine that the app inside is running on, mostly isolated from its host. The container has its own filesystem and its own ports that do not affect the host.

### Volumes

Containers are designed to be disposable. Since they have their own filesystem, they lose everything when you shut it down!

Volumes allow data to survive. It maps a directory (or file) from the host machine *into* the container, so when the container writes data into this directory in its filesystem, it is actually writing into a directory on the host. Since this directory stores data on the host, it does not disappear when the container stops.

This is how the config and media directories of YAMS works.

You might see them dotted around the compose file like this:
```yaml
volumes:
  - ${MEDIA_DIRECTORY}:/data
  - ${INSTALL_DIRECTORY}/config/radarr:/config
```

When the environment variables are substituted in (learn more about env vars [here](../fundamentals/environment-variables)) the Docker compose can be imagined like this:
```yaml
volumes:
  - [[media_path]]:/data
  - [[config_path]]/config/radarr:/config
```

What this means is that the **host** directory of `[[media_path]]` is being mapped into the Radarr container, but inside the container its path is `/data`. When data writes into the `/data` folder inside its little container, it *actually* is writing to your host `[[media_path]]` directory!

```
Server folder: [[media_path]] -> Container folder: /data
```

> [!INFO]
> This is why during configuration you often have to enter paths such as `/data/downloads` or `/data/movies` which don't exist on your host. It's because this is the specific container's path!

### Ports

Ports are how you actually access any of your running applications! A port is a slot your server can serve an application on. You've probably seen them before when having to access applications you run yourself, where you have to type `http://[[user_ip]]:PORT` into your browser.

Just like each container's own filesystem, each container *also* has its own ports. This means Radarr might be running on port `7878` inside you container, but you can't access it unless you map this port to a port on your host!

To make an application accessible on a hosts port, you'll see something like this in your compose:
```
ports:
  - 7878:7878
```
The left side of the colon (:) represents the host port, and the right side represents the container's port. So, this is making a sort of tunnel from the host and container port `7878`, so the container application can be accessed!

> [!INFO]
> The host port and container port don't have to be the same. For example, if an application is created to run on port `1212` but you already have something else on your host port, you could change the entry to `1213:1212`. This means the container's port `1212` will actually be mapped to your host port `1213`, stopping any clashes!

## What is Docker Compose?

Now you know the basics of Docker, it will be simple to explain what Docker Compose is.

It is a type of file (`docker-compose.yaml` and `docker-compose.custom.yaml` in YAMS) that defines what images you want to use, what containers you want to run and what volumes you want to give to each, *and much more!* It is how you interact with these Docker concepts described above, and **extremely** useful to understand.

Let's simplify the YAMS file to just Radarr and take a look at the `radarr` definition:
```yaml
services: # always at the very top, containers go under here
  radarr: # container identifier
    image: lscr.io/linuxserver/radarr # image to use
    container_name: radarr # name to give to the container
    environment: # environment variables to pass into the container
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes: # volumes to map
      - ${MEDIA_DIRECTORY}:/data
      - ${INSTALL_DIRECTORY}/config/radarr:/config
    ports: # ports to map
      - 7878:7878
    restart: unless-stopped # restart if anything goes wrong!
```

As you can see, its a simple way to describe everything Docker needs to get Radarr running for us in a way we can understand! YAMS gets you started by giving you a starter `docker-compose.yaml` with everything complicated (volume mapping, environment vairables) already figured out. You shouldn't have to edit this main one much.

However, YAMS has a `docker-compose.custom.yaml` file ! This is where you add additional container definitions. Don't worry, most application maintainers provide an example Docker compose for getting started. Just remember to correctly alter the volumes to the YAMS paths! See [adding custom containers to YAMS](../advanced/custom-containers/_index).

### Networking

If you want to access an application, you will have to ensure it is accessible on a host port, and then type your server's IP address and respective port into your browser.

However, although this also works for container-to-container communication, it isn't the best way. Instead of using the server IP address, all YAMS containers can actually use each other's container identifier as a hostname! For example, if Radarr wanted to communicate with Sonarr, it doesn't have to use `http://[[user_ip]]:8989`. It can actually use `http://sonarr:8989`, and Docker handles the connection!

> [!WARNING]
> If your qBitTorrent instance is behind a VPN, make sure to use `http://gluetun:8081` in other containers instead of `http://qbittorrent:8081`. Because remember: qBitTorrent is being masked *behind* Gluetun!

---

To learn more, check out [Docker's official page](https://docs.docker.com/get-started/docker-overview/)

---
# YAMS and Docker

YAMS is based on Docker. EXPAND THIS SECTION talking about how it uses two docker compose files, uses comments to selectively alter, uses profiles to disable, and the CLI just wraps docker commands.