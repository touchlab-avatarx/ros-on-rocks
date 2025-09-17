FROM ros:humble-ros-base-jammy

# Add vscode user with same UID and GID as your host system
# (copied from https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Rosdep update
RUN rosdep update

# Core dependencies (ESSENTIAL - keep these)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    cmake build-essential git \
    nano python3-pip python3-colcon-common-extensions python3-vcstool && \
    pip3 install wheel && \
    rm -rf /var/lib/apt/lists/*

# PROJECT-SPECIFIC DEPENDENCIES (CUSTOMIZE THESE)
# Uncomment and modify the sections you need for your project:

# Basic ROS2 packages (needed for examples)
RUN apt-get update && apt-get install -y \
    ros-humble-rclcpp ros-humble-rclpy \
    ros-humble-std-msgs ros-humble-geometry-msgs \
    && rm -rf /var/lib/apt/lists/*

# # URDF and visualization
# RUN apt-get update && apt-get install -y \
#     ros-humble-xacro ros-humble-joint-state-publisher-gui ros-humble-rviz2 \
#     liburdfdom-tools \
#     && rm -rf /var/lib/apt/lists/*

# # MoveIt motion planning
# RUN apt-get update && apt-get install -y \
#     ros-humble-moveit ros-humble-moveit-ros-planning-interface \
#     ros-humble-moveit-kinematics ros-humble-moveit-planners-ompl \
#     && rm -rf /var/lib/apt/lists/*

# # Control systems
# RUN apt-get update && apt-get install -y \
#     ros-humble-ros2-control ros-humble-ros2-controllers \
#     ros-humble-joint-trajectory-controller ros-humble-position-controllers \
#     && rm -rf /var/lib/apt/lists/*

# # Simulation (Gazebo)
# RUN apt-get update && apt-get install -y \
#     ros-humble-gazebo-ros2-control ros-humble-gazebo-ros \
#     && rm -rf /var/lib/apt/lists/*

# # GUI tools (RQT)
# RUN apt-get update && apt-get install -y \
#     python3-pyqt5 ros-humble-rqt-common-plugins \
#     && rm -rf /var/lib/apt/lists/*

# # Development tools (linting)
# RUN apt-get update && apt-get install -y \
#     ros-rolling-ament-cpplint ros-rolling-ament-cppcheck \
#     clang-format \
#     && rm -rf /var/lib/apt/lists/*

# # Additional Python packages
# RUN pip3 install numpy pandas matplotlib

# Add user to video group to allow access to webcam
RUN usermod --append --groups dialout,cdrom,sudo,dip,video,plugdev $USERNAME

# Switch from root to user
USER $USERNAME

# Source the ROS setup file
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
COPY source.bash /
COPY ros_entrypoint.sh /
RUN echo "source /source.bash" >> ~/.bashrc
RUN echo 'export PATH=/usr/bin:$PATH' >> /home/$USERNAME/.bashrc

# Ensure the user has a proper shell environment
RUN echo 'export SHELL=/bin/bash' >> /home/$USERNAME/.bashrc

# PROJECT-SPECIFIC PYTHON PACKAGES (CUSTOMIZE THESE)
# Uncomment and add the Python packages you need:

# RUN pip install --upgrade pip setuptools==58.2.0 wheel
# RUN pip install numpy pandas matplotlib
# RUN pip install torch==2.0.0
# RUN pip install opencv-python