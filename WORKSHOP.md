# 🎓 ROS-on-Rocks Workshop Setup

Do these steps **before the workshop**, as internet on-site is limited. For details see [README.md](README.md).

---

## 💻 Prerequisites

- Laptop: x86_64 CPU (ARM not supported), 4+ cores, 8 GB RAM (16 GB recommended), ~10 GB free disk space, USB port for the workshop stick
- GPU optional (NVIDIA, Intel or AMD integrated graphics are fine)
- Linux host, Ubuntu 22.04 or 24.04 (Windows/macOS/WSL2 not tested)
- Internet for steps 1–3 and 4a (or the workshop USB stick for 4b)

---

## 🚀 Steps

1. **Install Docker Engine + Compose plugin**: <https://docs.docker.com/engine/install/ubuntu/>, then run Docker without sudo (log out and back in):
   ```bash
   sudo usermod -aG docker $USER
   ```
2. **Install VS Code** (<https://code.visualstudio.com/>) and the Dev Containers extension:
   ```bash
   code --install-extension ms-vscode-remote.remote-containers
   ```
3. **Optional, NVIDIA machines only**: install the NVIDIA driver and [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), then check:
   ```bash
   docker run --rm --gpus all ubuntu nvidia-smi
   ```
   Without an NVIDIA GPU, switch `.devcontainer/dev.yml` to the generic GPU option (see [README.md](README.md#-create-a-workspace-from-this-template), GPU choice).

4. **Get the base image**, either:

   a) Pull it (needs internet):
   ```bash
   docker pull touchlab/ros:jazzy-example-base
   ```
   b) Load it from the USB stick:
   ```bash
   docker load -i /path/to/ros-jazzy-example-base.tar
   ```
5. **Optional, Set your git identity** (add to `~/.bashrc`):
   ```bash
   export GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="you@example.com"
   export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"