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
    dnf-plugins-core \
    libX11.i686 \
    mesa-libGL.i686 \
    && dnf clean all

# Install SteamCMD
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Install Wine GE from GitHub
RUN set -e && \
    # Download latest Wine GE release
    WINE_GE_RELEASE=$(wget -qO- https://api.github.com/repos/GloriousEggroll/wine-ge-custom/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    wget https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${WINE_GE_RELEASE}/wine-ge-custom-${WINE_GE_RELEASE#GE-Proton}-x86_64.tar.xz -O /tmp/wine-ge.tar.xz && \
    # Extract Wine GE to /opt
    mkdir -p /opt/wine-ge && \
    tar -xf /tmp/wine-ge.tar.xz -C /opt/wine-ge --strip-components=1 && \
    # Clean up
    rm /tmp/wine-ge.tar.xz && \
    # Set up Wine environment
    echo 'export PATH="/opt/wine-ge/bin:$PATH"' >> /etc/profile.d/wine-ge.sh && \
    chmod +x /etc/profile.d/wine-ge.sh && \
    # Verify Wine installation
    /opt/wine-ge/bin/wine --version || \
    (echo "Wine GE installation failed" && exit 1)

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
