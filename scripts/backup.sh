#!/bin/bash
set -e

# Backup configuration
BACKUP_DIR="/opt/ark-server/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SAVE_DIR="/opt/ark-server/ShooterGame/Saved"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Stop the server gracefully
pkill -f ArkAscendedServer.exe || true
sleep 10

# Create tar backup of save files
tar -czvf "${BACKUP_DIR}/ark-save-${TIMESTAMP}.tar.gz" -C "${SAVE_DIR}" .

# Rotate backups
find "${BACKUP_DIR}" -type f -name "ark-save-*.tar.gz" -mtime +${BACKUP_RETENTION_DAYS} -delete

# Restart the server
/opt/scripts/entrypoint.sh &
