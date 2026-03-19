#!/bin/bash
# Installs desktop shortcuts, wallpaper, and configures the desktop environment

WALLPAPER="/usr/share/wallpapers/container-catalog/wallpaper.png"

mkdir -p "${USER_HOME}/Desktop"

# Copy shortcut templates to user's desktop
for shortcut in /app/shortcuts/*.desktop; do
    [ -f "$shortcut" ] && cp "$shortcut" "${USER_HOME}/Desktop/"
done

# Make shortcuts executable (required by XFCE)
chmod +x "${USER_HOME}/Desktop"/*.desktop 2>/dev/null || true

# --- XFCE wallpaper configuration ---
if command -v xfce4-session &>/dev/null && [ -f "$WALLPAPER" ]; then
    XFCE_DESKTOP_DIR="${USER_HOME}/.config/xfce4/xfconf/xfce-perchannel-xml"
    mkdir -p "$XFCE_DESKTOP_DIR"
    cat > "$XFCE_DESKTOP_DIR/xfce4-desktop.xml" <<XFCE_EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorscreen" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="${WALLPAPER}"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XFCE_EOF
fi

# --- LXDE pre-configured settings from skel ---
if command -v pcmanfm &>/dev/null && [ -d /etc/skel/.config ]; then
    # Copy LXPanel profile (fixes taskbar) and libfm config (disables .desktop trust prompt)
    mkdir -p "${USER_HOME}/.config"
    cp -r /etc/skel/.config/* "${USER_HOME}/.config/" 2>/dev/null || true
fi

if command -v pcmanfm &>/dev/null && [ -f "$WALLPAPER" ]; then
    LXDE_DESKTOP_DIR="${USER_HOME}/.config/pcmanfm/LXDE"
    mkdir -p "$LXDE_DESKTOP_DIR"
    cat > "$LXDE_DESKTOP_DIR/desktop-items-0.conf" <<LXDE_EOF
[*]
wallpaper_mode=fit
wallpaper_common=1
wallpaper=${WALLPAPER}
desktop_bg=#2d2d2d
desktop_fg=#ffffff
desktop_shadow=#000000
show_trash=1
show_mounts=1
LXDE_EOF
fi

chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "${USER_HOME}/Desktop"
chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "${USER_HOME}/.config" 2>/dev/null || true
