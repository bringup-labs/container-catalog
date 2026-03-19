#!/bin/bash
# Verify desktop environment is running
set -e

IMAGE=${1:?Usage: test-desktop.sh <image-name>}

echo "=== Testing desktop in ${IMAGE} ==="

# Start container
CONTAINER_ID=$(docker run -d --security-opt seccomp=unconfined \
    -p 28080:8080 "$IMAGE")

# Wait for desktop to initialize
sleep 20

# Check that X display is running
docker exec "$CONTAINER_ID" bash -c "DISPLAY=:1 xdpyinfo > /dev/null 2>&1"
echo "X display is active"

# Check desktop shortcuts exist
docker exec "$CONTAINER_ID" bash -c "ls /home/ubuntu/Desktop/*.desktop"
echo "Desktop shortcuts present"

# Cleanup
docker stop "$CONTAINER_ID" > /dev/null
docker rm "$CONTAINER_ID" > /dev/null

echo "=== Desktop tests passed ==="
