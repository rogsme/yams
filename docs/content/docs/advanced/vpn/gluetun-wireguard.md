---
weight: 20
title: Switching between OpenVPN and Wireguard
---

Need to switch between VPN protocols? Whether you're moving to **WireGuard** for faster speeds or back to **OpenVPN** for better compatibility, this guide covers both directions - with a focus on **ProtonVPN**.

---

## Switching to WireGuard

WireGuard is a modern VPN protocol that's faster, more efficient, and easier to configure than OpenVPN.

### ProtonVPN Step 1: Get Your WireGuard Private Key

> [!INFO]
> If you do not use ProtonVPN, refer to your respective provider's Gluetun documentation on how to get any required Wireguard values

- Go to [ProtonVPN WireGuard Config Generator](https://account.proton.me/u/0/vpn/WireGuard)
- Select Platform: GNU/Linux
- Select VPN Options:
  + Level for NetShield blocker filtering: Block malware only
  + Moderate NAT - _optional_
  + NAT-PMP (Port Forwarding) - _optional_ (if you enable port forwarding, you need to disable Moderate NAT)
  + VPN Accelerator - _optional_
- Select a server yourself, or use the best server according to current load and position (default)
- Click Download to get the .conf file
- Open the file and copy the value of PrivateKey

It will look something like this:
```
PrivateKey = wOEI9rqqbDwnN8/Bpp22sVz48T71vJ4fYmFWujulwUU=
```

---

### Step 2: Update Your `.env` File

Open your `.env` file:

```
nano _INSTALL_PATH_/.env
```

Comment out the OpenVPN lines and uncomment the WireGuard lines:

```env {filename="_INSTALL_PATH_/.env"}
VPN_TYPE=wireguard

# openvpn specific settings
#VPN_USER=your-openvpn-username      # Comment this out
#VPN_PASSWORD=your-openvpn-password  # Comment this out

# WireGuard specific settings (uncomment all the relevant ones here!)
WIREGUARD_PRIVATE_KEY=wOEI9rqqbDwnN8/Bpp22sVz48T71vJ4fYmFWujulwUU=  # Add your key here
WIREGUARD_ADDRESSES=10.2.0.2/32
#WIREGUARD_PRESHARED_KEY=
```

Ensure your `VPN_TYPE` variable is set to `wireguard`.

> 💡 Not sure how the `.env` file works? Check out our [Environment File Guide](/docs/fundamentals/environment-variables/) to learn how to manage variables like `WIREGUARD_PRIVATE_KEY` securely.

---

### Step 3: Update `docker-compose.yaml`

Find the `gluetun` service's `environment` section. It should currently look like this:

```yaml
  # openvpn specific settings          ← currently active
  - OPENVPN_USER=${VPN_USER}
  - OPENVPN_PASSWORD=${VPN_PASSWORD}
  - OPENVPN_CIPHERS=AES-256-GCM

  # wireguard specific settings         ← currently commented out
  #- WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
  #- WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}
  #- WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
```

Comment out the OpenVPN lines and uncomment the WireGuard lines so it looks like this:

```yaml
  # openvpn specific settings          ← now commented out
  #- OPENVPN_USER=${VPN_USER}
  #- OPENVPN_PASSWORD=${VPN_PASSWORD}
  #- OPENVPN_CIPHERS=AES-256-GCM

  # wireguard specific settings         ← now active
  - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
  - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
  #- WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}
```


---

### Step 4: Restart YAMS

Apply the changes:

```bash
yams restart
```

---

### Step 5: Verify It's Working

Run the VPN check:

```bash
yams check-vpn
```

You should see your qBittorrent IP is different from your local IP — and located in the country you selected for you VPN (if you did, you don't have to!).

Check the Gluetun logs in your Dozzle interface, and give them a quick skim over to make sure everything looks right.

Look for lines like:
```
Using VPN provider: protonvpn
VPN type: wireguard
Port forwarding is enabled
```

---

## Switching to OpenVPN

OpenVPN is the most widely supported VPN protocol and works with nearly every provider. Switch back if you're having compatibility issues or your provider doesn't support WireGuard.

### Step 1: Get Your OpenVPN Credentials

> [!INFO]
> If you do not use ProtonVPN, refer to your respective provider's Gluetun documentation on how to get any required OpenVPN values.

ProtonVPN uses dedicated OpenVPN credentials that are different from your main account login:

- Go to [ProtonVPN Account](https://account.proton.me/u/0/vpn) → **OpenVPN / IKEv2** section
- Copy your **OpenVPN username** and **OpenVPN password**

If you're using a different provider, check their documentation for the correct OpenVPN credentials (usually a username and password, sometimes your account credentials).

---

### Step 2: Update Your `.env` File

Open your `.env` file:

```
nano _INSTALL_PATH_/.env
```

Comment out the WireGuard lines and uncomment the OpenVPN lines:

```env {filename="_INSTALL_PATH_/.env"}
VPN_TYPE=openvpn

# openvpn specific settings
VPN_USER=your-openvpn-username      # Uncomment and set this
VPN_PASSWORD=your-openvpn-password  # Uncomment and set this

# WireGuard specific settings
#WIREGUARD_PRIVATE_KEY=              # Comment this out
#WIREGUARD_PRESHARED_KEY=           # Comment this out
#WIREGUARD_ADDRESSES=               # Comment this out
```

Ensure your `VPN_TYPE` variable is set to `openvpn`.

> [!WARNING]
> ⚠️ ProtonVPN does not support port forwarding over OpenVPN. If you had port forwarding enabled with WireGuard, it will no longer work after switching.

---

### Step 3: Update `docker-compose.yaml`

Find the `gluetun` service's `environment` section. It should currently look like this:

```yaml
  # openvpn specific settings          ← currently commented out
  #- OPENVPN_USER=${VPN_USER}
  #- OPENVPN_PASSWORD=${VPN_PASSWORD}
  #- OPENVPN_CIPHERS=AES-256-GCM

  # wireguard specific settings         ← currently active
  - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
  - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
  #- WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}
```

Comment out the WireGuard lines and uncomment the OpenVPN lines so it looks like this:

```yaml
  # openvpn specific settings          ← now active
  - OPENVPN_USER=${VPN_USER}
  - OPENVPN_PASSWORD=${VPN_PASSWORD}
  - OPENVPN_CIPHERS=AES-256-GCM

  # wireguard specific settings         ← now commented out
  #- WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
  #- WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}
  #- WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
```

---

### Step 4: Restart YAMS

Apply the changes:

```bash
yams restart
```

---

### Step 5: Verify it's working

Run the VPN check:

```bash
yams check-vpn
```

You can also check the Gluetun logs in the Dozzle interface.

Look for lines like:
```
Using VPN provider: protonvpn
VPN type: openvpn
```

---

> [!WARNING]
> ⚠️ Not all providers support WireGuard or port forwarding. Check their documentation carefully.
