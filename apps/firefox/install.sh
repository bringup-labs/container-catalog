#!/bin/bash
set -euo pipefail

CODENAME=$(lsb_release -cs)

case "$CODENAME" in
    jammy)
        # Jammy requires PPA for non-snap Firefox
        DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:mozillateam/ppa -y
        cat > /etc/apt/preferences.d/mozilla-firefox <<'EOF'
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF
        ;;
    noble|*)
        # Noble and newer use Mozilla's official apt repo
        mkdir -p /etc/apt/keyrings
        wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg \
            -O /etc/apt/keyrings/packages.mozilla.org.asc
        echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
            | tee /etc/apt/sources.list.d/mozilla-apt.list
        cat > /etc/apt/preferences.d/mozilla <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
        ;;
esac

apt-get update -q
apt-get install -y --no-install-recommends firefox
apt-get autoclean && apt-get autoremove
rm -rf /var/lib/apt/lists/*
