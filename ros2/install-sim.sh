#!/bin/bash
set -euo pipefail

# Simulation packages are architecture and distro dependent
ARCH=$(dpkg --print-architecture)

if [ "$ARCH" != "amd64" ]; then
    echo "Skipping simulation packages on ${ARCH} (amd64 only)"
    exit 0
fi

apt-get update -q

case "${ROS_DISTRO}" in
    humble)
        apt-get install -y --no-install-recommends \
            "ros-${ROS_DISTRO}-gazebo-ros-pkgs" \
            "ros-${ROS_DISTRO}-ros-ign" || true
        ;;
    jazzy|rolling|kilted)
        apt-get install -y --no-install-recommends \
            "ros-${ROS_DISTRO}-ros-gz" || true
        ;;
    *)
        echo "Unknown ROS_DISTRO=${ROS_DISTRO}, skipping simulation packages"
        ;;
esac

apt-get autoclean && apt-get autoremove
rm -rf /var/lib/apt/lists/*
