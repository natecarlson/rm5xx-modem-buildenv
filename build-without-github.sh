#!/bin/bash

# Build newer version for RM520
docker build . -f Dockerfile.rm520-modem-buildenv --tag natecarlson/rm520-build-env:1.0

# Build for RM50x
docker build . -f Dockerfile.rm50x-modem-buildenv --tag natecarlson/rm50x-build-env:1.0
