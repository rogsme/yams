---
title: FAQs
weight: 1000
---

# Frequently Asked Questions 🤔

## General Questions

### Why another media server script?
YAMS was born from a simple goal: Create a media server that's so easy to use, your non-tech-savvy family members could handle it! While there are other solutions out there, YAMS focuses on simplicity and a beginner-friendly educational approach that doesn't sacrifice on any functionality.

### Why these specific software choices?
YAMS is **opinionated** by design. Every choice was made to create a reliable, user-friendly experience. If you're curious about specific choices:

- **Sonarr/Radarr + Prowlarr**: Standard for automated media and indexer management
- **qBittorrent**: Reliable, open-source torrent client
- **Gluetun**: Robust VPN client
- **Jellyfin/Emby/Plex**: Best self-hosted media streaming options
- **Dozzle**: Easy log management

Don't agree with our choices? That's totally fine! After installation YAMS is just a Docker Compose setup, and you are free to change anything you like.

## Platform Support

### Can I run YAMS on Windows?
While technically possible with Docker for Windows, we don't officially support it. Check out [WIMPS](https://github.com/Xaque8787/WIMPS) instead - it's inspired by YAMS but built specifically for Windows! Although the project has been archived, it could provide a better starting point than YAMS.

### What about macOS?
If you're looking to install YAMS on macOS, you're in luck! A community-maintained fork is available, specifically tailored for macOS.

