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

Since Dozzle can perform actions on containers, YAMS creates it with authentication enabled by default. The installer prints a unique password for the bootstrap `yams` user. Use it for the first login, then create your own user and remove the bootstrap account.

ADD DYNAMIC COMMAND GENERATOR HERE

Run this command, replacing `admin` with your desired username, `password` with your desired password, and `Name` with your desired name to show in the interface. This will generate a yml output.
```bash
docker run -it --rm amir20/dozzle generate admin --password password --name "Name"
```

You'll get something like this:
```yml
users:
    admin:
        email: ""
        name: Name
        password: $2a$11$FYTyP5VcWdhCwaUjMRx2eOoYPrLkck3jK7y5PORcg36qfWfQeoWQ2
        filter: ""
        roles: ""
```

Perfect. Open up the Dozzle `users.yml` file in your favorite text editor:
```
nano [[install_path]]/config/dozzle/users.yml
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

THESE LINKS DONT WORK YET, NEED TO FIGURE OUT HOW TO USE PLACEHOLDERS IN MARKDOWN LINKS
Open up your Dozzle interface by using this link: [http://your_ip:8777](http://localhost:8777)

You will see a sign in screen.

{{< image src="/pics/dozzle/dozzle-1.png" alt="" title="" loading="auto" >}}

Enter in the user and password you user before to create your user.
