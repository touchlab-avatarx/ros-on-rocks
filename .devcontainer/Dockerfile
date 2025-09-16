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

# Core dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    cmake build-essential git openssh-client net-tools \
    fakeroot dpkg-dev debhelper \
    nano python3-pip python3-colcon-common-extensions python3-vcstool \
    ffmpeg alsa-tools portaudio19-dev libcurlpp-dev libasio-dev && \
    pip3 install wheel && pip3 install bloom zmq msgpack msgpack-numpy pyserial pynput \
    ansi2html requests sphinx sphinx-rtd-theme python-box && \
    rm -rf /var/lib/apt/lists/*

# Touchlab dependencies
RUN apt-get update && apt-get install -y \
    socat curl libmsgpack-dev \
    liburdfdom-tools ros-humble-xacro ros-humble-joint-state-publisher-gui ros-humble-rviz2 \
    python3-pykdl python3-zmq python3-msgpack python3-rospkg python3-pygraphviz \
    liblapack-dev libncurses5-dev libjsoncpp-dev gnuplot-qt gnuplot ros-humble-pinocchio \
    ros-humble-osqp-vendor libwebsocketpp-dev ros-humble-rosx-introspection \
    nlohmann-json3-dev && \
    rm -rf /var/lib/apt/lists/*

# UR dependencies
RUN apt-get update && apt-get install -y \
    docker.io ros-humble-force-torque-sensor-broadcaster ros-humble-joint-state-broadcaster \
    ros-humble-ros2-control ros-humble-ros2-controllers ros-humble-moveit\
    ros-humble-joint-trajectory-controller ros-humble-position-controllers ros-humble-ros2-controllers-test-nodes \
    socat ros-humble-velocity-controllers ros-humble-controller-manager ros-humble-controller-manager-msgs \
    ros-humble-hardware-interface ros-humble-angles ros-humble-controller-interface \
    ros-humble-realtime-tools ros-humble-gazebo-ros2-control ros-humble-gazebo-ros ros-humble-plotjuggler-ros \
    ros-humble-moveit-ros-planning-interface libmodbus-dev ros-humble-moveit-kinematics \
    ros-humble-moveit-planners-ompl ros-humble-moveit-ros-move-group ros-humble-moveit-ros-visualization \
    ros-humble-moveit-servo ros-humble-moveit-simple-controller-manager ros-humble-warehouse-ros-sqlite \
    ros-humble-kinematics-interface-kdl ros-humble-asio-cmake-module ros-humble-launch-pytest ros-humble-hardware-interface-testing \
    ros-humble-camera-info-manager ros-humble-camera-calibration-parsers ros-humble-gazebo-plugins lm-sensors python3-ntplib && \
    rm -rf /var/lib/apt/lists/*

# RQT deps
RUN apt-get update && apt-get install -y \
    python3-pyqt5 pyqt5-dev-tools qttools5-dev-tools qtbase5-dev qt5-qmake ros-humble-rqt* && \
    rm -rf /var/lib/apt/lists/*

# Linting extras from ROS2 rolling
RUN apt-get update && apt-get install -y \
    ros-rolling-ament-cpplint ros-rolling-ament-cppcheck ros-rolling-ament-uncrustify \
    clang-format && \
    rm -rf /var/lib/apt/lists/*

# Note: ament_cpplint files would need to be provided if custom patches are required

# ML dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-image-publisher && \
    rm -rf /var/lib/apt/lists/*

# Switch from root to user
USER $USERNAME

# Add user to video group to allow access to webcam
RUN sudo usermod --append --groups dialout,cdrom,sudo,dip,video,plugdev $USERNAME

# Source the ROS setup file
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
COPY source.bash /
COPY ros_entrypoint.sh /
RUN echo "source /source.bash" >> ~/.bashrc
RUN echo 'export PATH=/usr/bin:$PATH' >> /home/$USERNAME/.bashrc

# Install additional Python packages
RUN pip install --upgrade pip setuptools==58.2.0 wheel \
    && pip install numpy pandas python-box torch==2.0.0