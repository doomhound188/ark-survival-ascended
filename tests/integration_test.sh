#!/bin/bash
set -e

# Ark Server Integration Test

# Configuration
SERVER_NAME="Test Ark Server"
RCON_PASSWORD="integration_test_password"
GAME_PORT=7777
RCON_PORT=27020

# Build Docker image
docker build -t ark-test-server .

# Run container
container_id=$(docker run -d \
  -p ${GAME_PORT}:${GAME_PORT}/udp \
  -p ${RCON_PORT}:${RCON_PORT} \
  -e RCON_PASSWORD=${RCON_PASSWORD} \
  -e SERVER_NAME="${SERVER_NAME}" \
  -e MAX_PLAYERS=10 \
  ark-test-server)

# Wait for server initialization
echo "Waiting for server to start..."
sleep 120

# Check container logs for errors
echo "Checking container logs..."
docker logs "$container_id"

# Verify container is still running
if ! docker ps | grep -q "$container_id"; then
    echo "Server container stopped unexpectedly"
    exit 1
fi

# Optional: Add more specific tests here
# For example, you could use a game query tool or RCON command to validate server state

# Cleanup
docker stop "$container_id"
docker rm "$container_id"

echo "Integration tests completed successfully"
