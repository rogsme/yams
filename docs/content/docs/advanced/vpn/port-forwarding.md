---
weight: 40
title: Port Forwarding
---

If you are unsure on what port forwarding is, check out the YAMS [Port Forwarding explanation](/docs/fundamentals/torrenting-and-vpns/#port-forwarding). tldr: It can speed up your downloads and uploads, but is a feature **not offered by all** VPN providers.

---

# How to Enable Port Forwarding

> [!INFO]
> This guide assumes you chose to **not enable port forwarding** in the YAMS installer.

Thanks to Docker, enabling port forwarding is actually very simple! We just have a tweaks some values here and there. Before we get started though, remember that port forwarding is a feature only offered by some VPN providers. Gluetun natively implements port forwarding support for the follow providers: Private Internet Access, ProtonVPN, Perfect Privacy, PrivateVPN. *Only these providers will be covered in this guide.*

> [!WARNING]
> If your provider supports port forwarding but is not in this list, see [Gluetun's port forwarding page](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md) for how to get started.

### 1. First, open up your docker compose

Open up your main YAMS docker compose file located at `_INSTALL_PATH_/docker-compose.yaml`

### 2. Uncomment port forwarding environment variables

Find the container entry for Gluetun, and look at it's environment variables. Inside here, you should find a section for port forwarding related variables. It might look something like this:

```yaml
# port forwarding settings
#- PORT_FORWARD_ONLY=on
#- VPN_PORT_FORWARDING=on
#- 'VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":{{PORT}}}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
#- 'VPN_PORT_FORWARDING_DOWN_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":0}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
```

To enable port forwarding, all you have to do is just uncomment all of these variables out. Do that, and verify it looks like this:

```yaml
# port forwarding settings
- PORT_FORWARD_ONLY=on
- VPN_PORT_FORWARDING=on
#- 'VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":{{PORT}}}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
#- 'VPN_PORT_FORWARDING_DOWN_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":0}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
```

### 3. Restart YAMS

Now, restart your media stack using `yams restart` and you should be good to go. Make sure to check everything is still working after any changes!

> [!SUCCESS]
> If you want to enable automatic updating of your forwarded port within qBitTorrent, follow [the steps in the qBitTorrent setup guide](/docs/configure/qbittorrent/#enable-automatic-port-updating).

---

# How to Disable Port Forwarding

> [!INFO]
> This guide assumes you chose **to enable port forwarding** in the YAMS installer.

Disabling port forwarding is super easy. Literally all you have to do is comment out a few lines 😂.

### 1. First, open up your docker compose

Open up your main YAMS docker compose file located at `_INSTALL_PATH_/docker-compose.yaml`

### 2. Comment out port forwarding environment variables

Find the container entry for Gluetun, and look at it's environment variables. Inside here, you should find a section for port forwarding related variables. It might look something like this:

```yaml
# port forwarding settings
- PORT_FORWARD_ONLY=on
- VPN_PORT_FORWARDING=on
- 'VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":{{PORT}}}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
- 'VPN_PORT_FORWARDING_DOWN_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":0}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
```

To disable port forwarding, all you have to do is just comment all of these variables out. Do that, and verify it looks like this:

```yaml
# port forwarding settings
#- PORT_FORWARD_ONLY=on
#- VPN_PORT_FORWARDING=on
#- 'VPN_PORT_FORWARDING_UP_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":{{PORT}}}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
#- 'VPN_PORT_FORWARDING_DOWN_COMMAND=/bin/sh -c "wget -O- --retry-connrefused --header=\"Authorization: Bearer ${QBITTORRENT_API_KEY}\" --post-data \"json={\\\"listen_port\\\":0}\" http://127.0.0.1:8081/api/v2/app/setPreferences 2>&1"'
```
### 3. Restart YAMS

Now, restart your media stack using `yams restart` and you should be good to go. Make sure to check everything is still working after any changes!

---
