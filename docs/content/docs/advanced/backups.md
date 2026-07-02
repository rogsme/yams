---
weight: 8
title: Backing up YAMS
---
# Backing up YAMS

Backups are always important. You never know when something might break, and you are forced to recreate your server. If you have a backup of all your config folder ready to go, this is **much easier** (it saves DAYS).

The key item your should backup from your media server is your config folder (`{config_path}`). This contains:
- All your container data
- Your YAMS settings
- Important environment variables

> Note that this does **not** contain your media. Backing up your media is less important and will not be covered in this guide.

Backups can either be conducted using the `yams` command, or by a third party. If you run other applications on your server in differing folders or want a more comprehensive backup method, you might look for a more capable backup handler. Some options might be the popular [restic](https://restic.net/) or [borg](https://borgbackup.readthedocs.io/en/stable/) which are command line utilities (don't worry, there are projects out there that wrap them and make them easier to digest) that store backup snapshots in a de-duplicating repository that can easily be stored on local as well  third party storage.

The `yams backup` command is a simple utility that simple creates a compressed archive of all your YAMS data at that point in time! You are responsible for storing and managing this file.

## Backing up with `yams backup`

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

Backing up YAMS to /home/user/backups...
This may take a while depending on the size of your installation.
Please wait... ⌛

Backup completed! 🎉
Starting YAMS services...

Backup completed successfully! 🎉
Backup file: /home/user/backups/yams-backup-2024-12-23-1734966570.tar.gz
```


### Pro Backup Tips
No matter what backup method you use, here are some important factors to keep in mind:
1. **Regular Backups**: Schedule them daily, weekly or monthly. Store more than one too!
2. **Multiple Locations**: Keep copies in different places so you can't lose all at once
3. **Before Updates**: Always backup before running `yams update-containers` to update your containers
4. **Version Control**: Keep a few recent backups around for easy access in case a quick rollback is needed
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
nano /usr/local/bin/yams
```

> [!INFO]
> If YAMS binary isn't installed yet and you **don't** want to repeat the installation process, check out the instructions on how to [update the CLI](../../getting%20started/cli/#updating-the-cli), and loosely follow them to instead paste the `/usr/local/bin/yams` content from GitLab


Find and update these lines:
```bash
#!/bin/bash
set -euo pipefail

# Constants
readonly DC="docker compose -f your/new/location/docker-compose.yaml -f your/new/location/docker-compose.custom.yaml"  # Update this!
readonly INSTALL_DIRECTORY="your/new/location"  # Update this!
```


### Step 3: Start YAMS
```bash
yams start
```

## Best Practices

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

## Troubleshooting

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

> [!INFO]
> If you are looking to expand to your backup practices, take a look at a backup manager instead of relying on YAMS' quick utility

Remember: The best time to make a backup is BEFORE you need it! 🎯