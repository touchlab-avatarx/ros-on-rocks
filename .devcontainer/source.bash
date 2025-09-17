

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

    export _colcon_cd_root="/ros2/install"
    export ROS_DOMAIN_ID=33

    if [ -f "/ros2/install/setup.bash" ]; then
        source "/ros2/install/setup.bash"
    else
        echo "⚠️  Warning: /ros2/install/setup.bash not found. Did you build your workspace?"
    fi
}


parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

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

cb() {
    cd /ros2
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo $@
}

set_term_color '1;35'

ws

if [ -f "/tmp/tl_startup" ]; then
    sudo chmod 777 /tmp/tl_startup
fi

