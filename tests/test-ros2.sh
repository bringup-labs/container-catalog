#!/bin/bash
# Verify ROS2 is installed and functional
set -e

IMAGE=${1:?Usage: test-ros2.sh <image-name>}
ROS_DISTRO=${2:?Usage: test-ros2.sh <image-name> <ros-distro>}

echo "=== Testing ROS2 in ${IMAGE} ==="

# Test ros2 CLI is available
docker run --rm --security-opt seccomp=unconfined "$IMAGE" \
    bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && ros2 --help"

# Test colcon is available
docker run --rm --security-opt seccomp=unconfined "$IMAGE" \
    bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && colcon --help"

# Test workspace exists
docker run --rm --security-opt seccomp=unconfined "$IMAGE" \
    bash -c "test -d /home/ubuntu/ros2_ws/src"

echo "=== ROS2 tests passed ==="
