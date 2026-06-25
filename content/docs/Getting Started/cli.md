---
weight: 3
---

# Using the CLI

Before we get into configuring all our new apps, lets take a quick break and learn about a handy tool that just got installed: **the YAMS CLI**. This adds a new `yams` command onto your machine that makes managing your media server a breeze.

You don't need to run these commands now, just skim through the page to get an idea of what it can do. You can always refer back later!

## Getting Started

To see what your YAMS CLI can do, just type:

```
yams --help
```

You’ll get a nice overview of all available commands:

```
yams - Yet Another Media Server

Usage: yams [command] [options]

Commands:
restart                   restarts yams services (can specify service names)
stop                      stops all yams services (can specify service names)
destroy                   destroy yams services so you can start from scratch (can specify service names)
backup                    backs up yams to the destination location
start                     starts yams services (can specify service names)
update-containers         updates all yams containers
--help                    displays this help message
check-vpn                 checks if the VPN is working as expected
status                    checks yams services status
```

## Available Commands

### `yams start`

Fires up your YAMS services. It’s like pressing the “ON” button for your media server! You can start all services or specify individual ones. The CLI will even show you a nice progress bar and let you know when everything’s up and running (when starting all services).

Examples:

```
yams start             # Starts all YAMS services
yams start jellyfin    # Starts only the 'jellyfin' service
```

### `yams stop`

Gracefully stops your YAMS services. Think of it as tucking your media server in for a good night’s rest. You can stop all services or specify individual ones. All downloads will be paused, and all services will shut down properly.

Examples:

```
yams stop             # Stops all YAMS services
yams stop prowlarr    # Stops only the 'prowlarr' service
```

### `yams restart`

Having a hiccup with one of your services? This command is like giving your media server a quick refresh by restarting it! You can restart all services or specify individual ones.

Examples:

```
yams restart             # Restarts all YAMS services
yams restart sonarr      # Restarts only the 'sonarr' service
```

### `yams backup [destination]`

Your safety net! Backs up your entire YAMS configuration to keep your setup safe. Just tell it where to save the backup:

```
yams backup ~/my-backups
```

This will:

- Stop all services (temporarily)
- Create a timestamped backup file
- Start everything back up
- Tell you exactly where your backup is saved

### `yams update-containers`

Keep your containers fresh! This command updates all your YAMS containers to the latest versions. Try and do this every now and then, its great to take advantage of the newly released features (but also the security fixes).

This will:

- Show you a warning about potential compatibility issues
- Ask for confirmation (safety first!)
- Pull the latest container images
- Restart all YAMS services with the new versions

> [!INFO]
> The command will suggest creating a backup first (with `yams backup`) to avoid any data loss if something goes wrong. Always a good idea before updating!

### `yams check-vpn`

Your privacy guardian! This command makes sure your VPN is doing its job by:

1. Checking your real IP address
2. Checking qBittorrent’s IP address
3. Comparing them to make sure they’re different
4. Showing you which countries both IPs are from
5. If something’s wrong and it isn't masking your location, it’ll let you know right away!

### `yams destroy`

> [!CAUTION]
> Do not use this command unless you are aware of its critical affects. It cannot be undone.

This command completely removes YAMS services so you can start fresh. You can destroy all services, or specific ones. But don’t worry - it’ll ask for confirmation first! We don’t want any accidents. 😅

Examples:

```
yams destroy             # Destroys all YAMS services, containers, volumes, and the custom network
yams destroy radarr      # Destroys only the 'radarr' service (its container and volume)
```

---

## Updating the CLI 🔧

Every now and then the YAMS CLI gets new features and improvements. To update it without repeating the install process:

1. Open the `/usr/local/bin/yams` file in a text editor with sudo permissions.
2. Copy the two lines just below the `# Constants` comment. These lines define the `INSTALL_DIRECTORY` and `DC` variables. You’ll need to keep these lines intact and accessible somewhere else whilst you reset the file!
3. Replace all of the existing content with the latest version from the Gitlab repository: https://gitlab.com/rogs/yams/-/raw/master/yams?ref_type=heads.
4. Replace the empty `INSTALL_DIRECTORY` and `DC` variable values with the ones you copied in step 2. This ensures that your CLI continues to work with your existing YAMS installation.
5. Save and close the file. Your CLI is now updated to the latest version!

---

Perfect. You are now ready to tackle the main setup. I believe in you!
