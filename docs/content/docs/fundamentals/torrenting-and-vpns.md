---
weight: 30
title: Torrenting and VPNs
---

# What is Torrenting?

Usually when you are downloading a file, one server sends the entire file to you. The downside of this is that is thousands of people want the file, the server needs *massive* bandwidth.

Torrenting works differently. Instead of one server sending the file, everyone who has pieces of the fileshares them with each other. Your computer downloades small pieces of the file from many people at the same time, piecing it together into a singular download. This is called **peer-to-peer (P2P)** file sharing.

## Key Terminology

- **Peer**: Anybody who is participating in the torrent
  - **Seeder**: A person who has 100% of the file downloaded, and is uploading it to others
  - **Leecher**: A person who is downloading the file, and has not shared it back. This isn't necessarily bad, it may mean you simply don't have the full file yet.

#### Torrent File
A `.torrent` file is a very small file (usually only a few KB).

**It does not contain any of the actual content inside of it.** Instead, it contains information such as file names, sizes, checksums, and other information needed to locate peers. Its a packet of information you give to your torrent client (in this case, qBitTorrent) so they know what to download!

> [!INFO]
> You won't have to deal with many `.torrent` files, as Radarr and Sonarr directly add downloads into qBitTorrent. However, they can be useful for manual downloads/testing.

A magnet link has similar logic, but it is just a link instead of a file.

### Trackers

A tracker is a service that helps connect people sharing the same file. It does not host the file itself, but contains a directory of content its members are actively seeding.

You'll often hear terms such as **public tracker** and **private tracker**.

#### Public Trackers

Public trackers can be used by anyone and typically don't require an account, making them easy to access. However, they are often less reliable. Let's discuss why.

Since torrents content is downloaded by piecing together the file from others who are seeding it, your download speed is affected by the availability of these seeders. The less seeders there are, the lower the download speed.

Public trackers often have no rules/requirements to be on their platforms, and therefore many members do not seed after download. This means your downloads speeds may be extremely unreliable or even nonexistant! In addition, public trackers often have less moderation surrounding the creation of torrents so there is likely to be larger amounts of subpar quality torrents.

Overall, public trackers are a great starting point and sufficient for a basic media server.

#### Private Trackers

Private trackers require an account to use them. They usually contain stricter moderation that results in better quality content, and better download speeds.

This is because private trackers often enforce seeding. This means that if you download a torrent from other members, you **must** continue to seed it for a set amount of time, or until you upload the amount of data you downloaded, to assist others with *their* downloads. This results in overall faster download speeds for everyone!

Some common private tracker concepts are:
- **Seed Ratio**: A ratio of the amount of data you have downloaded against what you have uploaded
  - For example, if you have downloaded `10GB` and uploaded only `5GB`, your ratio will be `0.5`
  - This often has to be kept **above** a certain value to be allowed to use the tracker
- **Hit and Run**: A torrent 'hit and run' is when you download a torrent, and don't seed it! These are often penalised within private trackers.

> [!DANGER]
> If you are participating in any private tracker, it is YOUR responsibility to ensure you are abiding by all the rules and requirements it enforces. If you do not, penalties will likely occur, such as being banned!

## Port Forwarding

You might have heard about port forwarding before, heard about how it speeds up downloads and only supported by specific providers. But what is it?

Port forwarding is when you open a specific numbered 'door' in your VPNs digital firewall so that outside computers can connect directly to your device. Normally when you use a VPN, your computer hides behind a wall. It can reach out to the internet but its incoming connections are firewalled. This means that your download client can still make outgoing connections to other peers, and downloads will still work, but some peers won't be able to connect back to you.

A VPN provider that supports port forwarding gives you a dedicated port on their VPN server. This has several benefits for torrenting:
- Without port forwarding, you can only connect to people who *do* have open ports. With a forwarded port, you can connect to both people with forwarded ports and people without. This drastically increases your pool of available peers you can connect to.
  - Your download speeds are faster because you can connect to more seeders.
  - You can seed to a larger pool of leechers, making it easier to hit ratio and seeding requirements on private trackers

Port forwarding is a useful but **not-compulsory** feature offered by some VPN providers, that can help enhance your media server.

Also note that Gluetun, the VPN client YAMS uses has in-built port forwarding support for these providers: Private Internet Access,  ProtonVPN, Perfect Privacy, PrivateVPN.


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
  - To learn more about how torrenting works and what port forwarding is, check out the port fowarding section [above](/docs/fundamentals/torrenting-and-vpns/#port-forwarding)

### YAMS Supported Providers

YAMS works with tons of VPN providers! If Gluetun supports it, YAMS does too. Here's the full list, with direct links to their setup guides (search them up for their pricing and main pages!):

Here are some of the most popular choices for torrenting that support port forwarding:
- {{< icon "logos/proton-vpn" >}} [ProtonVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md) (Recommended by the YAMS creator! Easy to set up and great privacy)
- {{< icon "logos/private-internet-access" >}} [Private Internet Access (PIA)](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/private-internet-access.md) (Can be very good value if you purchase a long time up front)
- {{< icon "logos/air-vpn" >}} [AirVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/airvpn.md) (*Port forwarding is not implemented natively into Gluetun, but possible.*)

Some popular options that do *not* have port forwarding capabilities are:
- {{< icon "logos/mullvad-vpn" >}} [Mullvad](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/mullvad.md)
- {{< icon "logos/surfshark" >}} [Surfshark](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/surfshark.md)
- {{< icon "logos/nord-vpn" >}} [NordVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/nordvpn.md)
- {{< icon "logos/express-vpn" >}} [ExpressVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/expressvpn.md)

### Other Options 📋
Here are the rest of the providers that Gluetun also supports. Providers that also support port forwarding are indicated. *If a provider support port forwarding but this feature is not natively implemented into Gluetun, it is recommended only for advanced users and YAMS does not cover setting this up.*
- [Cyberghost](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/cyberghost.md)
- [FastestVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/fastestvpn.md)
- [Giganews](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/giganews.md)
- [Hidemyass](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/hidemyass.md)
- [IPVanish](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/ipvanish.md)
- [IVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/ivpn.md)
- [Perfect Privacy](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/perfect-privacy.md) *(Supports port forwarding)*
- [Privado](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/privado.md)
- [PrivateVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/privatevpn.md) *(Supports port forwarding)*
- [PureVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/purevpn.md) *(Supports port forwarding, but this feature is not implemented natively into Gluetun)*
- [SlickVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/slickvpn.md)
- [Torguard](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/torguard.md) *(Supports port forwarding, but this feature is not implemented natively into Gluetun)*
- [VPN Secure](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vpn-secure.md)
- [VPN Unlimited](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vpn-unlimited.md) *(Supports port forwarding, but this feature is not implemented natively into Gluetun)*
- [VyprVPN](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/vyprvpn.md)
- [Windscribe](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/windscribe.md) *(Supports port forwarding, but this feature is not implemented natively into Gluetun)*
- [Custom Configuration](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md)

Want to use a different VPN? You can set up a [custom VPN provider](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md), but keep in mind this isn't officially supported by YAMS. This is an *advanced* DIY process for experienced server owners who already own a VPN 🛠️!

---

If you haven't installed YAMS yet and just came to learn more about VPNs, feel free to return to the [installation page](/docs/getting-started/installation/#prerequisites).

