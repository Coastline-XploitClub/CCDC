#!/bin/bash

# TaskManager Pro Backup/Restore Script
# Usage: ./backup-restore.sh [backup|restore]

set -e  # Exit on any error

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
MONGO_CONTAINER=”taskmanager-mongodb”
REDIS_CONTAINER=”taskmanager-redis”

function backup_data() {
    echo "Starting backup process..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup MongoDB
    echo "Backing up MongoDB..."
    
    docker exec "$MONGO_CONTAINER" mongodump –archive=/data/backup/mongo_backup.archive
    docker cp "$MONGO_CONTAINER":/data/backup/mongo_backup.archive "$BACKUP_DIR"/mongo_backup.archive


    
    # Backup Redis
    echo "Backing up Redis…"
    docker exec $REDIS_CONTAINER redis-cli save
    docker cp $REDIS_CONTAINER:/data/dump.rdb "$BACKUP_DIR/redis_dump.rdb

    
    # Backup uploaded files
    echo "Backing up uploaded files..."

    
    echo "Backup completed: $BACKUP_DIR"
}

function restore_data() {
    local restore_dir="$1"
    
    if [ -z "$restore_dir" ]; then
        echo "Usage: $0 restore [backup_directory]"
        exit 1
    fi
    
    echo "Starting restore from: $restore_dir"
    
    # Restore MongoDB
    echo "Restoring MongoDB…"
    docker cp "$restore_dir/mongo_backup.archive" $MONGO_CONTAINER:/backup/mongo_backup.archive
    docker exec $MONGO_CONTAINER mongorestore --drop --archive=/backup/mongo_backup.archive
    
    # Restore Redis
    echo "Restoring Redis..."
    docker cp "$restore_dir/redis_dump.rdb" $REDIS_CONTAINER:/data/dump.rdb
    docker restart $REDIS_CONTAINER
    
    # Restore uploaded files
    echo "Restoring uploaded files…"
    
    
    echo "Restore completed successfully"
}

# Main script logic
case "$1" in
    backup)
        backup_data
        ;;
    restore)
        restore_data "$2"
        ;;
    *)
        echo "Usage: $0 [backup|restore] [backup_directory]"
        exit 1
        ;;
esac
