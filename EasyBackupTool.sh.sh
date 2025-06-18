#!/bin/bash

echo "============================"
echo " Linux Backup & Recovery "
echo "============================"
echo

read -p "What do you want to do? (1 = Backup, 2 = Recovery): " ACTION

if [ "$ACTION" == "1" ]; then
    # Backup Mode
    read -p "Which file/folder do you want to backup? (e.g., /etc, /home, /): " SOURCE
    read -p "Where do you want to store the backup? (e.g., /mnt/backup): " DEST
    read -p "Do you want to backup daily or only once? (daily/once): " FREQUENCY

    # Check if source exists
    if [ ! -e "$SOURCE" ]; then
        echo " The source '$SOURCE' does not exist."
        exit 1
    fi

    # Create destination if it doesn't exist
    if [ ! -d "$DEST" ]; then
        echo " Backup directory '$DEST' does not exist. Creating it..."
        sudo mkdir -p "$DEST" || { echo " Failed to create directory."; exit 1; }
    fi

    DATE=$(date +%F)
    BACKUP_FILE="$DEST/backup_$(basename $SOURCE)_$DATE.tar.gz"

    echo " Starting backup..."
    sudo tar -czpf "$BACKUP_FILE" --one-file-system "$SOURCE"

    echo " Backup complete: $BACKUP_FILE"

    if [ "$FREQUENCY" == "daily" ]; then
        read -p "At what hour should the backup run daily? (0-23): " HOUR
        read -p "At what minute? (0-59): " MIN

        CRON_JOB="$MIN $HOUR * * * /bin/bash $(realpath $0)"
        (sudo crontab -l 2>/dev/null; echo "$CRON_JOB") | sudo crontab -

        echo " Daily backup cron job set at $HOUR:$MIN"
    fi

elif [ "$ACTION" == "2" ]; then
    # Recovery Mode
    read -p "What is the path of the backup file? (e.g., /mnt/backup/backup_home_2025-06-16.tar.gz): " BACKUP_FILE
    read -p "Where do you want to extract it? (e.g., /mnt/recovery or /): " TARGET_DIR

    echo "Starting recovery..."
    sudo tar -xpvf "$BACKUP_FILE" -C "$TARGET_DIR"

    echo " Recovery complete: $BACKUP_FILE -> $TARGET_DIR"

else
    echo " Invalid input. Exiting script."
    exit 1
fi
