#!/bin/bash
cd "$(dirname "$0")"
docker image build .. -f Dockerfile --tag touchlab/ros:jazzy-example-deploy "$@"
