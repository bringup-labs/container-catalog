#!/bin/bash
# Configures VNC password and noVNC auto-login

VNC_PASS="${VNC_PASSWORD:-${CONTAINER_PASSWORD:-ubuntu}}"

# Set up x11vnc password if provided
if [ -n "$VNC_PASS" ] && [ "$VNC_PASS" != "none" ]; then
    mkdir -p /etc/x11vnc
    x11vnc -storepasswd "$VNC_PASS" /etc/x11vnc/passwd 2>/dev/null
    # Add password flag to x11vnc supervisor config
    sed -i 's|-rfbport 5900|-rfbport 5900 -rfbauth /etc/x11vnc/passwd|' /app/conf.d/x11vnc.conf

    # Set noVNC auto-login password
    sed -i "s/password = WebUtil.getConfigVar('password');/password = '$VNC_PASS';/" \
        /usr/lib/novnc/app/ui.js 2>/dev/null || true
fi
