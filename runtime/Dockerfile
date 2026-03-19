FROM base

ARG TARGETPLATFORM

# Install VNC stack
COPY runtime/packages.list /tmp/runtime-packages.list
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $(grep -v '^#' /tmp/runtime-packages.list | tr '\n' ' ') && \
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/dbus

# Install noVNC with clipboard support
RUN git clone https://github.com/AtsushiSaito/noVNC.git \
        -b add_clipboard_support /usr/lib/novnc && \
    ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html

# Install websockify in isolated venv
RUN python3 -m venv /opt/novnc-venv && \
    /opt/novnc-venv/bin/pip install --no-cache-dir \
        git+https://github.com/novnc/websockify.git@v0.12.0

# Configure noVNC defaults: auto-resize and auto-connect
RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" \
        /usr/lib/novnc/app/ui.js && \
    sed -i "s/UI.initSetting('autoconnect', false);/UI.initSetting('autoconnect', true);/g" \
        /usr/lib/novnc/app/ui.js

# Copy supervisor base config and VNC service configs
COPY runtime/supervisord.conf /app/supervisord.conf
COPY runtime/conf.d/ /app/conf.d/

# Copy entrypoint and helper scripts
COPY runtime/scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Copy desktop shortcut templates
COPY apps/terminator/terminator.desktop /app/shortcuts/terminator.desktop
COPY apps/firefox/firefox.desktop /app/shortcuts/firefox.desktop
COPY apps/vscodium/codium.desktop /app/shortcuts/codium.desktop

# Copy wallpaper assets
COPY assets/wallpapers/ /usr/share/wallpapers/container-catalog/

# Configurable environment variables
ENV CONTAINER_USER=ubuntu
ENV CONTAINER_PASSWORD=ubuntu
ENV USER_HOME=/home/ubuntu
ENV DISPLAY=:1
ENV DISPLAY_WIDTH=1920
ENV DISPLAY_HEIGHT=1080
ENV VNC_PASSWORD=""

# NVIDIA GPU support (set at runtime)
ENV NVIDIA_VISIBLE_DEVICES=""
ENV NVIDIA_DRIVER_CAPABILITIES=""

EXPOSE 8080 5900

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD /app/scripts/healthcheck.sh

ENTRYPOINT ["/app/scripts/entrypoint.sh"]
