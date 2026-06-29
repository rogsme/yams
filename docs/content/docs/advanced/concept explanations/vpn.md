---
weight: 4
title: VPN
---

# What is a VPN?
A VPN is an **extremely important** tool that should be used in most cases when torrenting.

Normally when you connect to a website, your internet traffic goes through your internet service provider (ISP) who can see everything you do, and identify you based on your IP address and physical location. Obviously, you should be wary about having these constant eyes over the internet activities you engage in, but also look to protect your own information and hardware from dangerous bad actors.

A VPN removes the ability for any third parties to engage in this spying in three main ways:
1. **Encryption:** All your internet traffic is encrypted, meaning it is unintelligibly scrambled and unreadable.
2. **Tunnel:** Your traffic skips your ISP, being sent straight through a 'tunnel' to a VPN server.
3. **Masking:** Any connection with the wider internet is conducted through this VPN server, which may be located anywhere on earth! Thus, your server's IP address and physical location remain hidden.

These VPN servers are managed by a VPN provider, for which you must pay a subscription fee for to utilise them. Despite this cost, **you should always use a VPN when downloading torrents.**

> [!WARNING]
> VPNs are not strictly necessary for a functioning media server, but should only be skipped if you are aware of the severe risks of not using one. If you are adamant about avoiding a VPN, be sure to conduct extensive research into the type of personal information you may be exposing, and the ramifications you might face based on your activities and jurisdiction.



# VPN in YAMS

Knowing that, let's talk about how this VPN fits into YAMS.

YAMS uses [Gluetun](https://github.com/qdm12/gluetun) to manage VPN connections. Gluetun is a docker container that providers a connection to the main VPN providers. This allows us to run the traffic of qBitTorrent (the torrent downloader) and Sabnzbd (the usenet downloader) *through* this Gluetun container, thus masking their outside internet use behind your VPN.

## Picking a VPN

There are many VPN providers, and it can be hard to pick one. First, we'll cover  the things to consider when picking a provider, and then the list of available options.

Considerations when picking a VPN provider:
- **Perfomance + Reputation:** Make sure whatever provider you pick is generally trusted and has decent performance! The best way to test this out is to search around a little on the web, especially looking at online communities like Reddit. Take every post with a grain of salt, but this can help broadly conceptualise if a provider is a trustwothy option.
- **Price:** Make sure your provider has a good deal! Realistically, the difference between VPN providers for an everyday user of YAMS will be small. So, make sure to compare the pricing options and check for sales or deals (e.g with influencers) to ensure that no matter the provider you pick, you are optimising how much of your hard earned cash you have to spend. *Keep in mind, this must be balanced with a level of trustworthiness. Sometimes VPNs can be stupidly cheap for a reason - because they are bad* 🫤.
- **Port forwarding:** Port forwarding is a special feature some VPN providers offers that can improve your connectability and download/upload speeds whilst torrenting. It isn't required, but it can be handy if your provider supports it!
  - To learn more about how torrenting works and what port forwarding is, check out the YAMS docs here LINK HERE

### YAMS Supported Providers

YAMS works with tons of VPN providers! If Gluetun supports it, YAMS does too. Here's the full list, with direct links to their setup guides:

Here are some of the most popular choices for torrenting that support port forwarding:
- [{{< icon "logos/proton-vpn" >}} ProtonVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md) (Recommended by the YAMS creator! Easy to set up and great privacy)
- [{{< icon "logos/private-internet-access" >}} Private Internet Access (PIA)](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/private-internet-access.md) (Can be very good value if you purchase a long time up front)
- [{{< icon "logos/air-vpn" >}} AirVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/airvpn.md)

Some popular options that do *not* have port forwarding capabilities are:
- [{{< icon "logos/mullvad-vpn" >}} Mullvad](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/mullvad.md)
- [{{< icon "logos/surfshark" >}} Surfshark](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/surfshark.md)
- [{{< icon "logos/nord-vpn" >}} NordVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/nordvpn.md)
- [{{< icon "logos/express-vpn" >}} ExpressVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/expressvpn.md)

### Other Options 📋
Here are the rest of the providers that Gluetun also supports. *Providers that also support port forwarding are indicated.*
- [Cyberghost](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/cyberghost.md)
- [FastestVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/fastestvpn.md)
- [Giganews](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/giganews.md)
- [Hidemyass](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/hidemyass.md)
- [IPVanish](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/ipvanish.md)
- [IVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/ivpn.md)
- [Perfect Privacy](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/perfect-privacy.md) *(Supports port forwarding)*
- [Privado](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/privado.md)
- [PrivateVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/privatevpn.md) *(Supports port forwarding)*
- [PureVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/purevpn.md) *(Supports port forwarding)*
- [SlickVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/slickvpn.md)
- [Torguard](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/torguard.md) *(Supports port forwarding)*
- [VPN Secure](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vpn-secure.md)
- [VPN Unlimited](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vpn-unlimited.md) *(Supports port forwarding)*
- [VyprVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vyprvpn.md)
- [Windscribe](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/windscribe.md) *(Supports port forwarding)*
- [Custom Configuration](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md)

Want to use a different VPN? You can set up a [custom VPN provider](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md), but keep in mind this isn't officially supported by YAMS. This is an *advanced* DIY process for experienced server owners who already own a VPN 🛠️!

If you haven't installed YAMS yet and just came to learn more about VPNs, feel free to return to the [installation page](../../getting%20started/installation/#prerequisites).

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
nano {config_path}/.env
```

Update the VPN section with your provider's details:

```bash {filename="config_path/.env"}
# VPN configuration
VPN_ENABLED=y
VPN_SERVICE=myservice     # Your VPN service from the list above
VPN_USER=your-username    # Your VPN username
VPN_PASSWORD=your-pass    # Your VPN password
```

### Step 3: Review Your VPN Provider's Gluetun Configuration

Different VPN providers require different configuration options. Before continuing, review the provider-specific setup instructions in the Gluetun Wiki:

https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers

Find your VPN provider and note any additional environment variables that are required, if there are any. Note any other general information or notices from Gluetun.

These additional environment variables should be added to the `gluetun` service in your Docker Compose file later in this guide.

### Step 4: Update Docker Compose

Open your Docker Compose file:

```bash
nano {config_path}/docker-compose.yaml
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
{user_ip}
Your local IP country is ZYX

Your IPs are different. qBittorrent is working as expected! ✅
```

If the qBittorrent IP differs from your local IP, traffic is successfully being routed through the VPN.

