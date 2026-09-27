#!/bin/bash
cd "$(dirname "$0")"
docker image build .. -f Dockerfile --tag vladimirivan/ros:jazzy-example-deploy "$@"
