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

# Check if the log file exists
if [ ! -f "$LOG_FILE" ]; then
    message="Log file not found: $LOG_FILE"
    echo "$message"
    notify_pushover "$message"
    exit 1
fi

# Check the last modification time of the log file
LAST_RUN=$(stat -c %Y "$LOG_FILE")
NOW=$(date +%s)
let DIFF=NOW-LAST_RUN

# Notify if the script has not run in the last 24 hours (86400 seconds)
if [ $DIFF -gt 86400 ]; then
    message="rclone backup script has not run in the last 24 hours."
    echo "$message"
    notify_pushover "$message"
else
    message="rclone backup script has run successfully within the last 24 hours."
    echo "$message"
fi
