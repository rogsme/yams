---
weight: 10
title: What is YAMS?
---

# Welcome to YAMS!

YAMS (Yet Another Media Server) is a simple media server setup process that anyone can use! It provides a setup script as well as handcrafted guides to get you up and running with your own Docker Compose based \*Arr media server.

It consists of 4 major parts:

{{% steps %}}

1. ## Install Script

   A simple bash setup script you run on your machine, handling all the initial complexity. It wrangles permissions, files structures and initial docker compose content in the background and surfaces a simple interface in your terminal.

   {{< image src="/pics/install-yams.gif" alt="" title="" loading="auto" >}}


2. ## Setup Guide

   A handwritten guide with step-by-step instructions (including screenshots!) on how to connect all the applications within your stack together. You'll learn more about each one and the fundamental concepts it relies on as you go!

3. ## CLI Tool

   A bash CLI installed on your machine that simplifies the operation of your media server. Stop, start and backup your applications with simple terminal commands.

4. ## Community
   A welcoming community across the YAMS forum and Discord, ready to help or chat!
   {{% /steps %}}

And don't worry: its super customizable. Since its just a kick-starting template and not a separate application, all users are free tweak docker compose files and add new containers at any time. In fact, its recommended!

# The Story Behind YAMS

*A message from the YAMS creator Roger:*

Back in 2019, I had a mission: Create a media server that my non-tech-savvy girlfriend could use without calling me for help every five minutes. So I dove in, combining some awesome open-source projects and wrapping them up in a Docker compose.

Fast forward to today, and guess what? Mission accomplished! 🎉 Not only does my girlfriend use it without any issues, but I've even got my mom (who lives 5000km away) streaming her favorite shows with zero problems!

When my friends saw how well it worked, they all wanted one too. But explaining how to set everything up was like trying to teach a cat to swim - technically possible, but way more complicated than it needed to be.

That's when it hit me: Why not create a script that could do all the heavy lifting? And that's how YAMS was born! Now anyone can build their own kickass media server without needing a PhD in computer science. 😎

# What do you get with YAMS?

YAMS is the easiest way to get started up with your own streaming service replacement. Here's what you get out of the box:

- Smart Downloads: Just tell it what movie or show you want, your stack handles the rest
- Streaming: Using Jellyfin/Emby/Plex, you can stream your media anywhere. And I mean anywhere. Phones, computers, browsers, TVs, game consoles and more!
- And on the side you don't see:
  - Perfect Organisation: Media is kept neatly organised on your personal filesystem
  - Port forwarding to speed up your downloads and increase seeding capabilities
  - Hardlinking to prevent duplicating data, saving tons of storage space

YAMS utilises Docker as its foundation: it provides a docker compose with all the major open source tools, ready to go. You'll learn about the roles of these applications as we go along, but here are a few of the basics:

<div class="card-row">

  <div class="simple-card">
    <div class="card-header">
      <img src="/icons/logos/radarr.svg" class="card-icon" alt="Radarr" />
      <h4 class="card-title">Radarr + Sonarr</h4>
    </div>
    <div class="card-content">
      Track down your movies and shows, and organise them on your filesystem.
    </div>
  </div>

  <div class="simple-card">
    <div class="card-header">
      <img src="/icons/logos/qbittorrent.svg" class="card-icon" alt="qBitTorrent" />
      <h4 class="card-title">qBitTorrent + Gluetun</h4>
    </div>
    <div class="card-content">
      Download and seed your media behind a VPN.
    </div>
  </div>

  <div class="simple-card">
    <div class="card-header">
      <img src="/icons/logos/jellyfin.svg" class="card-icon" alt="Jellyfin" />
      <h4 class="card-title">Jellyfin/Emby/Plex</h4>
    </div>
    <div class="card-content">
      Stream your media to any device.
    </div>
  </div>

</div>

<div class="simple-card" style="padding: 0.75rem 1.25rem; margin-top: 1rem;">
  <div class="card-content" style="font-size: 0.9rem; line-height: 1.4; opacity: 0.95;">
    Also includes <strong>Lidarr</strong> (Music), <strong>SABnzbd</strong> (Usenet), <strong>Bazarr</strong> (Subtitles), <strong>Prowlarr</strong> (Indexers), <strong>Dozzle</strong> (Logs), and <strong>Watchtower</strong> (Auto-updates).
  </div>
</div>


Its that easy!

All these pieces work together seamlessly to create a media server that's both powerful AND easy to use. It's like having your own streaming service, but better - because YOU'RE in control!

Ready to dive in? Let's get started with the installation!
