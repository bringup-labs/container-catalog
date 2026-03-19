#!/bin/bash
# Verify VNC and noVNC services start correctly
set -e

IMAGE=${1:?Usage: test-vnc.sh <image-name>}

echo "=== Testing VNC services in ${IMAGE} ==="

# Start container in background
CONTAINER_ID=$(docker run -d --security-opt seccomp=unconfined \
    -p 18080:8080 -p 15900:5900 "$IMAGE")

# Wait for services to start
echo "Waiting for services..."
sleep 15

# Run healthcheck
docker exec "$CONTAINER_ID" /app/scripts/healthcheck.sh
echo "Healthcheck passed"

# Verify noVNC port responds
curl -sf http://localhost:18080 > /dev/null
echo "noVNC web interface responding"

# Cleanup
docker stop "$CONTAINER_ID" > /dev/null
docker rm "$CONTAINER_ID" > /dev/null

echo "=== VNC tests passed ==="
