#!/bin/bash
set -e

# Source modular setup scripts
source /app/scripts/setup-user.sh
source /app/scripts/setup-vnc.sh
source /app/scripts/setup-ros.sh
source /app/scripts/setup-desktop.sh

# Merge desktop-specific supervisor configs into main conf.d
if [ -d /app/desktop-conf.d ]; then
    cp /app/desktop-conf.d/*.conf /app/conf.d/ 2>/dev/null || true
fi

echo "============================================"
echo "  Container ready"
echo "  noVNC:   http://localhost:8080"
echo "  VNC:     localhost:5900"
echo "  User:    ${CONTAINER_USER}"
echo "  Display: ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}"
if [ -n "${ROS_DISTRO:-}" ]; then
echo "  ROS2:    ${ROS_DISTRO}"
fi
echo "============================================"

# Clear sensitive environment variables
unset CONTAINER_PASSWORD VNC_PASSWORD

exec /usr/bin/tini -- /usr/bin/supervisord -n -c /app/supervisord.conf
