# Rclone Backup Automation

This project automates the process of backing up files to pCloud using `rclone` and provides a mechanism to monitor the execution of the backup script. The setup includes a main backup script, a monitoring script, and configurations to run these scripts via cron jobs on an Ubuntu 22.04 LXC.

## Table of Contents

- [Overview](#overview)
- [Configuration](#configuration)
- [Setup](#setup)
- [Usage](#usage)
- [Cron Jobs](#cron-jobs)
- [Scripts](#scripts)
- [Contributing](#contributing)
- [License](#license)

## Overview

The project consists of two main scripts:
1. `rclone-backup.sh`: The main backup script that syncs files from a local directory to pCloud.
2. `check-rclone-backup.sh`: A monitoring script that checks if the main backup script has run in the last 24 hours and sends a PushOver notification.

## Configuration

Create a configuration file `config.cfg` with the following content:

```ini
# Directory to be backed up
SOURCE_DIR="/mnt/backup"

# Destination in pcloud
DESTINATION="pcloud:"

# Log file location
LOG_FILE="/var/log/rclone.log"

# Log level
LOG_LEVEL="INFO"

# Mount point to check if the backup disk is mounted
MOUNT_POINT="/mnt/backup"

# Sleep time in seconds if the backup disk is not mounted
SLEEP_TIME=300

# Log level for test mode
TEST_LOG_LEVEL="INFO"

# PushOver credentials
PUSHOVER_TOKEN="your_pushover_token"
PUSHOVER_USER="your_pushover_user"
```

Replace `your_pushover_token` and `your_pushover_user` with your actual PushOver credentials.

## Setup

1. Clone the repository or create the required directory structure.
2. Place `rclone-backup.sh`, `check-rclone-backup.sh`, and `config.cfg` in the same directory.
3. Ensure both scripts are executable:
   ```bash
   chmod +x /path/to/rclone-backup/rclone-backup.sh
   chmod +x /path/to/rclone-backup/check-rclone-backup.sh
   ```

## Usage

### Running the Backup Script

To run the backup script manually:
```bash
/path/to/rclone-backup/rclone-backup.sh
```

### Running in Test Mode

To run the backup script in test mode (dry-run) and output to the console:
```bash
/path/to/rclone-backup/rclone-backup.sh -t
```

### Checking Script Execution

To run the script execution check manually:
```bash
/path/to/rclone-backup/check-rclone-backup.sh
```

## Cron Jobs

Set up cron jobs to automate the execution of both scripts.

1. Open the crontab editor:
   ```bash
   crontab -e
   ```

2. Add the following lines:

   ```sh
   # Run the rclone backup script daily at 2 AM
   0 2 * * * /path/to/rclone-backup/rclone-backup.sh

   # Check if the rclone backup script ran in the last 24 hours and send a notification at 3 AM
   0 3 * * * /path/to/rclone-backup/check-rclone-backup.sh
   ```

3. Save the crontab file and exit the editor.

## Scripts

### `rclone-backup.sh`

This script performs the following actions:
- Checks if another instance of the script is running.
- Verifies if the backup disk is mounted.
- Performs the rclone sync operation.
- Supports test mode for dry-run operations.

### `check-rclone-backup.sh`

This script performs the following actions:
- Checks if the main backup script has run in the last 24 hours.
- Sends a PushOver notification if the script has not run or has run successfully.

## Contributing

Contributions are welcome! Please fork the repository and submit pull requests for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

