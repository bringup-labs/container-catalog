# Container Catalog

Modular, prebuilt desktop-enabled containers for ROS2 development. Access a full graphical ROS2 desktop environment from your browser via noVNC.

## Available Images

| Image Tag | ROS2 | Desktop | Ubuntu |
|-----------|------|---------|--------|
| `humble-xfce` / `humble` | Humble | XFCE | Jammy 22.04 |
| `humble-lxde` | Humble | LXDE | Jammy 22.04 |
| `jazzy-xfce` / `jazzy` / `latest` | Jazzy | XFCE | Noble 24.04 |
| `jazzy-lxde` | Jazzy | LXDE | Noble 24.04 |
| `rolling-xfce` / `rolling` | Rolling | XFCE | Noble 24.04 |
| `rolling-lxde` | Rolling | LXDE | Noble 24.04 |

## Quick Start

```bash
docker run -d \
  -p 8080:8080 \
  --security-opt seccomp=unconfined \
  --shm-size=512m \
  bringuplabs/ros2-desktop-vnc:jazzy-xfce
```

Open **http://localhost:8080** in your browser.

### With docker-compose

```yaml
services:
  ros2-desktop:
    image: bringuplabs/ros2-desktop-vnc:jazzy-xfce
    ports:
      - "8080:8080"
      - "5900:5900"
    volumes:
      - ros2_ws:/home/ubuntu/ros2_ws
    security_opt:
      - seccomp:unconfined
    shm_size: "512m"

volumes:
  ros2_ws:
```

See the `examples/` directory for more configurations including GPU support.

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `CONTAINER_USER` | `ubuntu` | Non-root username |
| `CONTAINER_PASSWORD` | `ubuntu` | User and VNC password |
| `DISPLAY_WIDTH` | `1920` | Desktop resolution width |
| `DISPLAY_HEIGHT` | `1080` | Desktop resolution height |
| `VNC_PASSWORD` | *(same as CONTAINER_PASSWORD)* | VNC-specific password (set to `none` to disable) |

### Ports

| Port | Service |
|------|---------|
| 8080 | noVNC (browser access) |
| 5900 | VNC (direct client access) |

### GPU Support (NVIDIA)

```bash
docker run -d \
  -p 8080:8080 \
  --gpus all \
  --security-opt seccomp=unconfined \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  bringuplabs/ros2-desktop-vnc:jazzy-xfce
```

## Architecture

The catalog uses a **4-layer chained build** strategy. Each layer is an independent Dockerfile, wired together by `docker-bake.hcl` using BuildKit named contexts.

```
Layer 1: BASE          Ubuntu Jammy / Noble
           |           (system packages, locale, sudo, python)
Layer 2: ROS2          Parameterized by ROS_DISTRO
           |           (ros2 packages, colcon, rosdep, simulation)
Layer 3: DESKTOP       XFCE / LXDE
           |           (desktop env, firefox, vscodium, supervisor conf.d)
Layer 4: RUNTIME       VNC + noVNC + entrypoint
                       (x11vnc, xvfb, websockify, healthcheck)
```

### Key Design Principles

- **Decoupled layers**: Desktop environments are completely independent of ROS2. Adding a new desktop requires zero changes to base, ROS2, or runtime layers.
- **Single parameterized Dockerfile per layer**: ROS2 uses one Dockerfile for all distros via `ARG ROS_DISTRO`. Desktops each have one Dockerfile reused across all ROS2 distros.
- **Static supervisor configs**: Each desktop drops its own `conf.d/*.conf` files. The runtime merges them at startup. No dynamic config generation.
- **Modular entrypoint**: The entrypoint sources small, focused scripts (`setup-user.sh`, `setup-vnc.sh`, `setup-ros.sh`, `setup-desktop.sh`) instead of one monolithic script.

### Directory Structure

```
container-catalog/
├── docker-bake.hcl          # Build orchestration
├── base/                    # Layer 1: OS base images
│   ├── Dockerfile.jammy
│   └── Dockerfile.noble
├── ros2/                    # Layer 2: ROS2 (single Dockerfile, all distros)
│   ├── Dockerfile
│   ├── install-ros2.sh
│   └── install-sim.sh
├── desktop/                 # Layer 3: Desktop environments
│   ├── xfce/
│   └── lxde/
├── runtime/                 # Layer 4: VNC + entrypoint
│   ├── Dockerfile
│   ├── supervisord.conf
│   ├── conf.d/
│   └── scripts/
├── apps/                    # Shared application installers
├── examples/                # docker-compose files
└── tests/                   # Smoke tests
```

## Building

Requires Docker with BuildKit (Docker Desktop or `docker buildx`).

```bash
# Build one image (resolves all layer dependencies automatically)
docker buildx bake jazzy-xfce --load

# Build all XFCE variants (default group)
docker buildx bake default --load

# Build the full 3x2 matrix
docker buildx bake all --load

# Preview build plan without building
docker buildx bake --print jazzy-xfce

# Build for specific platform only
docker buildx bake jazzy-xfce --set "*.platform=linux/amd64" --load
```

## Extending

### Adding a New Desktop Environment

1. Create `desktop/<name>/` with:
   - `Dockerfile` (use `FROM base`, install packages, copy conf.d)
   - `packages.list`
   - `conf.d/<session>.conf` (supervisor config for the desktop session, priority=30)

2. Add targets to `docker-bake.hcl`:
   - `{distro}-{name}-base` targets (Tier 3)
   - `{distro}-{name}` targets (Tier 4)

No changes needed to base, ros2, or runtime layers.

### Adding a New ROS2 Distribution

1. Add a `ros2-{distro}` target in `docker-bake.hcl`, pointing to the correct base (jammy/noble).
2. Add desktop and runtime targets following existing patterns.
3. If the distro has different simulation packages, update the `case` in `ros2/install-sim.sh`.

### What's Included

Each container ships with:

- **ROS2**: Full desktop install (rviz2, gazebo/gz where supported), colcon, rosdep, vcstool
- **Desktop**: Full window manager with panel, file manager, terminal, custom wallpaper
- **Apps**: Firefox, VSCodium, Terminator
- **Dev tools**: git, vim, build-essential, python3
- **Workspace**: Pre-created `~/ros2_ws/src` with ROS2 auto-sourced in `.bashrc`
- **Access**: noVNC (browser) + VNC (direct client) with optional password auth

## Container Features

- Non-root user with passwordless sudo
- Bi-directional clipboard support (via noVNC clipboard fork)
- Configurable resolution and scaling
- Container healthcheck (Xvfb + x11vnc + websockify)
- NVIDIA GPU support hooks
- `tini` init for proper signal handling
- Multi-architecture: `linux/amd64` and `linux/arm64`

## License

Apache License 2.0 - see [LICENSE](LICENSE).
