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

# hestia dependencies (package.xml + docs)
RUN apt-get update && apt-get install -y \
        libeigen3-dev pybind11-dev python3-dev python3-numpy python3-pytest libgtest-dev \
        python3-sphinx python3-sphinx-rtd-theme \
        ros-lyrical-pinocchio ros-lyrical-controller-interface ros-lyrical-hardware-interface \
        ros-lyrical-pluginlib ros-lyrical-ament-cmake-gtest \
    && rm -rf /var/lib/apt/lists/*

# ur_description dependencies (package.xml; rviz2 is installed above)
RUN apt-get update && apt-get install -y \
        ros-lyrical-xacro ros-lyrical-robot-state-publisher ros-lyrical-joint-state-publisher-gui \
        ros-lyrical-urdf ros-lyrical-launch ros-lyrical-launch-ros \
        ros-lyrical-ament-cmake-pytest ros-lyrical-launch-testing-ament-cmake ros-lyrical-launch-testing-ros \
        liburdfdom-tools \
    && rm -rf /var/lib/apt/lists/*

# ros2_control (controller manager, spawners, mock/sim hardware, standard controllers)
RUN apt-get update && apt-get install -y \
        ros-lyrical-ros2-control ros-lyrical-ros2-controllers \
        ros-lyrical-controller-manager ros-lyrical-ros2controlcli \
        ros-lyrical-joint-state-broadcaster ros-lyrical-joint-trajectory-controller \
        ros-lyrical-forward-command-controller \
    && rm -rf /var/lib/apt/lists/*

# RViz: interactive markers and common plugins
RUN apt-get update && apt-get install -y \
        ros-lyrical-interactive-markers ros-lyrical-visualization-msgs \
        ros-lyrical-rviz-visual-tools ros-lyrical-rviz-rendering \
        ros-lyrical-tf2-ros ros-lyrical-tf2-geometry-msgs \
    && rm -rf /var/lib/apt/lists/*

# rqt: the GUI, the common plugins (graph, plot, console, topic, publisher, service caller, reconfigure, bag, ...),
# the TF tree, the ros2_control plugins (controller manager, joint trajectory controller) and robot tools
RUN apt-get update && apt-get install -y \
        ros-lyrical-rqt ros-lyrical-rqt-common-plugins \
        ros-lyrical-rqt-reconfigure ros-lyrical-rqt-tf-tree \
        ros-lyrical-rqt-controller-manager ros-lyrical-rqt-joint-trajectory-controller \
        ros-lyrical-rqt-robot-steering ros-lyrical-rqt-robot-monitor ros-lyrical-rqt-runtime-monitor \
        ros-lyrical-rqt-gauges \
    && rm -rf /var/lib/apt/lists/*

# Install Claude dependencies and cleanup
COPY install-claude.sh /install-claude.sh
RUN /install-claude.sh && rm /install-claude.sh

# Add user extras script to the image.
COPY install-user-extras.sh /install-user-extras.sh
