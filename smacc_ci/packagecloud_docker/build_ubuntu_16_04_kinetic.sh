#!/bin/bash
echo "build docker image with github user: $1"
echo "build docker image with packagecloud user: $3"

set -e

export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT


dump_output() {
   echo Tailing the last 500 lines of output:
   tail -500 $BUILD_OUTPUT  
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  exit 1
}
# If an error occurs, run our error handler to output a tail of the build
trap 'error_handler' ERR

# Set up a repeating loop to send some output to Travis.

bash -c "while true; do echo \$(date) - building ...; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

sudo docker build --quiet --build-arg ROS_DOCKER_BASE="ros:kinetic-robot" --build-arg ROS_VERSION_NAME="kinetic" --build-arg UBUNTU_VERSION="xenial" --build-arg GITHUB_USER="$1" --build-arg GITHUB_TOKEN="$2" --build-arg PACKAGE_CLOUD_USER="$3" --build-arg PACKAGE_CLOUD_TOKEN="$4" -t package_cloud_tool_docker . >> $BUILD_OUTPUT

# The build finished without returning an error so dump a tail of the output
dump_output

# nicely terminate the ping output loop
kill $PING_LOOP_PID
