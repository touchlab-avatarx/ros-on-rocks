#!/bin/bash

# Check if docker and docker compose are installed
if ! command -v docker &> /dev/null; then
    echo " 🔴 Error: Docker is not installed. Please install Docker to continue."
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo " 🔴 Error: Docker Compose is not installed. Please install Docker Compose to continue."
    exit 1
fi

# Recursively find .env file in parent directories
find_env_file() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.devcontainer/.env" ]; then
            echo "$dir/.devcontainer/.env"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo " 🔴 Error: .env file not found in any parent directory."
    exit 1
}

ENV_FILE=$(find_env_file)

echo "🔧 Using environment file: $ENV_FILE"

docker compose --env-file $ENV_FILE down