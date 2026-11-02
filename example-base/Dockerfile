FROM ros:lyrical-ros-base-resolute

RUN rosdep update

# Example core dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
        cmake build-essential git curl openssh-client tmux nano python3-vcstool \
        python3-colcon-common-extensions python3-pip pipx \
    && rm -rf /var/lib/apt/lists/*

# Example ROS dependencies
RUN apt-get update && apt-get install -y \
        ros-lyrical-rviz2 ros-lyrical-rviz-common ros-lyrical-rviz-default-plugins \
    && rm -rf /var/lib/apt/lists/*

# Install Claude dependencies and cleanup
COPY install-claude.sh /install-claude.sh
RUN /install-claude.sh && rm /install-claude.sh

# Add user extras script to the image.
COPY install-user-extras.sh  /install-user-extras.sh
