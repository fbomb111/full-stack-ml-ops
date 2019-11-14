#!/usr/bin/env bash

# This script shows how to build the Docker image.
# The argument to this script is the image name. This will be used as the image on the local
# machine.
image=$1

if [ "$image" == "" ]
then
    echo "Usage: $0 <image-name>"
    exit 1
fi

# expose the train and serve functions

chmod +x container/application/train
chmod +x container/application/serve

# Build the docker image locally with the image name 

docker build -t ${image} .