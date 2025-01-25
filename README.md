# Ark Survival Ascended Server Docker Container

## Features
- Runs on AlmaLinux with Wine
- Configurable server parameters
- Automatic backups
- Automatic updates
- RCON support

## Environment Variables
- `GAME_PORT`: Game server port (default: 7777)
- `RCON_PORT`: RCON administration port (default: 27020)
- `SERVER_NAME`: Server display name (default: "Ark Survival Ascended Server")
- `GAME_PASSWORD`: Optional game password
- `RCON_PASSWORD`: Required RCON password (must be set)
- `MAP`: Server map (default: "TheIsland")
- `MAX_PLAYERS`: Maximum number of players (default: 70)
- `DIFFICULTY`: Server difficulty (default: 1.0)
- `BATTLE_EYE_ENABLED`: Enable BattlEye (default: true)
- `BACKUP_FREQUENCY`: Backup schedule (default: daily)
- `BACKUP_TIME`: Time for daily backup (default: "03:00")
- `BACKUP_RETENTION_DAYS`: Number of days to keep backups (default: 7)
- `AUTO_UPDATE_ENABLED`: Enable automatic updates (default: true)
- `UPDATE_TIME`: Time for daily updates (default: "04:00")

## Docker Compose Example
```yaml
version: '3.8'
services:
  ark-server:
    build: .
    ports:
      - "7777:7777/udp"
      - "27020:27020"
    environment:
      - RCON_PASSWORD=your_secure_password
      - SERVER_NAME=My Awesome Ark Server
      - MAP=TheIsland
    volumes:
      - ./ark-data:/opt/ark-server
```

## Building the Container
```bash
docker build -t ark-survival-ascended-server .
```

## Running the Container
```bash
docker run -d \
  -p 7777:7777/udp \
  -p 27020:27020 \
  -e RCON_PASSWORD=your_secure_password \
  ark-survival-ascended-server
```

## Backup and Update
- Backups are automatically created daily at the specified backup time
- Server updates can be automatically downloaded and applied

## Notes
- Ensure you have a stable internet connection for initial download and updates
- The RCON password is required for server administration
