#!/bin/bash

PROJECT_DIR="$(pwd)"
MEMORY_FILE="$PROJECT_DIR/project-memory.json"
DUMP_DIR="$PROJECT_DIR/memory-dumps"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_FILE="$PROJECT_DIR/logs/dump.log"

mkdir -p "$DUMP_DIR" "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

case "${1:-shutdown}" in
    "daily")
        log_message "Creating daily summary..."
        if [ -f "$MEMORY_FILE" ]; then
            timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
            cp "$MEMORY_FILE" "$DUMP_DIR/daily-backup-$timestamp.json"
            log_message "Daily backup created: daily-backup-$timestamp.json"
        fi
        ;;
    "shutdown"|*)
        log_message "Creating shutdown dump..."
        if [ -f "$MEMORY_FILE" ]; then
            timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
            cp "$MEMORY_FILE" "$BACKUP_DIR/shutdown-backup-$timestamp.json"
            gzip "$BACKUP_DIR/shutdown-backup-$timestamp.json"
            log_message "Shutdown backup created: shutdown-backup-$timestamp.json.gz"
        fi
        ;;
esac
