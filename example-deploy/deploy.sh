#!/bin/bash
cd "$(dirname "$0")"
docker image build .. -f Dockerfile --tag touchlab/ros:lyrical-example-deploy "$@"
