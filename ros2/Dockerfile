FROM base

ARG ROS_DISTRO=jazzy
ARG INSTALL_PACKAGE=desktop
ARG TARGETPLATFORM

ENV ROS_DISTRO=${ROS_DISTRO}

# Install ROS2
COPY ros2/install-ros2.sh /tmp/install-ros2.sh
RUN chmod +x /tmp/install-ros2.sh && /tmp/install-ros2.sh

# Install simulation packages (architecture-aware)
COPY ros2/install-sim.sh /tmp/install-sim.sh
RUN chmod +x /tmp/install-sim.sh && /tmp/install-sim.sh

# Initialize rosdep
RUN rosdep init && rosdep update

# Enable apt-get completion after running apt-get update in container
RUN rm -f /etc/apt/apt.conf.d/docker-clean
