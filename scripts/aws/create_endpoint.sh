#!/bin/sh

name=$1

# https://docs.aws.amazon.com/cli/latest/reference/sagemaker/create-endpoint.html
aws sagemaker create-endpoint \
--endpoint-name ${name} \
--endpoint-config-name ${name}