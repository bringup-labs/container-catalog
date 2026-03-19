#!/bin/bash
# Configures ROS2 environment for the container user

if [ -z "${ROS_DISTRO:-}" ]; then
    return 0 2>/dev/null || exit 0
fi

BASHRC="${USER_HOME}/.bashrc"

# Source ROS2 setup in user's bashrc
grep -qF "source /opt/ros/${ROS_DISTRO}/setup.bash" "$BASHRC" 2>/dev/null || \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> "$BASHRC"

# Colcon argcomplete
grep -qF "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" "$BASHRC" 2>/dev/null || \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> "$BASHRC"

# Create default workspace
mkdir -p "${USER_HOME}/ros2_ws/src"

# Copy rosdep data for non-root user
if [ -d /root/.ros/rosdep ] && [ "$CONTAINER_USER" != "root" ]; then
    mkdir -p "${USER_HOME}/.ros"
    cp -r /root/.ros/rosdep "${USER_HOME}/.ros/rosdep" 2>/dev/null || true
    chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "${USER_HOME}/.ros"
fi

chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "${USER_HOME}/ros2_ws"
chown "${CONTAINER_USER}:${CONTAINER_USER}" "$BASHRC"
