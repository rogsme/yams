---
weight: 1
title: Enabling/Disabling the VPN
---


## Enabling a VPN

Have you already set up YAMS without a VPN and want to enable it manually?

Let's walk through enabling your VPN manually.

### Step 1: Stop YAMS

```bash
yams stop
```

### Step 2: Configure Your VPN Settings

Open your `.env` file:

```bash
nano [[config_path]]/.env
```

Update the VPN section with your provider's details:

```bash {filename="config_path/.env"}
# VPN configuration
VPN_SERVICE=myservice     # Your VPN service from the list above
VPN_USER=your-username    # Your VPN username
VPN_PASSWORD=your-pass    # Your VPN password
```

### Step 3: Review Your VPN Provider's Gluetun Configuration

Different VPN providers require different configuration options. Before continuing, review the provider-specific setup instructions in the Gluetun Wiki:

https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers

Find your VPN provider and note any additional environment variables that are required, if there are any. If your provider only supports Wireguard, follow the Gluetun steps for your provider to get required Wireguard `ENV` values. Note any other general information or notices from Gluetun.

These additional environment variables should be added to the `gluetun` service in your Docker Compose file later in this guide.

### Step 4: Update Docker Compose

Open your Docker Compose file:

```bash
nano [[config_path]]/docker-compose.yaml
```

#### Update qBittorrent

Find the qBittorrent section and comment out the ports section, and then uncomment the `network_mode` line:

```yaml {filename="config_path/docker-compose.yaml"}
qbittorrent:
  # ports:
  #   - 8081:8081
  network_mode: "service:gluetun"
```

#### Update SABnzbd (if enabled)

If you use SABnzbd, make similar changes:

```yaml {filename="config_path/docker-compose.yaml"}
sabnzbd:
  # ports:
  #   - 8080:8080
  network_mode: "service:gluetun"
```

#### Enable the Gluetun Service

Find the `gluetun` service and ensure the following line is commented out or removed:

```yaml {filename="config_path/docker-compose.yaml"}
profiles: ["disabled"]
```

It should become:

```yaml {filename="config_path/docker-compose.yaml"}
# profiles: ["disabled"]
```

#### Add Any Provider-Specific Variables

If your VPN provider **requires** additional environment variables from the Gluetun Wiki, add them to the `gluetun` service's `environment` section.

Example:

```yaml {filename="config_path/docker-compose.yaml"}
gluetun:
  environment:
    - SERVER_COUNTRIES=Antarctica
    - CUSTOM_KEY=value
```

If your provider supports wireguard, supply all required environment variables.

It can be a smart idea to add sensitive variables into you `.env` file, and then pass them through into the container by adding it to Gluetun's docker compose entry (e.g. `WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}`). Learn more about how the `.env` file works [here](../concept%20explanations/environment-variables).

#### Expose qBittorrent and SABnzbd Through Gluetun

At the bottom of the file, find the `gluetun` service and uncomment these ports:

```yaml {filename="config_path/docker-compose.yaml"}
gluetun:
  ports:
    - 8081:8081/tcp # qbittorrent web UI routed through VPN
    - 8090:8080/tcp # sabnzbd web UI routed through VPN
```

### Step 5: Restart YAMS

```bash
yams restart
```

### Step 6: Verify Everything Works

```bash
yams check-vpn
```

You should see output similar to:

```bash
Getting your qBittorrent IP...
<qbittorrent_ip>
Your country in qBittorrent is XYZ

Getting your IP...
[[user_ip]]
Your local IP country is ZYX

Your IPs are different. qBittorrent is working as expected! ✅
```

If the qBittorrent IP differs from your local IP, traffic is successfully being routed through the VPN.

