#!/bin/bash
# Container healthcheck: verify core services are running

# Check Xvfb
pgrep -x Xvfb > /dev/null || exit 1

# Check x11vnc
pgrep -x x11vnc > /dev/null || exit 1

# Check websockify (noVNC proxy)
pgrep -f websockify > /dev/null || exit 1

exit 0