Please visit [zavan/yams on GitLab](https://gitlab.com/zavan/yams) to access the fork and follow their installation instructions.

### Which Linux distributions are supported?
- **Recommended**: Debian 13
- **Also Supported**: Ubuntu 24.04
- Other distros might work but aren't officially supported

## Advanced Usage

### How do I add custom containers?
Easy! Check out our [Adding Custom Containers](/docs/advanced/custom-containers/) guide. You can add *any* Docker container to work alongside YAMS.

### Can I modify YAMS's default settings?
Absolutely! While YAMS guides setting up sensible defaults, you can customize any settings within your apps. This could include:
- Container configurations
- Download settings
- Media organization
- Network settings
- And much more!


## Network & VPN

### Can I add more containers to the VPN?
Yes! Everything's documented in the [Gluetun connection guide](https://github.com/qdm12/gluetun-wiki/blob/main/setup/connect-a-container-to-gluetun.md). Your Docker Compose file is in your install directory at `_INSTALL_PATH_/docker-compose.yaml`.

### Which VPN providers work with YAMS?
We support many popular providers! Check our [VPN Configuration](/docs/advanced/vpn/) page for the full list.

## Troubleshooting

### Getting Docker permission errors?
Common issue! Check our [Common Errors](/docs/faqs/#common-docker-permission-errors) page for the fix.

### Services not starting?
1. Check the logs: `docker logs container-name`
2. Verify permissions
3. Check our [Common Issues](/docs/faqs/) page

## Getting Help 🆘

Need more help? We've got you covered!

1. **Documentation**
   - Check relevant service docs
   - Review our [Common Issues](/docs/faqs/) page
   - Search existing forum posts

2. **Community**
   - Join our [Discord](https://discord.gg/Gwae3tNMST) to search for similar problems/ask our friendly members
   - Post on our [Forum](https://forum.yams.media)

3. **Issues & Bugs**
   - Check our [GitLab Issues](https://gitlab.com/rogs/yams/-/issues)
   - Search for similar problems
   - Create a new issue if needed

## Contributing 🤝

Want to help make YAMS better? Awesome!
- Fork our repository
- Make your changes
- Submit a pull request
- Or help improve our documentation!

Remember: YAMS is a community project, and we welcome all contributions!

---

# Common YAMS Issues & Solutions 🔧

## Docker Issues

### Permission Denied Errors 🚫
Getting this error when running YAMS commands?
```bash
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

**Quick Fix:**
```bash
# Add yourself to the docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker
```

**Still having issues?**
1. Check group membership:
   ```bash
   groups $USER
   ```
   You should see 'docker' in the list.

2. Verify socket permissions:
   ```bash
   ls -l /var/run/docker.sock
   ```
   Should show: `srw-rw---- 1 root docker`

3. Check Docker service:
   ```bash
   systemctl status docker
   ```

## VPN Issues

### Gluetun Won't Connect 🔌

If your VPN isn't working, let's troubleshoot step by step:

1. **Check Gluetun Logs**
   ```bash
   docker logs -n 100 gluetun
   ```

2. **Common Error Messages:**
   - "Authentication failed": Check your VPN credentials
   - "Network unreachable": Check your internet connection
   - "No such host": DNS issues - check your network settings

3. **Verify VPN Settings**
   ```bash
   # In your .env file
   VPN_ENABLED=y
   VPN_SERVICE=your_provider
   VPN_USER=your_username
   VPN_PASSWORD=your_password
   ```

4. **Test VPN Connection**
   ```bash
   yams check-vpn
   ```

5. **Provider-Specific Issues:**
   - **ProtonVPN**: Make sure to use the correct username ([OpenVPN / IKEv2 username](https://account.proton.me/u/0/vpn/OpenVpnIKEv2))
   - **Mullvad**: Account number needs to be exactly 16 digits
   - **NordVPN**: Use your token, not your regular password

### Quick VPN Fixes 🛠️

1. **Reset VPN Connection**
   ```bash
   yams restart
   ```

2. **Force Container Recreation**
   ```bash
   yams destroy
   yams start
   ```

3. **Verify Network Settings**
   ```bash
   docker network ls
   ```

## Download Client Issues

### qBittorrent Not Accessible 🔒

1. **Check if VPN is Enabled**
   - Review [VPN Configuration](/docs/advanced/vpn/)
   - Run VPN check:
     ```bash
     yams check-vpn
     ```

2. **Verify Port Mappings**
   ```bash
   docker ps | grep qbittorrent
   ```
   Should show port 8081 mapped

3. **Check Network Mode**
   In `docker-compose.yaml`:
   ```yaml
   qbittorrent:
     network_mode: "service:gluetun"
   ```

4. **Review Logs**
   ```bash
   docker logs qbittorrent
   ```

### SABnzbd Connection Issues 📡

1. **Check Service Status**
   ```bash
   docker ps | grep sabnzbd
   ```

2. **Verify Config**
   Look for:
   ```yaml
   sabnzbd:
     ports:
       - 8080:8080
   ```

3. **Check Logs**
   ```bash
   docker logs sabnzbd
   ```

## Media Server Issues

### Jellyfin/Emby/Plex Can't Find Media 📺

1. **Check Permissions**
   ```bash
   ls -l /your/media/directory
   ```
   Should be owned by PUID:PGID from your .env file

2. **Verify Mount Points**
   ```bash
   docker inspect your-media-server
   ```
   Look for "Mounts" section

3. **Path Issues**
   - Inside container: `/data/movies`, `/data/tvshows`
   - On host: Your `MEDIA_DIRECTORY` paths

4. **Scan Library**
   - Trigger manual scan in web UI
   - Check library paths in settings

## Performance Issues

### High CPU Usage 🔥

1. **Check Container Stats**
   ```bash
   docker stats
   ```

2. **Monitor System Resources**
   ```bash
   top
   # or
   htop
   ```

3. **Review Logs for Issues**
   ```bash
   docker logs --tail 100 container-name
   ```

### Memory Problems 💾

1. **Check Available Memory**
   ```bash
   free -h
   ```

2. **Monitor Container Memory**
   ```bash
   docker stats --format "table {{.Name}}\t{{.MemUsage}}"
   ```

3. **Adjust Container Limits**
   In docker-compose.yaml:
   ```yaml
   services:
     your-service:
       mem_limit: 1g
   ```

## Getting More Help 🆘

Still stuck? We've got your back!

1. **Check Detailed Logs**
   ```bash
   # All container logs
   docker-compose logs

   # Specific container
   docker-compose logs container-name
   ```

2. **Community Resources**
   - [YAMS Forum](https://forum.yams.media)
   - [Discord Chat](https://discord.gg/Gwae3tNMST)

3. **Report Issues**
   - Check existing [GitLab issues](https://gitlab.com/rogs/yams/-/issues)
   - Provide logs and configuration when reporting new issues

Remember: Most issues have simple solutions! If you're stuck, our community is here to help! 💪
