#!/bin/bash
# Creates non-root user with passwordless sudo

USER_NAME="${CONTAINER_USER:-ubuntu}"
USER_PASS="${CONTAINER_PASSWORD:-ubuntu}"

if [ "$USER_NAME" != "root" ]; then
    if ! id "$USER_NAME" &>/dev/null; then
        useradd --create-home --shell /bin/bash --user-group --groups adm,sudo "$USER_NAME"
        echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
    echo "$USER_NAME:$USER_PASS" | chpasswd 2>/dev/null || true
    export USER_HOME="/home/$USER_NAME"
else
    export USER_HOME="/root"
fi

export CONTAINER_USER="$USER_NAME"

# Ensure home directory ownership
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME"
