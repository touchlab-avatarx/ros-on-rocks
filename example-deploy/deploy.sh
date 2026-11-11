#!/bin/bash
cd "$(dirname "$0")"
docker image build .. -f Dockerfile --tag touchlab/ros:hestia_lyrical-deploy "$@"
