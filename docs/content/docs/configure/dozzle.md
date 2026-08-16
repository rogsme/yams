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

### Creating a user

Since Dozzle can perform actions on containers, YAMS creates it with authentication enabled by default. The installer utilises a completely random hash as its default user, meaning it is impossible to sign into the default `yams` account. But don't worry, we are about to create you one you can actually use!

In order to create this user, we will have to generate a valid user YAML to add into our Dozzle configuration files. Utilise the generator below to build this command for you:
- `username` is the, well, username of your new user
- `password` is the password for this new user
- `name` is the display name that will show in the UI

> [!WARNING]
> Always be careful about entering your credentials into websites. The code for YAMS is fully open source [here](https://git.rogs.me/rogs/yams) and does not take any action from your entered credentials apart from command generation.

{{< dozzle-user-generator >}}

After you have filled out and copied the generation command for *your* user, copy it and run it on your machine.

You'll get something like this:
```yml
users:
    admin:
        email: ""
        name: Admin
        password: $2a$11$FYTyP5VcWdhCwaUjMRx2eOoYPrLkck3jK7y5PORcg36qfWfQeoWQ2
        filter: ""
        roles: ""
```

Perfect. Open up the Dozzle `users.yml` file in your favorite text editor:
```
nano _INSTALL_PATH_/config/dozzle/users.yml
```
and delete  **all** the contents and replace it with the output from the command above. Save and exit.

Now its time to use the YAMS CLI for the first time: lets restart Dozzle with the new user. Run this command:
```bash
yams restart dozzle
```
Once its fully started again, you are good to go.

---

## Using the interface

Now the user has been created, we can safely sign in and check Dozzle out!!

Open up your Dozzle interface by using this link: [http://_USER_IP_:8777](http://_USER_IP_:8777)

You will see a sign in screen.

{{< image src="/pics/dozzle/dozzle-1.png" alt="" title="" loading="auto" >}}

Enter in the user and password you user before to create your user.
