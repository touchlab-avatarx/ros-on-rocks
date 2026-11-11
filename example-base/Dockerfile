FROM ros:lyrical-ros-base-resolute

RUN rosdep update

# Example core dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
        cmake build-essential git curl openssh-client tmux nano python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# Example ROS dependencies
RUN apt-get update && apt-get install -y \
        ros-lyrical-rviz2 ros-lyrical-rviz-common ros-lyrical-rviz-default-plugins \
    && rm -rf /var/lib/apt/lists/*

# hestia dependencies (package.xml + docs)
RUN apt-get update && apt-get install -y \
        libeigen3-dev pybind11-dev python3-dev python3-numpy python3-pytest libgtest-dev \
        python3-sphinx python3-sphinx-rtd-theme \
        ros-lyrical-pinocchio ros-lyrical-controller-interface ros-lyrical-hardware-interface \
        ros-lyrical-pluginlib ros-lyrical-ament-cmake-gtest \
    && rm -rf /var/lib/apt/lists/*

# Add user extras script to the image.
COPY install-user-extras.sh /install-user-extras.sh
