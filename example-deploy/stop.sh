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

docker compose down