#!/bin/bash --init-file
set -e  # Exit immediately if any command fails

# Navigate to script directory (in case it's run from elsewhere)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "🔧 Using Docker Environment Configuration File 🔧"
else
    echo "🔧 Generating Docker Environment Configuration File 🔧"
    echo "# 🔧 Docker Environment Configuration File 🔧" > $SCRIPT_DIR/.env
    echo "HOST_UID=$(id -u)" >> $SCRIPT_DIR/.env
    echo "HOST_GID=$(id -g)" >> $SCRIPT_DIR/.env

    echo "GIT_COMMITTER_NAME=$GIT_COMMITTER_NAME" >> $SCRIPT_DIR/.env
    echo "GIT_COMMITTER_EMAIL=$GIT_COMMITTER_EMAIL" >> $SCRIPT_DIR/.env
    echo "GIT_AUTHOR_NAME=$GIT_AUTHOR_NAME" >> $SCRIPT_DIR/.env
    echo "GIT_AUTHOR_EMAIL=$GIT_AUTHOR_EMAIL" >> $SCRIPT_DIR/.env
    echo "REPO_PATH=$(readlink -f `pwd`/..)" >> $SCRIPT_DIR/.env
fi

if [ -f ".bash_history" ]; then
    echo "🔧 Using existing bash history 🔧"
else
    touch .bash_history
fi

export $(grep -E "^HOST_UID|^HOST_GID" .env | xargs)

echo "🔨 Building the Docker image with UID=$HOST_UID and GID=$HOST_GID..."
docker compose -f image.yml build
echo "✅ Build complete!"
exit 0
