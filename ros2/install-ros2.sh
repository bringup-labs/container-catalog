#!/bin/bash
set -euo pipefail

apt-get update -q
apt-get install -y --no-install-recommends curl gnupg2 lsb-release

# Add ROS2 GPG key and repository
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2 packages
apt-get update -q
apt-get install -y --no-install-recommends \
    "ros-${ROS_DISTRO}-${INSTALL_PACKAGE:-desktop}" \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool

apt-get autoclean && apt-get autoremove
rm -rf /var/lib/apt/lists/*
