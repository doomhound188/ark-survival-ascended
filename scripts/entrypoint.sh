#!/bin/bash
set -e

# Validate required environment variables
if [ -z "$RCON_PASSWORD" ]; then
    echo "Error: RCON_PASSWORD must be set"
    exit 1
fi

# Download Ark Survival Ascended server via SteamCMD
/opt/steamcmd/steamcmd.sh \
    +force_install_dir /opt/ark-server \
    +login anonymous \
    +app_update 2430930 validate \
    +quit

# Start cron for scheduled tasks
crond

# Prepare Wine environment
export WINEPREFIX=/opt/ark-server/.wine
wine wineboot -i

# Construct server launch parameters
SERVER_PARAMS=(
    "-port=${GAME_PORT}"
    "-rconport=${RCON_PORT}"
    "-servername=${SERVER_NAME}"
    "-map=${MAP}"
    "-maxplayers=${MAX_PLAYERS}"
)

# Add optional parameters
if [ -n "$GAME_PASSWORD" ]; then
    SERVER_PARAMS+=("-gamepassword=${GAME_PASSWORD}")
fi

# Add difficulty and battle eye settings
SERVER_PARAMS+=(
    "-difficulty=${DIFFICULTY}"
    "-battleye=${BATTLE_EYE_ENABLED}"
)

# Start Ark Server
wine /opt/ark-server/ShooterGame/Binaries/Win64/ArkAscendedServer.exe "${SERVER_PARAMS[@]}"
