FROM base

# Install LXDE desktop environment
COPY desktop/lxde/packages.list /tmp/desktop-packages.list
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $(grep -v '^#' /tmp/desktop-packages.list | tr '\n' ' ') && \
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install common desktop applications in a single layer
COPY apps/firefox/install.sh apps/vscodium/install.sh /tmp/
RUN chmod +x /tmp/install-firefox.sh /tmp/install-vscodium.sh && \
    /tmp/install-firefox.sh && \
    /tmp/install-vscodium.sh && \
    rm -f /tmp/install-firefox.sh /tmp/install-vscodium.sh

# Copy pre-configured LXPanel profile and libfm config
COPY desktop/lxde/config/ /etc/skel/.config/

# Copy desktop-specific supervisor configs
COPY desktop/lxde/conf.d/ /app/desktop-conf.d/
