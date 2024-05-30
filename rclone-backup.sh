#!/bin/bash

# Load configurations
CONFIG_FILE="$(dirname "$0")/config.cfg"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Function to send PushOver notifications
function notify_pushover {
    local message="$1"
    curl -s \
        --form-string "token=$PUSHOVER_TOKEN" \
        --form-string "user=$PUSHOVER_USER" \
        --form-string "message=$message" \
        https://api.pushover.net/1/messages.json
}

# Parse arguments
TEST_MODE=false
while getopts "t" opt; do
    case $opt in
        t) TEST_MODE=true ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

# Default log level for test mode if not specified in the config file
if [ -z "$TEST_LOG_LEVEL" ]; then
    TEST_LOG_LEVEL="INFO"
fi

# Lock file
LOCK_FILE="/tmp/rclone-backup.lock"

# Ensure only one instance of the script runs at a time
exec 200>"$LOCK_FILE"
flock -n 200 || {
    echo "Another instance of the script is running."
    exit 1
}

# Retry parameters
MAX_RETRIES=3
RETRY_INTERVAL=60  # 60 seconds

# Function to check if the backup disk is mounted
function check_mount {
    grep -qs "$MOUNT_POINT" /proc/mounts
}

# Retry loop for mounting
for ((i=1; i<=MAX_RETRIES; i++)); do
    if check_mount; then
        echo "Backup disk is mounted."
        break
    else
        if [ $i -lt $MAX_RETRIES ]; then
            echo "Backup disk not mounted. Retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
        else
            message="Backup disk not mounted after $MAX_RETRIES attempts. Script will exit."
            echo "$message"
            notify_pushover "$message"
            exit 1
        fi
    fi
done

# Perform the rclone sync operation or test mode
if [ "$TEST_MODE" = true ]; then
    echo "Test mode enabled. Performing a quick check."
    # Test mode: perform a dry-run of the rclone sync operation with specified log level and output to console
    /usr/bin/rclone sync "$SOURCE_DIR" "$DESTINATION" --dry-run --log-level "$TEST_LOG_LEVEL"
    if [ $? -ne 0 ]; then
        echo "rclone sync (test mode) failed. See above for details."
    else
        echo "rclone sync (test mode) completed successfully. See above for details."
    fi
else
    /usr/bin/rclone sync "$SOURCE_DIR" "$DESTINATION" --delete-before --log-file "$LOG_FILE" --log-level "$LOG_LEVEL"
    if [ $? -ne 0 ]; then
        message="rclone sync failed. Check log at $LOG_FILE"
        echo "$message"
        notify_pushover "$message"
    fi
fi

# Release the lock
flock -u 200

