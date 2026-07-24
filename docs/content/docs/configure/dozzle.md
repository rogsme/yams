---
weight: 10
title: Dozzle
---

Installation is complete! Good job. However, this was the easiest step. You still have all the containers and services to configure. Don't worry though, we will walk you through it step by step. The first service we will configure is Dozzle.

---

# Dozzle

### What is Dozzle?

> [!INFO]
> If you are unsure what Docker is, or how it works, please read the [Docker Fundamentals](/docs/fundamentals/docker-and-compose/) page first.

Dozzle is a simple log viewer for Docker containers. It allows you to view the logs of your containers in real time, which is very useful for troubleshooting and monitoring your applications. It also providers the ability to perform simple actions on containers such as stop, start, update, and even run commands inside! It will help us verify that everything is working as we go along, and allow us to spot any errors that might occur.

*Check out Dozzle's Github [here](https://github.com/amir20/dozzle) and the documentation [here](https://dozzle.dev/guide/getting-started).*

## Configuring Dozzle

Now, Dozzle will be broken until we configure authentication for it. Since it can perform actions on containers, YAMS creates it with authentication enabled by default. To actually use the interface, we need to create a user with a name and password to sign in as.

ADD DYNAMIC COMMAND GENERATOR HERE

Run this command, replacing `admin` with your desired username, `password` with your desired password, and `Name` with your desired name. This will generate a hashed password for you and add a new user into the `[[install_path]]/config/dozzle/users.yml` (seriously, you can check after).
```bash
docker run -it --rm amir20/dozzle generate admin --password password --name "Name"
```

