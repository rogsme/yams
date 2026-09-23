---
weight: 10
title: qBittorrent
---

## What is qBitorrent?

> [!INFO]
> If you are unsure what torrenting is, or how it works, please read the [What is Torrenting?](/docs/fundamentals/torrenting-and-vpns/#what-is-torrenting) page first.

qBitTorrent is a torrent downloader. It is the application that actually downloads the media onto our filesystem. Pretty easy! 😎

*Check out their website [here](https://www.qbittorrent.org/).*

## Initial configuration

First things first - if you set up a VPN during YAMS installation (which you really should!), qBittorrent should already be configured to use it. Let's verify everything is working correctly.

In your terminal, run:
```bash
yams check-vpn
```

You should see output like this:
```bash
Getting your qBittorrent IP...
<qBittorrent IP>
Your country in qBittorrent is Brazil

Getting your IP...
<your local IP>
Your local IP country is North Korea

Your IPs are different. qBittorrent is working as expected! ✅
```

If the check fails, you'll see something like:
```bash
Getting your qBittorrent IP...
<your local IP>
Your country in qBittorrent is North Korea

Getting your IP...
<your local IP>
Your local IP country is North Korea

Your IPs are the same! qBittorrent is NOT working! ⚠️
```

If your VPN check failed, the issue is almost always related to incorrect credentials or environment variables. Remember, you can check Gluetun's logs using Dozzle! **You should always use a VPN when downloading torrents!**

### Setting up qBittorrent

Let's get qBittorrent configured!
Now, using [Dozzle](http://_USER_IP_:8777/show?name=qbittorrent) (or `docker logs qbittorrent`), check the qBittorrent logs to get your initial login credentials.

You'll see the qBittorrent username and password in the logs:
```
qbittorrent  | ******** Information ********
qbittorrent  | To control qBittorrent, access the WebUI at: http://localhost:8081
qbittorrent  | The WebUI administrator username is: admin
qbittorrent  | The WebUI administrator password was not set. A temporary password is provided for this session: FBFsKbfbD
qbittorrent  | You should set your own password in program preferences.
```

Now, open up the qBitTorrent interface using this link: [http://_USER_IP_:8081](http://_USER_IP_:8081)
*If it doesn't work if you click on it, try copying it into your URL bar.*

Log in using the credentials in the logs:

```bash
username: admin
password: your-temporary-password-from-the-logs
```

{{< image src="/pics/qbittorrent/qbittorrent-1.png" alt="" title="" loading="auto" >}}

After logging in, you'll see the empty qBittorrent window. Click on the gear icon in the top right to enter the settings.

{{< image src="/pics/qbittorrent/qbittorrent-2.png" alt="" title="" loading="auto" >}}

### Configuring BitTorrent Settings

First, go to the "Downloads" tab and set the "Default Save Path" to `/data/downloads/torrents/`.

{{< image src="/pics/qbittorrent/qbittorrent-3.png" alt="" title="" loading="auto" >}}

### Configuring Web UI Settings

Next, go to the "Web UI" tab.
First, set a new username and password to use for your personal account and save it securely externally.

Next, tick the `Bypass authentication for clients in whitelisted IP subnets` setting and add in your local subnet (note the value in the image may not be *your* subnet). This is an **optional step** which increases ease of use but results in a slightly less secure qBitTorrent instance. If this option is not enabled, you will have to sign in every single time you open qBitTorrent.

{{< image src="/pics/qbittorrent/qbittorrent-4.png" alt="" title="" loading="auto" >}}

### Generating an API key

Now, lets generate a qBitTorrent API key. This will be used by our applications to connect to qBitTorrent securely, and allows us to set up automatic port updates if we choose to set up port forwarding. How easy!

First select the green icon and click Yes to generate a key, then copy it.

{{< image src="/pics/qbittorrent/qbittorrent-5.png" alt="" title="" loading="auto" >}}

Lets place this inside our `.env` for easy reference in the future, and so we can provide it to any extra applications that might need it. Open your `_INSTALL_PATH_/.env` file. Uncomment the line with `QBITTORRENT_API_KEY` and paste in the key you just generated. It should look something like this:
```env
# service secrets (remember to uncomment when using them!)
QBITTORRENT_API_KEY=qbt_your_api_key
```

### Enable automatic port updating

Perfect. Now, complete the following steps **only if you have already set up port forwarding using the YAMS installer:**
- Open your main docker compose file at `_INSTALL_PATH_/docker-compose.yaml`
- Find the 'gluetun' container entry
- Uncomment the two lines starting with `#- 'VPN_PORT_FORWARDING_UP_COMMAND=` and `#- 'VPN_PORT_FORWARDING_DOWN_COMMAND=`
- This will make sure Gluetun keeps qBitTorrent informed on which port is actually being forwarded by your VPN so it uses the right one! *To learn more about port forwarding, check out the explanation [here](/docs/fundamentals/torrenting-and-vpns/#port-forwarding)*



### Configuring Network Settings

On the "Advanced" tab, make sure your Network interface is set to `tun0`. This ensures qBittorrent always uses the VPN connection and stops if the VPN goes down.

{{< image src="/pics/qbittorrent/qbittorrent-6.png" alt="" title="" loading="auto" >}}

Finally, scroll to the bottom and click "Save".

{{< image src="/pics/qbittorrent/qbittorrent-7.png" alt="" title="" loading="auto" >}}


## Final VPN Checks

Let's run the YAMS check-vpn command again to make sure qBitTorrent is still up and working:

```bash
yams check-vpn
```
Great! Everything should be configured and ready to go. How about we get testing, eh?

The first will verify that our VPN is truly hiding your IP (you can never be too sure), and the second will verify we can actually download stuff onto our filesystem.

### IP Leak Verification

1. Visit [whatismyip.net’s Torrent Checker](https://www.whatismyip.net/tools/torrent-ip-checker/) and grab their test magnet link by right clicking on the button and selecting 'Copy Link Address'
{{< image src="/pics/qbittorrent/qbittorrent-8.png" alt="" title="" loading="auto" >}}

2. In [qBitTorrent](http://_USER_IP_:8081), click the 'Add Torrent Link' icon
{{< image src="/pics/qbittorrent/qbittorrent-9.png" alt="" title="" loading="auto" >}}


3. Paste the magnet link and click 'Download'. Then, scroll to the bottom of the next window and select 'Add Torrent'.
{{< image src="/pics/qbittorrent/qbittorrent-10.png" alt="" title="" loading="auto" >}}
{{< image src="/pics/qbittorrent/qbittorrent-11.png" alt="" title="" loading="auto" >}}


4. You’ll see a new torrent called 'Torrent Tracker IP Checker' in your list. Don’t worry - it won’t actually download anything!
{{< image src="/pics/qbittorrent/qbittorrent-12.png" alt="" title="" loading="auto" >}}

5. Back on the checker website, you will see your qBitTorrent client's IP.
{{< image src="/pics/qbittorrent/qbittorrent-13.png" alt="" title="" loading="auto" >}}


If this IP address:
- Is different to your real IP address
- Matches the output of `yams check-vpn`
Then you are good to go. You can delete that torrent entry you just added. Gluetun and qBitTorrent are successfully working together to mask your real IP address.

### Download Verification

Now we know your VPN is working, let's see if you can actually download anything! We will test by downloading a Debian ISO. (We will delete it after - it is just for testing).

1. Head over to the [Debian torrent download page](https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/), then scroll to the bottom. Click on the link called `debian-13.6.0-amd64-netinst.iso.torrent` and a `.torrent` file will download onto your computer. *Learn what `.torrent` files are [here](/docs/fundamentals/torrenting-and-vpns/#torrent-file)*

2. Open [qBitTorrent](http://_USER_IP_:8081) and click the 'Add Torrent' icon
{{< image src="/pics/qbittorrent/qbittorrent-14.png" alt="" title="" loading="auto" >}}

3. Select the file you just downloaded onto your computer, then scroll to the bottom of the window and select 'Add Torrent'
{{< image src="/pics/qbittorrent/qbittorrent-15.png" alt="" title="" loading="auto" >}}

4. There you go! In your torrent list, you should see it successfully downloading and the progress bar advancing. You can also see information such as your download speed, peers and ETA for when it will be finished.
{{< image src="/pics/qbittorrent/qbittorrent-16.png" alt="" title="" loading="auto" >}}

If that successfully downloads and swaps to 'Seeding' mode then you are all good! If you are feeling advanced, you can even look inside your `_MEDIA_PATH_/downloads/torrents` directory: you should see the Debian ISO in there.

All our testing is done. Let's clear this up for the future. Click on the Debian torrent to select it, then click the red 'Remove Torrent' trash icon in the top left. Select the 'Also remove the content files' because we don't need to keep the ISO on our disk taking up space. Then click 'Remove'.

{{< image src="/pics/qbittorrent/qbittorrent-17.png" alt="" title="" loading="auto" >}}


## That's done! 🎉

Looking good! Now we can move forward with [SABnzbd](/docs/configure/sabnzbd). Remember, SABnzbd is an optional Usenet downloader and you may have not have enabled it during the install script. If you are using it, continue onto [Radarr](/docs/configure/radarr) instead!