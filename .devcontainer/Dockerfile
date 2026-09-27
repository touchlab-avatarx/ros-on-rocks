# Base image. Change this to an image that has your binary dependencies installed.
FROM touchlab/ros:jazzy-example-base

# Add vscode user with same UID and GID as your host system
# (copied from https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user)
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ARG DOCKER_GID=999

# Set up environment variables and tools
COPY source.bash /
COPY ros_entrypoint.sh /
COPY tm /bin/tm

# Add a non-root user to the container and add them to the docker group
# Tolerates UID/GID collisions with base image users/groups (e.g. ubuntu:1000 on 24.04).
RUN /bin/bash -c "export DOCKER_GID=$DOCKER_GID && source /source.bash && setup_docker_group" \
    && for g in dialout video sudo; do getent group $g >/dev/null || groupadd $g; done \
    && for u in $(getent passwd $USER_UID | cut -d: -f1) $(getent passwd $USERNAME | cut -d: -f1); do \
           userdel -r $u 2>/dev/null || userdel $u; \
       done \
    && if ! getent group $USER_GID >/dev/null; then \
           if getent group $USERNAME >/dev/null; then groupmod -g $USER_GID $USERNAME; \
           else groupadd --gid $USER_GID $USERNAME; fi; \
       fi \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m -G docker,dialout,video,sudo $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch from root to user for workspace setup.
USER $USERNAME

# Source the ROS setup file
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /source.bash" >> ~/.bashrc
RUN echo 'export PATH=/usr/bin:$PATH' >> /home/$USERNAME/.bashrc
RUN echo "ws" >> /home/$USERNAME/.bashrc
RUN echo "set_term_color '1;35'" >> /home/$USERNAME/.bashrc
RUN touch /home/$USERNAME/.sudo_as_admin_successful


# Additional user space setup can be done in the install-user-extars.sh script, which will be run
# as the user at the end of the Dockerfile. You can add any commands you want to run as the user in
# that script, and it will be executed during the build process. This is a good place to install
# any additional packages or tools that you want to have available in the container but have to be
# installed as the user. Create this script in your base docker. It will allow you to download
# packages at build time and avoid having to do it every time you start the container.
# If the script does not exist, it will be created as an empty file and will not cause any issues.
USER root
RUN touch /install-user-extras.sh && chmod 755 /install-user-extras.sh
USER $USERNAME
RUN /install-user-extras.sh
USER root


