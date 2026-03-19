# docker-bake.hcl — Build orchestration for the container catalog
#
# Usage:
#   docker buildx bake jazzy-xfce          # Build one image (+ all deps)
#   docker buildx bake default             # Build all XFCE variants
#   docker buildx bake all                 # Build full matrix
#   docker buildx bake --print jazzy-xfce  # Preview build plan

variable "REGISTRY" {
  default = "ghcr.io/bringup-labs"
}

variable "DOCKERHUB_REGISTRY" {
  default = "docker.io/bringuplabs"
}

variable "IMAGE_NAME" {
  default = "ros2-desktop-vnc"
}

# ============================================================
# GROUPS
# ============================================================

group "default" {
  targets = [
    "humble-xfce",
    "jazzy-xfce",
    "rolling-xfce",
  ]
}

group "all" {
  targets = [
    "humble-xfce", "humble-lxde",
    "jazzy-xfce", "jazzy-lxde",
    "rolling-xfce", "rolling-lxde",
  ]
}

group "humble" {
  targets = ["humble-xfce", "humble-lxde"]
}

group "jazzy" {
  targets = ["jazzy-xfce", "jazzy-lxde"]
}

group "rolling" {
  targets = ["rolling-xfce", "rolling-lxde"]
}

# ============================================================
# TIER 1: Base OS images
# ============================================================

target "base-jammy" {
  dockerfile = "base/Dockerfile.jammy"
  context    = "."
  tags       = ["${REGISTRY}/ros2-base:jammy"]
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "base-noble" {
  dockerfile = "base/Dockerfile.noble"
  context    = "."
  tags       = ["${REGISTRY}/ros2-base:noble"]
  platforms  = ["linux/amd64", "linux/arm64"]
}

# ============================================================
# TIER 2: ROS2 layer (on top of base)
# ============================================================

target "_ros2-common" {
  dockerfile = "ros2/Dockerfile"
  context    = "."
  platforms  = ["linux/amd64", "linux/arm64"]
}

target "ros2-humble" {
  inherits = ["_ros2-common"]
  contexts = {
    base = "target:base-jammy"
  }
  args = {
    ROS_DISTRO      = "humble"
    INSTALL_PACKAGE = "desktop"
  }
  tags = ["${REGISTRY}/ros2-layer:humble"]
}

target "ros2-jazzy" {
  inherits = ["_ros2-common"]
  contexts = {
    base = "target:base-noble"
  }
  args = {
    ROS_DISTRO      = "jazzy"
    INSTALL_PACKAGE = "desktop"
  }
  tags = ["${REGISTRY}/ros2-layer:jazzy"]
}

target "ros2-rolling" {
  inherits = ["_ros2-common"]
  contexts = {
    base = "target:base-noble"
  }
  args = {
    ROS_DISTRO      = "rolling"
    INSTALL_PACKAGE = "desktop"
  }
  tags = ["${REGISTRY}/ros2-layer:rolling"]
}

# ============================================================
# TIER 3: Desktop environment (on top of ROS2)
# ============================================================

target "_desktop-common" {
  context    = "."
  platforms  = ["linux/amd64", "linux/arm64"]
}

# --- XFCE variants ---

target "humble-xfce-base" {
  inherits   = ["_desktop-common"]
  dockerfile = "desktop/xfce/Dockerfile"
  contexts   = { base = "target:ros2-humble" }
  tags       = ["${REGISTRY}/ros2-desktop:humble-xfce"]
}

target "jazzy-xfce-base" {
  inherits   = ["_desktop-common"]
  dockerfile = "desktop/xfce/Dockerfile"
  contexts   = { base = "target:ros2-jazzy" }
  tags       = ["${REGISTRY}/ros2-desktop:jazzy-xfce"]
}

target "rolling-xfce-base" {
  inherits   = ["_desktop-common"]
  dockerfile = "desktop/xfce/Dockerfile"
  contexts   = { base = "target:ros2-rolling" }
  tags       = ["${REGISTRY}/ros2-desktop:rolling-xfce"]
}

# --- LXDE variants ---

target "humble-lxde-base" {
  inherits   = ["_desktop-common"]
  dockerfile = "desktop/lxde/Dockerfile"
  contexts   = { base = "target:ros2-humble" }
  tags       = ["${REGISTRY}/ros2-desktop:humble-lxde"]
}

target "jazzy-lxde-base" {
  inherits   = ["_desktop-common"]
  dockerfile = "desktop/lxde/Dockerfile"
  contexts   = { base = "target:ros2-jazzy" }
  tags       = ["${REGISTRY}/ros2-desktop:jazzy-lxde"]
}

target "rolling-lxde-base" {
  inherits   = ["_desktop-common"]
  dockerfile = "desktop/lxde/Dockerfile"
  contexts   = { base = "target:ros2-rolling" }
  tags       = ["${REGISTRY}/ros2-desktop:rolling-lxde"]
}

# ============================================================
# TIER 4: Runtime — final composed images
# ============================================================

target "_runtime-common" {
  dockerfile = "runtime/Dockerfile"
  context    = "."
  platforms  = ["linux/amd64", "linux/arm64"]
}

# --- XFCE final images ---

target "humble-xfce" {
  inherits = ["_runtime-common"]
  contexts = { base = "target:humble-xfce-base" }
  tags     = [
    "${REGISTRY}/${IMAGE_NAME}:humble-xfce",
    "${REGISTRY}/${IMAGE_NAME}:humble",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:humble-xfce",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:humble",
  ]
}

target "jazzy-xfce" {
  inherits = ["_runtime-common"]
  contexts = { base = "target:jazzy-xfce-base" }
  tags     = [
    "${REGISTRY}/${IMAGE_NAME}:jazzy-xfce",
    "${REGISTRY}/${IMAGE_NAME}:jazzy",
    "${REGISTRY}/${IMAGE_NAME}:latest",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:jazzy-xfce",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:jazzy",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:latest",
  ]
}

target "rolling-xfce" {
  inherits = ["_runtime-common"]
  contexts = { base = "target:rolling-xfce-base" }
  tags     = [
    "${REGISTRY}/${IMAGE_NAME}:rolling-xfce",
    "${REGISTRY}/${IMAGE_NAME}:rolling",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:rolling-xfce",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:rolling",
  ]
}

# --- LXDE final images ---

target "humble-lxde" {
  inherits = ["_runtime-common"]
  contexts = { base = "target:humble-lxde-base" }
  tags     = [
    "${REGISTRY}/${IMAGE_NAME}:humble-lxde",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:humble-lxde",
  ]
}

target "jazzy-lxde" {
  inherits = ["_runtime-common"]
  contexts = { base = "target:jazzy-lxde-base" }
  tags     = [
    "${REGISTRY}/${IMAGE_NAME}:jazzy-lxde",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:jazzy-lxde",
  ]
}

target "rolling-lxde" {
  inherits = ["_runtime-common"]
  contexts = { base = "target:rolling-lxde-base" }
  tags     = [
    "${REGISTRY}/${IMAGE_NAME}:rolling-lxde",
    "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:rolling-lxde",
  ]
}
