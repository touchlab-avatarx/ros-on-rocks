# Production image: workspace built in Release mode and installed (no symlink install).
FROM vladimirivan/ros:jazzy-example-base

# Run user baked into the image. Rebuild with --build-arg USER_UID=... if your host UID differs.
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000

# Remove the noble "ubuntu" user (it holds UID/GID 1000) and add the run user.
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m -G dialout,video $USERNAME

WORKDIR /ros2

# Build and install the workspace, then drop the build artifacts.
# Mount source, install dependencies, remove apt cache for a smaller image,
# source ROS, build the workspace, remove build artifacts.
RUN --mount=type=bind,source=src,target=/ros2/src \
    apt-get update \
    && rosdep install --from-paths src --ignore-src -y \
    && rm -rf /var/lib/apt/lists/* \
    && . /opt/ros/$ROS_DISTRO/setup.sh \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && rm -rf build log

# Source ROS and the workspace. The ENTRYPOINT is inherited from the ros image.
RUN cat > /ros_entrypoint.sh <<'EOS'
#!/bin/bash
set -e
source /opt/ros/$ROS_DISTRO/setup.bash
source /ros2/install/setup.bash
exec "$@"
EOS

USER $USERNAME
WORKDIR /ros2
