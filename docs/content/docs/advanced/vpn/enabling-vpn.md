---
weight: 1
title: Enabling/Disabling the VPN
---


# Enabling the VPN

Have you already set up YAMS without a VPN and want to enable it manually?

Let's walk through enabling your VPN manually.

### Step 1: Stop YAMS

```bash
yams stop
```

### Step 2: Configure Your VPN Settings

Open your `.env` file:

```
nano [[install_path]]/.env
```

Update the VPN section with your provider's details:

```bash {filename="[[install_path]]/.env"}
# VPN configuration
VPN_SERVICE=protonvpn
VPN_TYPE=openvpn

# openvpn specific settings
VPN_USER=your-username
VPN_PASSWORD=your-password

# WireGuard specific settings
#WIREGUARD_PRIVATE_KEY=wireguard_private_key
#WIREGUARD_PRESHARED_KEY=wireguard_preshared_key
#WIREGUARD_ADDRESSES=wireguard_addresses

```
> [!INFO]
> OpenVPN is supported by nearly every VPN provider and is simpler to setup. Wireguard is generally faster and uses less CPU, but is not supported by all providers. Review the Gluetun documentation for your provider before continuing, and determine which VPN protocol you plan to use.

Make sure to uncomment/comment relevant sections of your env file! The example above is for OpenVPN. If you wish to use Wireguard, comment out the OpenVPN section and uncomment the relevant Wireguard values!

If you want to use Wireguard, follow the Gluetun steps for your provider to get required Wireguard `ENV` values. Note any other general information or notices from Gluetun.

### Step 3: Update Docker Compose

Open your Docker Compose file:

```
nano [[install_path]]/docker-compose.yaml
```

#### Uncomment correct ENV vars in Gluetun entry

Find the `gluetun` service. Ensure that the correct sections are uncommented. For example, if you are using Wireguard, ENV vars inside the OpenVPN section should be commented out.

If you wish to use port forwarding and are certain your provider supports it, ensure the variables `PORT_FORWARD_ONLY=on` and `VPN_PORT_FORWARDING=on` are set in your Gluetun instance.

#### Route qBittorrent Through Gluetun

Find the qBittorrent section, comment out the ports, and uncomment the `network_mode` line:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
qbittorrent:
  # ports:
  #   - 8081:8081
  network_mode: "service:gluetun"
```

This routes qBittorrent's traffic through the VPN.

#### Route SABnzbd Through Gluetun (if enabled)

If you use SABnzbd, make similar changes:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
sabnzbd:
  # ports:
  #   - 8080:8080
  network_mode: "service:gluetun"
```

This routes SABnzbd's traffic through the VPN.

#### Enable the Gluetun Service

Find the `gluetun` service and comment out or remove the `profiles` line:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
# profiles: ["disabled"]
```

#### Add Any Provider-Specific Variables

If your VPN provider **requires** additional environment variables from the Gluetun Wiki, add them to the `gluetun` service's `environment` section. Or, if you want to configure some optional values, set them here too!

Example:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
gluetun:
  environment:
    - SERVER_COUNTRIES=Antarctica
    - CUSTOM_KEY=value
```

> It can be a smart idea to add *sensitive* variables into your `.env` file, and then pass them through into the container by adding them to Gluetun's docker compose entry.

### Step 4: Restart YAMS

```bash
yams restart
```

### Step 5: Verify Everything Works

```bash
yams check-vpn
```

You should see output similar to:

```
Getting your qBittorrent IP...
<qbittorrent_ip>
Your country in qBittorrent is XYZ

Getting your IP...
[[user_ip]]
Your local IP country is ZYX

Your IPs are different. qBittorrent is working as expected! ✅
```

If the qBittorrent IP differs from your local IP, traffic is successfully being routed through the VPN.

# Disabling the VPN

> [!WARNING]
> It is not advised you disable your VPN! However, if you wish to operate YAMS without a VPN connection, follow these steps:

### Step 1: Stop YAMS

```bash
yams stop
```

### Step 2: Disable the Gluetun Container

Find the `gluetun` service in your Docker Compose file and uncomment the `profiles` line:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
# profiles: ["disabled"]
```

It should become:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
profiles: ["disabled"]
```

This prevents Gluetun from starting when YAMS is up.

### Step 3: Disconnect qBittorrent from the VPN

Find the qBittorrent section, comment out the `network_mode` line, and uncomment the ports:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
qbittorrent:
  ports:
    - 8081:8081
  # network_mode: "service:gluetun"
```

This exposes qBittorrent directly on your host network so it remains accessible without the VPN.

### Step 4: Disconnect SABnzbd from the VPN (if enabled)

If you use SABnzbd, make similar changes:

```yaml {filename="[[install_path]]/docker-compose.yaml"}
sabnzbd:
  ports:
    - 8090:8080
  # network_mode: "service:gluetun"
```

### Step 5: Clear VPN Configuration (optional)

To optionally clean up, open your `.env` file and clear the VPN variables:

```bash
nano [[install_path]]/.env
```

Set them to empty values:

```bash {filename="[[install_path]]/.env"}
VPN_ENABLED=
VPN_SERVICE=
VPN_USER=
VPN_PASSWORD=
VPN_TYPE=
#WIREGUARD_PRIVATE_KEY=
#WIREGUARD_PRESHARED_KEY=
#WIREGUARD_ADDRESSES=
```

### Step 6: Restart YAMS

```bash
yams restart
```

Gluetun will no longer start, and qBittorrent and SABnzbd will be accessible directly on your host network.


