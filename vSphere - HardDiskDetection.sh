#!/bin/sh
# Reboot script for ESXi - reboots the node up to 3 times.

# Variables
LOGS_FILE="/vmfs/volumes/ESX4/reboots.txt"
SCRIPT_PATH="/vmfs/volumes/ESX4/script.sh"
STARTUP_SCRIPT="/etc/rc.local.d/local.sh"
DISK_PATH="ESX4"
MAX_REBOOTS=3


# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /vmfs/volumes/$DISK_PATH/log.txt
}

# Function to add script to startup
add() {
    if ! grep -q "$(basename $SCRIPT_PATH)" $STARTUP_SCRIPT; then
        if grep -q "exit 0" $STARTUP_SCRIPT; then
            sed -i "/exit 0/i sh $SCRIPT_PATH" $STARTUP_SCRIPT
        else
            echo "sh $SCRIPT_PATH" >> $STARTUP_SCRIPT
        fi
        log_message "Script added to startup."
    else
        log_message "Script already in startup."
    fi
}

# Function to remove script from startup
remove() {
    if grep -q "$SCRIPT_PATH" $STARTUP_SCRIPT; then
        sed -i "/$(basename $SCRIPT_PATH)/d" $STARTUP_SCRIPT
        log_message "Script removed from startup."
    else
        log_message "Script not found in startup."
    fi
}

# Function to count devices starting with "naa.55"
count() {
    local count=$(esxcli storage core device list | grep -c "eui.")
    log_message "Detected only $count devices starting with eui., expected at least 3"
}

# Read the current reboot count from file or initialize it
if [ -f "$LOGS_FILE" ]; then
    read -r reboot_count < "$LOGS_FILE"
else
    reboot_count=0
fi

# Increment and write the new count back to the file
reboot_count=$((reboot_count + 1))
echo "$reboot_count" > "$LOGS_FILE"

# Log and check if the maximum reboot count has not been reached
log_message "Reboot count: $reboot_count"
if [ "$reboot_count" -lt "$MAX_REBOOTS" ]; then
    log_message "Initiating reboot #$reboot_count."
    add
    count
    reboot
else
    log_message "Maximum reboot count reached. No further reboots will be initiated."
    remove
fi

