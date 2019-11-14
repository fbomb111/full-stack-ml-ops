#!/bin/sh

image=$1

docker run --rm ${image} application/train