---
weight: 3
title: Running Prowlarr behind a VPN
---


# Extra Privacy for Prowlarr 🔒

While downloading .torrent files isn't usually illegal, some ISPs might try to block your access to indexers. Let's fix that by putting Prowlarr behind your VPN!

## Why Put Prowlarr Behind the VPN? 🤔

1. **Bypass ISP Blocks**: Some ISPs block torrent indexer websites
2. **Extra Privacy**: Keep your searches private
3. **Better Access**: Reach indexers that might be geo-blocked in your country

## Configuration Steps 🛠️

We'll need to modify two services in your `docker-compose.yaml` file: Prowlarr and Gluetun. Let's do this step by step!

### Step 1: Modify Prowlarr's Config
First, let's update Prowlarr to use the VPN network. Open your `docker-compose.yaml` and find the Prowlarr service:

```yaml
prowlarr:
    image: lscr.io/linuxserver/prowlarr
    container_name: prowlarr
    # Delete or comment out the 'ports' section
    # ports:
    #   - 9696:9696
    network_mode: "service:gluetun"  # Add this line
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
    volumes:
      - ${INSTALL_DIRECTORY}/config/prowlarr:/config
    restart: unless-stopped
    # Delete or comment out the 'networks' section
    # networks:
    #   yams_network:
    #     ipv4_address: 172.60.0.17
```

Key changes:
1. Remove or comment out the `ports` section
2. Add `network_mode: "service:gluetun"`
3. Remove or comment out the `networks` section

### Step 2: Update Gluetun's Config
Now we need to tell Gluetun to handle Prowlarr's traffic. Find the Gluetun service in your `docker-compose.yaml`:

```yaml
gluetun:
    image: qmcgaw/gluetun:v3
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8888:8888/tcp   # HTTP proxy
      - 8388:8388/tcp   # Shadowsocks
      - 8388:8388/udp   # Shadowsocks
      - 8080:8080/tcp   # gluetun
      - 9696:9696/tcp   # Add this line for Prowlarr
    # Leave the rest as is
```

Key changes:
1. Add `9696:9696/tcp` to the ports

### Step 3: Apply the Changes 🔄

Save your changes and restart YAMS:
```bash
yams restart
```

### Step 4: Update Prowlarr's Application Connections 🔗

Because Prowlarr is now routing its traffic through the VPN (Gluetun), it won't be able to resolve the internal Docker service names (like `radarr`, `sonarr`, `lidarr`) directly. You'll need to update the "Host" or "Server" settings for your connected applications within Prowlarr's "Apps" configuration to use their specific IP addresses.

1. **Access Prowlarr**: Go to `http://your-ip:9696`
2. **Navigate to Settings > Apps**: Click on the "Apps" tab.

{{< image src="/pics/prowlarr-behind-vpn-1.png" alt="" title="" loading="auto" >}}

3. **Edit Each Application**: For Radarr, Sonarr, and Lidarr, click on their respective entries to edit them.

**For Sonarr**:
  * Change the "Sonarr Server" URL from `http://sonarr:8989` to `http://172.60.0.13:8989`.
  * Ensure "Prowlarr Server" is set to `http://your-host-ip:9696` (replace `your-host-ip` with the actual IP address of your YAMS host, e.g., `192.168.0.190`).
  * Click "Test" and then "Save".

{{< image src="/pics/prowlarr-behind-vpn-2.png" alt="" title="" loading="auto" >}}

**For Radarr**:
  * Change the "Radarr Server" URL from `http://radarr:7878` to `http://172.60.0.14:7878`.
  * Ensure "Prowlarr Server" is set to `http://your-host-ip:9696` (replace `your-host-ip` with the actual IP address of your YAMS host, e.g., `192.168.0.190`).
  * Click "Test" and then "Save".

{{< image src="/pics/prowlarr-behind-vpn-3.png" alt="" title="" loading="auto" >}}

**For Lidarr (Optional, if you want to use Lidarr)**:
  * If you haven't added Lidarr yet, click the `+` button, select "Lidarr".
  * Set "Prowlarr Server" to `http://your-host-ip:9696` (replace `your-host-ip` with the actual IP address of your YAMS host, e.g., `192.168.0.190`).
  * Set "Lidarr Server" to `http://172.60.0.15:8686` (assuming Lidarr uses port 8686).
  * Paste your Lidarr API Key.
  * Click "Test" and then "Save".

{{< image src="/pics/prowlarr-behind-vpn-4.png" alt="" title="" loading="auto" >}}

After updating all applications, click "Sync App Indexers" on the main Apps page.

## Testing Your Setup 🎯

After YAMS restarts, check that:
1. You can still access Prowlarr at `http://your-ip:9696`
2. Your indexers still work
3. The search function works correctly

## Troubleshooting 🔧

### Can't Access Prowlarr?
1. Check Gluetun's logs:
```bash
docker logs gluetun
```
2. Verify your subnet setting is correct
3. Make sure the port mapping is right in both services

### Indexers Not Working?
1. Check your VPN connection:
```bash
yams check-vpn
```
2. Try accessing an indexer manually through Prowlarr
3. Check Prowlarr's logs for any errors

### Still Having Issues?
1. Compare your configuration with the examples above
2. Make sure your VPN provider allows port forwarding
3. Try a different VPN server

## Pro Tips 💡

1. **Speed Matters**: Choose a VPN server close to you for better performance
2. **Regular Checks**: Use `yams check-vpn` to verify your VPN is working
3. **Monitor Logs**: Keep an eye on both Prowlarr and Gluetun logs for issues

## Need Help? 🆘

If you're stuck:
1. Check the [Common Issues](/faqs/common-errors/) page
2. Visit the [YAMS Forum](https://forum.yams.media)
3. Join our [Discord](https://discord.gg/Gwae3tNMST) chat

Remember: Taking a few extra steps for privacy is always worth it! Stay safe out there! 🛡️