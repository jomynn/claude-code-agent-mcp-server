#!/bin/bash

PROJECT_DIR="$(pwd)"
SCRIPT_PATH="$PROJECT_DIR/automation/auto-dump.sh"

# Add daily dump at 6 PM
(crontab -l 2>/dev/null; echo "0 18 * * * cd $PROJECT_DIR && $SCRIPT_PATH daily") | crontab -

# Add shutdown dump at 11:30 PM
(crontab -l 2>/dev/null; echo "30 23 * * * cd $PROJECT_DIR && $SCRIPT_PATH shutdown") | crontab -

echo "Cron jobs added successfully!"
echo "Daily dumps: 6 PM"
echo "Shutdown dumps: 11:30 PM"
