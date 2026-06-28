---
weight: 4
title: VPN + Port Forwarding
---


# Keeping Your Downloads Private 🔒

Let's talk about VPNs! While they might seem like an optional extra, **you should always use a VPN when downloading torrents**. It's not just about privacy - it's about keeping you safe and sound on the internet!

YAMS uses [gluetun](https://github.com/qdm12/gluetun) to manage VPN connections. It's like a super-smart traffic controller for your downloads! 🚦

## Supported VPN Providers 🌐

YAMS works with tons of VPN providers! Here's the full list, with direct links to their setup guides:

### Popular Choices 🌟
- [ProtonVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md) (Recommended! Easy to set up and great privacy)
- [Mullvad](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/mullvad.md)
- [NordVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/nordvpn.md)
- [Private Internet Access](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/private-internet-access.md)
- [Surfshark](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/surfshark.md)

### Full Provider List 📋
- [AirVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/airvpn.md)
- [Cyberghost](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/cyberghost.md)
- [ExpressVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/expressvpn.md)
- [FastestVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/fastestvpn.md)
- [Hidemyass](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/hidemyass.md)
- [IPVanish](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/ipvanish.md)
- [IVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/ivpn.md)
- [Perfect Privacy](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/perfect-privacy.md)
- [Privado](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/privado.md)
- [PrivateVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/privatevpn.md)
- [PureVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/purevpn.md)
- [SlickVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/slickvpn.md)
- [Torguard](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/torguard.md)
- [VPN Secure](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vpn-secure.md)
- [VPN Unlimited](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vpn-unlimited.md)
- [VyprVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vyprvpn.md)
- [WeVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/wevpn.md)
- [Windscribe](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/windscribe.md)

Want to use a different VPN? You can set up a [custom VPN provider](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md), but keep in mind this isn't officially supported by YAMS. You'll be in DIY territory! 🛠️

## Manual Configuration 🔧

Let's walk through setting up your VPN manually. For this guide, I'll assume your YAMS is installed in `/opt/yams` - adjust the paths if you installed it somewhere else!

### Step 1: Stop YAMS
```bash
yams stop
```

### Step 2: Configure Your VPN Settings
Open your `.env` file:
```bash
nano /opt/yams/.env
```

Find the VPN section and update it:
```bash
# VPN configuration
VPN_ENABLED=y
VPN_SERVICE=protonvpn     # Your VPN service from the list above
VPN_USER=your-username    # Your VPN username
VPN_PASSWORD=your-pass    # Your VPN password
```

### Step 3: Update Docker Compose
Open `docker-compose.yaml`:
```bash
nano /opt/yams/docker-compose.yaml
```

Find the qBittorrent section and make these changes:
```yaml
  qbittorrent:
    # ports:     # Comment out these lines
    #  - 8081:8081
    network_mode: "service:gluetun"  # Uncomment this line
```

Find the SABnzbd section and make similar changes:
```yaml
  sabnzbd:
    # ports:     # Comment out these lines
    # - 8080:8080
    network_mode: "service:gluetun"  # Uncomment this line
```

At the bottom, find the gluetun section and uncomment these ports:
```yaml
  gluetun:
    ports:
      - 8080:8080/tcp  # Uncomment this line
      - 8081:8081/tcp  # Uncomment this line
```

### Step 4: Restart and Test
```bash
yams restart
```

### Step 5: Verify Everything Works
```bash
yams check-vpn
```

You should see something like:
```bash
Getting your qBittorrent IP...
<qbittorrent_ip>
Your country in qBittorrent is Brazil

Getting your IP...
<your_local_ip>
Your local IP country is North Korea

Your IPs are different. qBittorrent is working as expected! ✅
```

If you get an error, double-check all your settings and make sure they're correct!

## Pro Tips 🎯

1. **Regular Checks**: Run `yams check-vpn` periodically to make sure your VPN is working correctly
2. **Kill Switch**: YAMS automatically includes a kill switch - if the VPN goes down, your downloads stop too!
3. **Speed Matters**: Choose a VPN server that's relatively close to you for better download speeds
4. **Port Problems**: If you can't access qBittorrent after setting up the VPN, check the troubleshooting section below

## Switching to WireGuard ⚡

By default, YAMS uses **OpenVPN** for Gluetun. But if your VPN provider supports it, you can switch to **WireGuard** for faster speeds and quicker connections.

We recommend ProtonVPN for this, and we’ve written a full guide to help you switch:

👉 [Switching Gluetun to WireGuard](/advanced/wireguard/)

> 💡 If you store your WireGuard private key in the `.env` file, make sure to read the [Environment File Guide](/advanced/env-file/) to learn how to manage secrets securely.

## ProtonVPN Free Tier 🆓

If you're using a **free ProtonVPN account**, there are a few important things to know:

1.  **No Port Forwarding**: ProtonVPN's free tier does **not** support port forwarding. This means you cannot use `VPN_PORT_FORWARDING=on` or append `+pmp` to your username. The YAMS installer will automatically disable port forwarding if you select ProtonVPN and indicate you are using the free tier.
2.  **Specific Gluetun Configuration**: To ensure Gluetun connects to the free servers, you need to set the `FREE_ONLY` environment variable to `on` in your `gluetun` service configuration.

Here's how your `gluetun` service in `docker-compose.yaml` should look for a free ProtonVPN account (assuming OpenVPN, which is the default for free tier):

```yaml
  gluetun:
    image: qmcgaw/gluetun:v3
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8888:8888/tcp # HTTP proxy
      - 8388:8388/tcp # Shadowsocks
      - 8388:8388/udp # Shadowsocks
      - 8003:8000/tcp # Admin
      - 8080:8080/tcp # gluetun
      - 8081:8081/tcp # gluetun
    environment:
      - VPN_SERVICE_PROVIDER=protonvpn
      - VPN_TYPE=openvpn
      - OPENVPN_USER=${VPN_USER}
      - OPENVPN_PASSWORD=${VPN_PASSWORD}
      - OPENVPN_CIPHERS=AES-256-GCM
      - FREE_ONLY=on # <--- Add this line for free tier
      #- PORT_FORWARD_ONLY=on # <--- Comment out or remove this line
      #- VPN_PORT_FORWARDING=on # <--- Comment out or remove this line
      - FIREWALL_OUTBOUND_SUBNETS=172.60.0.0/24
    restart: unless-stopped
    networks:
      yams_network:
        ipv4_address: 172.60.0.18
```

**Important**: If you are using the free tier, you will **not** be able to use port forwarding. This means some torrenting features (like being a seed for others) might be limited.

For more details on ProtonVPN's free tier and Gluetun, refer to the [gluetun ProtonVPN documentation](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md).

## Troubleshooting 🔧

### Common Issues:

1. **Can't access qBittorrent:**
   - Check gluetun logs: `docker logs gluetun`
   - Verify your VPN credentials
   - Make sure ports are configured correctly

2. **VPN keeps disconnecting:**
   - Try a different VPN server
   - Check your internet connection
   - Review the gluetun logs for errors

3. **Slow speeds:**
   - Try a server closer to your location
   - Check if your VPN provider throttles P2P traffic
   - Some providers have specialized servers for torrenting - try those!

## Need Extra Security? 🛡️

Want to double-check that your torrent client is really using the VPN? Head over to [Double-checking your torrent client IP address](/advanced/torrenting/#double-checking-your-torrent-client-ip-address) for a detailed guide!

## Still Need Help? 🆘

If you're stuck:
1. Check our [Common Issues](/faqs/common-errors/#gluetun-does-not-connect) page
2. Visit the [YAMS Forum](https://forum.yams.media)
3. Join our [Discord](https://discord.gg/Gwae3tNMST) chat

Remember: A working VPN is crucial for safe downloading. Take the time to set it up right, and you'll be good to go! 🚀

---


Port forwarding helps you get better download speeds by allowing incoming connections to your torrent client. YAMS enables port forwarding by default, but setup varies by VPN provider.

## ProtonVPN Users 🚀
ProtonVPN makes port forwarding easy! Just follow these steps:

> 🆕 ProtonVPN now supports **WireGuard with port forwarding**! If you want faster VPN performance, check out our [Switching Gluetun to WireGuard](/advanced/wireguard/) guide.

### Setup from zero

If you didn’t set up port forwarding with the YAMS installer, start here.

If you did set up port forwarding with the YAMS installer, skip ahead to [Automatically change to the forwarded port](#automatically-change-to-the-forwarded-port).

#### Update your .env file

For OpenVPN users, you need to modify your `OPENVPN_USER` in your `.env` file.
- Open your `.env` file (usually located at `/opt/yams/.env`) using `nano`:
  ```bash
  nano /opt/yams/.env
  ```
- Locate the `VPN_USER` line and append `+pmp` to your username, as shown in this example:

```bash
# VPN configuration
VPN_ENABLED=y
VPN_SERVICE=protonvpn
VPN_USER=your_user+pmp # Append +pmp here!
VPN_PASSWORD=your_password
```

- Save the file and exit nano (Ctrl+S, then Ctrl+X).

#### Update your Docker Compose file

Open your Docker Compose file, located at `/your/install/location/docker-compose.yaml`, and update these variables:

```yaml
  # Gluetun is our VPN, so you can download torrents safely
  gluetun:
    image: qmcgaw/gluetun:v3.41.0
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8888:8888/tcp # HTTP proxy
      - 8388:8388/tcp # Shadowsocks
      - 8388:8388/udp # Shadowsocks
      - 8003:8000/tcp # Admin
      - 8080:8080/tcp # gluetun
      - 8081:8081/tcp # gluetun
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_SERVICE}
      - VPN_TYPE=openvpn
      - OPENVPN_USER=${VPN_USER}
      - OPENVPN_PASSWORD=${VPN_PASSWORD}
      - OPENVPN_CIPHERS=AES-256-GCM
      - PORT_FORWARD_ONLY=on  # Change this!
      - VPN_PORT_FORWARDING=on  # Change this!
      - FIREWALL_OUTBOUND_SUBNETS=172.60.0.0/24
    restart: unless-stopped
    networks:
      yams_network:
        ipv4_address: 172.60.0.18
```

Summary of changes:
- `PORT_FORWARD_ONLY` should be set to `on`.
- `VPN_PORT_FORWARDING` should be set to `on`.

## Automatically change to the forwarded port
VPN providers can often change your forwarded port without notice when you restart your VPN, breaking your qBitTorrent connection.

Fix this issue by adding these two environment variables to your Gluetun container:
```yaml
environment:
- VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c 'wget -O- --retry-connrefused --post-data "json={\"listen_port\":{{PORT}},\"current_network_interface\":\"{{VPN_INTERFACE}}\",\"random_port\":false,\"upnp\":false}" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1'
- VPN_PORT_FORWARDING_DOWN_COMMAND=/bin/sh -c 'wget -O- --retry-connrefused --post-data "json={\"listen_port\":0,\"current_network_interface\":\"lo\"}" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1'
```

For this to work, the qBittorrent web UI server must be enabled and listening on port 8081 and the Web UI "Bypass authentication for clients on localhost" must be ticked (json key bypass_local_auth) so Gluetun can reach qBittorrent without authentication. Both of these should already be correctly configured if you set up your qBitTorrent instance as per the [YAMS config guide](/config/qbittorrent).

Then, restart Gluetun, and you are done! When port forwarding is established, the Gluetun container will contact your qBitTorrent instance, automatically updating the port number.

*Read more about this Gluetun feature [here](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md#custom-port-forwarding-updown-command)*

## Other VPN Providers 🌐
For other VPN providers, port forwarding configuration varies.

> 💡 Some providers support WireGuard too! See [Switching Gluetun to WireGuard](/advanced/wireguard/) for details.

Gluetun natively supports port forwarding for these providers:
- Private Internet Access
- ProtonVPN
- Perfect Privacy
- PrivateVPN

For detailed provider-specific instructions, check the [Gluetun Port Forwarding Documentation](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md).

> ⚠️ Remember, if your provider needs custom environment variables, they must be provided in the containers `environment:` section. Variables defined within the YAMS `.env` file can be acessed by the `docker-compose.yml` file, but not within the containers themselves! Check out [Your Environment File (.env)](/advanced/content/advanced/env-file) for more info.

## Verifying Port Forwarding ✅
To check if port forwarding is working:

1. Run `curl http://localhost:8003/v1/portforward` to see which port is currently forwarded by your VPN. Note this port number for the next step.
2. Visit [Open Port Check Tool](https://www.yougetsignal.com/tools/open-ports/) and test your port by using your public VPN IP and the active port
3. Check qBittorrent's connection status - it should show "Connection Status: Connected"

{{< image src="/pics/advanced-port-forwarding-1.png" alt="" title="" loading="auto" >}}

## Troubleshooting 🔧
Look for port forwarding logs in the Gluetun container to diagnose issues:
```bash
   docker logs gluetun | grep "\[port forwarding\]"
```

Need help? Visit our [Common Issues](/faqs/common-errors/) page or join our [Discord](https://discord.gg/Gwae3tNMST) chat!