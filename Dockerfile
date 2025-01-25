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
    curl \
    && dnf clean all

# Install SteamCMD
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Install Wine GE from GitHub
RUN set -e && \
    # Hardcoded latest known working Wine GE release
    WINE_GE_RELEASE="GE-Proton8-25" && \
    WINE_GE_VERSION="${WINE_GE_RELEASE#GE-Proton}" && \
    WINE_GE_FILENAME="wine-ge-custom-${WINE_GE_VERSION}-x86_64.tar.xz" && \
    # Download Wine GE release with multiple retry mechanisms
    (wget -q https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${WINE_GE_RELEASE}/${WINE_GE_FILENAME} -O /tmp/wine-ge.tar.xz || \
     curl -L -f https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${WINE_GE_RELEASE}/${WINE_GE_FILENAME} -o /tmp/wine-ge.tar.xz) && \
    # Verify download integrity
    if [ ! -s /tmp/wine-ge.tar.xz ]; then \
        echo "Wine GE download failed" && exit 1; \
    fi && \
    # Extract Wine GE to /opt with verbose output
    mkdir -p /opt/wine-ge && \
    tar -xvf /tmp/wine-ge.tar.xz -C /opt/wine-ge --strip-components=1 && \
    # Clean up
    rm /tmp/wine-ge.tar.xz && \
    # Set up Wine environment
    echo 'export PATH="/opt/wine-ge/bin:$PATH"' >> /etc/profile.d/wine-ge.sh && \
    chmod +x /etc/profile.d/wine-ge.sh && \
    # Verify Wine installation with detailed error reporting
    /opt/wine-ge/bin/wine --version || \
    (echo "Wine GE installation failed. Checking wine binary..." && \
     ls -l /opt/wine-ge/bin/wine && \
     file /opt/wine-ge/bin/wine && \
     exit 1)

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
