---
weight: 5
title: Backups
---

 handy backup command that takes care of everything:

```bash
yams backup [destination]
```

### Quick Backup Example

Let's say you want to back up to your home directory:
```bash
yams backup ~/backups/
```

You'll see something like this:
```bash
Stopping YAMS services...

Backing up YAMS to /home/roger...
This may take a while depending on the size of your installation.
Please wait... ⌛

Backup completed! 🎉
Starting YAMS services...

Backup completed successfully! 🎉
Backup file: /home/roger/yams-backup-2024-12-23-1734966570.tar.gz
```

### What Gets Backed Up? 🤔

The backup includes:
- All your container configurations
- Your YAMS settings
- Your service preferences
- Custom container configurations
- Important environment variables

### Pro Backup Tips 💡

1. **Regular Backups**: Schedule them weekly or monthly
2. **Multiple Locations**: Keep copies in different places
3. **Before Updates**: Always backup before running `yams update-containers` to update your containers
4. **Version Control**: Keep a few recent backups around
5. **Test Restores**: Occasionally verify your backups work

## Restoring from Backup 🔄

Need to restore your YAMS setup? Here's the step-by-step guide:

### Step 1: Extract the Backup
```bash
tar -xzvf your-backup.tar.gz -C /your/new/location
cd /your/new/location
```

### Step 2: Update YAMS Configuration
Edit the YAMS binary with your favorite text editor (we'll use `nano` here, but use whatever you prefer):
```bash
nano yams
```

Find and update these lines:
```bash
#!/bin/bash
set -euo pipefail

# Constants
readonly DC="docker compose -f your/new/location/docker-compose.yaml -f your/new/location/docker-compose.custom.yaml"  # Update this!
readonly INSTALL_DIRECTORY="your/new/location"  # Update this!
```

### Step 3: Install YAMS Binary
```bash
sudo cp yams /usr/local/bin/
```

### Step 4: Start YAMS
```bash
yams start
```

## Best Practices 📚

1. **Regular Schedule**
   ```bash
   # Example: Weekly backups to different locations
   yams backup ~/backups/weekly/
   yams backup /mnt/external/yams-backup/
   ```

2. **Pre-Update Backups**
   ```bash
   # Before updating your containers
   yams backup ~/backups/pre-update/
   yams update-containers
   ```

## Troubleshooting 🔧

### Backup Failed?
1. Check disk space:
   ```bash
   df -h
   ```
2. Verify write permissions:
   ```bash
   ls -la /backup/destination
   ```
3. Try stopping services manually:
   ```bash
   yams stop
   ```

### Restore Issues?
1. Verify backup integrity:
   ```bash
   tar -tvf your-backup.tar.gz
   ```
2. Check file permissions
3. Ensure all paths are correct in the YAMS binary

## Advanced Topics 🎓

### Automated Backups

You can automate backups using cron. Here's an example:

1. Open your crontab:
   ```bash
   crontab -e
   ```

2. Add a weekly backup job:
   ```bash
   # Run backup every Sunday at 2 AM
   0 2 * * 0 /usr/local/bin/yams backup /path/to/backups/
   ```

### Backup Rotation

Keep your backups manageable with rotation:

```bash
#!/bin/bash
# backup-rotate.sh
MAX_BACKUPS=5
BACKUP_DIR="/path/to/backups"

# Create new backup
yams backup $BACKUP_DIR

# Remove old backups
ls -t $BACKUP_DIR/yams-backup-* | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f
```

## Need Help? 🆘

If you run into backup or restore issues:
1. Check our [Common Issues](/docs/faqs/) page
2. Visit the [YAMS Forum](https://forum.yams.media)
3. Join our [Discord](https://discord.gg/Gwae3tNMST) chat

Remember: The best time to make a backup is BEFORE you need it! 🎯