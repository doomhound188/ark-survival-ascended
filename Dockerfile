FROM almalinux:9

# Set environment variables with defaults
ENV GAME_PORT=7777 \
    RCON_PORT=27020 \
    SERVER_NAME="Ark Survival Ascended Server" \
    GAME_PASSWORD="" \
    RCON_PASSWORD="changeme" \
    MAP="TheIsland" \
    MAX_PLAYERS=70 \
    DIFFICULTY=1.0 \
    BATTLE_EYE_ENABLED=true \
    BACKUP_FREQUENCY=daily \
    BACKUP_TIME="03:00" \
    BACKUP_RETENTION_DAYS=7 \
    AUTO_UPDATE_ENABLED=true \
    UPDATE_TIME="04:00" \
    UPDATE_BRANCH=default

# Install dependencies
RUN dnf update -y && \
    dnf install -y epel-release && \
    dnf install -y \
    wget \
    tar \
    gzip \
    cabextract \
    libstdc++ \
    glibc.i686 \
    libgcc.i686 \
    libstdc++.i686 \
    cronie \
    procps \
    && dnf clean all

# Install SteamCMD
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Install Glorious Eggrolls Wine
RUN rpm --import https://dl.winehq.org/wine-builds/winehq.key && \
    dnf config-manager --add-repo https://dl.winehq.org/wine-builds/rhel/9/winehq.repo && \
    dnf install -y wine-staging && \
    wine --version

# Create game server directory
RUN mkdir -p /opt/ark-server

# Copy scripts
COPY scripts/entrypoint.sh /opt/scripts/entrypoint.sh
COPY scripts/backup.sh /opt/scripts/backup.sh
COPY scripts/update.sh /opt/scripts/update.sh

# Set executable permissions
RUN chmod +x /opt/scripts/*.sh

# Set up crontab for backups and updates
RUN echo "${BACKUP_TIME} root /opt/scripts/backup.sh" >> /etc/crontab && \
    echo "${UPDATE_TIME} root /opt/scripts/update.sh" >> /etc/crontab

# Expose game and RCON ports
EXPOSE ${GAME_PORT}/udp ${RCON_PORT}/tcp

# Volume for persistent data
VOLUME ["/opt/ark-server"]

# Entrypoint
ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
