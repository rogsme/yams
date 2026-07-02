---
weight: 1
title: Portainer
---


# What is Portainer? 🐋

Think of Portainer as your mission control for Docker! It gives you a sleek web interface to manage all your containers, making it way easier than typing commands in the terminal all day.

From their [website](https://www.portainer.io/):
> Deploy, configure, troubleshoot and secure containers in minutes on Kubernetes, Docker, Swarm and Nomad in any data center, cloud, network edge or IIOT device.

Portainer is optional in YAMS, but we highly recommend it. It's like having x-ray vision into your containers! 🦸‍♂️

## Initial Setup 🚀

### Step 1: Access Portainer
Open your browser and go to `http://{your-ip-address}:9000/`. You'll see the first-time setup screen.

### Step 2: Create Admin Account
Let's set up your admin credentials:
1. Choose a secure username
2. Pick a strong password
3. Click "Create User"

{{< image src="/pics/portainer/portainer-1.png" alt="" title="" loading="auto" >}}

### Step 3: Quick Setup
On the "Quick Setup" screen:
1. Click "Get Started" - this sets up Portainer with good default settings
2. No need to mess with advanced options for now!

{{< image src="/pics/portainer/portainer-2.png" alt="" title="" loading="auto" >}}

### Step 4: Access Your Environment
1. Click on your "local" Docker environment
2. This is where all the magic happens!

{{< image src="/pics/portainer/portainer-3.png" alt="" title="" loading="auto" >}}

## Managing Your Containers 🎮

### Viewing Containers
1. Click on "Containers" in the left menu
2. Here you'll see all your running YAMS services

{{< image src="/pics/portainer/portainer-4.png" alt="" title="" loading="auto" >}}

### What You Can Do Here
- 👀 Monitor container status
- 🔄 Restart services
- 📊 Check resource usage
- 📝 View logs
- ⚙️ Change container settings

{{< image src="/pics/portainer/portainer-5.png" alt="" title="" loading="auto" >}}

## Pro Tips 💡

### 1. Container Management
- **Quick Restart**: Use the circular arrow icon next to a container
- **Batch Actions**: Select multiple containers to restart/stop them together
- **Auto-Refresh**: Enable auto-refresh to monitor containers in real-time

### 2. Logs and Troubleshooting
- View container logs directly in Portainer
- Check container stats for resource usage
- Inspect container configuration when things go wrong

### 3. Resource Monitoring
- Monitor CPU and memory usage
- Track network traffic
- Set up resource limits if needed

## Cool Features You Should Try 🌟

1. **Container Console**
   - Access container terminals directly from the web
   - Great for quick debugging!

2. **Real-Time Stats**
   - Monitor CPU, memory, and network usage
   - Perfect for spotting performance issues

3. **Volume Management**
   - Check where your data is stored
   - Manage persistent storage

4. **Network Overview**
   - See how containers are connected
   - Troubleshoot network issues

## Best Practices 📚

1. **Security**
   - Change the default admin password regularly
   - Use a strong password
   - Don't expose Portainer to the internet

2. **Monitoring**
   - Check container logs regularly
   - Monitor resource usage
   - Set up email alerts for container failures

3. **Maintenance**
   - Restart containers gracefully
   - Use the "Recreate" option when updating
   - Keep an eye on storage usage

## Troubleshooting 🔧

### Can't Access Portainer?
1. Check if the container is running:
   ```bash
   yams check portainer
   ```
2. Verify the port isn't blocked
3. Make sure you're using the right IP address

### Container Issues?
1. Check container logs in Portainer
2. Look for error messages
3. Verify container settings

### Resource Problems?
1. Monitor container stats
2. Check host system resources
3. Consider setting resource limits

## Need Help? 🆘

If you're stuck:
1. Check our [Common Issues](/docs/faqs/) page
2. Visit the [YAMS Forum](https://forum.yams.media)
3. Join our [Discord](https://discord.gg/Gwae3tNMST) chat
4. Check [Portainer's documentation](https://docs.portainer.io/)

Remember: Portainer is your friend! It makes managing YAMS much easier, so take some time to explore its features. 🎮