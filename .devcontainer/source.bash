#!/bin/bash
# This will be sourced in the devcontainer to set up the ROS2 environment and terminal prompt.

# This sets up the ROS2 environment and terminal prompt for the development container.
ws() {
    echo "🔧 Setting up ROS2 environment..."

    if [ -f "/opt/ros/$ROS_DISTRO/setup.bash" ]; then
        source "/opt/ros/$ROS_DISTRO/setup.bash"
    else
        echo "⚠️  Warning: /opt/ros/$ROS_DISTRO/setup.bash not found"
    fi

    if [ -f "/usr/share/colcon_cd/function/colcon_cd.sh" ]; then
        source "/usr/share/colcon_cd/function/colcon_cd.sh"
    else
        echo "⚠️  Warning: colcon_cd.sh not found"
    fi

    if [ -f "/ros2/install/setup.bash" ]; then
        source "/ros2/install/setup.bash"
    else
        echo "⚠️  Warning: /ros2/install/setup.bash not found. Did you build your workspace?"
    fi

    # Colcon auto-completion
    source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
}

# Parses the current git branch and formats it for display in the terminal prompt (optional)
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Sets the terminal prompt with colors and git branch information (optional)
set_term_color() {
    PS1="${debian_chroot:+($debian_chroot)}\[\033[$@m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]\$(parse_git_branch)\[\033[00m\]\$ "
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
    esac
}

# Sets up the docker group to allow non-root users to run docker commands, and handles GID conflicts
# If DOCKER_GID is set, it will use that GID for the docker group.
# If that GID is already in use by another group, it will reassign that group to GID 800.
setup_docker_group() {
    local target_gid="${DOCKER_GID:-998}"

    # If a group other than "docker" already owns target_gid, reassign it to 800
    local occupying_group
    occupying_group=$(getent group | awk -F: -v gid="$target_gid" '$3 == gid {print $1}')
    if [ -n "$occupying_group" ] && [ "$occupying_group" != "docker" ]; then
        echo "⚠️  GID $target_gid is in use by '$occupying_group', reassigning it to 800..."
        groupmod -g 800 "$occupying_group"
    fi

    # Modify or create the "docker" group
    if getent group docker > /dev/null 2>&1; then
        echo "🔧 Changing GID of existing 'docker' group to $target_gid..."
        groupmod -g "$target_gid" docker
    else
        echo "🔧 Creating 'docker' group with GID $target_gid..."
        groupadd -g "$target_gid" docker
    fi
}

# Colcon build wrapper that sources the workspace after building (recommended)
cb() {
    /bin/bash -c "cd /ros2 && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo $*" && ws
}

# Add the local bin directory to the PATH so that any user-installed tools are available in the terminal.
export PATH="$HOME/.local/bin:$PATH"




