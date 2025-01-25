#!/bin/bash
set -e

# Check if auto-update is enabled
if [ "$AUTO_UPDATE_ENABLED" != "true" ]; then
    echo "Auto-update is disabled. Skipping update."
    exit 0
fi

# Stop the server gracefully
pkill -f ArkAscendedServer.exe || true
sleep 10

# Update server via SteamCMD
/opt/steamcmd/steamcmd.sh \
    +force_install_dir /opt/ark-server \
    +login anonymous \
    +app_update 2430930 validate \
    +quit

# Restart the server
/opt/scripts/entrypoint.sh &
